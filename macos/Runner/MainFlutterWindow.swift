import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

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
        
        if monitorIndex == 1 {
           target.isOpaque = false
           target.backgroundColor = .clear
           target.level = .floating
           target.hasShadow = false
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
        
        target.styleMask = [.borderless]
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
}
