# Builds all QRes binaries (32-bit, release) with cl.exe from an MSVC developer prompt.
# The legacy .vcproj/.dsp files can't be opened by modern MSBuild, so we compile directly.
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$out  = Join-Path $root 'dist'
$obj  = Join-Path $root 'obj'
New-Item -ItemType Directory -Force $out, $obj | Out-Null

$common = '/nologo', '/O2', '/MT', '/W1', '/D', 'WIN32', '/D', 'NDEBUG', '/D', '_WINDOWS', '/D', '_CRT_SECURE_NO_WARNINGS', '/D', '_CRT_NONSTDC_NO_DEPRECATE'

function Run($exe, $argList) {
    & $exe @argList
    if ($LASTEXITCODE -ne 0) { throw "$exe failed (exit $LASTEXITCODE)" }
}
function Rc($dir, $rc, $res) {
    Run 'rc.exe' @('/nologo', '/I', (Join-Path $root 'qreslib'), '/I', $dir, "/fo$res", (Join-Path $dir $rc))
}

# qreslib (static library)
Push-Location (Join-Path $root 'qreslib')
Run 'cl.exe' ($common + '/c', "/Fo$obj\", 'qreslib.c', 'qreslib2.c')
Run 'lib.exe' @('/nologo', "/OUT:$obj\qreslib.lib", "$obj\qreslib.obj", "$obj\qreslib2.obj")
Pop-Location
$lib  = "$obj\qreslib.lib"
$inc  = '/I', (Join-Path $root 'qreslib')

# qres32.dll (+ import lib qres32.lib)
Push-Location (Join-Path $root 'qres32')
Run 'cl.exe' ($common + $inc + '/LD', "/Fo$obj\", "/Fe$out\qres32.dll", 'qres32.c', 'Qres32.res',
    '/link', '/DEF:qres32.def', "/IMPLIB:$obj\qres32.lib", $lib, 'odbc32.lib', 'odbccp32.lib', 'user32.lib', 'gdi32.lib', 'advapi32.lib')
Pop-Location

# qres.exe
Push-Location (Join-Path $root 'qres')
Rc (Get-Location) 'qres.rc' "$obj\qres.res"
Run 'cl.exe' ($common + $inc + "/Fo$obj\", "/Fe$out\qres.exe", 'qres.c', "$obj\qres.res",
    '/link', '/SUBSYSTEM:WINDOWS', $lib, "$obj\qres32.lib", 'odbc32.lib', 'odbccp32.lib', 'user32.lib', 'gdi32.lib', 'comctl32.lib', 'shell32.lib', 'advapi32.lib')
Pop-Location

# qrescd.exe
Push-Location (Join-Path $root 'qrescd')
Rc (Get-Location) 'qrescd.rc' "$obj\qrescd.res"
Run 'cl.exe' ($common + $inc + "/Fo$obj\", "/Fe$out\qrescd.exe", 'qrescd.c', "$obj\qrescd.res",
    '/link', '/SUBSYSTEM:WINDOWS', $lib, 'odbc32.lib', 'odbccp32.lib', 'user32.lib', 'gdi32.lib', 'comctl32.lib', 'shell32.lib', 'advapi32.lib')
Pop-Location

# qresprop.dll (shell property page extension)
Push-Location (Join-Path $root 'qresprop')
Rc (Get-Location) 'qresext.RC' "$obj\qresprop.res"
Run 'cl.exe' ($common + $inc + '/EHsc', '/LD', "/Fo$obj\", "/Fe$out\qresprop.dll",
    'colormode.cpp', 'qresext.cpp', 'qresprop.cpp', 'qrxtinit.cpp', 'Shortcut.cpp', "$obj\qresprop.res",
    '/link', '/DEF:qresext.def', $lib, 'comctl32.lib', 'odbc32.lib', 'odbccp32.lib', 'user32.lib', 'gdi32.lib', 'shell32.lib', 'ole32.lib', 'oleaut32.lib', 'uuid.lib', 'advapi32.lib')
Pop-Location

# QResCfg.exe (MFC, statically linked)
Push-Location (Join-Path $root 'QResCfg')
Rc (Get-Location) 'QResCfg.rc' "$obj\QResCfg.res"
$cfgObj = "$obj\cfg\"
New-Item -ItemType Directory -Force $cfgObj | Out-Null
Run 'cl.exe' ($common + $inc + '/EHsc', "/Fo$cfgObj", "/Fe$out\QResCfg.exe",
    'AdvDlg.cpp', 'colormode.cpp', 'QResCfg.cpp', 'QResPropertyPage1.cpp', 'QResPropertyPage2.cpp', 'QResPropertyPage3.cpp',
    'qrespropertypage4.cpp', 'QResPropertySheet.cpp', 'Shortcut.cpp', 'StdAfx.cpp', "$obj\QResCfg.res",
    '/link', '/SUBSYSTEM:WINDOWS', $lib, 'ole32.lib')
Pop-Location

Copy-Item (Join-Path $root 'license.txt') $out
Copy-Item (Join-Path $root 'QResCfg\hlp\QRES.HLP') $out
Get-ChildItem $out
