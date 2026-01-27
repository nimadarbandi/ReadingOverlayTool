import Cocoa

final class AppController {
    private let defaults = UserDefaults.standard

    private var overlayWindow: NSWindow?
    private var overlayView: OverlayView?
    private var controlPanel: ControlPanel?
    private var hotKeyManager: HotKeyManager?
    private var isEditMode = false
    private var isVisible = true

    private var bottomHeight: CGFloat = 0
    private var overlayAlpha: CGFloat = 0.8
    private var overlayColor: NSColor = .black
    private var isTransparentTop = true

    func start() {
        loadSettings()
        setupOverlay()
        setupControlPanel()
        setupHotKey()
        applyState()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    func stop() {
        hotKeyManager?.stop()
        NotificationCenter.default.removeObserver(self)
    }

    private func loadSettings() {
        if let savedHeight = defaults.object(forKey: "bottomHeight") as? Double {
            bottomHeight = CGFloat(savedHeight)
        }
        if let savedAlpha = defaults.object(forKey: "overlayAlpha") as? Double {
            overlayAlpha = CGFloat(savedAlpha)
        }
        if let savedColor = defaults.color(forKey: "overlayColor") {
            overlayColor = savedColor
        }
        if defaults.object(forKey: "isTransparentTop") != nil {
            isTransparentTop = defaults.bool(forKey: "isTransparentTop")
        }
    }

    private func saveSettings() {
        defaults.set(Double(bottomHeight), forKey: "bottomHeight")
        defaults.set(Double(overlayAlpha), forKey: "overlayAlpha")
        defaults.setColor(overlayColor, forKey: "overlayColor")
        defaults.set(isTransparentTop, forKey: "isTransparentTop")
    }

    private func setupOverlay() {
        let window = NSWindow(
            contentRect: .zero,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .screenSaver
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let view = OverlayView()
        view.onDragBoundary = { [weak self] newHeight in
            self?.setBottomHeight(newHeight)
        }
        window.contentView = view

        overlayWindow = window
        overlayView = view

        layoutOverlayWindow()
        window.makeKeyAndOrderFront(nil)
    }

    private func setupControlPanel() {
        let panel = ControlPanel()
        panel.onAlphaChanged = { [weak self] alpha in
            self?.setOverlayAlpha(alpha)
        }
        panel.onColorChanged = { [weak self] color in
            self?.setOverlayColor(color)
        }
        panel.onClose = { [weak self] in
            self?.toggleEditMode()
        }
        panel.onQuit = {
            NSApp.terminate(nil)
        }
        panel.onFlipChanged = { [weak self] isTransparentTop in
            self?.setTransparentTop(isTransparentTop)
        }
        controlPanel = panel
        if let overlayWindow {
            panel.attach(to: overlayWindow)
        }
    }

    private func setupHotKey() {
        hotKeyManager = HotKeyManager()
        hotKeyManager?.onHotKey = { [weak self] in
            self?.toggleEditMode()
        }
        hotKeyManager?.onToggleVisibility = { [weak self] in
            self?.toggleVisibility()
        }
        hotKeyManager?.start()
    }

    private func applyState() {
        if bottomHeight == 0 {
            bottomHeight = (NSScreen.main?.frame.height ?? 800) / 2
        }
        overlayView?.bottomHeight = bottomHeight
        overlayView?.overlayAlpha = overlayAlpha
        overlayView?.overlayColor = overlayColor
        overlayView?.isTransparentTop = isTransparentTop
        overlayView?.isEditMode = isEditMode
        controlPanel?.setAlphaValue(overlayAlpha)
        controlPanel?.setColor(overlayColor)
        controlPanel?.setTransparentTop(isTransparentTop)

        overlayWindow?.ignoresMouseEvents = !isEditMode
        if isEditMode {
            NSApp.activate(ignoringOtherApps: true)
            controlPanel?.show()
        } else {
            controlPanel?.hide()
        }
        saveSettings()
    }

    private func setBottomHeight(_ height: CGFloat) {
        guard let screenHeight = NSScreen.main?.frame.height else { return }
        let clamped = max(80, min(height, screenHeight - 80))
        bottomHeight = clamped
        overlayView?.bottomHeight = clamped
        saveSettings()
    }

    private func setOverlayAlpha(_ alpha: CGFloat) {
        overlayAlpha = max(0.05, min(alpha, 0.95))
        overlayView?.overlayAlpha = overlayAlpha
        saveSettings()
    }

    private func setOverlayColor(_ color: NSColor) {
        overlayColor = color
        overlayView?.overlayColor = overlayColor
        saveSettings()
    }

    private func setTransparentTop(_ value: Bool) {
        isTransparentTop = value
        overlayView?.isTransparentTop = isTransparentTop
        saveSettings()
    }

    private func toggleEditMode() {
        isEditMode.toggle()
        applyState()
    }

    private func toggleVisibility() {
        isVisible.toggle()
        if isVisible {
            overlayWindow?.makeKeyAndOrderFront(nil)
            if isEditMode {
                NSApp.activate(ignoringOtherApps: true)
                controlPanel?.show()
            }
        } else {
            controlPanel?.hide()
            overlayWindow?.orderOut(nil)
        }
    }

    @objc private func screenDidChange() {
        layoutOverlayWindow()
        applyState()
    }

    private func layoutOverlayWindow() {
        guard let screen = NSScreen.main else { return }
        let frame = screen.frame
        let newFrame = NSRect(
            x: frame.minX,
            y: frame.minY,
            width: frame.width,
            height: frame.height
        )
        overlayWindow?.setFrame(newFrame, display: true)
        overlayView?.needsDisplay = true
    }
}
