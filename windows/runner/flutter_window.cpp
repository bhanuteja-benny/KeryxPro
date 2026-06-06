#include "flutter_window.h"

#include <optional>
#include <windows.h>
#include <string>

#include "flutter/generated_plugin_registrant.h"
#include "flutter/method_channel.h"
#include "flutter/method_result_functions.h"
#include "flutter/standard_method_codec.h"

// ── Helper: find a sub-window ────────────────────────────────────────────────
// desktop_multi_window creates sub-windows with an EMPTY title (L"").
// After we rename a window, its title changes.  So to find the "newest"
// un-renamed window we search for any FLUTTER_MULTI_WINDOW_WIN32_WINDOW
// with the specified search title (empty string for newly created, or
// the display title for previously renamed windows).
struct SubWindowSearchData {
  HWND         mainHwnd;
  DWORD        processId;
  std::wstring targetTitle;
  HWND         found;
};

static BOOL CALLBACK FindSubWindowByTitle(HWND hwnd, LPARAM lParam) {
  auto* data = reinterpret_cast<SubWindowSearchData*>(lParam);
  if (hwnd == data->mainHwnd) return TRUE;

  DWORD pid = 0;
  GetWindowThreadProcessId(hwnd, &pid);
  if (pid != data->processId) return TRUE;

  wchar_t cls[256] = {};
  GetClassNameW(hwnd, cls, 256);
  if (wcscmp(cls, L"FLUTTER_MULTI_WINDOW_WIN32_WINDOW") != 0) return TRUE;

  wchar_t title[512] = {};
  GetWindowTextW(hwnd, title, 512);
  if (data->targetTitle == title) {
    data->found = hwnd;
    return FALSE;
  }
  return TRUE;
}

// Search for a sub-window with an empty title (newly created, not yet renamed)
static HWND FindUnnamedSubWindow(HWND mainHwnd) {
  SubWindowSearchData data = {mainHwnd, GetCurrentProcessId(), L"", nullptr};
  EnumWindows(FindSubWindowByTitle, reinterpret_cast<LPARAM>(&data));
  return data.found;
}

// Search for a sub-window by its display title (already renamed)
static HWND FindNamedSubWindow(HWND mainHwnd, const std::wstring& displayTitle) {
  SubWindowSearchData data = {mainHwnd, GetCurrentProcessId(), displayTitle, nullptr};
  EnumWindows(FindSubWindowByTitle, reinterpret_cast<LPARAM>(&data));
  return data.found;
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

        // ── configure_subwindow ─────────────────────────────────────────────
        // Finds a newly created (unnamed) sub-window OR an already-renamed one,
        // renames it, and resizes it.
        if (call.method_name() == "configure_subwindow") {
          const auto* args =
              std::get_if<flutter::EncodableMap>(call.arguments());
          if (!args) {
            result->Error("BAD_ARGS", "Expected EncodableMap");
            return;
          }

          auto getInt = [&](const std::string& key, int def) -> int {
            auto it = args->find(flutter::EncodableValue(key));
            if (it != args->end()) {
              if (auto* d = std::get_if<double>(&it->second)) return static_cast<int>(*d);
              if (auto* i = std::get_if<int>(&it->second))    return *i;
            }
            return def;
          };
          auto getString = [&](const std::string& key) -> std::string {
            auto it = args->find(flutter::EncodableValue(key));
            if (it != args->end())
              if (auto* s = std::get_if<std::string>(&it->second)) return *s;
            return "";
          };
          auto getBool = [&](const std::string& key, bool def) -> bool {
            auto it = args->find(flutter::EncodableValue(key));
            if (it != args->end())
              if (auto* b = std::get_if<bool>(&it->second)) return *b;
            return def;
          };

          int monitorIndex = getInt("monitorIndex", 1);
          int x            = getInt("x", 100);
          int y            = getInt("y", 100);
          int w            = getInt("w", 1280);
          int h            = getInt("h", 720);
          std::string newTitle = getString("title");
          bool noMove      = getBool("noMove", false);

          // Convert title to wide string
          std::wstring newTitleW(newTitle.begin(), newTitle.end());

          // Strategy: first try to find a window already named with this title
          // (for resize/update calls).  If not found, look for the newest
          // unnamed window (empty title from desktop_multi_window creation).
          HWND target = FindNamedSubWindow(mainHwnd, newTitleW);
          if (!target) {
            target = FindUnnamedSubWindow(mainHwnd);
          }

          if (!target) {
            result->Error("NOT_FOUND", "No sub-window found (named or unnamed)");
            return;
          }

          // Set display title
          if (!newTitle.empty()) {
            SetWindowTextW(target, newTitleW.c_str());
          }

          // Resize / reposition
          UINT flags = SWP_FRAMECHANGED | SWP_SHOWWINDOW | SWP_NOACTIVATE;
          if (noMove) flags |= SWP_NOMOVE;

          LONG style = GetWindowLong(target, GWL_STYLE);
          LONG exStyle = GetWindowLong(target, GWL_EXSTYLE);

          // Adjust window rect so the client area is exactly w x h
          RECT rect = { 0, 0, w, h };
          AdjustWindowRectEx(&rect, style, FALSE, exStyle);
          int adjustedW = rect.right - rect.left;
          int adjustedH = rect.bottom - rect.top;

          // Apply layered window with chroma key for transparency support.
          // Both monitors use RGB(1,0,1) as the chroma key — the Flutter side
          // renders this exact color when transparency is desired.
          exStyle |= WS_EX_LAYERED;
          SetWindowLong(target, GWL_EXSTYLE, exStyle);
          SetLayeredWindowAttributes(target, RGB(1, 0, 1), 0, LWA_COLORKEY);

          // Monitor 2 = normal z-order; Monitor 1 = always-on-top
          HWND insertAfter = (monitorIndex == 2) ? HWND_NOTOPMOST : HWND_TOPMOST;
          SetWindowPos(target, insertAfter, x, y, adjustedW, adjustedH, flags);

          SetForegroundWindow(mainHwnd);
          result->Success();

        // ── move_subwindow_to_display ───────────────────────────────────────
        // For Monitor 1: strips decorations and positions full-screen on
        // the secondary display.
        } else if (call.method_name() == "move_subwindow_to_display") {
          const auto* args =
              std::get_if<flutter::EncodableMap>(call.arguments());
          if (!args) {
            result->Error("BAD_ARGS", "Expected EncodableMap");
            return;
          }

          auto getInt = [&](const std::string& key) -> int {
            auto it = args->find(flutter::EncodableValue(key));
            if (it != args->end()) {
              if (auto* d = std::get_if<double>(&it->second)) return static_cast<int>(*d);
              if (auto* i = std::get_if<int>(&it->second))    return *i;
            }
            return 0;
          };

          int x = getInt("x");
          int y = getInt("y");
          int w = getInt("w");
          int h = getInt("h");

          // Monitor 1 is unnamed at first, but may already be visible.
          // Search for unnamed first, then for any sub-window we haven't
          // renamed to "KeryxPro Monitor 2".
          HWND target = FindUnnamedSubWindow(mainHwnd);
          if (!target) {
            // All windows are named; the Monitor 1 window should NOT have
            // the Monitor 2 title.  This is a fallback — shouldn't normally
            // be needed since move_subwindow_to_display is called before rename.
            result->Error("NOT_FOUND", "Projector sub-window not found");
            return;
          }

          // Name the window so OBS shows a proper title
          SetWindowTextW(target, L"KeryxPro Monitor 1");

          // Strip decorations for full-screen projector
          LONG style = GetWindowLong(target, GWL_STYLE);
          style &= ~(WS_CAPTION | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_SYSMENU);
          SetWindowLong(target, GWL_STYLE, style);

          LONG exStyle2 = GetWindowLong(target, GWL_EXSTYLE);
          exStyle2 &= ~(WS_EX_DLGMODALFRAME | WS_EX_CLIENTEDGE | WS_EX_STATICEDGE);
          // Use WS_EX_LAYERED with a NON-BLACK chroma key color.
          // RGB(1,0,1) is a near-invisible magenta that won't conflict with
          // normal content. The Flutter side renders this exact color when
          // transparency is desired, and the OS makes those pixels transparent.
          // Using RGB(0,0,0) would make ALL black pixels transparent, breaking
          // black backgrounds.
          exStyle2 |= WS_EX_LAYERED;
          SetWindowLong(target, GWL_EXSTYLE, exStyle2);
          SetLayeredWindowAttributes(target, RGB(1, 0, 1), 0, LWA_COLORKEY);

          SetWindowPos(target, HWND_TOPMOST, x, y, w, h,
                       SWP_FRAMECHANGED | SWP_SHOWWINDOW | SWP_NOACTIVATE);
          SetForegroundWindow(mainHwnd);
          result->Success();

        // ── close_subwindow ─────────────────────────────────────────────────
        } else if (call.method_name() == "close_subwindow") {
          const auto* args =
              std::get_if<flutter::EncodableMap>(call.arguments());
          std::string displayTitle = "";
          if (args) {
            auto it = args->find(flutter::EncodableValue("title"));
            if (it != args->end()) {
              if (auto* s = std::get_if<std::string>(&it->second))
                displayTitle = *s;
            }
          }

          HWND target = nullptr;
          if (!displayTitle.empty()) {
            std::wstring titleW(displayTitle.begin(), displayTitle.end());
            target = FindNamedSubWindow(mainHwnd, titleW);
          }
          if (!target) {
            target = FindUnnamedSubWindow(mainHwnd);
          }

          if (target) {
            PostMessage(target, WM_CLOSE, 0, 0);
            result->Success();
          } else {
            result->Error("NOT_FOUND", "Sub-window not found");
          }

        // ── minimize_subwindow ──────────────────────────────────────────────
        } else if (call.method_name() == "minimize_subwindow") {
          const auto* args =
              std::get_if<flutter::EncodableMap>(call.arguments());
          std::string displayTitle = "";
          if (args) {
            auto it = args->find(flutter::EncodableValue("title"));
            if (it != args->end()) {
              if (auto* s = std::get_if<std::string>(&it->second))
                displayTitle = *s;
            }
          }

          HWND target = nullptr;
          if (!displayTitle.empty()) {
            std::wstring titleW(displayTitle.begin(), displayTitle.end());
            target = FindNamedSubWindow(mainHwnd, titleW);
          }
          if (!target) {
            target = FindUnnamedSubWindow(mainHwnd);
          }

          if (target) {
            ShowWindow(target, SW_MINIMIZE);
            result->Success();
          } else {
            result->Error("NOT_FOUND", "Sub-window not found");
          }

        // ── refocus_main_window ─────────────────────────────────────────────
        } else if (call.method_name() == "refocus_main_window") {
          SetForegroundWindow(mainHwnd);
          result->Success();
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
