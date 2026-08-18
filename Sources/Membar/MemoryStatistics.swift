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

        // These are host-wide resident pages. The compressor count is included
        // because compressed memory still occupies physical memory.
        let usedPages = UInt64(statistics.active_count)
            + UInt64(statistics.inactive_count)
            + UInt64(statistics.wire_count)
            + UInt64(statistics.compressor_page_count)
        let usedBytes = usedPages.multipliedReportingOverflow(by: pageSize)

        guard !usedBytes.overflow else {
            return nil
        }

        return min(max(Double(usedBytes.partialValue) / Double(totalBytes), 0), 1)
    }
}
