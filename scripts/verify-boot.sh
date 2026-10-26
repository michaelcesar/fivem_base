#!/usr/bin/env bash
#
# Checks whether the last server boot was healthy, and exits non-zero if it was not.
#
# "It looked fine when I grepped it" is the kind of verification that fails exactly when
# someone is tired. This encodes what healthy actually means, including the traps:
#   - `Authenticated with cfx.re Nucleus` appears even when the database is unreachable
#     and every resource failed to load, so it proves nothing on its own.
#   - Starting FXServer from the wrong working directory boots an empty server that still
#     authenticates. `couldn't find resource` is how that shows up.
#
# Usage: scripts/verify-boot.sh [path-to-log]

set -uo pipefail

LOG="${1:-/d/island/fxserver_boot.log}"

RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RESET=$'\033[0m'
failures=0

fail() { printf '%sFAIL%s  %s\n' "$RED" "$RESET" "$1"; failures=$((failures + 1)); }
pass() { printf '%s ok %s  %s\n' "$GREEN" "$RESET" "$1"; }
warn() { printf '%swarn%s  %s\n' "$YELLOW" "$RESET" "$1"; }

if [[ ! -f "$LOG" ]]; then
  fail "boot log not found: $LOG"
  exit 1
fi

# Strip ANSI colour so patterns match the text rather than the escape codes.
plain="$(sed -r 's/\x1b\[[0-9;]*m//g' "$LOG")"

# --- required signals -------------------------------------------------------------

if grep -qi "Database server connection established" <<< "$plain"; then
  pass "database connected"
else
  fail "database never connected - is MariaDB running?"
fi

expected_resources=(lite_lib lite_crosshair lite_shootingrange lite_tools lite_zones lite_jobs qbx_core ox_lib ox_inventory)
for resource in "${expected_resources[@]}"; do
  if grep -qE "Started resource ${resource}\b" <<< "$plain"; then
    pass "started ${resource}"
  else
    fail "resource did not start: ${resource}"
  fi
done

# --- failure signals --------------------------------------------------------------

if missing="$(grep -oiE "couldn't find resource [^ ]+" <<< "$plain" | sort -u)"; [[ -n "$missing" ]]; then
  fail "unresolved resources (wrong working directory?):"
  sed 's/^/        /' <<< "$missing"
else
  pass "no unresolved resources"
fi

if errors="$(grep -iE "SCRIPT ERROR|attempt to index|attempt to call|attempt to compare" <<< "$plain")"; [[ -n "$errors" ]]; then
  fail "script errors in log:"
  sed 's/^/        /' <<< "$errors" | head -20
else
  pass "no script errors"
fi

if grep -qi "ECONNREFUSED" <<< "$plain"; then
  fail "connection refused - a dependency was unreachable during boot"
else
  pass "no refused connections"
fi

# Errors our own resources reported from the client, which reach nowhere else.
if client_errors="$(grep -E "\[lite_lib\] client error" <<< "$plain")"; [[ -n "$client_errors" ]]; then
  warn "client-side errors were reported during this session:"
  sed 's/^/        /' <<< "$client_errors" | head -10
fi

# --- result -----------------------------------------------------------------------

echo
if (( failures > 0 )); then
  printf '%s%d check(s) failed.%s\n' "$RED" "$failures" "$RESET"
  exit 1
fi

printf '%sBoot is healthy.%s\n' "$GREEN" "$RESET"
