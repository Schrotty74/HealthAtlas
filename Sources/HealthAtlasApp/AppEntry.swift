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
    private var dashboard: DashboardViewController?

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
            dashboard = content
            installMainMenu()
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

    private func installMainMenu() {
        let mainMenu = NSMenu()

        let applicationMenu = NSMenu()
        applicationMenu.addItem(withTitle: "About \(BuildChannel.current.displayName)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        applicationMenu.addItem(.separator())
        applicationMenu.addItem(withTitle: "Hide \(BuildChannel.current.displayName)", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        applicationMenu.addItem(withTitle: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h").keyEquivalentModifierMask = [.command, .option]
        applicationMenu.addItem(withTitle: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
        applicationMenu.addItem(.separator())
        applicationMenu.addItem(withTitle: "Quit \(BuildChannel.current.displayName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        let applicationItem = NSMenuItem(title: BuildChannel.current.displayName, action: nil, keyEquivalent: "")
        applicationItem.submenu = applicationMenu
        mainMenu.addItem(applicationItem)

        let fileMenu = NSMenu(title: "File")
        fileMenu.addItem(NSMenuItem(title: "Import Apple Health Export…", action: #selector(DashboardViewController.importFromMenu(_:)), keyEquivalent: "i"))
        fileMenu.addItem(NSMenuItem(title: "Export Local PDF Report…", action: #selector(DashboardViewController.exportReportFromMenu(_:)), keyEquivalent: "e"))
        fileMenu.addItem(.separator())
        fileMenu.addItem(withTitle: "Close Window", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        let fileItem = NSMenuItem(title: "File", action: nil, keyEquivalent: "")
        fileItem.submenu = fileMenu
        mainMenu.addItem(fileItem)

        let viewMenu = NSMenu(title: "View")
        viewMenu.addItem(NSMenuItem(title: "Show Sidebar", action: #selector(DashboardViewController.toggleSidebar(_:)), keyEquivalent: "s"))
        viewMenu.addItem(NSMenuItem(title: "Design Studio", action: #selector(DashboardViewController.showDesignStudio(_:)), keyEquivalent: ","))
        let viewItem = NSMenuItem(title: "View", action: nil, keyEquivalent: "")
        viewItem.submenu = viewMenu
        mainMenu.addItem(viewItem)

        let windowMenu = NSMenu(title: "Window")
        windowMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.miniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
        windowMenu.addItem(withTitle: "Enter Full Screen", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f").keyEquivalentModifierMask = [.command, .control]
        windowMenu.addItem(.separator())
        windowMenu.addItem(withTitle: "Bring All to Front", action: #selector(NSApplication.arrangeInFront(_:)), keyEquivalent: "")
        let windowItem = NSMenuItem(title: "Window", action: nil, keyEquivalent: "")
        windowItem.submenu = windowMenu
        mainMenu.addItem(windowItem)

        NSApp.mainMenu = mainMenu
    }
}
