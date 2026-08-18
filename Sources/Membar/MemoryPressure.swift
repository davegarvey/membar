import Dispatch
import Foundation

enum MemoryPressure: Equatable {
    case normal
    case warning
    case critical

    var displayName: String {
        switch self {
        case .normal:
            return "Normal"
        case .warning:
            return "Elevated"
        case .critical:
            return "Critical"
        }
    }

    static func from(_ event: DispatchSource.MemoryPressureEvent) -> MemoryPressure {
        if event.contains(.critical) {
            return .critical
        }
        if event.contains(.warning) {
            return .warning
        }
        return .normal
    }
}

enum MemoryUtilization {
    static func fillLevel(for percentage: Double) -> Int {
        guard percentage.isFinite else {
            return 0
        }

        let clampedPercentage = min(max(percentage, 0), 100)
        return min(Int(clampedPercentage / 10), 10)
    }
}

struct MemorySnapshot: Equatable {
    let utilization: Double
    let pressure: MemoryPressure

    var fillLevel: Int {
        MemoryUtilization.fillLevel(for: utilization * 100)
    }

    var percentage: Int {
        let percentage = utilization * 100
        guard percentage.isFinite else {
            return 0
        }
        return min(max(Int(percentage.rounded()), 0), 100)
    }
}
