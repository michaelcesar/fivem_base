#!/usr/bin/env bash
#
# Pre-commit checks for Server. Install with: scripts/install-hooks.sh
#
# Each check exists because the rule it enforces was already broken by hand, while the
# rule itself sat written down and agreed on. Documentation that relies on remembering is
# weaker than a check that runs whether or not anyone remembered.
#
# Bypass with `git commit --no-verify` when a check is wrong. If you find yourself doing
# that regularly, fix the check instead.

set -uo pipefail

RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RESET=$'\033[0m'
failures=0

fail() { printf '%sFAIL%s  %s\n' "$RED" "$RESET" "$1"; failures=$((failures + 1)); }
pass() { printf '%s ok %s  %s\n' "$GREEN" "$RESET" "$1"; }
warn() { printf '%swarn%s  %s\n' "$YELLOW" "$RESET" "$1"; }

staged="$(git diff --cached --name-only --diff-filter=ACM)"
[[ -z "$staged" ]] && exit 0

# --- 1. Portuguese mirrors move with their English source -------------------------
#
# Only README.md is versioned - CLAUDE.md/AGENTS.md, their .pt.md mirrors and the whole
# docs/ tree are local-only (gitignored) by design, so there is no committed mirror for
# this repo to keep in sync. No-op kept for history; see docs/decisions.md.

pass "documentation mirrors in sync (local-only docs have no mirror to track)"

# --- 2. No leftover diagnostics in our own resources -------------------------------
#
# Temporary instrumentation is expected while chasing a bug and is meant to come out
# afterwards. It has already been left behind once.

diagnostics=""
while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  [[ "$file" != server-data/resources/*/srv_*/*.lua ]] && continue

  hits="$(grep -nE ":server:(trace|debug)|\[(TRACE|DEBUG)\]|TEMPORARY diagnostic" "$file" 2>/dev/null)"
  [[ -n "$hits" ]] && diagnostics+="        $file"$'\n'"$(sed 's/^/          /' <<< "$hits")"$'\n'
done <<< "$staged"

if [[ -n "$diagnostics" ]]; then
  fail "temporary diagnostics still present:"
  printf '%s' "$diagnostics"
else
  pass "no leftover diagnostics"
fi

# --- 3. No real secrets ------------------------------------------------------------
#
# server.cfg holds the licence key and database password and is gitignored; only the
# sanitised example is committed. This catches it being added anyway, or a real value
# being pasted into the example.

secrets="$(git diff --cached -U0 | grep -E '^\+' | grep -EI 'cfxk_[A-Za-z0-9_]{10,}|ServerDb_[A-Za-z0-9_!]+' || true)"

if grep -qx "server-data/server.cfg" <<< "$staged"; then
  fail "server-data/server.cfg is staged - it holds the licence key and DB password"
elif [[ -n "$secrets" ]]; then
  fail "what looks like a real secret is being committed:"
  sed 's/^/        /' <<< "$secrets"
else
  pass "no secrets staged"
fi

# --- 4. Local entities are deleted correctly ---------------------------------------
#
# SetEntityAsMissionEntity(entity, true, ...) on a locally created entity makes the
# following DeleteEntity a silent no-op. Use srv_lib's DeleteLocalEntity.

# A genuinely networked entity (CreateVehicle/CreatePed/CreateObject with isNetwork = true)
# *must* pass true here - for those the claim is correct and DeleteEntity works. The check
# cannot tell the two apart from the call alone, so a hit is forgiven when one of the five
# lines above it states `isNetwork = true`. That keeps the guard strict by default while
# requiring the exception to explain itself in the code rather than in a bypass flag.

bad_delete=""
while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  [[ "$file" != server-data/resources/*/srv_*/*.lua ]] && continue

  file_hits=""
  while IFS= read -r hit; do
    [[ -z "$hit" ]] && continue
    line_no="${hit%%:*}"
    context_start=$(( line_no > 5 ? line_no - 5 : 1 ))

    if sed -n "${context_start},$(( line_no - 1 ))p" "$file" 2>/dev/null \
       | grep -q 'isNetwork = true'; then
      continue
    fi

    file_hits+="$hit"$'\n'
  done <<< "$(grep -nE 'SetEntityAsMissionEntity\([^,]+,\s*true' "$file" 2>/dev/null)"

  if [[ -n "${file_hits//[$'\n']/}" ]]; then
    bad_delete+="        $file"$'\n'"$(sed 's/^/          /' <<< "${file_hits%$'\n'}")"$'\n'
  fi
done <<< "$staged"

if [[ -n "$bad_delete" ]]; then
  fail "local entity claimed as networked - DeleteEntity will silently do nothing:"
  printf '%s' "$bad_delete"
  printf '        use exports.srv_lib:DeleteLocalEntity(entity)\n'
else
  pass "entity deletion looks correct"
fi

# --- 5. Vendored resource edits are recorded ---------------------------------------
#
# Our edits inside third-party resources look exactly like the vendor's own code, and an
# upstream update reverts them silently. docs/patches.md is the local inventory that makes
# them recoverable. docs/ is gitignored now (local-only, like CLAUDE.md), so this check can
# no longer confirm patches.md was staged alongside the change - it just reminds every time,
# since forgetting to write it down locally is what costs, not whether git tracked it.

vendored=""
while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  [[ "$file" != server-data/resources/* ]] && continue
  [[ "$file" == *srv_* ]] && continue
  [[ "$file" == *ox_lib/web/build/* ]] && continue   # generated, covered as a whole

  vendored+="        $file"$'\n'
done <<< "$staged"

if [[ -n "$vendored" ]]; then
  warn "third-party files changed - make sure this is recorded in docs/patches.md:"
  printf '%s' "$vendored"
  printf '        If this is a new patch, record it there (local file, not tracked by git) or it will be lost on the next update.\n'
else
  pass "no vendored resources touched"
fi

# --- 6. Lua static analysis on srv_* resources -------------------------------------
#
# Catches a config key that doesn't exist (`undefined-field`) or a value used without checking
# it isn't nil first (`need-check-nil`) before either ships as a dead thread - the exact class of
# bug this project has shipped before. Scoped to just those two diagnostics, not everything
# lua-language-server can report: the FiveM native stubs (dev/fivem-lls-addon) are close but not
# perfect, and a handful of other diagnostic types have known, accepted false positives in this
# codebase already (Cfx's `+=` syntax, a couple of imprecise native stubs) that would otherwise
# fail every commit permanently. A warning, not a failure, if the tool itself isn't installed -
# not every machine running this hook will have it.

luals_bin=""
for candidate in \
  "${LOCALAPPDATA:-}/Microsoft/WinGet/Packages/LuaLS.lua-language-server_Microsoft.Winget.Source_8wekyb3d8bbwe/bin/lua-language-server.exe" \
  "$(command -v lua-language-server 2>/dev/null)"; do
  if [[ -n "$candidate" && -x "$candidate" ]]; then
    luals_bin="$candidate"
    break
  fi
done

lua_resources=""
while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  [[ "$file" != server-data/resources/*/srv_*/*.lua ]] && continue

  resource="${file%/*}"
  grep -qxF "$resource" <<< "$lua_resources" || lua_resources+="$resource"$'\n'
done <<< "$staged"

if [[ -z "$luals_bin" ]]; then
  if [[ -n "$lua_resources" ]]; then
    warn "lua-language-server not found - skipping static analysis (see dev/fivem-lls-addon)"
  fi
elif [[ -n "$lua_resources" ]]; then
  # Server: the CLI is a native Windows exe - it cannot parse the POSIX-style path git bash's
  # own $PWD gives it (crashes with "canonical: ... path not found"). `pwd -W` is the Windows-
  # style equivalent. Caught live: the crash produced no check.json, which an earlier version of
  # this check silently read as "no findings" and passed - the exact silent-failure shape
  # CLAUDE.md's own rules warn against, on a check meant to catch exactly that in other people's
  # code. Never redirect this run's stderr away again.
  root_win="$(pwd -W)"

  # .luarc.json's `workspace.library` entries are relative, but lua-language-server's --check
  # mode resolves a relative library path against the directory being checked, not the
  # workspace root or --configpath's directory - so they resolve to nothing once --check
  # targets a single resource subfolder, and every type the FiveM stub library
  # (dev/fivem-lls-addon) provides silently disappears, producing bogus undefined-field hits
  # on ordinary vector field access. Resolve them to absolute before handing off the config.
  luarc_resolved="$(mktemp -d)/luarc-resolved.json"
  node -e "
    const fs = require('fs');
    const path = require('path');
    const root = process.argv[1];
    const cfg = JSON.parse(fs.readFileSync('.luarc.json', 'utf8'));
    if (Array.isArray(cfg['workspace.library'])) {
      cfg['workspace.library'] = cfg['workspace.library'].map(
        (p) => (path.isAbsolute(p) ? p : path.join(root, p)),
      );
    }
    fs.writeFileSync(process.argv[2], JSON.stringify(cfg));
  " "$root_win" "$luarc_resolved"

  lua_findings=""
  lua_tool_errors=""

  while IFS= read -r resource; do
    [[ -z "$resource" ]] && continue

    checkdir="$(mktemp -d)"
    check_output="$("$luals_bin" --check="$root_win/$resource" --configpath="$luarc_resolved" \
      --check_format=json --checklevel=Warning --logpath="$checkdir" 2>&1)"

    if [[ ! -f "$checkdir/check.json" ]]; then
      # No file means either a crash (see above) or genuinely zero findings - lua-language-server
      # only omits check.json in the former case, so treat a missing file as a tool failure to
      # report, never as a silent pass.
      lua_tool_errors+="        $resource:"$'\n'"$(sed 's/^/          /' <<< "$check_output")"$'\n'
    else
      hits="$(node -e "
        const fs = require('fs');
        const d = JSON.parse(fs.readFileSync(process.argv[1], 'utf8'));
        const wanted = new Set(['undefined-field', 'need-check-nil']);
        for (const file in d) {
          for (const diag of d[file]) {
            if (!wanted.has(diag.code)) continue;
            const path = decodeURIComponent(file.replace('file:///', ''));
            console.log(path + ':' + (diag.range.start.line + 1) + ': [' + diag.code + '] ' + diag.message.split('\n')[0]);
          }
        }
      " "$checkdir/check.json" 2>/dev/null)"
      [[ -n "$hits" ]] && lua_findings+="$hits"$'\n'
    fi

    rm -rf "$checkdir"
  done <<< "$lua_resources"

  if [[ -n "$lua_tool_errors" ]]; then
    fail "lua-language-server itself failed to run - static analysis did NOT check anything:"
    printf '%s' "$lua_tool_errors"
  elif [[ -n "$lua_findings" ]]; then
    fail "lua-language-server found real issues:"
    sed 's/^/        /' <<< "${lua_findings%$'\n'}"
  else
    pass "lua static analysis clean (undefined-field, need-check-nil)"
  fi
fi

# --- result -----------------------------------------------------------------------

echo
if (( failures > 0 )); then
  printf '%s%d check(s) failed. Commit aborted.%s\n' "$RED" "$failures" "$RESET"
  printf 'Override with: git commit --no-verify\n'
  exit 1
fi

printf '%sPre-commit checks passed.%s\n' "$GREEN" "$RESET"
