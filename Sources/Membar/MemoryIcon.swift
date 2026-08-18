import AppKit

enum MemoryIcon {
    static let size = NSSize(width: 18, height: 18)

    static func image(fillLevel: Int, pressure: MemoryPressure) -> NSImage {
        let image = NSImage(size: size)
        let clampedFillLevel = min(max(fillLevel, 0), 10)
        let foregroundColor = color(for: pressure)

        image.lockFocus()
        defer { image.unlockFocus() }

        drawPins(using: foregroundColor)

        let bodyRect = NSRect(x: 4, y: 3.5, width: 10, height: 11)
        let body = NSBezierPath(
            roundedRect: bodyRect,
            xRadius: 1.8,
            yRadius: 1.8
        )
        body.lineWidth = 1.2
        foregroundColor.setStroke()
        body.stroke()

        let segmentWidth: CGFloat = 1.35
        let segmentHeight: CGFloat = 2.35
        let segmentGap: CGFloat = 0.38
        let segmentStartX: CGFloat = 5.15
        let segmentStartY: CGFloat = 5.0
        let rowGap: CGFloat = 1.0
        let emptyColor = foregroundColor.withAlphaComponent(0.24)

        for index in 0..<10 {
            let row = index / 5
            let column = index % 5
            let rect = NSRect(
                x: segmentStartX + CGFloat(column) * (segmentWidth + segmentGap),
                y: segmentStartY + CGFloat(row) * (segmentHeight + rowGap),
                width: segmentWidth,
                height: segmentHeight
            )
            let segment = NSBezierPath(
                roundedRect: rect,
                xRadius: 0.35,
                yRadius: 0.35
            )
            (index < clampedFillLevel ? foregroundColor : emptyColor).setFill()
            segment.fill()
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
                rect: NSRect(x: 14, y: y, width: sidePinWidth, height: sidePinHeight)
            ).fill()
        }

        let verticalPinWidth: CGFloat = 0.9
        let verticalPinHeight: CGFloat = 1.9
        let verticalPinXPositions: [CGFloat] = [6.1, 11.0]
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
