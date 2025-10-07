import Cocoa

// MARK: - Mouse tracking + popup coordination
@MainActor
class MouseTracker {
    nonisolated(unsafe) private var eventMonitor: Any?
    nonisolated(unsafe) private var localEventMonitor: Any?
    nonisolated(unsafe) private var timer: Timer?
    private var notchRect: NSRect?
    private var wasInsideNotch = false

    // popup
    private var helloPanel: HelloPanel?

    // Tunables
    private let panelSize = NSSize(width: 160, height: 48)
    private let panelGap: CGFloat = 8

    init() {
        calculateNotchRect()
        startTracking()
    }

    private func calculateNotchRect() {
        guard let screen = NSScreen.main else { return }

        if #available(macOS 12.0, *) {
            let safeAreaInsets = screen.safeAreaInsets

            if safeAreaInsets.top > 0 {
                let screenFrame = screen.frame
                // Approximate notch width; centered at the top
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
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] _ in
            Task { @MainActor in
                self?.checkMousePosition()
            }
        }
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) {
            [weak self] event in
            Task { @MainActor in
                self?.checkMousePosition()
            }
            return event
        }
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkMousePosition()
            }
        }
        print("Mouse tracking started (global monitor, local monitor, and timer)")
    }

    // Compute a rect centered under the notch for the panel
    private func panelFrameBelowNotch() -> NSRect? {
        guard let screen = NSScreen.main, let notchRect = notchRect else { return nil }
        let width = panelSize.width
        let height = panelSize.height

        var x = notchRect.midX - width / 2
        // keep within screen horizontally
        x = max(screen.frame.minX + 8, min(x, screen.frame.maxX - width - 8))

        let y = notchRect.minY - height - panelGap
        return NSRect(x: x, y: y, width: width, height: height)
    }

    private func showHelloPanel() {
        guard let frame = panelFrameBelowNotch() else { return }

        if helloPanel == nil {
            helloPanel = HelloPanel(frame: frame, message: "Hello World")
        }
        helloPanel?.setFrame(frame, display: true)
        helloPanel?.orderFrontRegardless()  // non-activating
    }

    private func hideHelloPanel() {
        helloPanel?.orderOut(self)
    }

    private func isMouseInsidePanel(_ mouseLocation: NSPoint) -> Bool {
        guard let panel = helloPanel, panel.isVisible else { return false }
        return panel.frame.contains(mouseLocation)
    }

    private func checkMousePosition() {
        guard let notchRect = notchRect else { return }

        let mouseLocation = NSEvent.mouseLocation
        let insideNotch = notchRect.contains(mouseLocation)
        let insidePanel = isMouseInsidePanel(mouseLocation)

        // Show on first notch entry
        if insideNotch && !wasInsideNotch {
            print("Hello World")
            showHelloPanel()
            wasInsideNotch = true
            return
        }

        // Track whether we're still in the notch
        if insideNotch {
            wasInsideNotch = true
            return
        }

        // If not in notch, keep the panel open only while mouse is within the panel
        if !insideNotch && !insidePanel {
            hideHelloPanel()
            wasInsideNotch = false
        }
    }

    deinit {
        if let monitor = eventMonitor { NSEvent.removeMonitor(monitor) }
        if let monitor = localEventMonitor { NSEvent.removeMonitor(monitor) }
        timer?.invalidate()
    }
}

// MARK: - App entry (unchanged except for keeping MouseTracker alive)
@_cdecl("show_status_item")
@MainActor
public func show_status_item() {
    print("Starting notcher application...")

    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)
    print("Application activation policy set to .accessory")

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
    menu.addItem(
        NSMenuItem(
            title: "Quit",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
    statusItem.menu = menu
    print("Menu created and attached to status item")

    let mouseTracker = MouseTracker()
    objc_setAssociatedObject(app, "mouseTracker", mouseTracker, .OBJC_ASSOCIATION_RETAIN)

    print("Starting application run loop...")
    app.run()
}
