## Why

Membar currently reports memory utilization while its pressure state can remain `Normal`, even when Activity Monitor shows elevated or critical pressure. Its pressure color is also applied to the entire chip icon, which makes the indicator less readable than intended. This change aligns the indicator with Activity Monitor's pressure and memory-used semantics.

## What Changes

- Read the current macOS memory-pressure state during startup and periodic polling so Membar does not depend on receiving a pressure transition notification.
- Map elevated pressure to orange and critical pressure to red.
- Calculate the displayed used percentage from Activity Monitor's Memory Used categories divided by physical memory: App Memory, Wired Memory, and Compressed memory, excluding cached files.
- Apply pressure colors only to the filled portion of the central bar; keep the pins, outline, and empty bar neutral and appropriate for the menu bar appearance.
- Add automated coverage for pressure-state mapping, Activity Monitor-style usage calculation, and fill-only color rendering.

## Capabilities

### New Capabilities

- `memory-monitoring`: Provide a menu-bar memory indicator whose pressure state, used percentage, and visual color behavior correspond to Activity Monitor.

### Modified Capabilities

<!-- No existing capability specifications are present in this repository. -->

## Impact

- Affects `Sources/Membar/MemoryMonitor.swift`, `MemoryPressure.swift`, `MemoryStatistics.swift`, and `MemoryIcon.swift`.
- Extends `Tests/MembarTests/MemoryTests.swift`.
- Uses the macOS kernel memory-pressure state query as a system interface; pressure updates may follow the existing polling interval rather than requiring immediate event delivery.
- No external dependencies or user-facing API changes.
