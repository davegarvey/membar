## Purpose

Provide a reliable menu-bar memory indicator whose pressure state, used percentage, and visual emphasis correspond to the information shown by Activity Monitor.

## ADDED Requirements

### Requirement: Current memory pressure is represented

The indicator SHALL represent the current system memory-pressure state as normal, elevated, or critical. It SHALL read the current state at startup and during each scheduled refresh rather than depending exclusively on a pressure transition notification.

#### Scenario: Membar starts during elevated pressure

- **WHEN** Membar starts while the system is in Activity Monitor's elevated/orange pressure state
- **THEN** the next indicator refresh reports elevated pressure and uses the elevated pressure color

#### Scenario: Membar starts during critical pressure

- **WHEN** Membar starts while the system is in Activity Monitor's critical/red pressure state
- **THEN** the next indicator refresh reports critical pressure and uses the critical pressure color

#### Scenario: Pressure changes between refreshes

- **WHEN** the system pressure changes after a refresh
- **THEN** Membar reflects the new pressure state on the next scheduled refresh

### Requirement: Used percentage matches Activity Monitor accounting

The displayed used percentage SHALL be calculated as `(App Memory + Wired Memory + Compressed Memory) / Physical Memory * 100`. Cached files SHALL NOT be included in Memory Used. The displayed percentage SHALL be rounded to the nearest whole percent and the bar fill level SHALL be derived from the same ratio.

#### Scenario: Cached files do not inflate used percentage

- **WHEN** physical memory is 10 GB, App Memory is 4 GB, Wired Memory is 2 GB, Compressed Memory is 1 GB, and Cached Files is 3 GB
- **THEN** Membar displays 70% used rather than including Cached Files in the numerator

#### Scenario: Percentage and fill use the same ratio

- **WHEN** Activity Monitor-style used memory is 45.6% of physical memory
- **THEN** Membar displays 46% used and selects the corresponding ten-step fill level from the 45.6% ratio

### Requirement: Only the filled bar uses pressure color

The pins, chip outline, and empty portion of the central bar SHALL remain a neutral color appropriate for the menu bar. Only the non-empty filled portion of the central bar SHALL use pressure color: neutral for normal pressure, orange for elevated pressure, and red for critical pressure.

#### Scenario: Elevated pressure with a non-empty bar

- **WHEN** pressure is elevated and the used percentage produces a non-zero fill level
- **THEN** only the filled portion of the central bar is orange while the pins, outline, and empty portion remain neutral

#### Scenario: Critical pressure with a non-empty bar

- **WHEN** pressure is critical and the used percentage produces a non-zero fill level
- **THEN** only the filled portion of the central bar is red while the pins, outline, and empty portion remain neutral

#### Scenario: Normal pressure

- **WHEN** pressure is normal
- **THEN** the entire icon, including the filled portion, uses the normal neutral menu-bar appearance

#### Scenario: Zero fill

- **WHEN** pressure is elevated or critical and the used percentage produces an empty bar
- **THEN** no pressure-colored pixels are rendered because there is no filled portion
