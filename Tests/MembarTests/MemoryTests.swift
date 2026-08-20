import AppKit
import Dispatch
import Testing
@testable import Membar

@Suite
struct MemoryTests {
    @Test
    func memoryPressureMapsKernelValues() {
        #expect(MemoryPressure.fromKernelValue(1) == .normal)
        #expect(MemoryPressure.fromKernelValue(2) == .warning)
        #expect(MemoryPressure.fromKernelValue(4) == .critical)
        #expect(MemoryPressure.fromKernelValue(0) == nil)
    }

    @Test
    func fillLevelClampsAndUsesTenSteps() {
        #expect(MemoryUtilization.fillLevel(for: -.infinity) == 0)
        #expect(MemoryUtilization.fillLevel(for: -1) == 0)
        #expect(MemoryUtilization.fillLevel(for: 9.99) == 0)
        #expect(MemoryUtilization.fillLevel(for: 10) == 1)
        #expect(MemoryUtilization.fillLevel(for: 54.9) == 5)
        #expect(MemoryUtilization.fillLevel(for: 100) == 10)
        #expect(MemoryUtilization.fillLevel(for: .infinity) == 0)
    }

    @Test
    func snapshotRoundsPercentageSeparatelyFromFillLevel() {
        let snapshot = MemorySnapshot(utilization: 0.456, pressure: .warning)

        #expect(snapshot.fillLevel == 4)
        #expect(snapshot.percentage == 46)
    }

    @Test
    func memoryUsageMatchesActivityMonitorAndExcludesPurgeablePages() {
        let usedPages = MemoryUsage.activityMonitorUsedPages(
            internalPages: 100,
            wirePages: 20,
            compressedPages: 5,
            purgeablePages: 10
        )

        #expect(usedPages == 115)
    }

    @Test
    func memoryUsageDoesNotUnderflowWhenPurgeablePagesExceedInternalPages() {
        let usedPages = MemoryUsage.activityMonitorUsedPages(
            internalPages: 2,
            wirePages: 20,
            compressedPages: 5,
            purgeablePages: 3
        )

        #expect(usedPages == 25)
    }

    @Test
    func memoryUsageUsesPhysicalMemoryAsDenominator() {
        let utilization = MemoryUsage.activityMonitorUtilization(
            internalPages: 4,
            wirePages: 2,
            compressedPages: 1,
            purgeablePages: 0,
            pageSize: 1,
            physicalMemory: 10
        )

        #expect(utilization == 0.7)
    }

    @Test
    func iconUsesTemplateNormalAndColoredPressureImages() {
        #expect(MemoryIcon.size == NSSize(width: 24, height: 18))

        for pressure in [MemoryPressure.normal, .warning, .critical] {
            let image = MemoryIcon.image(fillLevel: 5, pressure: pressure)

            #expect(image.size == MemoryIcon.size)
            #expect(image.isTemplate == (pressure == .normal))
        }
    }

    @Test
    func iconRenderingChangesForFillAndPressureStates() {
        let empty = MemoryIcon.image(fillLevel: 0, pressure: .normal)
        let full = MemoryIcon.image(fillLevel: 10, pressure: .normal)
        let warning = MemoryIcon.image(fillLevel: 5, pressure: .warning)

        #expect(empty.tiffRepresentation != full.tiffRepresentation)
        #expect(full.tiffRepresentation != warning.tiffRepresentation)
    }

    @Test
    func pressureColorsAreLimitedToTheFilledBar() {
        let warning = MemoryIcon.image(fillLevel: 5, pressure: .warning)
        let critical = MemoryIcon.image(fillLevel: 5, pressure: .critical)

        #expect(pixel(at: NSPoint(x: 8, y: 9), in: warning) != pixel(at: NSPoint(x: 8, y: 9), in: critical))
        #expect(pixel(at: NSPoint(x: 8, y: 9), in: warning) != pixel(at: NSPoint(x: 16, y: 9), in: warning))
        #expect(pixel(at: NSPoint(x: 16, y: 9), in: warning) == pixel(at: NSPoint(x: 16, y: 9), in: critical))
        #expect(pixel(at: NSPoint(x: 4, y: 9), in: warning) == pixel(at: NSPoint(x: 4, y: 9), in: critical))
    }

    @Test
    func pressureColorsAreAbsentWhenTheBarIsEmpty() {
        let warning = MemoryIcon.image(fillLevel: 0, pressure: .warning)
        let critical = MemoryIcon.image(fillLevel: 0, pressure: .critical)

        #expect(warning.tiffRepresentation == critical.tiffRepresentation)
    }

    @Test
    func monitorPublishesPressureReadAtEachSample() {
        let semaphore = DispatchSemaphore(value: 0)
        let lock = NSLock()
        var snapshots: [MemorySnapshot] = []
        let pressureReader = SequencePressureReader(values: [.warning, .critical])
        let monitor = MemoryMonitor(
            statisticsReader: FixedStatisticsReader(utilization: 0.456),
            pressureReader: pressureReader,
            samplingInterval: .milliseconds(10)
        ) { snapshot in
            lock.lock()
            snapshots.append(snapshot)
            lock.unlock()
            semaphore.signal()
        }
        defer { monitor.stop() }

        monitor.start()

        #expect(semaphore.wait(timeout: .now() + .seconds(1)) == .success)
        #expect(semaphore.wait(timeout: .now() + .seconds(1)) == .success)

        lock.lock()
        let pressures = snapshots.map(\.pressure)
        lock.unlock()
        #expect(pressures == [.warning, .critical])
    }
}

private struct Pixel: Equatable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
}

private func pixel(at point: NSPoint, in image: NSImage) -> Pixel {
    guard
        let tiffRepresentation = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiffRepresentation),
        let color = bitmap.colorAt(
            x: Int(point.x * CGFloat(bitmap.pixelsWide) / image.size.width),
            y: Int(point.y * CGFloat(bitmap.pixelsHigh) / image.size.height)
        )?.usingColorSpace(.deviceRGB)
    else {
        return Pixel(red: -1, green: -1, blue: -1, alpha: -1)
    }

    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return Pixel(red: red, green: green, blue: blue, alpha: alpha)
}

private struct FixedStatisticsReader: MemoryStatisticsReading {
    let utilizationValue: Double

    init(utilization: Double) {
        self.utilizationValue = utilization
    }

    func utilization() -> Double? {
        utilizationValue
    }
}

private final class SequencePressureReader: MemoryPressureReading {
    private let values: [MemoryPressure?]
    private var index = 0

    init(values: [MemoryPressure?]) {
        self.values = values
    }

    func current() -> MemoryPressure? {
        defer { index += 1 }
        return values[min(index, values.count - 1)]
    }
}
