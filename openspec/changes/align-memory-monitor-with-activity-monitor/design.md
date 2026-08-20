## Context

See `proposal.md` for the motivation and user-visible scope. The current monitor initializes pressure to `.normal` and updates it only from `DispatchSourceMemoryPressure` transition events. Its periodic timer samples utilization but does not query current pressure. The current statistics reader already has the Activity Monitor-style page equation, while the icon uses one foreground color for every drawn element.

The app targets macOS 13 or newer, uses a five-second default sampling interval, and has no persisted memory-monitoring state or external dependencies.

## Goals / Non-Goals

**Goals:**

- Make the current pressure state authoritative at startup and on each periodic sample.
- Keep the existing polling cadence and accept up to one sampling interval of pressure-display lag.
- Preserve the Activity Monitor Memory Used equation and make its percentage behavior explicit and testable.
- Separate neutral icon structure from the pressure-colored filled bar.
- Keep the pressure source and rendering decisions injectable or directly testable without allocating system pressure in unit tests.

**Non-Goals:**

- Reproducing Activity Monitor's historical pressure graph.
- Adding a user-configurable refresh interval.
- Showing additional memory categories or changing the menu layout.
- Making the app an App Store-compatible consumer of undocumented kernel interfaces.

## Decisions

### Use the current kernel pressure value as the source of truth

Read `kern.memorystatus_vm_pressure_level` with `sysctlbyname` through a small `MemoryPressureReader`. Decode the kernel values corresponding to normal (`1`), warning (`2`), and critical (`4`). The reader is queried at the beginning of each existing monitor sample, including the first immediate sample after startup.

This is preferred over relying on `DispatchSourceMemoryPressure` because the dispatch API delivers transition notifications and does not provide a reliable initial snapshot for the observed failure. Polling is acceptable because the user accepts the existing five-second lag. The dispatch source can be removed rather than maintained as a competing pressure state.

If a kernel read fails, retain the last known pressure so a transient read failure does not cause a visual downgrade. The initial fallback remains normal because no current state is available.

### Preserve the Activity Monitor page equation

Continue deriving App Memory pages as anonymous/internal pages minus purgeable pages, then add wired pages and physical compressor pages. Multiply by the kernel page size and divide by `ProcessInfo.processInfo.physicalMemory`. Keep clamping and finite-value handling at the utilization boundary, and retain nearest-integer rounding only for the displayed menu percentage.

Synthetic counter tests will verify cached/purgeable exclusion, compressor inclusion, denominator use, and the independent rounding/fill-level behavior.

### Render neutral structure and colored fill separately

Use a menu-bar-aware neutral color such as `NSColor.labelColor` for pins, outline, and the empty bar. Use a separate pressure fill color for only the clipped filled rectangle: neutral in normal state, `NSColor.systemOrange` for warning, and `NSColor.systemRed` for critical.

Normal images may remain template images so macOS controls their native menu-bar tint. Elevated and critical images must remain non-template so their fill colors survive rendering; their structural elements use the resolved neutral label color.

### Keep tests at behavior boundaries

Add raw kernel-value mapping tests, pressure-reader/monitor sampling tests using injected readers, usage equation tests, and icon rendering tests that verify the filled region changes while structural pixels remain neutral. Do not use a real memory-pressure stress command in unit tests.

## Risks / Trade-offs

- **Undocumented sysctl may change or become unavailable.** -> Isolate the name and decoding in one reader, constrain support to the existing macOS 13+ target, and retain the last known state on read failure.
- **Polling can lag pressure changes by up to five seconds.** -> This is an explicit accepted requirement; the first sample is scheduled immediately at startup.
- **Activity Monitor's raw field mapping is not publicly specified.** -> Use Apple's documented Memory Used categories, keep the page mapping centralized, and cover the equation with deterministic tests.
- **Non-template colored images must resolve a neutral appearance color.** -> Use the dynamic label color at render time and continue rebuilding the image whenever a snapshot changes.

## Migration Plan

No persisted data or migration is required. Build and test the new monitor, compare it manually against Activity Monitor under normal, warning, and critical conditions, then ship the updated app. Rollback is replacing the app with the previous release if the private sysctl is unavailable or rendering is incorrect.
