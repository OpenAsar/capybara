import os
import osproc
import strutils

echo "capybara v1.0.0"

let params = commandLineParams()

let productName = lastPathPart(getAppDir())
if params.find("--uninstall") != -1:
  echo "deleting registry values..." # these registry deletes are somewhat discord-specific but also somewhat general
  discard execCmd("reg.exe delete HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run /v " & productName & " /f") # auto run
  discard execCmd("reg.exe delete HKCU\\Software\\Classes\\" & productName.replace("Canary", "").replace("PTB", "").replace("Development", "") & " /f") # protocol
  discard execCmd("reg.exe delete HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\" & productName & " /f") # uninstall program entry

  echo "deleting dirs..." # delete dirs
  removeDir(joinPath(getEnv("appdata"), productName.toLower())) # %appdata%\{lowered product name}

  echo "deleting self... \\o" # launch detached process to remove our own directory as on Windows you can't delete directories with programs (ourself) open
  discard startProcess("cmd.exe", args=["/s", "/c", "rmdir", "/q", "/s", getAppDir()])
  quit(0)

let processStart = params.find("--processStart")
if processStart == -1:
  echo "capybara: minimal replacement for Squirrel's Update.exe for launcher use only - https://github.com/OpenAsar/capybara"
  echo "usage: capybara.exe --processStart [path] (--process-start-args ...)"
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


var app = 0
for kind, path in walkDir(getAppDir()):
  case kind:
  of pcDir:
    let dir = lastPathPart(path)
    if dir.startsWith("app-1.0."):
      let ver = parseInt(dir.replace("app-1.0.", ""))

      if ver > app:
        app = ver

  else:
    discard


let dir = joinPath(getAppDir(), "app-1.0." & $app)
echo "Starting ", joinPath(dir, exeName)
discard startProcess(joinPath(dir, exeName), workingDir=dir, args=argsToGive, options={poParentStreams, poEvalCommand})