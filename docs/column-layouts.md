# Fixed column layouts

Adds 32 fixed positions to the expanded Shortcuts section and the additional-size menu:

| Group | Positions | Window size |
|---|---:|---|
| Full-Height Sixths | 6 | 1/6 width, full height |
| Full-Height Eighths | 8 | 1/8 width, full height |
| Top-Half Eighths | 8 | 1/8 width, half height |
| Top-Half Tenths | 10 | 1/10 width, half height |

Open **Shortcuts → disclosure arrow** to assign shortcuts. The four new groups continue the existing two-column shortcut rows. Enable **Show additional sizes in menu** for the menu entries. No shortcuts are assigned by default. Positions stay left-to-right on portrait displays and repeated execution targets the same column.

A shared calculation divides the usable screen area using adjacent rounded boundaries, respecting existing gap handling. Existing action identifiers and shortcut keys are preserved. Titles are localized across all 31 supported locales.

URL examples: `rectangle://execute-action?name=first-sixth`, `rectangle://execute-action?name=last-eighth`, and `rectangle://execute-action?name=top-half-column10-of10`.

## Screenshots

Actual screenshots captured from the installed Debug build after code review, 2026-09-26.

![Full-height sixths and eighths](https://raw.githubusercontent.com/nsozturk/Rectangle/feature/codex-gpt6-001-column-layouts/docs/screenshots/column-layouts/full-height-columns.png)

![Top-half eight- and ten-column shortcuts](https://raw.githubusercontent.com/nsozturk/Rectangle/feature/codex-gpt6-001-column-layouts/docs/screenshots/column-layouts/top-half-columns.png)

## Verification

- Xcode 26.6 Debug build succeeded; deployment target stays macOS 10.15.
- All 9 focused tests passed on the isolated feature branch and the combined local build: geometry, odd/fractional dimensions, negative origins, portrait screens, repeat execution, gaps, menu entries, shortcut bindings, disclosure visibility and scrolling.
- Existing IDs/names and prior catalog entries remain unchanged; 36 new keys cover 31 locales.
- Native preference UI was inspected, including Fourth Eighth. The real storyboard window test verifies all 32 rows are fully reachable, share the existing 18-point icon/control gap, and hide on collapse. No Auto Layout warnings remain in the focused run. Real window movement remains unverified: both new and legacy URL probes left the test window unchanged in the automation session. Do not interpret these screenshots as movement verification.
- The earlier full-suite comparison produced the same 22 assertion failures before and after the feature, in existing tests depending on ambient preferences.
- Applications may enforce a minimum window width larger than a requested column.
