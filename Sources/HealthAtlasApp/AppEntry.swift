import AppKit

@main
@MainActor
enum HealthAtlasApp {
    private static let appDelegate = AppDelegate()

    static func main() {
        let app = NSApplication.shared
        app.delegate = appDelegate
        app.setActivationPolicy(.regular)
        appDelegate.presentMainWindow()
        app.run()
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        presentMainWindow()
    }

    func presentMainWindow() {
        if window == nil {
            let content = DashboardViewController()
            let newWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 1280, height: 720),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            newWindow.title = BuildChannel.current.displayName
            newWindow.isOpaque = false
            newWindow.backgroundColor = .clear
            newWindow.titlebarAppearsTransparent = false
            newWindow.minSize = NSSize(width: 960, height: 540)
            newWindow.contentViewController = content
            // Installing the controller can make AppKit recalculate the frame.
            // Set the initial 16:9 content size only after that final layout step.
            newWindow.setContentSize(NSSize(width: 1280, height: 720))
            newWindow.center()
            window = newWindow
        }

        window?.makeKeyAndOrderFront(nil)
        window?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        presentMainWindow()
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
