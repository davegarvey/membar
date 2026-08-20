import Darwin
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

    static func fromKernelValue(_ value: UInt32) -> MemoryPressure? {
        switch value {
        case 1:
            return .normal
        case 2:
            return .warning
        case 4:
            return .critical
        default:
            return nil
        }
    }
}

protocol MemoryPressureReading {
    func current() -> MemoryPressure?
}

struct MemoryPressureReader: MemoryPressureReading {
    private static let sysctlName = "kern.memorystatus_vm_pressure_level"

    func current() -> MemoryPressure? {
        var value: UInt32 = 0
        var size = MemoryLayout<UInt32>.size

        guard sysctlbyname(Self.sysctlName, &value, &size, nil, 0) == 0 else {
            return nil
        }

        return MemoryPressure.fromKernelValue(value)
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
