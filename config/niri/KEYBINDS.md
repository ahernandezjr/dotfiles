# Niri Keybind Schema Documentation

This document outlines the logical organization of hotkeys following the Omarchy-inspired format.

## Schema Logic

| Modifier | Category | Description |
| :--- | :--- | :--- |
| **Super (MOD)** | **System** | Core OS and Window Manager functions. |
| **Super + Shift** | **Movement** | Movement of windows, columns, and workspaces. |
| **Super + Alt** | **Programs** | Launching applications and custom tools. |
| **Super + Shift + Alt** | **Monitor** | Cross-monitor movement and management. |

## Key Hotkeys

### System (Super + Any)
- `MOD + Return`: Terminal (Ghostty)
- `MOD + Space`: Launcher (Noctalia)
- `MOD + V`: Clipboard History
- `MOD + W`: Close Window
- `MOD + 1-9`: Focus Workspace

### Programs (Super + Alt + Any)
- `MOD + Alt + B`: Browser (Brave)
- `MOD + Alt + F`: File Manager (Nautilus)
- `MOD + Alt + Y`: File Manager (Yazi)
- `MOD + Alt + T`: System Monitor (btop)
- `MOD + Alt + N`: Editor (Neovim)
- `MOD + Alt + Space`: Nyx Menu (Proposed)

### Movement (Super + Shift + Any)
- `MOD + Shift + HJKL/Arrows`: Move Window/Column
- `MOD + Shift + 1-9`: Move to Workspace

### QoL Features
- `MOD + Ctrl + Print`: OCR to Clipboard (via grim/slurp/tesseract)
- `MOD + Ctrl + Space`: Wallpaper Selector
