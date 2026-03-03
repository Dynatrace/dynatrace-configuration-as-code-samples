#!/usr/bin/env bash
###############################################################################
# Documentation Completeness Check
#
# For every top-level sample directory (Terraform or Monaco):
#   ERROR  – Missing README.md                        (fails CI)
#   WARN   – Missing prerequisites / setup section     (informational)
#   WARN   – Missing .gitignore                        (informational)
#
# Only sections that AGENTS.md mandates as required cause errors.
# Warnings are informational and do NOT fail the CI to avoid false positives.
#
# Usage:  bash scripts/ci/check-docs.sh
###############################################################################
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

ERRORS=0
WARNINGS=0
CHECKED=0

echo "============================================="
echo "  Documentation Check"
echo "============================================="
echo ""

# Directories to skip (not sample directories)
SKIP_DIRS=".git .github scripts images dev .vs .idea .terraform"

for dir in */; do
  dir="${dir%/}"

  # Skip non-sample directories
  skip=false
  for s in $SKIP_DIRS; do
    [[ "$dir" == "$s" ]] && skip=true
  done
  $skip && continue

  # Only check directories that are Terraform or Monaco samples
  has_tf=$(find "$dir" -maxdepth 3 -name "*.tf" -not -path "*/.terraform/*" -print -quit 2>/dev/null || true)
  has_manifest=$(find "$dir" -maxdepth 2 -name "manifest*.yaml" -not -name "_manifest*" -print -quit 2>/dev/null || true)
  has_config=$(find "$dir" -maxdepth 3 -name "config.yaml" -print -quit 2>/dev/null || true)
  has_readme_already=$(find "$dir" -maxdepth 1 -name "README*" -print -quit 2>/dev/null || true)

  # If no TF/Monaco files and no README, it's not a sample directory
  if [[ -z "$has_tf" ]] && [[ -z "$has_manifest" ]] && [[ -z "$has_config" ]] && [[ -z "$has_readme_already" ]]; then
    continue
  fi

  CHECKED=$((CHECKED + 1))
  echo "  $dir/"

  # ── README.md ────────────────────────────────────────────────────
  readme=""
  for candidate in "$dir/README.md" "$dir/README.MD" "$dir/readme.md"; do
    if [[ -f "$candidate" ]]; then
      readme="$candidate"
      break
    fi
  done

  if [[ -z "$readme" ]]; then
    echo "    ERROR: Missing README.md"
    ERRORS=$((ERRORS + 1))
  else
    echo "    README.md: present"

    content=$(cat "$readme")

    # Check for Prerequisites / Requirements section
    if ! echo "$content" | grep -qiE '^#{1,3}[[:space:]]+(prerequisite|requirement)'; then
      echo "    WARN:  No 'Prerequisites' or 'Requirements' section"
      WARNINGS=$((WARNINGS + 1))
    fi

    # Check for setup / deployment instructions
    if ! echo "$content" | grep -qiE '^#{1,3}[[:space:]]+(setup|getting.started|deploy|installation|usage|how.to|quick.start|step)'; then
      echo "    WARN:  No setup/deployment instructions section"
      WARNINGS=$((WARNINGS + 1))
    fi

    # Check for cleanup / destroy instructions (important for IaC samples)
    if [[ -n "$has_tf" ]] || [[ -n "$has_manifest" ]]; then
      if ! echo "$content" | grep -qiE '^#{1,3}[[:space:]]+(cleanup|clean.up|tear.?down|destroy|delet|remov|uninstall)'; then
        echo "    WARN:  No cleanup/deletion instructions section"
        WARNINGS=$((WARNINGS + 1))
      fi
    fi
  fi

  # ── .gitignore ──────────────────────────────────────────────────
  if [[ ! -f "$dir/.gitignore" ]]; then
    echo "    WARN:  No .gitignore (consider adding per AGENTS.md standards)"
    WARNINGS=$((WARNINGS + 1))
  fi

done

echo ""
echo "============================================="
echo "  Results ($CHECKED samples checked)"
echo "    Errors:   $ERRORS"
echo "    Warnings: $WARNINGS"
if [[ $ERRORS -gt 0 ]]; then
  echo "  FAILED"
else
  echo "  PASSED"
  if [[ $WARNINGS -gt 0 ]]; then
    echo "  (warnings are informational and do not fail the CI)"
  fi
fi
echo "============================================="

# Only errors fail CI — warnings are informational
exit $((ERRORS > 0 ? 1 : 0))
