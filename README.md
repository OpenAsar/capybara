# capybara
Minimal replacement for Squirrel's `Update.exe` for launcher use only. This is mostly intended for use as transitioning to your own updater from Squirrel, so you can still use the same path/exe (`Update.exe`) like before, but being self contained (just the exe) without requiring any own/Squirrel code/updating/files, but this **does not follow Squirrel spec**/etc. This project is mostly focused on Discord but should apply generally to most apps.

<br>

## Usage

### Process Start
Capybara will run whatever path you give it in the latest app-1.0.X directory in the directory it's in. For example, if you had the directories:
- `app-1.0.0`
- `app-1.0.15`

With each containing your main exe, `Capy.exe`. You would use Capybara via: `.\capybara.exe --processStart Capy.exe`, which would launch `app-1.0.15\Capy.exe` as it's the latest directory.

You can also pass your exe args with `--process-start-args ...` at the end.

### Uninstall
Capybara also provides uninstalling via `--uninstall`. Values to delete are determined from the product name, gotten from the name of the folder it is in (eg: if it's in `Capy\capybara.exe`, it'll use product name `Capy`). This will automatically try to delete:
- Registry values:
  - Auto run / run on startup (`HKCU\Software\Microsoft\Windows\CurrentVersion\Run > {product name}`)
  - Protocol (`HKCU\Software\Classes\{product name}`)
  - Uninstall program entry (`HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\{product name}`)
- Directories:
  - `%appdata%\{lowercase product name}`
  - Own directory (directory containing itself)
- Shortcuts:
  - Start menu (`%appdata%\Microsoft\Windows\Start Menu\Programs\{product name} Inc\{product name with spaces}.lnk`)
  - Desktop (`%userprofile%\Desktop\{product name with spaces}.lnk`)

This does **not** follow the Squirrel spec (passing args to exe/etc), instead being self contained.

### Shortcut Management (Start Menu)
Capybara will create a start menu shortcut given a path (like process start) via `--createShortcut [exePath]` and also optionally given a path to an ico to use for the shortcut with `--setupIcon [icoPath]` (should be absolute). Shortcut path: `%appdata%\Microsoft\Windows\Start Menu\Programs\{product name} Inc\{product name with spaces}.lnk`.

Capybara will remove the start menu shortcut previously created via `--removeShortcut` (no extra args needed for deletion).

<br>

## Implemented

- [X] `--processStart`
- [X] `--process-start-args`
- [X] `--uninstall`
- [X] `--createShortcut`
- [X] `--removeShortcut`
- [X] `--setupIcon`

### Out of Scope

- `--install`
- `--update`
- `--updateOnly`