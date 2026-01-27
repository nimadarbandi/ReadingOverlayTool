import Cocoa

final class OverlayView: NSView {
    var bottomHeight: CGFloat = 200 {
        didSet { needsDisplay = true }
    }
    var overlayAlpha: CGFloat = 0.8 {
        didSet { needsDisplay = true }
    }
    var overlayColor: NSColor = .black {
        didSet { needsDisplay = true }
    }
    var isTransparentTop: Bool = true {
        didSet { needsDisplay = true }
    }
    var isEditMode: Bool = false {
        didSet { needsDisplay = true }
    }

    var onDragBoundary: ((CGFloat) -> Void)?

    private var isDraggingBoundary = false

    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.clear.setFill()
        dirtyRect.fill()

        let height = bounds.height
        let coloredHeight = bottomHeight
        let coloredRect: NSRect
        if isTransparentTop {
            coloredRect = NSRect(x: 0, y: height - coloredHeight, width: bounds.width, height: coloredHeight)
        } else {
            coloredRect = NSRect(x: 0, y: 0, width: bounds.width, height: coloredHeight)
        }
        overlayColor.withAlphaComponent(overlayAlpha).setFill()
        coloredRect.fill()

        if isEditMode {
            let boundaryY = isTransparentTop ? (height - coloredHeight) : coloredHeight
            let lineRect = NSRect(x: 0, y: boundaryY - 1, width: bounds.width, height: 2)
            NSColor.white.withAlphaComponent(0.6).setFill()
            lineRect.fill()
        }
    }

    override func mouseDown(with event: NSEvent) {
        guard isEditMode else { return }
        let point = convert(event.locationInWindow, from: nil)
        let boundaryY = isTransparentTop ? (bounds.height - bottomHeight) : bottomHeight
        if abs(point.y - boundaryY) <= 6 {
            isDraggingBoundary = true
        }
    }

    override func mouseDragged(with event: NSEvent) {
        guard isEditMode, isDraggingBoundary else { return }
        let point = convert(event.locationInWindow, from: nil)
        let newBottomHeight = isTransparentTop ? (bounds.height - point.y) : point.y
        onDragBoundary?(newBottomHeight)
    }

    override func mouseUp(with event: NSEvent) {
        isDraggingBoundary = false
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for area in trackingAreas {
            removeTrackingArea(area)
        }
        let area = NSTrackingArea(rect: bounds, options: [.activeAlways, .mouseMoved, .inVisibleRect], owner: self, userInfo: nil)
        addTrackingArea(area)
    }

    override func mouseMoved(with event: NSEvent) {
        guard isEditMode else { return }
        let point = convert(event.locationInWindow, from: nil)
        let boundaryY = isTransparentTop ? (bounds.height - bottomHeight) : bottomHeight
        if abs(point.y - boundaryY) <= 6 {
            NSCursor.resizeUpDown.set()
        } else {
            NSCursor.arrow.set()
        }
    }
}
