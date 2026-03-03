#!/usr/bin/env python3
"""
Reference Integrity & JSON Syntax Check

Validates:
  1. JSON syntax    — all non-templated .json files parse without errors
                     (files containing Go template syntax {{...}} are skipped;
                      Monaco dry-run validates those separately)
  2. Merge conflicts — flags leftover Git merge conflict markers
  3. Template refs   — config.yaml `template:` fields point to existing files
  4. Project refs    — manifest.yaml `projects[].path` dirs exist on disk

No external dependencies (stdlib only).

Usage:  python3 scripts/ci/check-references.py
"""

import glob
import json
import os
import re
import sys


# ── Directories / patterns to skip ──────────────────────────────────
SKIP_SEGMENTS = {".terraform", "node_modules", ".git"}


def should_skip(path: str) -> bool:
    """Return True if any path segment is in the skip-list."""
    return any(seg in path.split(os.sep) for seg in SKIP_SEGMENTS)


# ── 1. JSON syntax validation ───────────────────────────────────────
def validate_json_files(repo_root: str) -> int:
    errors = 0
    checked = 0
    skipped_templates = 0

    print("--- JSON Syntax Validation ---")
    print("    (Files with Go template syntax {{...}} are skipped —")
    print("     Monaco dry-run validates those separately.)")
    print()

    for json_file in sorted(glob.glob(os.path.join(repo_root, "**", "*.json"), recursive=True)):
        rel = os.path.relpath(json_file, repo_root)
        if should_skip(rel):
            continue

        try:
            with open(json_file, "r", encoding="utf-8") as fh:
                content = fh.read()
        except Exception as exc:  # noqa: BLE001
            print(f"  ERROR:   {rel}: {exc}")
            errors += 1
            continue

        # Skip files that use Go template syntax (Monaco renders these)
        if re.search(r"\{\{[^}]*\}\}", content):
            skipped_templates += 1
            continue

        checked += 1
        try:
            json.loads(content)
        except json.JSONDecodeError as exc:
            print(f"  INVALID: {rel}")
            print(f"           Line {exc.lineno}: {exc.msg}")
            errors += 1

    status = "OK" if errors == 0 else "ISSUES FOUND"
    print(f"  Checked {checked} JSON files, skipped {skipped_templates} Go templates — {status}"
          + (f" ({errors} invalid)" if errors else ""))
    return errors


# ── 2. Git merge conflict marker check ──────────────────────────────
def check_merge_conflicts(repo_root: str) -> int:
    """Flag leftover Git merge conflict markers in any tracked file."""
    errors = 0
    extensions = ("*.json", "*.yaml", "*.yml", "*.tf", "*.hcl", "*.sh", "*.md")

    print()
    print("--- Git Merge Conflict Markers ---")
    print()

    for ext in extensions:
        for filepath in sorted(glob.glob(os.path.join(repo_root, "**", ext), recursive=True)):
            rel = os.path.relpath(filepath, repo_root)
            if should_skip(rel):
                continue
            try:
                with open(filepath, "r", encoding="utf-8", errors="ignore") as fh:
                    for line_no, line in enumerate(fh, 1):
                        if re.match(r"^(<{7}|={7}|>{7})", line):
                            print(f"  CONFLICT: {rel}:{line_no}")
                            print(f"            {line.rstrip()}")
                            errors += 1
                            break  # one per file is enough
            except Exception:  # noqa: BLE001
                pass

    status = "OK" if errors == 0 else "ISSUES FOUND"
    print(f"  {status}" + (f" ({errors} file(s) with merge conflict markers)" if errors else ""))
    return errors


# ── 2. Template reference validation ────────────────────────────────
def check_template_references(repo_root: str) -> int:
    errors = 0
    checked = 0

    print()
    print("--- Template References (config.yaml → *.json) ---")
    print()

    # Find all config.yaml files (Monaco configuration files)
    for config_file in sorted(glob.glob(os.path.join(repo_root, "**", "config.yaml"), recursive=True)):
        rel_config = os.path.relpath(config_file, repo_root)
        if should_skip(rel_config):
            continue

        config_dir = os.path.dirname(config_file)

        with open(config_file, "r", encoding="utf-8") as fh:
            for line_no, line in enumerate(fh, 1):
                stripped = line.strip()
                if stripped.startswith("#"):
                    continue

                match = re.search(r"\btemplate:\s*[\"']?([^\"'\s#]+)", line)
                if not match:
                    continue

                template_name = match.group(1).strip()

                # Skip variable/template expressions
                if template_name.startswith(("{{", "$", "%")):
                    continue

                checked += 1
                template_path = os.path.join(config_dir, template_name)

                if not os.path.isfile(template_path):
                    print(f"  BROKEN: {rel_config}:{line_no}")
                    print(f"          template '{template_name}' not found at "
                          f"{os.path.relpath(template_path, repo_root)}")
                    errors += 1

    status = "OK" if errors == 0 else "ISSUES FOUND"
    print(f"  Checked {checked} template references — {status}" + (f" ({errors} broken)" if errors else ""))
    return errors


# ── 3. Manifest project path validation ─────────────────────────────
def extract_project_paths(manifest_path: str) -> list[str]:
    """Parse the `projects:` section of a Monaco manifest (no PyYAML needed)."""
    projects: list[str] = []

    with open(manifest_path, "r", encoding="utf-8") as fh:
        content = fh.read()

    in_projects = False
    projects_indent: str | None = None
    current_name: str | None = None
    current_path: str | None = None

    for line in content.split("\n"):
        # Detect the projects section (allow leading indentation)
        proj_match = re.match(r"^(\s*)projects\s*:", line)
        if proj_match:
            in_projects = True
            projects_indent = proj_match.group(1)
            continue

        # Detect end of projects section (new key at the same indentation level)
        if in_projects and projects_indent is not None and line and ":" in line:
            indent_re = re.escape(projects_indent)
            if re.match(rf"^{indent_re}\S.*:", line):
                if current_name is not None:
                    projects.append(current_path if current_path else current_name)
                    current_name = None  # prevent double-append after loop
                break

        if not in_projects:
            continue

        # New project entry:   - name: <value>
        name_m = re.match(r"\s+-\s+name:\s*(.+)", line)
        if name_m:
            # Save the previous project
            if current_name is not None:
                projects.append(current_path if current_path else current_name)
            current_name = name_m.group(1).strip().strip("\"'")
            current_path = None
            continue

        # Explicit path under a project:     path: <value>
        path_m = re.match(r"\s+path:\s*(.+)", line)
        if path_m and current_name is not None:
            current_path = path_m.group(1).strip().strip("\"'")
            continue

    # Handle last project in section (no trailing top-level key)
    if current_name is not None:
        projects.append(current_path if current_path else current_name)

    return projects


def check_manifest_projects(repo_root: str) -> int:
    errors = 0
    checked = 0

    print()
    print("--- Manifest Project References ---")
    print()

    for manifest in sorted(glob.glob(os.path.join(repo_root, "**", "manifest*.yaml"), recursive=True)):
        basename = os.path.basename(manifest)
        rel_manifest = os.path.relpath(manifest, repo_root)

        # Skip _manifest.yaml (gitignored template files)
        if basename.startswith("_"):
            continue
        if should_skip(rel_manifest):
            continue

        manifest_dir = os.path.dirname(manifest)
        project_paths = extract_project_paths(manifest)

        for path in project_paths:
            checked += 1
            full_path = os.path.join(manifest_dir, path)

            if not os.path.isdir(full_path):
                print(f"  BROKEN: {rel_manifest}")
                print(f"          project '{path}' — directory not found at "
                      f"{os.path.relpath(full_path, repo_root)}")
                errors += 1

    status = "OK" if errors == 0 else "ISSUES FOUND"
    print(f"  Checked {checked} project references — {status}" + (f" ({errors} broken)" if errors else ""))
    return errors


# ── Main ─────────────────────────────────────────────────────────────
def main() -> int:
    # Resolve repo root (two levels up from scripts/ci/)
    repo_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

    print("=============================================")
    print("  Reference Integrity & JSON Syntax Check")
    print("=============================================")
    print()

    total_errors = 0
    total_errors += validate_json_files(repo_root)
    total_errors += check_merge_conflicts(repo_root)
    total_errors += check_template_references(repo_root)
    total_errors += check_manifest_projects(repo_root)

    print()
    print("=============================================")
    if total_errors:
        print(f"  FAILED: {total_errors} issue(s) found")
    else:
        print("  PASSED: All references valid, all JSON files valid")
    print("=============================================")

    return 1 if total_errors else 0


if __name__ == "__main__":
    sys.exit(main())
