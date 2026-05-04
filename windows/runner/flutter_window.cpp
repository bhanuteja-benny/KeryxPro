#include "flutter_window.h"

#include <optional>
#include <windows.h>

#include "flutter/generated_plugin_registrant.h"
#include "flutter/method_channel.h"
#include "flutter/method_result_functions.h"
#include "flutter/standard_method_codec.h"

// ── Helper: find the projector sub-window ────────────────────────────────────
// EnumWindows callback data.
struct SubWindowSearchData {
  HWND mainHwnd;
  DWORD processId;
  HWND found;
};

static BOOL CALLBACK FindSubWindowProc(HWND hwnd, LPARAM lParam) {
  auto* data = reinterpret_cast<SubWindowSearchData*>(lParam);

  if (hwnd == data->mainHwnd) return TRUE;           // skip main window

  DWORD pid = 0;
  GetWindowThreadProcessId(hwnd, &pid);
  if (pid != data->processId) return TRUE;           // different process

  // Check if it's a desktop_multi_window class
  wchar_t cls[256] = {};
  GetClassNameW(hwnd, cls, 256);
  if (wcscmp(cls, L"FLUTTER_MULTI_WINDOW_WIN32_WINDOW") == 0) {
    data->found = hwnd;
    return FALSE;  // found it! stop enumeration
  }
  
  return TRUE;
}
// ─────────────────────────────────────────────────────────────────────────────

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  // ── KeryxPro: native window-control channel ──────────────────────────────
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(),
      "keryx/window",
      &flutter::StandardMethodCodec::GetInstance());

  HWND mainHwnd = GetHandle();

  channel->SetMethodCallHandler(
      [mainHwnd](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

        if (call.method_name() == "move_subwindow_to_display") {
          const auto* args =
              std::get_if<flutter::EncodableMap>(call.arguments());
          if (!args) {
            result->Error("BAD_ARGS", "Expected map with x,y,w,h");
            return;
          }

          auto getInt = [&](const std::string& key) -> int {
            auto it = args->find(flutter::EncodableValue(key));
            if (it != args->end()) {
              if (auto* d = std::get_if<double>(&it->second))
                return static_cast<int>(*d);
              if (auto* i = std::get_if<int>(&it->second)) return *i;
            }
            return 0;
          };

          int x = getInt("x");
          int y = getInt("y");
          int w = getInt("w");
          int h = getInt("h");

          // Find the projector sub-window
          SubWindowSearchData data = {mainHwnd, GetCurrentProcessId(), nullptr};
          EnumWindows(FindSubWindowProc, reinterpret_cast<LPARAM>(&data));

          if (data.found) {
            // Remove window decorations for true full screen
            LONG style = GetWindowLong(data.found, GWL_STYLE);
            style &= ~(WS_CAPTION | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_SYSMENU);
            SetWindowLong(data.found, GWL_STYLE, style);

            LONG exStyle = GetWindowLong(data.found, GWL_EXSTYLE);
            exStyle &= ~(WS_EX_DLGMODALFRAME | WS_EX_CLIENTEDGE | WS_EX_STATICEDGE);
            SetWindowLong(data.found, GWL_EXSTYLE, exStyle);

            // Move and resize to the secondary display bounds
            SetWindowPos(data.found, HWND_TOPMOST,
                         x, y, w, h,
                         SWP_FRAMECHANGED | SWP_SHOWWINDOW);
            
            result->Success();
          } else {
            result->Error("NOT_FOUND", "Projector sub-window (FLUTTER_MULTI_WINDOW_WIN32_WINDOW) not found");
          }
        } else if (call.method_name() == "close_subwindow") {
          // Find and close the projector sub-window
          SubWindowSearchData data = {mainHwnd, GetCurrentProcessId(), nullptr};
          EnumWindows(FindSubWindowProc, reinterpret_cast<LPARAM>(&data));

          if (data.found) {
            PostMessage(data.found, WM_CLOSE, 0, 0);
            result->Success();
          } else {
            result->Error("NOT_FOUND", "Projector sub-window not found");
          }
        } else {
          result->NotImplemented();
        }
      });

  window_channel_ = std::move(channel);
  // ─────────────────────────────────────────────────────────────────────────

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
