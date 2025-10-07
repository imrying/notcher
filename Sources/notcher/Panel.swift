import Cocoa

final public class HelloPanel: NSPanel {
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
        effect.material = NSVisualEffectView.Material.hudWindow  // explicit type
        effect.state = NSVisualEffectView.State.active  // explicit type
        effect.wantsLayer = true
        effect.layer?.cornerRadius = 12
        effect.layer?.masksToBounds = true
        effect.autoresizingMask = [.width, .height]

        let label = NSTextField(labelWithString: message)
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.alignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.maximumNumberOfLines = 10
        label.translatesAutoresizingMaskIntoConstraints = false

        effect.addSubview(label)
        contentView = effect

        // Constrain label after contentView is set
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: effect.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: effect.trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: effect.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: effect.bottomAnchor, constant: -8),
        ])

        preventsApplicationTerminationWhenModal = false
    }
}
