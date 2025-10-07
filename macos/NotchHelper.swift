import Cocoa

class MouseTracker {
    private var eventMonitor: Any?
    private var localEventMonitor: Any?
    private var timer: Timer?
    private var notchRect: NSRect?
    private var wasInsideNotch = false
    
    init() {
        calculateNotchRect()
        startTracking()
    }
    
    private func calculateNotchRect() {
        guard let screen = NSScreen.main else { return }
        
        // Get the safe area insets which indicate the notch area
        if #available(macOS 12.0, *) {
            let safeAreaInsets = screen.safeAreaInsets
            
            // If there's a top inset, we have a notch
            if safeAreaInsets.top > 0 {
                let screenFrame = screen.frame
                // The notch is centered at the top of the screen
                // Typical notch width is around 200-300 pixels
                let notchWidth: CGFloat = 200
                let notchHeight = safeAreaInsets.top
                
                let notchX = (screenFrame.width - notchWidth) / 2
                let notchY = screenFrame.height - notchHeight
                
                notchRect = NSRect(x: notchX, y: notchY, width: notchWidth, height: notchHeight)
                
                print("Notch detected at: \(notchRect!)")
            } else {
                print("No notch detected on this display")
            }
        }
    }
    
    private func startTracking() {
        // Try to add global monitor (may require accessibility permissions)
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            self?.checkMousePosition()
        }
        
        // Also add local monitor for events within the app
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            self?.checkMousePosition()
            return event
        }
        
        // Use a timer as a fallback to poll mouse position
        // This works even without accessibility permissions
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.checkMousePosition()
        }
        
        print("Mouse tracking started (global monitor, local monitor, and timer)")
    }
    
    private func checkMousePosition() {
        guard let notchRect = notchRect else { return }
        
        let mouseLocation = NSEvent.mouseLocation
        let isInside = notchRect.contains(mouseLocation)
        
        // Only print when mouse enters the notch (not continuously)
        if isInside && !wasInsideNotch {
            print("Hello World")
            wasInsideNotch = true
        } else if !isInside && wasInsideNotch {
            wasInsideNotch = false
        }
    }
    
    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        timer?.invalidate()
    }
}

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
    
    // Initialize mouse tracker
    let mouseTracker = MouseTracker()
    
    // Keep a strong reference to prevent deallocation
    objc_setAssociatedObject(app, "mouseTracker", mouseTracker, .OBJC_ASSOCIATION_RETAIN)
    
    print("Starting application run loop...")

    app.run()
}

