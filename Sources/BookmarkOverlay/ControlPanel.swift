import Cocoa

final class ControlPanel {
    var onAlphaChanged: ((CGFloat) -> Void)?
    var onColorChanged: ((NSColor) -> Void)?
    var onClose: (() -> Void)?
    var onQuit: (() -> Void)?
    var onFlipChanged: ((Bool) -> Void)?

    private let panel: NSPanel
    private lazy var alphaSlider: NSSlider = {
        let slider = NSSlider(value: 0.8, minValue: 0.05, maxValue: 0.95, target: self, action: #selector(alphaChanged))
        return slider
    }()
    private lazy var colorWell: NSColorWell = {
        let well = NSColorWell()
        well.target = self
        well.action = #selector(colorChanged)
        return well
    }()
    private lazy var flipCheckbox: NSButton = {
        let checkbox = NSButton(checkboxWithTitle: "Transparent on Top", target: self, action: #selector(flipChanged))
        checkbox.state = .on
        return checkbox
    }()

    init() {
        panel = NSPanel(
            contentRect: NSRect(x: 200, y: 200, width: 320, height: 180),
            styleMask: [.titled, .closable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        panel.level = NSWindow.Level(rawValue: NSWindow.Level.screenSaver.rawValue + 1)
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.title = "Bookmark Overlay"
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let contentView = NSView(frame: panel.contentRect(forFrameRect: panel.frame))
        panel.contentView = contentView

        let alphaLabel = NSTextField(labelWithString: "Opacity")
        alphaLabel.font = NSFont.systemFont(ofSize: 12)

        let colorLabel = NSTextField(labelWithString: "Color")
        colorLabel.font = NSFont.systemFont(ofSize: 12)

        let hintLabel = NSTextField(labelWithString: "Drag the edge to set the line.")
        hintLabel.font = NSFont.systemFont(ofSize: 11)
        hintLabel.textColor = .secondaryLabelColor

        let doneButton = NSButton(title: "Done (⇧⌘Z)", target: self, action: #selector(donePressed))
        doneButton.bezelStyle = .rounded

        let quitButton = NSButton(title: "Quit", target: self, action: #selector(quitPressed))
        quitButton.bezelStyle = .rounded

        let stack = NSStackView(views: [alphaLabel, alphaSlider, colorLabel, colorWell, flipCheckbox, hintLabel, doneButton, quitButton])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    func show() {
        panel.makeKeyAndOrderFront(nil)
    }

    func hide() {
        panel.orderOut(nil)
    }

    func attach(to parent: NSWindow) {
        if panel.parent == nil {
            parent.addChildWindow(panel, ordered: .above)
        }
    }

    func setAlphaValue(_ value: CGFloat) {
        alphaSlider.doubleValue = Double(value)
    }

    func setColor(_ color: NSColor) {
        colorWell.color = color
    }

    func setTransparentTop(_ value: Bool) {
        flipCheckbox.state = value ? .on : .off
    }

    @objc private func alphaChanged() {
        onAlphaChanged?(CGFloat(alphaSlider.doubleValue))
    }

    @objc private func colorChanged() {
        onColorChanged?(colorWell.color)
    }

    @objc private func donePressed() {
        onClose?()
    }

    @objc private func flipChanged() {
        onFlipChanged?(flipCheckbox.state == .on)
    }

    @objc private func quitPressed() {
        onQuit?()
    }
}
