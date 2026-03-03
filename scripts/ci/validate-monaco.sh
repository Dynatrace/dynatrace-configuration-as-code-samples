#!/usr/bin/env bash
###############################################################################
# Monaco Dry-Run Validation Script
#
# For every Monaco manifest (manifest*.yaml) in the repo:
#   1. Detect whether it is an environment or account manifest
#   2. Run `monaco deploy --dry-run`  or  `monaco account deploy --dry-run`
#
# The dry-run validates JSON template syntax and config YAML structure
# WITHOUT connecting to any Dynatrace environment (see official docs:
# https://docs.dynatrace.com/docs/deliver/configuration-as-code/monaco/reference/commands-saas).
#
# All auth-related environment variables are set to dummy values so Monaco
# can resolve manifest references without real credentials.
#
# Usage:  bash scripts/ci/validate-monaco.sh
# Requires: monaco CLI in PATH (v2.28.0+)
###############################################################################
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

# ── Dummy environment variables ──────────────────────────────────────
# Monaco resolves env var references in manifests even during dry-run.
# These values are never sent anywhere — dry-run is fully offline.
#
# Instead of maintaining a manual list, we scan ALL Monaco config files
# for env var references and set any unset ones to dummy values.
# This ensures new samples don't break CI without manual updates.

# Auth-related vars that need specific formats (set explicitly)
export DYNATRACE_PLATFORM_TOKEN="${DYNATRACE_PLATFORM_TOKEN:-ci-dummy-token}"
export PLATFORM_TOKEN="${PLATFORM_TOKEN:-ci-dummy-token}"
export API_TOKEN="${API_TOKEN:-ci-dummy-token}"
export DT_API_TOKEN="${DT_API_TOKEN:-ci-dummy-token}"
export DEMO_ENV_TOKEN="${DEMO_ENV_TOKEN:-ci-dummy-token}"
export devToken="${devToken:-ci-dummy-token}"

export OAUTH_CLIENT_ID="${OAUTH_CLIENT_ID:-ci-dummy-client-id}"
export OAUTH_CLIENT_SECRET="${OAUTH_CLIENT_SECRET:-ci-dummy-client-secret}"
export OAUTH_TOKEN_ENDPOINT="${OAUTH_TOKEN_ENDPOINT:-https://sso.dynatrace.com/sso/oauth2/token}"
export CLIENT_ID="${CLIENT_ID:-ci-dummy-client-id}"
export CLIENT_SECRET="${CLIENT_SECRET:-ci-dummy-client-secret}"
export DT_OAUTH_CLIENT_ID="${DT_OAUTH_CLIENT_ID:-ci-dummy-client-id}"
export DT_OAUTH_CLIENT_SECRET="${DT_OAUTH_CLIENT_SECRET:-ci-dummy-client-secret}"
export DYNATRACE_CLIENT_ID="${DYNATRACE_CLIENT_ID:-ci-dummy-client-id}"
export DYNATRACE_SECRET="${DYNATRACE_SECRET:-ci-dummy-client-secret}"
export ACCOUNT_OAUTH_CLIENT_ID="${ACCOUNT_OAUTH_CLIENT_ID:-ci-dummy-client-id}"
export ACCOUNT_OAUTH_CLIENT_SECRET="${ACCOUNT_OAUTH_CLIENT_SECRET:-ci-dummy-client-secret}"

export ACCOUNT_UUID="${ACCOUNT_UUID:-00000000-0000-0000-0000-000000000000}"
export DT_ACCOUNT_ID="${DT_ACCOUNT_ID:-00000000-0000-0000-0000-000000000000}"
export DT_ENV_URL="${DT_ENV_URL:-https://dummy.apps.dynatrace.com}"
export DT_URL="${DT_URL:-https://dummy.apps.dynatrace.com}"
export DEMO_ENV_URL="${DEMO_ENV_URL:-https://dummy.apps.dynatrace.com}"
export ENVIRONMENT_URL="${ENVIRONMENT_URL:-https://dummy.apps.dynatrace.com}"
export DYNATRACE_URL_GEN3="${DYNATRACE_URL_GEN3:-https://dummy.apps.dynatrace.com}"
export DYNATRACE_SSO_URL="${DYNATRACE_SSO_URL:-https://sso.dynatrace.com/sso/oauth2/token}"
export DYNATRACE_ENV_URL="${DYNATRACE_ENV_URL:-https://dummy.apps.dynatrace.com}"

# Auto-discover ALL env vars referenced in Monaco config files and
# set any that aren't already defined to a dummy placeholder.
echo "  Auto-discovering env var references in Monaco configs..."
AUTO_VARS=0
while IFS= read -r var_name; do
  [[ -z "$var_name" ]] && continue
  # Skip invalid bash variable names
  [[ ! "$var_name" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] && continue
  if [[ -z "${!var_name:-}" ]]; then
    export "$var_name=ci-dummy-value"
    AUTO_VARS=$((AUTO_VARS + 1))
  fi
done < <(
  # Pattern 1: `type: environment` blocks with `name: VAR_NAME`
  grep -rh 'type:\s*environment' -A2 --include="*.yaml" --include="*.yml" "$REPO_ROOT" 2>/dev/null \
    | grep 'name:' | sed 's/.*name:\s*//' | tr -d "\"' "
  # Pattern 2: direct `name: VAR_NAME` under value/parameter blocks
  grep -rh '^\s*name:\s*[A-Z_][A-Z0-9_]*\s*$' --include="*.yaml" --include="*.yml" "$REPO_ROOT" 2>/dev/null \
    | sed 's/.*name:\s*//' | tr -d ' '
  # Pattern 3: Go template {{ .Env.VAR_NAME }}
  grep -roh '{{ *\.Env\.\([A-Za-z_][A-Za-z0-9_]*\)' --include="*.json" --include="*.yaml" "$REPO_ROOT" 2>/dev/null \
    | sed 's/.*\.Env\.//'
)
echo "  Set $AUTO_VARS additional env vars to dummy values"
echo ""

# ── Discovery & validation ───────────────────────────────────────────
FAILED=0
PASSED=0
SKIPPED=0
TOTAL=0

# Samples with intentional placeholders (%VALUE%) that can't pass dry-run
SKIP_PATTERNS=(
  "account-monaco-admin-access/manifest-account.yaml"
)

echo "============================================="
echo "  Monaco Dry-Run Validation"
echo "============================================="
echo ""

# Find all manifest files (skip gitignored _manifest.yaml files)
MANIFESTS=$(find . -name "manifest*.yaml" \
  -not -name "_manifest*" \
  -not -path "*/.terraform/*" \
  -not -path "*/.git/*" \
  | sort)

if [[ -z "$MANIFESTS" ]]; then
  echo "  No Monaco manifests found."
  exit 0
fi

for manifest in $MANIFESTS; do
  TOTAL=$((TOTAL + 1))
  manifest_dir=$(dirname "$manifest")
  manifest_file=$(basename "$manifest")

  echo -n "  $manifest ... "

  # Skip manifests with known placeholder issues
  skip=false
  for pattern in "${SKIP_PATTERNS[@]}"; do
    if [[ "$manifest" == *"$pattern"* ]]; then
      echo "SKIPPED (contains non-resolvable placeholders)"
      SKIPPED=$((SKIPPED + 1))
      skip=true
      break
    fi
  done
  [[ "$skip" == "true" ]] && continue

  # Account manifests use `accounts:` key and need `monaco account deploy`
  if grep -q '^accounts:' "$manifest" 2>/dev/null; then
    if dry_output=$(cd "$manifest_dir" && monaco account deploy --dry-run -m "$manifest_file" 2>&1); then
      echo "OK"
      PASSED=$((PASSED + 1))
    else
      echo "FAILED"
      echo "$dry_output" | tail -15 | sed 's/^/    /'
      FAILED=$((FAILED + 1))
    fi
  else
    # Regular environment manifest
    if dry_output=$(cd "$manifest_dir" && monaco deploy --dry-run "$manifest_file" 2>&1); then
      echo "OK"
      PASSED=$((PASSED + 1))
    else
      echo "FAILED"
      echo "$dry_output" | tail -15 | sed 's/^/    /'
      FAILED=$((FAILED + 1))
    fi
  fi
done

echo ""
echo "============================================="
echo "  Results: $PASSED passed, $FAILED failed, $SKIPPED skipped (of $TOTAL)"
echo "============================================="

exit $((FAILED > 0 ? 1 : 0))
