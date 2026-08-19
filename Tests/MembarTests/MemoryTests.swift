import AppKit
import Dispatch
import Testing
@testable import Membar

@Suite
struct MemoryTests {
    @Test
    func memoryPressureMapsDispatchEvents() {
        #expect(MemoryPressure.from(.normal) == .normal)
        #expect(MemoryPressure.from(.warning) == .warning)
        #expect(MemoryPressure.from(.critical) == .critical)
        #expect(MemoryPressure.from([.warning, .critical]) == .critical)
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
}
