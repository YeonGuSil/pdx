# Installing

[← Documentation](README.md)

> **Demo.** No PDX release has been published yet. `install.sh` checks that the installation flow works on your
> machine and installs a placeholder `pdx` command. The placeholder is not PDX.

PDX runs on macOS and Linux (`x86_64`, `arm64`). Windows is not supported yet.

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

## What the demo installer does

1. Detects your operating system and architecture, and stops on one that is not supported.
2. Creates `~/.pdx/bin` (or `$PDX_HOME/bin`).
3. Writes a placeholder `pdx` command there and runs it once to check that it starts.
4. Prints the line to add to your shell's `PATH`.

It downloads nothing, sends nothing, and does not edit your shell profile. If a `pdx` that is not the placeholder is
already at that path, the installer leaves it alone and stops.

## Another directory

```sh
curl -fsSL https://raw.githubusercontent.com/YeonGuSil/pdx/main/install.sh | PDX_HOME="$HOME/pdx-demo" sh
```

| variable | effect | default |
| --- | --- | --- |
| `PDX_HOME` | the installation directory | `~/.pdx` |

## Checking the installation

Add the printed line to your shell profile (`~/.zshrc`, `~/.bashrc`), open a new terminal, then:

```sh
pdx --version    # pdx 0.0.0-demo
pdx              # says that the installer works on this machine
```

## Uninstalling

```sh
curl -fsSL https://raw.githubusercontent.com/YeonGuSil/pdx/main/install.sh | sh -s -- --uninstall
```

or, with the script on disk, `sh install.sh --uninstall`. Only the placeholder is removed; then remove the `PATH`
line you added.

## Troubleshooting

| message | what to do |
| --- | --- |
| `unsupported operating system` / `unsupported architecture` | this platform is not supported yet |
| `already exists and is not the demo placeholder` | another `pdx` is installed there; set `PDX_HOME` to another directory |
| `cannot create …` | you cannot write to that directory; set `PDX_HOME` to one you can |
| `pdx: command not found` | add the printed `PATH` line to your shell profile and open a new terminal |

## The released installer

From the first release the same command installs PDX itself: it downloads the release for your platform, verifies
the release's signature and the archive's digest before unpacking anything, and has no option that skips the
verification.
