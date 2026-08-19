import Darwin
import Foundation

struct MemoryStatisticsReader {
    func utilization() -> Double? {
        var statistics = vm_statistics64_data_t()
        var count = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size
        )

        let result = withUnsafeMutablePointer(to: &statistics) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(
                    mach_host_self(),
                    HOST_VM_INFO64,
                    $0,
                    &count
                )
            }
        }

        guard result == KERN_SUCCESS else {
            return nil
        }

        let pageSize = UInt64(vm_kernel_page_size)
        let totalBytes = ProcessInfo.processInfo.physicalMemory
        guard pageSize > 0, totalBytes > 0 else {
            return nil
        }

        let usedPages = MemoryUsage.activityMonitorUsedPages(
            internalPages: UInt64(statistics.internal_page_count),
            wirePages: UInt64(statistics.wire_count),
            compressedPages: UInt64(statistics.compressor_page_count),
            purgeablePages: UInt64(statistics.purgeable_count)
        )
        let usedBytes = usedPages.multipliedReportingOverflow(by: pageSize)

        guard !usedBytes.overflow else {
            return nil
        }

        return min(max(Double(usedBytes.partialValue) / Double(totalBytes), 0), 1)
    }
}

enum MemoryUsage {
    // Match Activity Monitor: App Memory + Wired + Compressed. File-backed and
    // purgeable pages are reclaimable cached files, not memory in use.
    static func activityMonitorUsedPages(
        internalPages: UInt64,
        wirePages: UInt64,
        compressedPages: UInt64,
        purgeablePages: UInt64
    ) -> UInt64 {
        let appPages = internalPages > purgeablePages
            ? internalPages - purgeablePages
            : 0
        return appPages + wirePages + compressedPages
    }
}
