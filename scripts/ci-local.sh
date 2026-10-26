#!/usr/bin/env bash
#
# Runs the same checks as .github/workflows/ci.yml, locally, over the whole tracked tree.
# Called by the pre-push hook before a push is allowed to leave this machine - the same
# relationship scripts/ci-local.sh has in juscia-api.
#
# Unlike scripts/pre-commit.sh (which only looks at staged files), this scans every
# tracked file, matching what CI will see once the push lands.

set -uo pipefail

RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RESET=$'\033[0m'
failures=0

fail() { printf '%sFAIL%s  %s\n' "$RED" "$RESET" "$1"; failures=$((failures + 1)); }
pass() { printf '%s ok %s  %s\n' "$GREEN" "$RESET" "$1"; }
warn() { printf '%swarn%s  %s\n' "$YELLOW" "$RESET" "$1"; }

root="$(git rev-parse --show-toplevel)"
cd "$root"

# --- secrets --------------------------------------------------------------------
if git ls-files | grep -qx "server-data/server.cfg"; then
  fail "server-data/server.cfg is committed - it holds the licence key and DB password"
else
  secrets_hits="$(git grep -nEI 'cfxk_[A-Za-z0-9_]{10,}|ServerDb_[A-Za-z0-9_!]+' -- . 2>/dev/null || true)"
  if [[ -n "$secrets_hits" ]]; then
    fail "what looks like a real secret is committed:"
    printf '%s\n' "$secrets_hits"
  else
    pass "no committed credentials"
  fi
fi

# --- leftover diagnostics --------------------------------------------------------
diagnostics_hits="$(git grep -nE ':server:(trace|debug)|\[(TRACE|DEBUG)\]|TEMPORARY diagnostic' -- 'server-data/resources/*/srv_*/*.lua' 2>/dev/null || true)"
if [[ -n "$diagnostics_hits" ]]; then
  fail "temporary diagnostics still present:"
  printf '%s\n' "$diagnostics_hits"
else
  pass "no leftover diagnostics"
fi

# --- local entity deletion --------------------------------------------------------
bad_delete=""
while IFS= read -r file; do
  [[ -z "$file" ]] && continue

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
done < <(git ls-files 'server-data/resources/*/srv_*/*.lua')

if [[ -n "$bad_delete" ]]; then
  fail "local entity claimed as networked - DeleteEntity will silently do nothing:"
  printf '%s' "$bad_delete"
  printf '        use exports.srv_lib:DeleteLocalEntity(entity)\n'
else
  pass "entity deletion looks correct"
fi

# --- lua static analysis (best effort, same as CI) --------------------------------
luals_bin=""
for candidate in \
  "${LOCALAPPDATA:-}/Microsoft/WinGet/Packages/LuaLS.lua-language-server_Microsoft.Winget.Source_8wekyb3d8bbwe/bin/lua-language-server.exe" \
  "$(command -v lua-language-server 2>/dev/null)"; do
  if [[ -n "$candidate" && -x "$candidate" ]]; then
    luals_bin="$candidate"
    break
  fi
done

lua_resources="$(git ls-files 'server-data/resources/*/srv_*/*.lua' | xargs -n1 dirname 2>/dev/null | sort -u)"

if [[ -z "$luals_bin" ]]; then
  [[ -n "$lua_resources" ]] && warn "lua-language-server not found - skipping static analysis (CI runs this too, best-effort)"
elif [[ -n "$lua_resources" ]]; then
  root_win="$(pwd -W 2>/dev/null || pwd)"

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
  while IFS= read -r resource; do
    [[ -z "$resource" ]] && continue
    checkdir="$(mktemp -d)"
    "$luals_bin" --check="$root_win/$resource" --configpath="$luarc_resolved" \
      --check_format=json --checklevel=Warning --logpath="$checkdir" >/dev/null 2>&1 || true

    if [[ -f "$checkdir/check.json" ]]; then
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

  if [[ -n "$lua_findings" ]]; then
    fail "lua-language-server found real issues:"
    sed 's/^/        /' <<< "${lua_findings%$'\n'}"
  else
    pass "lua static analysis clean (undefined-field, need-check-nil)"
  fi
fi

# --- vendored resources (reminder only, never fails) -------------------------------
vendored="$(git ls-files 'server-data/resources/*' | grep -v '/srv_' | grep -v 'ox_lib/web/build/' || true)"
if [[ -n "$vendored" ]]; then
  warn "third-party resource files are tracked - make sure local edits are recorded in docs/patches.md"
else
  pass "no vendored resources touched"
fi

echo
if (( failures > 0 )); then
  printf '%s%d check(s) failed. Push aborted.%s\n' "$RED" "$failures" "$RESET"
  printf 'Override with: git push --no-verify\n'
  exit 1
fi

printf '%sLocal CI checks passed.%s\n' "$GREEN" "$RESET"
