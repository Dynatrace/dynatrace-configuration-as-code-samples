#!/usr/bin/env bash
###############################################################################
# Terraform Validation Script
#
# Discovers all Terraform root modules (directories with providers.tf) and runs:
#   1. terraform fmt -check     — formatting consistency
#   2. terraform init -backend=false — download providers (no credentials needed)
#   3. terraform validate       — HCL syntax & type checking
#
# Usage:  bash scripts/ci/validate-terraform.sh
# Requires: terraform CLI in PATH
###############################################################################
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

FMT_FAILED=0
VALIDATE_FAILED=0
VALIDATE_PASSED=0
VALIDATE_SKIPPED=0

echo "============================================="
echo "  Terraform Validation"
echo "============================================="
echo ""

# ── Phase 1: Format check (top-level sample directories, recursive) ──
echo "--- Format Check (terraform fmt -check) ---"
echo ""

for dir in */; do
  dir="${dir%/}"
  # Only check directories that contain .tf files somewhere
  if ! find "$dir" -name "*.tf" -not -path "*/.terraform/*" -print -quit 2>/dev/null | grep -q .; then
    continue
  fi

  echo -n "  $dir ... "
  fmt_output=$(terraform fmt -check -recursive "$dir" 2>&1) || true
  if [[ -z "$fmt_output" ]]; then
    echo "OK"
  else
    echo "NEEDS FORMATTING"
    echo "$fmt_output" | sed 's/^/    /'
    echo "    Fix: terraform fmt -recursive $dir"
    FMT_FAILED=$((FMT_FAILED + 1))
  fi
done

echo ""

# ── Phase 2: Init & Validate (every directory with providers.tf) ─────
echo "--- Init & Validate ---"
echo ""

DIRS=$(find . -name "providers.tf" -not -path "*/.terraform/*" -exec dirname {} \; | sort -u)

for dir in $DIRS; do
  dir="${dir#./}"
  echo "  $dir"

  sample_failed=0

  # terraform init -backend=false  (downloads providers, skips backend)
  echo -n "    init ....... "
  if init_output=$(terraform -chdir="$dir" init -backend=false -input=false -no-color 2>&1); then
    echo "OK"
  else
    echo "FAILED"
    echo "$init_output" | grep -iE 'error|failed|could not' | head -5 | sed 's/^/      /'
    sample_failed=1
  fi

  # terraform validate  (syntax + type checking, no API calls)
  echo -n "    validate ... "
  if [[ $sample_failed -eq 1 ]]; then
    echo "SKIPPED (init failed)"
    VALIDATE_SKIPPED=$((VALIDATE_SKIPPED + 1))
  else
    if validate_output=$(terraform -chdir="$dir" validate -no-color 2>&1); then
      echo "OK"
      VALIDATE_PASSED=$((VALIDATE_PASSED + 1))
    else
      echo "FAILED"
      echo "$validate_output" | head -10 | sed 's/^/      /'
      sample_failed=1
      VALIDATE_FAILED=$((VALIDATE_FAILED + 1))
    fi
  fi

  echo ""
done

# ── Summary ──────────────────────────────────────────────────────────
TOTAL=$((VALIDATE_PASSED + VALIDATE_FAILED + VALIDATE_SKIPPED))
echo "============================================="
echo "  Results"
echo "    Format:   $FMT_FAILED failures"
echo "    Validate: $VALIDATE_PASSED passed, $VALIDATE_FAILED failed, $VALIDATE_SKIPPED skipped (of $TOTAL)"
echo "============================================="

EXIT_CODE=0
if [[ $FMT_FAILED -gt 0 ]]; then
  echo "::warning::$FMT_FAILED Terraform sample(s) need formatting — run 'terraform fmt -recursive' to fix"
fi
[[ $VALIDATE_FAILED -gt 0 ]]  && EXIT_CODE=1
exit $EXIT_CODE
