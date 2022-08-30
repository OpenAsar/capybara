import os
import osproc
import strutils

let params = commandLineParams()

if params.find("--uninstall") != -1:
  echo "no" # todo
  quit(0)

let processStart = params.find("--processStart")
if processStart == -1:
  quit(1)

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