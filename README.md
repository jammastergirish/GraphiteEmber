# GraphiteEmber

The "Graphite & Ember" look shared by two macOS apps, One Tap Transcribe and
Intercept, plus the scripts that build and release them.

## What's in it

- `Theme.swift`: colour tokens (`Theme.ember`, `Theme.cardBG`, …), `Color(hex:)`,
  `Color.dynamic(light:dark:)`, `Font.mono` and `MonoLabel`.
- `Components.swift`: `StatusBadge`, `LogoSquircle` (each app passes its own
  mark), `EmberSpinner`, `GraphiteButtonStyle`, `WindowTitleBar`,
  `MenuPanelHeader`, `MenuRow` and `NoticeBanner`.
- `Controls.swift`: `CheckSquare` and `EmberCheckboxStyle` (checkboxes),
  `ChipGroup` with `SegmentPicker` (pick one) and `ToggleChip` (tick any
  combination), `OptionMenu` (a drop-down), and `EmberLinkButtonStyle`.
- `TableCard.swift`: the rounded card the apps use for their lists. Short lists
  draw their rows directly; long ones scroll. `tableRowHover(_:)` gives a row
  the ember hover tint.
- `Format.swift`: date labels (`Format.when`), recording lengths and the
  running timer.
- `Artwork.swift`: `SquircleIcon`, which draws the app-icon squircle around an
  app's mark, writes `.iconset` folders and makes menu-bar template images.
- `Scripts/`: `build_app.sh`, `make_dmg.sh`, `release.sh` and
  `setup_signing.sh`. Each app keeps thin wrappers that pass in its own folder;
  the app's `app.conf` sets `APP_NAME`, `DISPLAY_NAME` and `BUNDLE_ID`.

Each app keeps what is its own: its mark (`RecordGlyph`, `WaveformGlyph`), its
icon drawing and any components only it uses.

## Using it

Add it to an app's `Package.swift`:

```swift
.package(url: "https://github.com/jammastergirish/GraphiteEmber.git", from: "1.0.0")
```

and `.product(name: "GraphiteEmber", package: "GraphiteEmber")` to the app
target. The app's wrapper scripts ask SwiftPM where the package is checked out
and run the scripts in its `Scripts/` folder.

To change the package and an app together, run
`swift package edit GraphiteEmber --path ../GraphiteEmber` in the app; SwiftPM
then uses your local copy until `swift package unedit GraphiteEmber`.

```bash
swift test   # checks the date and length labels
```
