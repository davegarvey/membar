import AppKit

enum MemoryIcon {
    static let size = NSSize(width: 24, height: 18)

    static func image(fillLevel: Int, pressure: MemoryPressure) -> NSImage {
        let image = NSImage(size: size)
        let clampedFillLevel = min(max(fillLevel, 0), 10)
        let foregroundColor = color(for: pressure)

        image.lockFocus()
        defer { image.unlockFocus() }

        drawPins(using: foregroundColor)

        let bodyRect = NSRect(x: 4, y: 3.5, width: 16, height: 11)
        let body = NSBezierPath(
            roundedRect: bodyRect,
            xRadius: 1.8,
            yRadius: 1.8
        )
        body.lineWidth = 1.2
        foregroundColor.setStroke()
        body.stroke()

        let barRect = bodyRect.insetBy(dx: 1.6, dy: 1.7)
        let emptyColor = foregroundColor.withAlphaComponent(0.24)
        let emptyBar = NSBezierPath(
            roundedRect: barRect,
            xRadius: 0.8,
            yRadius: 0.8
        )
        emptyColor.setFill()
        emptyBar.fill()

        let fillWidth = barRect.width * CGFloat(clampedFillLevel) / 10
        if fillWidth > 0 {
            NSGraphicsContext.saveGraphicsState()
            emptyBar.addClip()
            let fillRect = NSRect(
                x: barRect.minX,
                y: barRect.minY,
                width: fillWidth,
                height: barRect.height
            )
            foregroundColor.setFill()
            NSBezierPath(rect: fillRect).fill()
            NSGraphicsContext.restoreGraphicsState()
        }

        image.isTemplate = pressure == .normal
        return image
    }

    private static func color(for pressure: MemoryPressure) -> NSColor {
        switch pressure {
        case .normal:
            // A template image lets the menu bar supply its native foreground color.
            return .black
        case .warning:
            return .systemYellow
        case .critical:
            return .systemRed
        }
    }

    private static func drawPins(using color: NSColor) {
        let sidePinWidth: CGFloat = 2.1
        let sidePinHeight: CGFloat = 0.9
        let sidePinYPositions: [CGFloat] = [5.1, 8.0, 10.9]

        color.setFill()
        for y in sidePinYPositions {
            NSBezierPath(
                rect: NSRect(x: 1.9, y: y, width: sidePinWidth, height: sidePinHeight)
            ).fill()
            NSBezierPath(
                rect: NSRect(x: 20, y: y, width: sidePinWidth, height: sidePinHeight)
            ).fill()
        }

        let verticalPinWidth: CGFloat = 0.9
        let verticalPinHeight: CGFloat = 1.9
        let verticalPinXPositions: [CGFloat] = [8.0, 15.0]
        for x in verticalPinXPositions {
            NSBezierPath(
                rect: NSRect(x: x, y: 1.4, width: verticalPinWidth, height: verticalPinHeight)
            ).fill()
            NSBezierPath(
                rect: NSRect(x: x, y: 14.6, width: verticalPinWidth, height: verticalPinHeight)
            ).fill()
        }
    }
}
