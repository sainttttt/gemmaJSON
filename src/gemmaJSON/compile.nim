import std/os
import std/strformat
import std/compilesettings

proc sh (cmd :string; dir :string= "") :void=
  ## Executes the given shell command and writes the output to console.
  ## Same as the nimscript version, but usable at compile time in static blocks.
  ## Runs the command from `dir` when specified.
  when defined(windows): {.warning: "running `sh -c` commands on Windows has not been tested".}
  var command :string
  echo "command"
  echo cmd
  if dir != "":  command = &"cd {dir}; " & cmd
  else:          command = cmd
  discard gorgeEx(&"sh -c \"{$command}\"").output

const cacheDir  = compilesettings.querySetting(nimcacheDir)
const outDir  = compilesettings.querySetting(outDir)

const curSrcPath = currentSourcePath.parentDir

# {.passL: &"-L{trgDir}/ -lgemmaJSON".}

static:
  sh(&"""mkdir -p {cacheDir}""")
  when defined(linux):
    sh(&"""g++ -fpic -c {curSrcPath}/gemmasimdjsonc.cpp {curSrcPath}/simdjson.cpp """, cacheDir)
  elif defined(macosx):
    sh(&"""clang++ -c {curSrcPath}/gemmasimdjsonc.cpp {curSrcPath}/simdjson.cpp -std=c++11""", cacheDir)

  # sh(&"""cp {cacheDir}/libgemmaJSON.so {outDir}/""")

{.passC: &"-I{curSrcPath}/" .}
{.passL: &"{cacheDir}/gemmasimdjsonc.o {cacheDir}/simdjson.o".}

when defined(linux):
  {.passL: "-lstdc++" .}
elif defined(macosx):
  {.passL: "-lc++" .}
