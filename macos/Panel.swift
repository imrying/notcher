import Cocoa

final class HelloPanel: NSPanel {
    init(frame: NSRect, message: String) {
        super.init(
            contentRect: frame,
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        isFloatingPanel = true
        level = .statusBar
        hasShadow = true
        isOpaque = false
        backgroundColor = .clear
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        hidesOnDeactivate = false
        worksWhenModal = true
        becomesKeyOnlyIfNeeded = false

        // Use a view sized to the panel (windows don't have `bounds`)
        let effectFrame = NSRect(origin: .zero, size: frame.size)
        let effect = NSVisualEffectView(frame: effectFrame)
        effect.material = NSVisualEffectView.Material.hudWindow   // explicit type
        effect.state = NSVisualEffectView.State.active            // explicit type
        effect.wantsLayer = true
        effect.layer?.cornerRadius = 12
        effect.layer?.masksToBounds = true
        effect.autoresizingMask = [.width, .height]

        let label = NSTextField(labelWithString: message)
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        effect.addSubview(label)
        contentView = effect

        // Constrain label after contentView is set
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: effect.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: effect.centerYAnchor),
            effect.widthAnchor.constraint(greaterThanOrEqualTo: label.widthAnchor, constant: 24),
            effect.heightAnchor.constraint(greaterThanOrEqualTo: label.heightAnchor, constant: 16)
        ])

        preventsApplicationTerminationWhenModal = false
    }
}

