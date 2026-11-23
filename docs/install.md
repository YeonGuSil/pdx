# Installing

[← Documentation](README.md)

> **Demo.** No PDX release has been published yet. `install.sh` and `install.ps1` check that the installation flow
> works on your machine and install a placeholder `pdx` command. The placeholder is not PDX.

| platform | installer | architectures |
| --- | --- | --- |
| macOS, Linux | [`install.sh`](#install-script) | `x86_64`, `arm64` |
| Windows 10, 11 | [`install.ps1`](#windows-powershell) (Windows PowerShell 5.1 or PowerShell 7) | `x86_64`, `arm64` |

The demo installers run on all of these. Which platforms PDX releases are built for is announced with the first
release.

## Install script

```sh
curl -fsSL https://raw.githubusercontent.com/YeonGuSil/pdx/main/install.sh | sh
```

To read the script before running it:

```sh
curl -fsSL https://raw.githubusercontent.com/YeonGuSil/pdx/main/install.sh -o install.sh
less install.sh
sh install.sh
```

## Windows (PowerShell)

In PowerShell:

```powershell
irm https://raw.githubusercontent.com/YeonGuSil/pdx/main/install.ps1 | iex
```

To read the script before running it:

```powershell
irm https://raw.githubusercontent.com/YeonGuSil/pdx/main/install.ps1 -OutFile install.ps1
notepad install.ps1
powershell -ExecutionPolicy Bypass -File install.ps1
```

`-ExecutionPolicy Bypass` applies to that one run only; it does not change your execution policy. The piped form
needs no policy change. An error from the piped form is reported in the window and does not close it.

The demo installs `%USERPROFILE%\.pdx\bin\pdx.cmd` and prints one line that adds that directory to your user `PATH`:

```powershell
[Environment]::SetEnvironmentVariable('Path', "$env:USERPROFILE\.pdx\bin;" + [Environment]::GetEnvironmentVariable('Path', 'User'), 'User')
```

Run it once, open a new terminal, and `pdx --version` works in PowerShell and in Command Prompt.

## What the demo installer does

1. Detects your operating system and architecture, and stops on one that is not supported.
2. Creates `~/.pdx/bin` (Windows: `%USERPROFILE%\.pdx\bin`), or `bin` under `PDX_HOME`.
3. Writes a placeholder `pdx` command there (Windows: `pdx.cmd`) and runs it once to check that it starts.
4. Prints the line that puts that directory on your `PATH`.

It downloads nothing, sends nothing, and does not edit your shell profile or your `PATH`. If a `pdx` that is not the
placeholder is already at that path (on Windows also a `pdx.exe`), the installer leaves it alone and stops.

## Another directory

```sh
curl -fsSL https://raw.githubusercontent.com/YeonGuSil/pdx/main/install.sh | PDX_HOME="$HOME/pdx-demo" sh
```

Windows:

```powershell
$env:PDX_HOME = "$env:USERPROFILE\pdx-demo"; irm https://raw.githubusercontent.com/YeonGuSil/pdx/main/install.ps1 | iex
```

| variable | effect | default |
| --- | --- | --- |
| `PDX_HOME` | the installation directory | `~/.pdx` (Windows: `%USERPROFILE%\.pdx`) |

## Checking the installation

Add the printed line to your shell profile (`~/.zshrc`, `~/.bashrc`) or, on Windows, run it once; open a new
terminal, then:

```sh
pdx --version    # pdx 0.0.0-demo
pdx              # says that the installer works on this machine
```

## Uninstalling

```sh
curl -fsSL https://raw.githubusercontent.com/YeonGuSil/pdx/main/install.sh | sh -s -- --uninstall
```

or, with the script on disk, `sh install.sh --uninstall`.

Windows:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/YeonGuSil/pdx/main/install.ps1))) -Uninstall
```

or, with the script on disk, `powershell -ExecutionPolicy Bypass -File install.ps1 -Uninstall`.

Only the placeholder is removed; then remove the `PATH` entry you added (Windows: *Settings → System → About →
Advanced system settings → Environment Variables*, user `Path`).

## Troubleshooting

| message | what to do |
| --- | --- |
| `unsupported operating system` / `unsupported architecture` | this platform is not supported yet |
| `on Windows use install.ps1` | `install.sh` was run in Git Bash or a similar shell; use the PowerShell command above |
| `this installer is for Windows` | `install.ps1` was run in PowerShell on macOS or Linux; use `install.sh` |
| `running scripts is disabled on this system` | run the file with `powershell -ExecutionPolicy Bypass -File install.ps1`, or use the piped form |
| `already exists and is not the demo placeholder` | another `pdx` is installed there; set `PDX_HOME` to another directory |
| `cannot create …` | you cannot write to that directory; set `PDX_HOME` to one you can |
| `pdx: command not found` / `'pdx' is not recognized` | add the printed `PATH` line (Windows: run it) and open a new terminal |

## The released installer

From the first release the same commands install PDX itself: it downloads the release for your platform, verifies
the release's signature and the archive's digest before unpacking anything, and has no option that skips the
verification.
