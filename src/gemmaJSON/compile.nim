import std/os
import std/strformat
import std/compilesettings
import osproc
import pathutils
import options

const cacheDir         = compilesettings.querySetting(nimcacheDir)
const outDir           = compilesettings.querySetting(outDir)
const curSrcPath       = currentSourcePath.parentDir

echo "cacheDir: "      , cacheDir
echo "outDir: "        , outDir
echo "curSrcPath: "    , curSrcPath

let gemmasimdjsonc_cpp = newStrictFile curSrcPath / "gemmasimdjsonc.cpp" 
let simdjson_cpp       = newStrictFile curSrcPath / "simdjson.cpp"

let gemmasimdjsonc_o   = newStrictFile cacheDir / "gemmasimdjsonc.o" 
let simdjson_o         = newStrictFile cacheDir / "simdjson.o"

if not gemmasimdjsonc_cpp.ok:
  echo fmt"gemmasimdjsonc.cpp not found! It should be in {curSrcPath}/gemmasimdjsonc.cpp"
  quit(1)

if not simdjson_cpp.ok:
  echo fmt"simdjson.cpp not found in {curSrcPath}/simdjson.cpp"
  quit(1)

proc shell_execute(cmd :string) : tuple[output: string, exitCode: int] =
  var full_command = ""

  when defined(windows):
    full_command = &"powershell -c {$cmd}"
    return execCmdEx full_command
  
  elif defined(linux):
    full_command = &"sh -c \"{$cmd}\" "
    return execCmdEx full_command
  
  elif defined(macosx):
    full_command = &"sh -c \"{$cmd}\" "
    return execCmdEx full_command

  else:
    {.fatal: "OS not supported".}
    echo "OS not supported"
    quit(1)

var 
  output   : string
  exitCode : int

proc mk_cache_dir() =
  # Create cache dir if it doesn't exist
  when defined(windows):
    (output, exitCode) = shell_execute(&"""New-Item -Path "{cacheDir}" -ItemType Directory -Force""")
  else:
    (output, exitCode) = shell_execute(&"""mkdir -p {cacheDir}""")

  echo ""
  echo "Creating cacheDir..."
  echo "output: ", output
  echo "exitCode: ", exitCode
  if exitCode != 0:
    echo fmt"Failed to create cacheDir at {cacheDir}"
    echo ""
    quit(1)
  else:
    echo fmt"Successfully created cacheDir at {cacheDir}"
    echo ""

proc compile_cpp() =
  var check_if_gcc_installed = ""

  # Compile C++ files
  when defined(windows):
    check_if_gcc_installed = "if ((Get-Command g++ -ErrorAction SilentlyContinue) -eq $null) { exit 1 }"
    (output, exitCode)     = shell_execute(check_if_gcc_installed)
    if exitCode != 0:
      echo "g++ not found. Please install g++"
      quit(1)

    (output, exitCode) = shell_execute(&"""cd {cacheDir} ; g++ -fpic -c -O3 {$gemmasimdjsonc_cpp.val.get} {$simdjson_cpp.val.get} """)
  elif defined(linux):
    
    #  This checks if g++ is in the path and redirects both standard output and standard error to /dev/null.
    check_if_gcc_installed = "which g++ >/dev/null 2>&1"
    (output, exitCode) = shell_execute(check_if_gcc_installed)
    if exitCode != 0:
      echo "g++ not found. Please install g++"
      quit(1)

    (output, exitCode) = shell_execute(&"""cd {cacheDir} ; g++ -fpic -c -O3 {$gemmasimdjsonc_cpp.val.get} {$simdjson_cpp.val.get} """)
  elif defined(macosx):
    (output, exitCode) = shell_execute(&"""cd {cacheDir} ; clang++ -c -O3 {$gemmasimdjsonc_cpp.val.get} {$simdjson_cpp.val.get} -std=c++11""")

  echo "compiling C++ files..."
  echo "output: "   , output
  echo "exitCode: " , exitCode
  if exitCode != 0:
    echo "Failed to compile C++ files"
    quit(1)
  else:
    echo "C++ files compiled"

if not gemmasimdjsonc_o.ok or not simdjson_o.ok:
  mk_cache_dir()  
  compile_cpp()
else:
  echo "C++ files already compiled"

{.passC: &"-I{curSrcPath}/" .}
{.passL: &"{cacheDir}/gemmasimdjsonc.o {cacheDir}/simdjson.o".}

when defined(windows):
  {.passL: "-lstdc++" .}
elif defined(linux):
  {.passL: "-lstdc++" .}
elif defined(macosx):
  {.passL: "-lc++" .}
