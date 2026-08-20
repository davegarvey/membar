## 1. Pressure State Source

- [x] 1.1 Add an isolated memory-pressure reader for `kern.memorystatus_vm_pressure_level`, including normal, warning, and critical value decoding.
- [x] 1.2 Update `MemoryMonitor` to poll the current pressure before each utilization sample, remove event-only pressure dependence, and retain the last known state when a read fails.
- [x] 1.3 Add deterministic tests for kernel-value mapping and monitor publication when pressure changes between samples.

## 2. Activity Monitor Usage Accounting

- [x] 2.1 Verify and, where needed, centralize the Activity Monitor Memory Used equation using App Memory, Wired Memory, and Compressed Memory over physical memory while excluding cached/purgeable file pages.
- [x] 2.2 Add tests covering denominator use, cached/purgeable exclusion, compressor inclusion, percentage rounding, and ten-step fill derivation.

## 3. Fill-Only Pressure Rendering

- [x] 3.1 Split icon rendering into neutral structural colors and a pressure-dependent filled-bar color, using orange for warning and red for critical pressure.
- [x] 3.2 Preserve template behavior for normal icons and non-template behavior for colored pressure fills while keeping pins, outline, and empty bar neutral.
- [x] 3.3 Add rendering tests that verify pressure colors are confined to the filled bar and that zero fill produces no pressure-colored pixels.

## 4. Validation

- [x] 4.1 Run `openspec validate --strict` and resolve any artifact or requirement-format issues.
- [x] 4.2 Run the Swift test suite and build/package checks for the macOS 13 target.
- [ ] 4.3 Manually compare normal, elevated, and critical pressure states and the used percentage against Activity Monitor on macOS.
