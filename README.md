# Servidor

FiveM roleplay server built on the QBox framework (`qbx_core`).

## Stack

| Layer | Technology |
|---|---|
| Game server | FXServer (downloaded separately, not vendored — see `/fxserver/` in `.gitignore`) |
| Framework | QBox (`qbx_core`) |
| Scripting | Lua, own resources under the `srv_*` prefix |
| Database | MariaDB |
| OS | Windows (developed and run locally) |

## Local setup

```bash
# 1. Copy the example config and fill in your licence key and database credentials.
#    server.cfg is gitignored — never commit it.
cp server-data/server.cfg.example server-data/server.cfg

# 2. Start MariaDB and FXServer pointed at server-data/.

# 3. After a start or restart, check the boot log for errors.
scripts/verify-boot.sh
```

## Scripts

| Script | What it does |
|---|---|
| `scripts/install-hooks.sh` | Installs the local git hooks (`pre-commit` → `scripts/pre-commit.sh`, `pre-push` → `scripts/ci-local.sh`). Run once per clone. |
| `scripts/pre-commit.sh` | Secrets scan, leftover-diagnostics scan, entity-deletion correctness, vendored-resource reminder, Lua static analysis — against the staged changes. |
| `scripts/ci-local.sh` | The same checks as `scripts/pre-commit.sh`, run against the whole tracked tree — same jobs as `.github/workflows/ci.yml`, run locally before a push leaves this machine. |
| `scripts/verify-boot.sh` | Checks the FXServer boot log for errors after a start or restart. |

## Local CI (git hooks)

```bash
scripts/install-hooks.sh
```

Installs `pre-commit` (runs `scripts/pre-commit.sh` against every staged change before it's
allowed into a commit) and `pre-push` (runs `scripts/ci-local.sh` — the same checks as
`.github/workflows/ci.yml` — against the whole tracked tree before a push is allowed to leave
this machine). Bypass either one-off with `git commit --no-verify` / `git push --no-verify`.

## CI (GitHub Actions)

There's no build step or network service to run in CI here — `.github/workflows/ci.yml` re-runs
the same checks as `scripts/pre-commit.sh`, scoped to the whole tracked tree instead of just the
staged diff, as a second line of defence behind the local hook: committed secrets, leftover
diagnostics, local-entity-deletion correctness, Lua static analysis (best effort — the runner
doesn't have `lua-language-server` preinstalled), and a non-blocking reminder about vendored
resource edits.

## Documentation

Project rules, architecture, conventions and the decision log are internal documentation and
are not published in this repository.
