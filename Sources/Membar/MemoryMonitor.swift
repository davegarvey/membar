import Dispatch
import Foundation

final class MemoryMonitor {
    typealias UpdateHandler = (MemorySnapshot) -> Void

    private let queue = DispatchQueue(
        label: "com.membar.memory-monitor",
        qos: .utility
    )
    private let statisticsReader: MemoryStatisticsReader
    private let updateHandler: UpdateHandler
    private let samplingInterval: DispatchTimeInterval

    private var pressureSource: DispatchSourceMemoryPressure?
    private var timer: DispatchSourceTimer?
    private var pressure: MemoryPressure = .normal
    private var lastFillLevel: Int?
    private var lastPressure: MemoryPressure?
    private var started = false

    init(
        statisticsReader: MemoryStatisticsReader = MemoryStatisticsReader(),
        samplingInterval: DispatchTimeInterval = .seconds(5),
        updateHandler: @escaping UpdateHandler
    ) {
        self.statisticsReader = statisticsReader
        self.samplingInterval = samplingInterval
        self.updateHandler = updateHandler
    }

    func start() {
        queue.async { [weak self] in
            self?.startOnQueue()
        }
    }

    func stop() {
        queue.async { [weak self] in
            guard let self else { return }
            self.timer?.cancel()
            self.pressureSource?.cancel()
            self.timer = nil
            self.pressureSource = nil
            self.started = false
        }
    }

    private func startOnQueue() {
        guard !started else { return }
        started = true

        let source = DispatchSource.makeMemoryPressureSource(
            eventMask: .all,
            queue: queue
        )
        source.setEventHandler { [weak self] in
            guard let self, let source = self.pressureSource else { return }
            self.handlePressureEvent(source.data)
        }
        pressureSource = source
        source.resume()

        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(
            deadline: .now(),
            repeating: samplingInterval,
            leeway: .seconds(1)
        )
        timer.setEventHandler { [weak self] in
            self?.sampleAndPublish()
        }
        self.timer = timer
        timer.resume()
    }

    private func handlePressureEvent(_ event: DispatchSource.MemoryPressureEvent) {
        let nextPressure = MemoryPressure.from(event)
        guard nextPressure != pressure else { return }

        pressure = nextPressure
        sampleAndPublish()
    }

    private func sampleAndPublish() {
        guard let utilization = statisticsReader.utilization() else {
            return
        }

        let snapshot = MemorySnapshot(
            utilization: utilization,
            pressure: pressure
        )
        let fillLevelChanged = snapshot.fillLevel != lastFillLevel
        let pressureChanged = snapshot.pressure != lastPressure

        guard fillLevelChanged || pressureChanged else {
            return
        }

        lastFillLevel = snapshot.fillLevel
        lastPressure = snapshot.pressure
        updateHandler(snapshot)
    }
}
