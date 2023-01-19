#if canImport(AppKit)
import AppKit
#endif

#if canImport(AppKit)
extension NSScrollView {
    var verticalScrollerKnobColor: NSColor? {
        get {
            (verticalScroller as? CustomScroller)?.knobColor
        }
        set {
            guard let newValue else {
                verticalScroller = (verticalScroller as? CustomScroller)?.original
                return
            }

            if !(verticalScroller is CustomScroller) {
                let custom = CustomScroller()
                custom.original = verticalScroller
                verticalScroller = custom
            }

            (verticalScroller as? CustomScroller)?.knobColor = newValue
        }
    }
}
#endif

#if canImport(AppKit)
private class CustomScroller: NSScroller {
    override class var isCompatibleWithOverlayScrollers: Bool {
       return true
    }

    var original: NSScroller?
    var backgroundColor: NSColor = .clear
    var knobColor: NSColor = .white

    override func draw(_ dirtyRect: NSRect) {
        backgroundColor.setFill()
        dirtyRect.fill()
        self.drawKnob()
    }

    override func drawKnob() {
        let isHorizontal = frame.size.width > frame.size.height

        knobColor.setFill()

        let dx, dy: CGFloat
        if isHorizontal {
            dx = 0; dy = 3
        } else {
            dx = 3; dy = 0
        }

        let frame = rect(for: .knob).insetBy(dx: dx, dy: dy)
        NSBezierPath.init(roundedRect: frame, xRadius: 3, yRadius: 3).fill()
    }
}
#endif
