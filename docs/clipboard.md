# Clipboard History (Ringboard)

Clipboard manager that persists history across reboots, supports regex search, and handles images and binary content.

## Services

Two systemd user services run automatically after login:

| Service | Role |
|---|---|
| `ringboard-server` | Backend database daemon |
| `ringboard-wayland` | Captures every clipboard write on Wayland |

Check status:
```
systemctl --user status ringboard-server ringboard-wayland
```

## Opening the UI

**Keyboard shortcut:** `Mod+V` — toggles the egui window open/closed.

Closing the window sends it to the background (no re-init delay on next open). To kill it entirely: `pkill ringboard-egui`.

## egui Keybindings

| Key | Action |
|---|---|
| `Enter` | Paste selected entry |
| `Ctrl+N` | Paste the Nth entry directly |
| `Space` or right-click | View entry details |
| `/` | Enter search mode |
| `Alt+X` | Toggle regex search |
| `Alt+M` | Filter by MIME type |
| `Ctrl+R` | Manually refresh the database |

## CLI

```bash
# List recent entries
ringboard list

# Search (plain text)
ringboard search "some text"

# Search with regex
ringboard search --regex "https?://.*"

# Migrate from another clipboard manager
ringboard migrate gch              # Gnome Clipboard History
ringboard migrate g-paste          # GPaste
ringboard migrate clipboard-indicator
```

## Troubleshooting

```bash
# Restart both services
systemctl --user restart ringboard-server ringboard-wayland

# Watch live logs
journalctl --user -fu ringboard-server
journalctl --user -fu ringboard-wayland
```
