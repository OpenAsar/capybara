import os
import osproc
import strutils
import sequtils
import winim/mean

if AttachConsole(-1).bool: # fix stdout in already opened cmd when compiling as a gui app
  discard stdout.reopen("CONOUT$", fmWrite)

echo "capybara v3.0.0"

let params = commandLineParams()

let productName = lastPathPart(getAppDir()) # name constants derived from parent directory name
let pureName = productName.replace("Canary", "").replace("PTB", "").replace("Development", "")
let spacedName = productName.replace("Canary", " Canary").replace("PTB", " PTB").replace("Development", " Development")
let companyName = pureName & " Inc"

let startShortcutPath = joinPath(getEnv("appdata"), "Microsoft\\Windows\\Start Menu\\Programs", companyName, spacedName & ".lnk") # start menu entry
let desktopShortcutPath = joinPath(getEnv("userprofile"), "Desktop", spacedName & ".lnk") # desktop shortcut

if params.find("--uninstall") != -1:
  echo "deleting registry values..." # these registry deletes are somewhat discord-specific but also somewhat general
  discard execCmd("reg.exe delete HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run /v " & productName & " /f") # auto run
  discard execCmd("reg.exe delete HKCU\\Software\\Classes\\" & pureName & " /f") # protocol
  discard execCmd("reg.exe delete HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\" & productName & " /f") # uninstall program entry

  echo "deleting dirs..." # delete dirs
  removeDir(joinPath(getEnv("appdata"), productName.toLower())) # %appdata%\{lowered product name}

  echo "deleting shortcuts..." # delete shortcuts
  removeFile(startShortcutPath) # start menu entry
  removeFile(desktopShortcutPath) # desktop shortcut

  echo "deleting own dir... \\o" # launch detached process to remove our own directory as on Windows you can't delete directories with programs (ourself) open
  discard startProcess("cmd.exe", args=["/s", "/c", "rmdir", "/q", "/s", getAppDir()])
  quit(0)


var app = newSeq[int]() # find latest app- dir
for kind, path in walkDir(getAppDir()):
  case kind:
  of pcDir:
    let dir = lastPathPart(path)
    if dir.startsWith("app-"):
      let ver = dir.replace("app-", "").split(".").map(parseInt) # app-1.2.3 -> [1, 2, 3]

      for i in (0..ver.len-1): # check if version is newer following semver
        if i >= app.len: app.add(0) # fix oob by defaulting to 0

        if ver[i] > app[i]:
          app = ver
          break
        elif app[i] > ver[i]: break

  else:
    discard

let dir = joinPath(getAppDir(), "app-" & $app.join("."))

let createShortcut = params.find("--createShortcut")
if createShortcut != -1:
  let exeName = params[createShortcut + 1] # exe path to link to

  var ico = "" # optional ico to use
  let setupIcon = params.find("--setupIcon")
  if setupIcon != -1:
    ico = params[params.find("--setupIcon") + 1]

  createDir(joinPath(startShortcutPath, "..")) # create dir to shortcut

  discard execCmd("powershell \"$s=(New-Object -COM WScript.Shell).CreateShortcut('" & startShortcutPath & "');$s.TargetPath='" & joinPath(dir, exeName) & (if ico != "": ("';$s.IconLocation='" & $ico) else: "") & "';$s.WorkingDirectory='" & dir & "';$s.WindowStyle=1;$s.Save()\"") # use powershell because apparently that's what everyone does

  echo "created start menu shortcut at: ", startShortcutPath
  quit(0)

let removeShortcut = params.find("--removeShortcut")
if removeShortcut != -1:
  removeFile(startShortcutPath)
  echo "deleted start menu shortcut at: ", startShortcutPath
  quit(0)


let processStart = params.find("--processStart")
if processStart == -1:
  echo "capybara: minimal replacement for Squirrel's Update.exe for launcher use only - https://github.com/OpenAsar/capybara"
  echo "usage you probably want: capybara.exe --processStart [path] (--process-start-args ...)"
  echo "eg: capybara.exe --processStart " & productName & ".exe"
  quit(0)

let exeName = params[processStart + 1]

var argsToGive = newSeq[string]()
var addingArgs = false

for arg in params:
  if addingArgs:
    argsToGive.add(arg)

  if arg == "--process-start-args":
    addingArgs = true

echo "Starting ", joinPath(dir, exeName)
discard startProcess(joinPath(dir, exeName), workingDir=dir, args=argsToGive, options={poParentStreams, poEvalCommand})