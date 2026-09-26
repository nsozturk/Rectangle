# Fixed column and grid layouts

Adds 32 fixed positions to the expanded Shortcuts section and the additional-size menu:

| Group | Positions | Window size |
|---|---:|---|
| Full-Height Sixths | 6 | 1/6 width, full height |
| Full-Height Eighths | 8 | 1/8 width, full height |
| Top-Half Eighths | 8 | 1/8 width, half height |
| Top-Half Tenths | 10 | 1/10 width, half height |

Open **Shortcuts → disclosure arrow** to assign shortcuts. The four new groups continue the existing two-column shortcut rows. Enable **Show additional sizes in menu** for the menu entries. No shortcuts are assigned by default. Positions stay left-to-right on portrait displays. Repeating an assigned column action moves one position right within its 6-, 8-, or 10-column group and wraps after the final position; a new action, window, or externally moved window starts again from the assigned position. Selecting **Do nothing** for repeated commands keeps the assigned position fixed.

A shared calculation divides the usable screen area using adjacent rounded boundaries, respecting existing gap handling. Existing action identifiers and shortcut keys are preserved. Titles are localized across all 31 supported locales.

URL examples: `rectangle://execute-action?name=first-sixth`, `rectangle://execute-action?name=last-eighth`, and `rectangle://execute-action?name=top-half-column10-of10`.

## Fixed grids

The expanded Shortcuts section also has two fixed-grid categories:

| Category | Grid (rows × columns) | Positions |
|---|---|---:|
| Two-Row Layouts | 2 × 4 | 8 |
| Three-Row Layouts | 3 × 3, 3 × 4, 3 × 6, 3 × 8 | 63 |

The three-row category has one subgroup per column count. Rows are ordered Top, Middle (three-row grids), then Bottom; columns run left to right. The native shortcut controls and cell icons match the existing Shortcuts rows.

These 71 actions keep the same grid dimensions, including on portrait screens. Repeated invocation traverses that whole grid in row-major order—Top left-to-right, then Middle, then Bottom—continues from the final cell to the first, and returns to the assigned cell after one complete grid cycle. A 2×4 action never enters a 3-row grid, and each 3-row column count remains independent. They are separate from the existing orientation-aware Eighths, Ninths and Twelfths, whose stored shortcuts and behavior are unchanged. No default shortcuts or drag regions are added.

URL examples: `rectangle://execute-action?name=grid2x4-row1-column1` and `rectangle://execute-action?name=grid3x8-row3-column8`.

## Duplicate shortcut assignments

All shortcut recorders check for assignments already used by another Rectangle action or Todo shortcut. A conflicting candidate opens the existing native shortcut warning, names the assigned action, and leaves the saved shortcut unchanged. Re-recording the current action’s own shortcut is allowed. This check also applies when **Allow any shortcut** is enabled; that option only relaxes normal key/system validation. Existing saved assignments are not automatically removed.

## Screenshots

Actual screenshots captured from the installed Debug build after code review, 2026-09-26.

![Full-height sixths and eighths](https://raw.githubusercontent.com/nsozturk/Rectangle/feature/codex-gpt6-001-column-layouts/docs/screenshots/column-layouts/full-height-columns.png)

![Top-half eight- and ten-column shortcuts](https://raw.githubusercontent.com/nsozturk/Rectangle/feature/codex-gpt6-001-column-layouts/docs/screenshots/column-layouts/top-half-columns.png)

![Two-row grids and three-row subgroups](https://raw.githubusercontent.com/nsozturk/Rectangle/feature/codex-gpt6-001-column-layouts/docs/screenshots/column-layouts/two-row-grids.png)

![Three-row six- and eight-column shortcuts](https://raw.githubusercontent.com/nsozturk/Rectangle/feature/codex-gpt6-001-column-layouts/docs/screenshots/column-layouts/three-row-grids.png)

![Native duplicate shortcut warning](https://raw.githubusercontent.com/nsozturk/Rectangle/feature/codex-gpt6-001-column-layouts/docs/screenshots/column-layouts/shortcut-conflict.png)

## Verification

- Duplicate-assignment update: 21 focused validator, recorder wiring/observer, and existing shortcut-cycle tests passed. Native installed-app verification rejected Control+Option+A in the last 3×8 cell, named First Fourth in the existing warning, and preserved both stored values with Allow any shortcut enabled. The explanation covers all 31 locales.

- Xcode 26.6 Debug build succeeded; deployment target stays macOS 10.15.
- Focused coverage includes geometry, odd/fractional dimensions, negative origins, portrait screens, two complete group cycles from every assigned cell, row-major grid traversal, wrapping, effective gap edges, reset behavior, menu entries, shortcut bindings, disclosure visibility and scrolling.
- Existing IDs/names and prior catalog entries remain unchanged; The original 36 column keys and 10 shared grid keys cover all 31 locales.
- Native Shortcuts UI was inspected through the final 3×8 cell. The storyboard test verifies all 103 dynamic rows are fully reachable, share the existing 18-point icon/control gap, and hide on collapse. Two fixed-grid categories contain 8 and 63 menu actions. A temporary grid shortcut was recorded and cleared; the existing First Fourth shortcut was preserved. No Auto Layout conflicts appeared in the final focused run.
- Live external-window movement remains unverified: the automation-created TextEdit window did not become the macOS foreground application, so URL/key movement was not treated as a valid end-to-end check. URL-name lookup and geometry are covered by tests.
- The earlier full-suite comparison produced the same 22 assertion failures before and after the feature, in existing tests depending on ambient preferences.
- Applications may enforce a minimum window width larger than a requested column.
