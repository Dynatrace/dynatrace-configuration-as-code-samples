#!/usr/bin/env bash
###############################################################################
# Secret & Credential Scanner
#
# Scans all tracked files for patterns that indicate hardcoded secrets,
# tokens, private keys, or non-placeholder user-specific values.
#
# Pattern sources & references:
#   - Dynatrace token formats: dt0c01 (API), dt0s01 (SaaS), dt0a01 (Agent)
#     https://docs.dynatrace.com/docs/manage/identity-access-management/access-tokens-and-oauth-clients/access-tokens
#   - GitHub token prefixes: ghp_, gho_, ghs_, github_pat_
#   - AWS AKIA prefix, GCP AIza prefix
#   - OWASP credential patterns
#
# Design: conservative patterns to minimise false positives.
# Files excluded: CI scripts (contain the patterns themselves), images, .git/
#
# Usage:  bash scripts/ci/check-secrets.sh
###############################################################################
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

FAILED=0

echo "============================================="
echo "  Secret & Credential Scan"
echo "============================================="
echo ""

# ── Helper ────────────────────────────────────────────────────────────
check_pattern() {
  local description="$1"
  local pattern="$2"
  shift 2
  local extra_grep_args=("$@")   # optional extra grep -v filters

  echo -n "  $description ... "

  # Search tracked text files, skip CI scripts, images, binaries, AGENTS.md
  local results
  results=$(
    grep -rnE "$pattern" \
      --include="*.tf" --include="*.yaml" --include="*.yml" \
      --include="*.json" --include="*.sh" --include="*.env" \
      --include="*.env.*" --include="*.hcl" --include="*.md" \
      --exclude-dir=.git --exclude-dir=.terraform \
      --exclude-dir=images --exclude-dir=node_modules \
      . 2>/dev/null \
    | grep -v 'scripts/ci/' \
    | grep -v 'AGENTS.md' \
    | grep -v '.github/workflows/' \
    || true
  )

  # Apply optional extra exclusions
  for filter in "${extra_grep_args[@]+"${extra_grep_args[@]}"}"; do
    if [[ -n "$results" ]] && [[ -n "$filter" ]]; then
      results=$(echo "$results" | grep -v "$filter" || true)
    fi
  done

  if [[ -n "$results" ]]; then
    local count
    count=$(echo "$results" | wc -l | tr -d ' ')
    echo "FAILED ($count match(es))"
    echo "$results" | head -20 | sed 's/^/    /'
    if [[ "$count" -gt 20 ]]; then
      echo "    ... and $((count - 20)) more"
    fi
    FAILED=$((FAILED + 1))
  else
    echo "OK"
  fi
}

# ── 1. Dynatrace API / SaaS / Agent tokens ───────────────────────────
# Format: dt0c01.<24+ chars>.<64+ chars>  (API token)
#         dt0s01.<chars>                    (SaaS token)
#         dt0a01.<chars>                    (Agent token)
check_pattern \
  "Dynatrace API / SaaS / Agent tokens  (dt0[csa]01.)" \
  'dt0[csa]01\.[A-Za-z0-9_-]{8,}'

# ── 2. Private keys ──────────────────────────────────────────────────
check_pattern \
  "Private keys  (BEGIN PRIVATE KEY)" \
  '-----BEGIN[[:space:]]+(RSA[[:space:]]+|EC[[:space:]]+|DSA[[:space:]]+|OPENSSH[[:space:]]+)?PRIVATE[[:space:]]+KEY-----'

# ── 3. AWS Access Key IDs ────────────────────────────────────────────
check_pattern \
  "AWS Access Key IDs  (AKIA...)" \
  'AKIA[0-9A-Z]{16}'

# ── 4. GCP API keys ──────────────────────────────────────────────────
check_pattern \
  "GCP API keys  (AIza...)" \
  'AIza[A-Za-z0-9_-]{35}'

# ── 5. GitHub tokens ─────────────────────────────────────────────────
check_pattern \
  "GitHub tokens  (ghp_, gho_, ghs_, github_pat_)" \
  '(ghp|gho|ghs|github_pat)_[A-Za-z0-9_]{20,}'

# ── 6. Slack tokens ──────────────────────────────────────────────────
check_pattern \
  "Slack tokens  (xox[bpsa]-)" \
  'xox[bpsa]-[A-Za-z0-9/-]{10,}'

# ── 7. Generic Bearer tokens in code ─────────────────────────────────
# Match: Authorization: Bearer <long-alphanumeric-string>
check_pattern \
  "Hardcoded Bearer tokens" \
  'Bearer[[:space:]]+[A-Za-z0-9_-]{40,}'

# ── 8. Hardcoded credential assignments in shell / env files ─────────
# Catches:  export SECRET="real-looking-value"
# Excludes: placeholders like <YOUR_TOKEN>, your-xxx, dummy, example, TODO
echo -n "  Hardcoded credential assignments in scripts ... "
CRED_RESULTS=$(
  grep -rnE '(PASSWORD|SECRET|API_KEY|PRIVATE_KEY|ACCESS_KEY)\s*[:=]\s*"[^"]{8,}"' \
    --include="*.sh" --include="*.env" --include="*.env.*" \
    --exclude-dir=.git --exclude-dir=.terraform \
    . 2>/dev/null \
  | grep -v 'scripts/ci/' \
  | grep -v '\.env\.example' \
  | grep -iEv '<|your[-_]|xxx|dummy|TODO|CHANGE.ME|placeholder|example|0000|ci-dummy|template' \
  || true
)

if [[ -n "$CRED_RESULTS" ]]; then
  count=$(echo "$CRED_RESULTS" | wc -l | tr -d ' ')
  echo "FAILED ($count match(es))"
  echo "$CRED_RESULTS" | head -10 | sed 's/^/    /'
  FAILED=$((FAILED + 1))
else
  echo "OK"
fi

# ── 9. Committed .env files (only .env.example should be tracked) ────
echo -n "  Committed .env files (should be .env.example only) ... "
if command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null; then
  ENV_FILES=$(git ls-files 2>/dev/null | grep -E '/\.env$|^\.env$' || true)
  if [[ -n "$ENV_FILES" ]]; then
    echo "FAILED"
    echo "$ENV_FILES" | sed 's/^/    /'
    echo "    Only .env.example files should be committed."
    FAILED=$((FAILED + 1))
  else
    echo "OK"
  fi
else
  echo "SKIPPED (not a git repo)"
fi

# ── 10. Connection strings with embedded credentials ──────────────────
check_pattern \
  "Connection strings with credentials" \
  '(mongodb|postgresql|mysql|redis|amqp)://[^/[:space:]:]+:[^/[:space:]@]+@[^/[:space:]]+' \
  'example\|placeholder\|localhost'

# ── Summary ──────────────────────────────────────────────────────────
echo ""
echo "============================================="
if [[ $FAILED -gt 0 ]]; then
  echo "  FAILED: $FAILED check(s) found potential secrets"
else
  echo "  PASSED: No secrets or credentials detected"
fi
echo "============================================="

exit $((FAILED > 0 ? 1 : 0))
