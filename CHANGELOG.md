# Changelog

All notable changes to the **Fullscreen Power Menu** plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.2.0] - 2026-10-10

### Added
- **Dynamic Shape Morphing Animation**: Added smooth Material 3 shape morphing on hover with `DLoadingIndicator` spinner and corner radius squircle transitions.
- **Shape Morphing Speed Setting**: Added a configurable slider and numeric input in Settings to adjust the hover shape morphing speed independently.
- **IPC Toggle Button in Settings**: Added a direct "Toggle Power Menu" button inside Settings to test and preview the menu instantly.
- **Niri Compositor Integration & Blur Support**: Split the menu into separate backdrop overlay and menu floating window layers (`dms:plugins:fullscreenPowerMenu:backdrop` and `dms:plugins:fullscreenPowerMenu:menu`) enabling compositors like Niri to apply blur effects specifically to the power menu card.
- **CopyBox Quick Actions**: Integrated one-click copyable IPC command cards for `toggle`, `open`, `close`, and Niri bind configurations.
- **Orientation & Appearance Options**: Full control over menu transparency, background dim opacity, orientation (dynamic, horizontal, vertical), animation speed multiplier, primary color tint toggle, and tint intensity.
- **Automatic GitHub Release Workflow**: CI automation to build tarball archives and publish GitHub releases upon version bumps in `plugin.json`.

### Changed
- **Modernized Graphics Pipeline**: Migrated from legacy canvas & graphical effects to `QtQuick.Shapes` and `QtQuick.Effects MultiEffect` for hardware-accelerated drop shadows, corner curvature, and smooth tint overlays.
- **Settings Layout Redesign**: Reorganized settings into clean sections with synced slider pills and instant global variable propagation.
- **Light Mode UI Polish**: Improved contrast and icon visibility under light themes with high menu opacity.

---

## [1.0.3] - Earlier Release

### Added
- Initial release of Material 3 Fullscreen Power Menu for Dank Material Shell.
- Support for Lock, Sleep, Restart DMS, Reboot, Log Out, and Power Off commands.
- Quick keyboard shortcuts (`L`, `S`, `D`, `R`, `X`, `P`).
- IPC handlers for external triggers (`dms ipc call fullscreenPowerMenu toggle`).
