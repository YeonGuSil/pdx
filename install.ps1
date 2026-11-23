# PDX installer for Windows (demo) - https://github.com/YeonGuSil/pdx
#
#   irm https://raw.githubusercontent.com/YeonGuSil/pdx/main/install.ps1 | iex
#
# DEMO: no PDX release has been published yet. This script only checks that the installation
# flow works on your machine: it detects the platform, creates the installation directory and
# puts a placeholder `pdx` command there. The placeholder is not PDX. It downloads nothing and
# sends nothing, and it does not change your PATH or any other setting.
#
#   powershell -ExecutionPolicy Bypass -File install.ps1              install the placeholder
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Uninstall   remove it
#   piped:  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/YeonGuSil/pdx/main/install.ps1))) -Uninstall
#
# Environment:
#   PDX_HOME   where PDX is installed. Default: %USERPROFILE%\.pdx
#
# Runs on Windows PowerShell 5.1 and PowerShell 7. A piped run reports errors by throwing, never
# `exit`, so it does not close your PowerShell window; a run from a file exits with status 1.

param([switch]$Uninstall)

& {
  $ErrorActionPreference = 'Stop'
  Set-StrictMode -Version 2

  $DemoVersion = '0.0.0-demo'
  $DemoMark = 'pdx-demo-placeholder'

  function Say([string]$m) { Write-Host "pdx install: $m" }
  function Fail([string]$m) { throw "pdx install: $m" }

  # --- platform --------------------------------------------------------------------------------
  # $IsWindows exists only in PowerShell 6+; Windows PowerShell 5.1 runs on Windows only.
  $onWindows = $true
  if (Test-Path variable:IsWindows) { $onWindows = $IsWindows }
  if (-not $onWindows) {
    Fail 'this installer is for Windows; on macOS and Linux use install.sh'
  }

  $arch = $null
  try {
    $arch = [string][System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
  } catch { }
  if (-not $arch) {
    # A 32-bit process on 64-bit Windows sees x86 here; PROCESSOR_ARCHITEW6432 holds the real one.
    $arch = $env:PROCESSOR_ARCHITEW6432
    if (-not $arch) { $arch = $env:PROCESSOR_ARCHITECTURE }
  }
  if (-not $arch) { Fail 'cannot detect the architecture' }
  switch ($arch.ToUpperInvariant()) {
    { $_ -in 'X64', 'AMD64' } { $arch = 'x86_64'; break }
    'ARM64'                   { $arch = 'arm64'; break }
    default                   { Fail "unsupported architecture: $arch" }
  }

  $home_ = $env:PDX_HOME
  if (-not $home_) { $home_ = Join-Path $env:USERPROFILE '.pdx' }
  $bin = Join-Path $home_ 'bin'
  $target = Join-Path $bin 'pdx.cmd'
  $realExe = Join-Path $bin 'pdx.exe'

  function Test-Demo {
    (Test-Path -LiteralPath $target -PathType Leaf) -and
      [bool](Select-String -LiteralPath $target -SimpleMatch $DemoMark -Quiet)
  }

  # --- uninstall -------------------------------------------------------------------------------
  if ($Uninstall) {
    if (Test-Demo) {
      Remove-Item -LiteralPath $target -Force
      foreach ($d in $bin, $home_) {
        if ((Test-Path -LiteralPath $d) -and -not (Get-ChildItem -LiteralPath $d -Force)) {
          Remove-Item -LiteralPath $d -Force
        }
      }
      Say "the demo placeholder was removed from $target"
    } elseif (Test-Path -LiteralPath $target) {
      Fail "$target is not the demo placeholder; it was left alone"
    } else {
      Say "nothing to remove at $target"
    }
    return
  }

  Say "demo $DemoVersion for windows/$arch"

  # --- install ---------------------------------------------------------------------------------
  if (Test-Path -LiteralPath $realExe) {
    Fail "$realExe already exists; it was left alone. Set PDX_HOME to another directory to try the demo."
  }
  if ((Test-Path -LiteralPath $target) -and -not (Test-Demo)) {
    Fail "$target already exists and is not the demo placeholder; it was left alone. Set PDX_HOME to another directory to try the demo."
  }

  try {
    New-Item -ItemType Directory -Force -Path $bin | Out-Null
  } catch {
    Fail "cannot create $bin"
  }

  $lines = @(
    '@echo off'
    "rem $DemoMark - written by the PDX demo installer. This is not PDX."
    'if /i "%~1"=="--version" goto version'
    'if /i "%~1"=="-V" goto version'
    'if /i "%~1"=="version" goto version'
    "echo pdx $DemoVersion - the installer works on this machine (windows/$arch)."
    'echo This is a placeholder: no PDX release has been published yet.'
    'echo Watch https://github.com/YeonGuSil/pdx/releases'
    'exit /b 0'
    ':version'
    "echo pdx $DemoVersion"
  )
  # cmd.exe needs CRLF; ASCII keeps it free of a byte order mark.
  [System.IO.File]::WriteAllText($target, (($lines -join "`r`n") + "`r`n"), [System.Text.Encoding]::ASCII)

  # --- check -----------------------------------------------------------------------------------
  $got = ''
  try { $got = ((& $target --version) | Out-String).Trim() } catch { }
  if ($got -ne "pdx $DemoVersion") { Fail "the installed command did not run: $target" }
  Say "installed $target ($got)"

  $norm = { param($p) $p.Trim().TrimEnd('\', '/').ToLowerInvariant() }
  $onPath = @($env:PATH -split [System.IO.Path]::PathSeparator | Where-Object { $_ } | ForEach-Object { & $norm $_ }) -contains (& $norm $bin)
  if ($onPath) {
    Say "$bin is already on your PATH - run: pdx"
  } else {
    $quoted = $bin.Replace("'", "''")
    Say 'to put it on your PATH, run this line once, then open a new terminal:'
    Write-Host ''
    Write-Host "  [Environment]::SetEnvironmentVariable('Path', '$quoted;' + [Environment]::GetEnvironmentVariable('Path', 'User'), 'User')"
    Write-Host ''
  }
  Say 'to remove the demo: powershell -ExecutionPolicy Bypass -File install.ps1 -Uninstall'
}
