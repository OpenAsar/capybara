# capybara
Minimal replacement for Squirrel's Update.exe for launcher use only.

## Usage

### Process Start
Capybara will run whatever path you give it in the latest app-1.0.X directory in the directory it's in. For example, if you had the directories:
- `app-1.0.0`
- `app-1.0.15`

With each containing your main exe, `Capy.exe`. You would use Capybara via: `.\capybara.exe --processStart Capy.exe`, which would launch `app-1.0.15\Capy.exe` as it's the latest directory.

You can also pass your exe args with `--process-start-args ...` at the end.

### Uninstall
Capybara also provides uninstalling via `--uninstall`. Values to delete and determined from the product name, gotten from the name of the folder it is in (eg: if it's in `Capy\capybara.exe`, it'll use product name `Capy`). This will automatically try to delete:
- Registry values:
  - Auto run / run on startup (HKCU\Software\Microsoft\Windows\CurrentVersion\Run > {product name})
  - Protocol (HKCU\Software\Classes\\{product name})
  - Uninstall program entry (HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\\{product name})
- Directories:
  - `%appdata%\\{lowercase product name}`
  - Own directory (directory containing itself)


## Implemented

- [X] `--processStart`
- [X] `--process-start-args`
- [X] `--uninstall`