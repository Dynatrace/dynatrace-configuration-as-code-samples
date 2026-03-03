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

# Tokens
export DYNATRACE_PLATFORM_TOKEN="ci-dummy-token"
export PLATFORM_TOKEN="ci-dummy-token"
export API_TOKEN="ci-dummy-token"
export DT_API_TOKEN="ci-dummy-token"
export DEMO_ENV_TOKEN="ci-dummy-token"
export devToken="ci-dummy-token"

# OAuth client credentials
export OAUTH_CLIENT_ID="ci-dummy-client-id"
export OAUTH_CLIENT_SECRET="ci-dummy-client-secret"
export OAUTH_TOKEN_ENDPOINT="https://sso.dynatrace.com/sso/oauth2/token"
export CLIENT_ID="ci-dummy-client-id"
export CLIENT_SECRET="ci-dummy-client-secret"
export DT_OAUTH_CLIENT_ID="ci-dummy-client-id"
export DT_OAUTH_CLIENT_SECRET="ci-dummy-client-secret"
export DYNATRACE_CLIENT_ID="ci-dummy-client-id"
export DYNATRACE_SECRET="ci-dummy-client-secret"
export ACCOUNT_OAUTH_CLIENT_ID="ci-dummy-client-id"
export ACCOUNT_OAUTH_CLIENT_SECRET="ci-dummy-client-secret"

# Account / URL references
export ACCOUNT_UUID="00000000-0000-0000-0000-000000000000"
export DT_ACCOUNT_ID="00000000-0000-0000-0000-000000000000"
export DT_ENV_URL="https://dummy.apps.dynatrace.com"
export DT_URL="https://dummy.apps.dynatrace.com"
export DEMO_ENV_URL="https://dummy.apps.dynatrace.com"
export ENVIRONMENT_URL="https://dummy.apps.dynatrace.com"
export DYNATRACE_URL_GEN3="https://dummy.apps.dynatrace.com"
export DYNATRACE_SSO_URL="https://sso.dynatrace.com/sso/oauth2/token"
export DYNATRACE_ENV_URL="https://dummy.apps.dynatrace.com"

# Sample-specific env vars (referenced by individual configs)
export SERVICE_ID="SERVICE-000000000000000"
export USER_EMAIL="ci-dummy@example.com"
export JIRA_URL="https://dummy.atlassian.net"
export JIRA_TOKEN="ci-dummy-jira-token"
export OWNERSHIP_TEAM_NAME="ci-dummy-team"
export OWNERSHIP_EMAIL="ci-dummy@example.com"
export CHANNEL_URL="https://dummy.slack.com/channel"
export TAG_KEY="ci-dummy-tag"
export SERVICE_TAG_VALUE="ci-dummy-value"
export KUBERNETES_CLUSTER_NAME="ci-dummy-cluster"
export RUM_PERCENTAGE="100"
export REPLAY_PERCENTAGE="0"
export REPLAY_ENABLED="false"

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
