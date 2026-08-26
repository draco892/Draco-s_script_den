#!/bin/bash
#
# port_self_update.sh — Refresh and update MacPorts on macOS
# Usage:  ./port_self_update.sh
#
set -euo pipefail

# ── helpers ──────────────────────────────────────────────────────────
info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m[✓]\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }
fail()  { printf '\033[1;31m[✗]\033[0m %s\n' "$*" >&2; exit 1; }

# ── pre-flight checks ────────────────────────────────────────────────
command -v port >/dev/null 2>&1 || fail "MacPorts not found.  Install it from https://www.macports.org/install.php"

if ! id -u -G >/dev/null 2>&1; then
  warn "Running as non-root is fine; sudo will be requested when needed."
fi

# ── 1. Update the ports tree ─────────────────────────────────────────
info "Updating the ports tree (port selfupdate)…"
sudo port selfupdate && ok "Ports tree is up to date."

# ── 2. Show what is outdated ─────────────────────────────────────────
outdated_list="$(port outdated 2>/dev/null || true)"

if [[ -n "$outdated_list" ]]; then
  info "Outdated ports:"
  echo "$outdated_list" | sed 's/^/  /'
else
  ok "No outdated ports found."
fi

# ── 3. Upgrade everything that is outdated ───────────────────────────
if [[ -n "$outdated_list" ]]; then
  info "Upgrading outdated ports…"
  sudo port upgrade outdated && ok "All outdated ports upgraded."
else
  info "Nothing to upgrade, skipping."
fi

# ── 4. Remove inactive (orphaned) ports ──────────────────────────────
inactive_list="$(port inactive 2>/dev/null || true)"

if [[ -n "$inactive_list" ]]; then
  info "Inactive ports that will be removed:"
  echo "$inactive_list" | sed 's/^/  /'
  info "Uninstalling inactive ports…"
  sudo port uninstall inactive && ok "Inactive ports removed."
else
  ok "No inactive ports found."
fi

# ── done ──────────────────────────────────────────────────────────────
ok "All done."
