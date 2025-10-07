import Cocoa

@_cdecl("show_status_item")
public func show_status_item() {
    print("Starting notcher application...")
    
    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)
    
    print("Application activation policy set to .accessory")
    
    // Activate the application to make it responsive
    app.activate(ignoringOtherApps: true)
    
    print("Application activated")

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    print("Status item created: \(statusItem)")
    
    if let button = statusItem.button {
        button.title = "Notch"
        print("Button title set to 'Notch'")
    } else {
        print("WARNING: Status item has no button!")
    }

    let menu = NSMenu()
    menu.addItem(NSMenuItem(
        title: "Quit",
        action: #selector(NSApplication.terminate(_:)),
        keyEquivalent: "q"
    ))
    statusItem.menu = menu
    
    print("Menu created and attached to status item")
    print("Starting application run loop...")

    app.run()
}

