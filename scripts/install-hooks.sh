#!/usr/bin/env bash
#
# Installs the repository's git hooks. Hooks live in .git/hooks, which is not versioned,
# so every clone has to run this once.

set -euo pipefail

root="$(git rev-parse --show-toplevel)"
hooks="$root/.git/hooks"

mkdir -p "$hooks"

cat > "$hooks/pre-commit" <<'HOOK'
#!/usr/bin/env bash
exec "$(git rev-parse --show-toplevel)/scripts/pre-commit.sh"
HOOK

cat > "$hooks/pre-push" <<'HOOK'
#!/usr/bin/env bash
exec "$(git rev-parse --show-toplevel)/scripts/ci-local.sh"
HOOK

chmod +x "$hooks/pre-commit" "$hooks/pre-push"
chmod +x "$root/scripts/pre-commit.sh" "$root/scripts/ci-local.sh" "$root/scripts/verify-boot.sh"

echo "Installed pre-commit hook -> scripts/pre-commit.sh"
echo "Installed pre-push hook -> scripts/ci-local.sh (same checks as .github/workflows/ci.yml)"
