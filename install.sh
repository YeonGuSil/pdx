#!/bin/sh
# PDX installer (demo) — https://github.com/YeonGuSil/pdx
#
#   curl -fsSL https://raw.githubusercontent.com/YeonGuSil/pdx/main/install.sh | sh
#
# DEMO: no PDX release has been published yet. This script only checks that the installation
# flow works on your machine: it detects the platform, creates the installation directory and
# puts a placeholder `pdx` command there. The placeholder is not PDX. It downloads nothing and
# sends nothing.
#
#   sh install.sh               install the placeholder
#   sh install.sh --uninstall   remove it      (piped: curl … | sh -s -- --uninstall)
#
# Environment:
#   PDX_HOME   where PDX is installed. Default: ~/.pdx

set -eu

DEMO_VERSION="0.0.0-demo"
DEMO_MARK="pdx-demo-placeholder"

say()  { printf '%s\n' "$*"; }
fail() { printf 'pdx install: %s\n' "$*" >&2; exit 1; }

home="${PDX_HOME:-$HOME/.pdx}"
bin="$home/bin"
target="$bin/pdx"

is_demo() { [ -f "$target" ] && grep -q "$DEMO_MARK" "$target" 2>/dev/null; }

# --- uninstall ---------------------------------------------------------------------------------
if [ "${1:-}" = "--uninstall" ]; then
  if is_demo; then
    rm -f "$target"
    rmdir "$bin" 2>/dev/null || true
    rmdir "$home" 2>/dev/null || true
    say "pdx install: the demo placeholder was removed from $target"
  elif [ -e "$target" ]; then
    fail "$target is not the demo placeholder; it was left alone"
  else
    say "pdx install: nothing to remove at $target"
  fi
  exit 0
fi
[ $# -eq 0 ] || fail "unknown option: $1 (the only option is --uninstall)"

# --- platform ----------------------------------------------------------------------------------
os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m)"
case "$os" in
  darwin|linux) ;;
  mingw*|msys*|cygwin*) fail "on Windows use install.ps1 in PowerShell:
  irm https://raw.githubusercontent.com/YeonGuSil/pdx/main/install.ps1 | iex" ;;
  *) fail "unsupported operating system: $os (macOS and Linux are supported)" ;;
esac
case "$arch" in
  x86_64|arm64|aarch64) ;;
  *) fail "unsupported architecture: $arch" ;;
esac
say "pdx install: demo $DEMO_VERSION for $os/$arch"

# --- install -----------------------------------------------------------------------------------
if [ -e "$target" ] && ! is_demo; then
  fail "$target already exists and is not the demo placeholder; it was left alone.
Set PDX_HOME to another directory to try the demo."
fi

mkdir -p "$bin" || fail "cannot create $bin"
cat > "$target" <<EOF
#!/bin/sh
# $DEMO_MARK — written by the PDX demo installer. This is not PDX.
case "\${1:-}" in
  --version|-V|version) echo "pdx $DEMO_VERSION" ;;
  *) echo "pdx $DEMO_VERSION — the installer works on this machine ($os/$arch)."
     echo "This is a placeholder: no PDX release has been published yet."
     echo "Watch https://github.com/YeonGuSil/pdx/releases" ;;
esac
EOF
chmod 755 "$target"

# --- check -------------------------------------------------------------------------------------
got="$("$target" --version 2>/dev/null || true)"
[ "$got" = "pdx $DEMO_VERSION" ] || fail "the installed command did not run: $target"
say "pdx install: installed $target ($got)"

case ":$PATH:" in
  *":$bin:"*) say "pdx install: $bin is already on your PATH — run: pdx" ;;
  *) say "pdx install: add this line to your shell profile, then open a new terminal:"
     say ""
     say "  export PATH=\"$bin:\$PATH\""
     say "" ;;
esac
say "pdx install: to remove the demo: sh install.sh --uninstall"
