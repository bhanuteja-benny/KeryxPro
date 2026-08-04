#include "flutter_window.h"

#include <optional>
#include <windows.h>
#include <string>
#include <vector>

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

static std::string WideToUtf8(const std::wstring& value){
  if (value.empty()) return "";
  int utf8Size = WideCharToMultiByte(
    CP_UTF8, 0, value.c_str(), static_cast<int>(value.size()), nullptr, 0, nullptr, nullptr);
    if(utf8Size <= 0) return "";

    std::string result(static_cast<size_t>(utf8Size), '\0');
    WideCharToMultiByte(
      CP_UTF8, 0, value.c_str(), static_cast<int>(value.size()), &result[0], utf8Size, nullptr, nullptr);
    return result;
}

static std::wstring GetWindowTitle(HWND hwnd) {
  int length = GetWindowTextLengthW(hwnd);
  if(length <= 0) return L"";

  std::wstring title(static_cast<size_t>(length) + 1, L'\0');
  GetWindowTextW(hwnd, &title[0], length + 1);
  title.resize(static_cast<size_t>(length));
  return title;
}

static std::wstring GetProcessName(DWORD pid) {
  HANDLE process = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
  if(!process) return L"";

  wchar_t pathBuffer[MAX_PATH] = {};
  DWORD size = MAX_PATH;
  std::wstring result;
  if (QueryFullProcessImageNameW(process, 0, pathBuffer, &size)) {
    std::wstring fullPath(pathBuffer);
    size_t slash = fullPath.find_last_of(L'\\');
    result = slash == std::wstring::npos ? fullPath : fullPath.substr(slash + 1);
  }
  CloseHandle(process);
  return result;
}

static bool IsCapturableWindow(HWND hwnd, HWND mainHwnd) {
  if (!hwnd || hwnd == mainHwnd) return false; 
  if (!IsWindowVisible(hwnd) || IsIconic(hwnd)) return false; 
  if (GetWindow(hwnd, GW_OWNER) != nullptr) return false; 
  
  LONG exStyle = GetWindowLong(hwnd, GWL_EXSTYLE); 
  if ((exStyle & WS_EX_TOOLWINDOW) != 0) return false; 
  
  DWORD pid = 0; 
  GetWindowThreadProcessId(hwnd, &pid); 
  if (pid == 0 || pid == GetCurrentProcessId()) return false; 
  
  std::wstring title = GetWindowTitle(hwnd); 
  if (title.empty()) return false;

  return true;
}

struct CapturableWindowListData {
  HWND mainHwnd; 
  flutter::EncodableList* out;
};

static BOOL CALLBACK EnumerateCapturableWindows(HWND hwnd, LPARAM lParam) {
  auto* data = reinterpret_cast<CapturableWindowListData*>(lParam); 
  if (!data || !data->out) return FALSE;

  if (!IsCapturableWindow(hwnd, data->mainHwnd)) return TRUE;

  DWORD pid = 0; 
  GetWindowThreadProcessId(hwnd, &pid); 
  std::wstring title = GetWindowTitle(hwnd); 
  std::wstring processName = GetProcessName(pid);

  flutter::EncodableMap windowInfo;
  windowInfo[flutter::EncodableValue("handle")] = flutter::EncodableValue(std::to_string(reinterpret_cast<uint64_t>(hwnd)));
  windowInfo[flutter::EncodableValue("title")] = flutter::EncodableValue(WideToUtf8(title));
  windowInfo[flutter::EncodableValue("processName")] = flutter::EncodableValue(WideToUtf8(processName));
  windowInfo[flutter::EncodableValue("processId")] = flutter::EncodableValue(static_cast<int>(pid));

  data->out->push_back(flutter::EncodableValue(windowInfo));
  return TRUE;
}

// Returns the largest visible direct child covering >=70% of the parent client area.
static HWND FindLargestDirectChild(HWND parent) {
    RECT pc = {};
    if (!GetClientRect(parent, &pc)) return nullptr;
    const LONG parentArea = (pc.right - pc.left) * (pc.bottom - pc.top);
    if (parentArea <= 0) return nullptr;

    struct SD { HWND parent, best; LONG bestArea, threshold; };
    SD sd = {parent, nullptr, 0, parentArea * 7 / 10};

    EnumChildWindows(parent, [](HWND child, LPARAM lp) -> BOOL {
        auto* d = reinterpret_cast<SD*>(lp);
        if (GetParent(child) != d->parent) return TRUE;
        if (!IsWindowVisible(child)) return TRUE;
        RECT r = {};
        if (!GetWindowRect(child, &r)) return TRUE;
        LONG area = (r.right - r.left) * (r.bottom - r.top);
        if (area > d->bestArea) { d->bestArea = area; d->best = child; }
        return TRUE;
    }, reinterpret_cast<LPARAM>(&sd));

    return (sd.best && sd.bestArea >= sd.threshold) ? sd.best : nullptr;
}

static bool CaptureWindowFrame(HWND hwnd, std::vector<uint8_t>& outPixels, int& outWidth, int& outHeight, bool contentOnly) {
    RECT windowRect = {};
    if (!GetWindowRect(hwnd, &windowRect)) return false;

    int fullwidth  = windowRect.right - windowRect.left;
    int fullHeight = windowRect.bottom - windowRect.top;
    if (fullwidth <= 0 || fullHeight <= 0) return false;

    HDC screenDc = GetDC(nullptr);
    if (!screenDc) return false;

    HDC memDc = CreateCompatibleDC(screenDc);
    if (!memDc) { ReleaseDC(nullptr, screenDc); return false; }

    BITMAPINFO bmi = {};
    bmi.bmiHeader.biSize        = sizeof(BITMAPINFOHEADER);
    bmi.bmiHeader.biWidth       = fullwidth;
    bmi.bmiHeader.biHeight      = -fullHeight; // top-down
    bmi.bmiHeader.biPlanes      = 1;
    bmi.bmiHeader.biBitCount    = 32;
    bmi.bmiHeader.biCompression = BI_RGB;

    void*   bits = nullptr;
    HBITMAP dib = CreateDIBSection(screenDc, &bmi, DIB_RGB_COLORS, &bits, nullptr, 0);
    if (!dib || !bits) {
        if (dib) DeleteObject(dib);
        DeleteDC(memDc);
        ReleaseDC(nullptr, screenDc);
        return false;
    }

  HGDIOBJ oldBmp = SelectObject(memDc, dib);

// Capture full window - always use PW_RENDERFULLCONTENT for GPU-composited content.
bool captured = PrintWindow(hwnd, memDc, PW_RENDERFULLCONTENT);
if (!captured) {
    HDC windowDc = GetWindowDC(hwnd);
    if (windowDc) {
        captured = BitBlt(memDc, 0, 0, fullWidth, fullHeight, windowDc, 0, 0, SRCCOPY | CAPTUREBLT) == TRUE;
        ReleaseDC(hwnd, windowDc);
    }
    if (!captured) {
        captured = BitBlt(memDc, 0, 0, fullWidth, fullHeight, screenDc,
                          windowRect.left, windowRect.top, SRCCOPY | CAPTUREBLT) == TRUE;
    }
}

  if (captured) {
    if (contentOnly) {
        // Prefer capturing the largest direct child (e.g. PowerPoint slide view).
        // Status bars are separate sibling HWNDs and will be excluded - matches OBS behaviour.
        HWND contentChild = FindLargestDirectChild(hwnd);
        if (contentChild) {
            SelectObject(memDc, oldBmp);
            DeleteObject(dib);
            DeleteDC(memDc);
            ReleaseDC(nullptr, screenDc);
            return CaptureWindowFrame(contentChild, outPixels, outWidth, outHeight, false);
        } else {
            // No dominant child: crop to client area to remove OS chrome.
            RECT  clientRect   = {};
            POINT clientOrigin = {0, 0};
            bool ok = GetClientRect(hwnd, &clientRect) && ClientToScreen(hwnd, &clientOrigin);
            int dx = clientOrigin.x - windowRect.left;
            int dy = clientOrigin.y - windowRect.top;
            int cw = clientRect.right  - clientRect.left;
            int ch = clientRect.bottom - clientRect.top;

            if (ok && dx >= 0 && dy >= 0 && cw > 0 && ch > 0 &&
                dx + cw <= fullWidth && dy + ch <= fullHeight) {
                const auto* src = static_cast<const uint8_t*>(bits);
                std::vector<uint8_t> cropped(static_cast<size_t>(cw) * static_cast<size_t>(ch) * 4);
                for (int row = 0; row < ch; ++row) {
                    const uint8_t* srcRow = src + (static_cast<size_t>(dy + row) * fullWidth + dx) * 4;
                    uint8_t*       dstRow = cropped.data() + static_cast<size_t>(row) * cw * 4;
                    memcpy(dstRow, srcRow, static_cast<size_t>(cw) * 4);
                }
                outPixels = std::move(cropped);
                outWidth  = cw;
                outHeight = ch;
            } else {
                size_t n = static_cast<size_t>(fullWidth) * fullHeight * 4;
                outPixels.assign(static_cast<uint8_t*>(bits), static_cast<uint8_t*>(bits) + n);
                outWidth  = fullWidth;
                outHeight = fullHeight;
            }
        }
    } else {
        size_t n = static_cast<size_t>(fullWidth) * fullHeight * 4;
        outPixels.assign(static_cast<uint8_t*>(bits), static_cast<uint8_t*>(bits) + n);
        outWidth  = fullWidth;
        outHeight = fullHeight;
    }
}

  SelectObject(memDc, oldBmp);
  DeleteObject(dib);
  DeleteDC(memDc);
  ReleaseDC(nullptr, screenDc);

  return captured;
}

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

        // --- list_capturable_windows ---
        if (call.method_name() == "list_capturable_windows") {
          flutter::EncodableList windows;
          CapturableWindowListData data = {mainHwnd, &windows};
          EnumWindows(EnumerateCapturableWindows, reinterpret_cast<LPARAM>(&data));
          result->Success(flutter::EncodableValue(windows));
          return;
        }
        else if (call.method_name() == "capture_window_frame") {
          const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
          if (!args) {
            result->Error("BAD_ARGS", "Expected EncodableMap");
            return;
          }

          auto it = args->find(flutter::EncodableValue("handle"));
          if (it == args->end()) {
            result->Error("BAD_ARGS", "Missing handle");
            return;
          }
          
          std::string handleStr;
          bool contentOnly = false;
          if (auto* s = std::get_if<std::string>(&it->second)) {
            handleStr = *s;
          } else if (auto* i = std::get_if<int>(&it->second)) {
            handleStr = std::to_string(*i);
          } else if (auto* i64 = std::get_if<int64_t> (&it->second)) {
            handleStr = std::to_string(*i64);
          } 

          auto contentOnlyIt = args->find(flutter::EncodableValue("contentOnly"));
if (contentOnlyIt != args->end()) {
    if (auto* b = std::get_if<bool>(&contentOnlyIt->second)) {
        contentOnly = *b;
    }
}

          if (handleStr.empty()) {
            result->Error("BAD_ARGS", "handle is null or not supported type");
            return;
          }

          uint64_t handleValue = 0;
          try {
            handleValue = std::stoull(handleStr);
          } catch (...) {
            result->Error("BAD_ARGS", "handle is not a valid number");
            return;
          }

          HWND targetHwnd = reinterpret_cast<HWND>(handleValue);
          if (!IsWindow(targetHwnd) || !IsWindowVisible(targetHwnd) || IsIconic(targetHwnd)) {
            result->Error("BAD_ARGS", "target window is not valid or not visible");
            return;
          }

          std::vector<uint8_t> pixels;
          int width = 0;
          int height = 0;
          if (!CapturewindowFrame(targetHwnd, pixels, width, height, contentOnly)) {
            result->Error("CAPTURE_FAILED", "Failed to capture window frame");
            return;
          }

          flutter::EncodableMap response;
          response[flutter::EncodableValue("width")] = flutter::EncodableValue(width);
          response[flutter::EncodableValue("height")] = flutter::EncodableValue(height);
          response[flutter::EncodableValue("pixels")] = flutter::EncodableValue(pixels);
          result->Success(flutter::EncodableValue(response));
        
        // ── configure_subwindow ─────────────────────────────────────────────
        // Finds a newly created (unnamed) sub-window OR an already-renamed one,
        // renames it, and resizes it.
        } else if (call.method_name() == "configure_subwindow") {
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
    case WM_ACTIVATE: {
      WORD activeState = LOWORD(wparam);
      HWND projectorWnd = FindNamedSubWindow(hwnd, L"KeryxPro Monitor 1");
      if (projectorWnd) {
        if (activeState == WA_INACTIVE) {
          SetWindowPos(projectorWnd, HWND_NOTOPMOST, 0, 0, 0, 0,
                       SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
        } else {
          SetWindowPos(projectorWnd, HWND_TOPMOST, 0, 0, 0, 0,
                       SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
        }
      }
      break;
    }
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
