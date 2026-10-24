# QRes

QRes is a small freeware utility that automates screen mode changes. It switches color depth and screen resolution when you start an application and switches back when the application closes. This is handy for older games and programs that need a specific mode, without the user having to know which one.

Written by Berend Engelbrecht (1997–2005) and originally distributed by Software Cave. The source code was released as open source in 2005 (version 1.0.9.7). Original project page: <https://qres.sourceforge.net/>

## Features

- Switches screen mode automatically when an application starts and restores the regular mode afterwards
- Front end for QuickRes on Windows 95 and 98
- Changes resolution directly on Windows NT, 2000 and XP, without QuickRes
- Configuration Wizard (`QResCfg.exe`) for changing Start Menu entries or Desktop icons
- QRes property page added to the Windows shortcut property sheet (`qresprop.dll`)
- `/R` option restores desktop icon positions after the original resolution returns
- Windows help file

## Components

| Directory | Output | Description |
|-----------|--------|-------------|
| `qreslib` | static lib | Core library (ANSI C, Win32 API) |
| `qres32` | `qres32.dll` | Screen mode filter / helper DLL |
| `qres` | `qres.exe` | Command-line launcher that switches mode around an application |
| `qrescd` | `qrescd.exe` | CD-launcher variant |
| `qresprop` | `qresprop.dll` | Shell extension adding the QRes property page |
| `QResCfg` | `QResCfg.exe` | MFC configuration wizard |

## Download

Pre-built 32-bit binaries are attached to each [release](../../releases), and every CI run uploads them as the `qres-win32` artifact.

## Using QRes with Sunshine

[Sunshine](https://github.com/LizardByte/Sunshine) can run commands when a streaming session starts and ends. QRes can match the host display to the client's resolution and refresh rate. In the Sunshine web UI, open the application's **Command Preparations** and add an entry:

**Do:**

```
cmd /C <qres path>\QRes.exe X=%SUNSHINE_CLIENT_WIDTH% Y=%SUNSHINE_CLIENT_HEIGHT% F=%SUNSHINE_CLIENT_FPS%
```

**Undo** (set this to your normal desktop mode, e.g. 2560x1440 at 144 Hz):

```
cmd /C <qres path>\QRes.exe X=2560 Y=1440 F=144
```

Notes:

- Numeric options use `=` (`X=1920`, or `/X=1920`), not `:`. A token starting with `/` is read as a list of flags, so `/X:1920` fails with an "Unknown option" dialog.
- `F=` is the refresh rate in Hz. `/R` is **not** the refresh rate: it is a flag that restores the original mode (and desktop icon positions) after a launched application exits.
- Without an application after the options, QRes switches the mode and exits. It does not switch back by itself, so the undo command is needed.
- The display must offer exactly the requested width, height and refresh rate. Otherwise QRes shows a "Screen mode not found" dialog, which blocks until someone closes it, which is a problem in an unattended session.
- The command line has not been tested with Sunshine yet. It is based on reading the argument parser in `qreslib/qreslib2.c`.

### Sunshine environment variables

Sunshine sets these variables for the commands it runs. Only the first three are useful for QRes:

| Variable | Meaning | Use with QRes |
|----------|---------|---------------|
| `SUNSHINE_CLIENT_WIDTH` | Width requested by the client (int) | `X=` |
| `SUNSHINE_CLIENT_HEIGHT` | Height requested by the client (int) | `Y=` |
| `SUNSHINE_CLIENT_FPS` | FPS requested by the client (int) | `F=` (refresh rate in Hz) |
| `SUNSHINE_APP_ID`, `SUNSHINE_APP_NAME` | App ID / name | Not used by QRes |
| `SUNSHINE_CLIENT_NAME` | Client name assigned during pairing | Not used by QRes |
| `SUNSHINE_CLIENT_HDR` | HDR enabled by the client (true/false) | Not used. QRes does not change HDR |
| `SUNSHINE_CLIENT_GCMAP` | Requested gamepad mask (bitfield) | Not used by QRes |
| `SUNSHINE_CLIENT_HOST_AUDIO` | Client requested host audio (true/false) | Not used by QRes |
| `SUNSHINE_CLIENT_ENABLE_SOPS` | Client requested game optimization for streaming (true/false) | Not used by QRes |
| `SUNSHINE_CLIENT_AUDIO_CONFIGURATION` | Requested audio layout (2.0/5.1/7.1) | Not used by QRes |

Because the width, height and FPS come straight from the client, a client that asks for a mode the host display does not offer (for example a phone's native resolution) makes QRes show the "Screen mode not found" dialog. Prefer client settings that match a mode your display supports.

## Building

CI builds with MSVC via [`build.ps1`](build.ps1) (see [`.github/workflows/build.yml`](.github/workflows/build.yml)). To build locally, run it from an x86 Visual Studio developer prompt:

```powershell
./build.ps1   # output in dist/
```

The original Visual C++ 6.0 / .NET 2003 and Borland C++ Builder project files are still included, see [`readme-build.txt`](readme-build.txt) for those and for deployment notes.

## Releasing

Pushing any tag, e.g. `git tag 1.0.9.8 && git push origin 1.0.9.8`, builds the project and publishes `qres-win32.zip` as a GitHub release.

## License

BSD-style open source license, free for private and commercial use. See [`license.txt`](license.txt). Copyright (c) 1997–2005 Berend Engelbrecht.
