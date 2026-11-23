# PDX

**The AI-native workspace.** People and AI agents work under the same Work Contract, results are verified through
Evidence and Gates, and what was done accumulates as your organization's Knowledge. PDX manages the *Work*, not any
particular AI: every person and every model is a replaceable executor.

> **Status: pre-release.** No public release has been published yet. The installer below is a **demo**: it checks
> that the installation flow works on your machine and installs a placeholder `pdx` command, not PDX itself.

## Get started

1. Run the installer (macOS, Linux):

   ```sh
   curl -fsSL https://raw.githubusercontent.com/YeonGuSil/pdx/main/install.sh | sh
   ```

2. Add the line it prints to your shell profile, open a new terminal, and check:

   ```sh
   pdx --version
   ```

Details, another installation directory and removing it: [Installing](docs/install.md).

## What PDX does

| | |
| --- | --- |
| **One contract for people and AI** | A piece of Work starts from an Intent and is frozen as a Work Contract when a person adopts it. Whoever executes it — a person, Claude, Codex, Gemini or another model — works inside the same contract. |
| **Evidence, not trust** | A claim is closed only by evidence the party doing the work does not control. An independent reviewer, preferably of another model family, checks the result. |
| **A person at every gate** | A person adopts the contract, authorizes every external effect, and accepts the result. No agent fills that slot. |
| **Knowledge that stays** | The record is the source. Lessons become your project's rules when a person promotes them. |
| **Vendor neutral** | Every tool, model and backend is a registry entry you can replace. |
| **Local first** | PDX runs on your machine. Secrets stay in a separate guard process; what PDX starts runs under the operating system's sandbox. |

More: [Features](docs/features.md).

## Documentation

- [Installing](docs/install.md)
- [Features](docs/features.md)
- [All documents](docs/README.md)

## License

[`LICENSE.md`](LICENSE.md) — a draft until counsel has reviewed it. PDX is free to use, including for commercial
purposes; a team of 10 or more PDX users requests approval.

## About this repository

This repository is PDX's home page, manual and download site. It holds documents and the installer; binaries will be
attached to [Releases](https://github.com/YeonGuSil/pdx/releases), one per version tag. The source code is not
published here.
