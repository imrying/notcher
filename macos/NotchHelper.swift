import Cocoa

@_cdecl("show_status_item")
public func show_status_item() {
    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)
    
    // Activate the application to make it responsive
    app.activate(ignoringOtherApps: true)

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    if let button = statusItem.button {
        button.title = "Notch"
    }

    let menu = NSMenu()
    menu.addItem(NSMenuItem(
        title: "Quit",
        action: #selector(NSApplication.terminate(_:)),
        keyEquivalent: "q"
    ))
    statusItem.menu = menu

    app.run()
}

