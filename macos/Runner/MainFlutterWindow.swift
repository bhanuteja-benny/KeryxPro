import Cocoa
import FlutterMacOS
import desktop_multi_window

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
      RegisterGeneratedPlugins(registry: controller)
    }

    // KeryxPro: native window-control channel
    let channel = FlutterMethodChannel(name: "keryx/window", binaryMessenger: flutterViewController.engine.binaryMessenger)
    channel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      let args = call.arguments as? [String: Any]
      let windows = NSApp.windows
      
      func findSubWindow(title: String?) -> NSWindow? {
        if let title = title, !title.isEmpty {
          if let w = windows.first(where: { $0.title == title }) { return w }
        }
        return windows.last(where: { $0 != self && $0.title.isEmpty })
      }
      
      switch call.method {
      case "configure_subwindow":
        let w = args?["w"] as? Double ?? 1280
        let h = args?["h"] as? Double ?? 720
        let newTitle = args?["title"] as? String ?? ""
        let monitorIndex = args?["monitorIndex"] as? Int ?? 1
        
        guard let target = findSubWindow(title: newTitle) else {
          result(FlutterError(code: "NOT_FOUND", message: "No sub-window found", details: nil))
          return
        }
        
        if !newTitle.isEmpty {
          target.title = newTitle
        }
        
        var frame = target.frame
        frame.origin.y = frame.origin.y + frame.size.height - CGFloat(h)
        frame.size = CGSize(width: CGFloat(w), height: CGFloat(h))
        target.setFrame(frame, display: true)
        
        // Both monitors need transparency support so the Flutter-side
        // transparent background renders correctly through the native window.
        target.isOpaque = false
        target.backgroundColor = .clear
        target.hasShadow = false
        
        if monitorIndex == 1 {
           target.level = .floating
        } else {
           target.level = .normal
        }
        result(nil)
        
      case "move_subwindow_to_display":
        guard let target = findSubWindow(title: nil) else {
          result(FlutterError(code: "NOT_FOUND", message: "No sub-window found", details: nil))
          return
        }
        target.title = "KeryxPro Monitor 1"
        
        // IMPORTANT: Do NOT set styleMask = [.borderless].
        // Changing styleMask destroys the window backing and invalidates
        // the FlutterEngine's plugin registrations (including WindowChannel),
        // causing CHANNEL_UNREGISTERED errors when the main window tries
        // to communicate with the sub-window.
        //
        // Instead, we hide the titlebar elements individually and add
        // .fullSizeContentView so the Flutter content fills the entire window.
        target.titlebarAppearsTransparent = true
        target.titleVisibility = .hidden
        target.styleMask.insert(.fullSizeContentView)
        // Hide all standard window buttons (close, minimize, zoom)
        target.standardWindowButton(.closeButton)?.isHidden = true
        target.standardWindowButton(.miniaturizeButton)?.isHidden = true
        target.standardWindowButton(.zoomButton)?.isHidden = true
        // Remove toolbar if present
        target.toolbar = nil
        
        target.isOpaque = false
        target.backgroundColor = .clear
        target.level = .floating
        target.hasShadow = false
        
        let screens = NSScreen.screens
        if screens.count > 1 {
            let secondaryScreen = screens.first(where: { $0 != self.screen }) ?? screens[1]
            target.setFrame(secondaryScreen.frame, display: true)
        }
        
        self.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        result(nil)
        
      case "close_subwindow":
        let displayTitle = args?["title"] as? String
        guard let target = findSubWindow(title: displayTitle) else {
          result(FlutterError(code: "NOT_FOUND", message: "No sub-window found", details: nil))
          return
        }
        target.close()
        result(nil)
        
      case "minimize_subwindow":
        let displayTitle = args?["title"] as? String
        guard let target = findSubWindow(title: displayTitle) else {
          result(FlutterError(code: "NOT_FOUND", message: "No sub-window found", details: nil))
          return
        }
        target.miniaturize(nil)
        result(nil)
        
      case "refocus_main_window":
        self.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        result(nil)
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }

  override func becomeKey() {
    super.becomeKey()
    if let target = NSApp.windows.first(where: { $0.title == "KeryxPro Monitor 1" }) {
      target.level = .floating
    }
  }

  override func resignKey() {
    super.resignKey()
    if let target = NSApp.windows.first(where: { $0.title == "KeryxPro Monitor 1" }) {
      target.level = .normal
    }
  }
}
