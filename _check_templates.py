#!/usr/bin/env python3
import os, yaml, glob

base = os.path.dirname(os.path.abspath(__file__))
os.chdir(base)

patterns = ["**/config.yaml", "**/_config.yaml", "**/configs.yaml"]
config_files = []
for p in patterns:
    config_files.extend(glob.glob(p, recursive=True))
config_files = sorted(set(config_files))

print("=== TEMPLATE REFERENCE PATTERNS ===\n")
missing = []
styles = {"bare-filename": [], "relative-dot-slash": [], "relative-subdir": []}

for cf in config_files:
    cf_dir = os.path.dirname(cf)
    with open(cf) as f:
        try:
            data = yaml.safe_load(f)
        except Exception as e:
            print(f"PARSE ERROR in {cf}: {e}")
            continue
    configs = data.get('configs', []) if data else []
    for c in (configs or []):
        config_block = c.get('config', {}) or {}
        template = config_block.get('template')
        if template:
            if template.startswith('./'):
                styles["relative-dot-slash"].append(template)
            elif '/' in template:
                styles["relative-subdir"].append(template)
            else:
                styles["bare-filename"].append(template)
            template_clean = template
            if template_clean.startswith('./'):
                template_clean = template_clean[2:]
            template_path = os.path.join(cf_dir, template_clean)
            exists = os.path.isfile(template_path)
            if not exists:
                missing.append((cf, template, template_path))

for style, examples in styles.items():
    if examples:
        print(f"  {style}: {len(examples)} usages (e.g. {examples[0]})")

print("\n=== MISSING TEMPLATE FILES ===")
if missing:
    for cf, tpl, path in missing:
        print(f"  Config: {cf}")
        print(f"    template: {tpl}")
        print(f"    Expected at: {path}")
else:
    print("  None! All template references resolve correctly.")

print("\n=== CONFIGS WITHOUT TEMPLATE FIELD ===")
count = 0
for cf in config_files:
    with open(cf) as f:
        try:
            data = yaml.safe_load(f)
        except:
            continue
    configs = data.get('configs', []) if data else []
    for c in (configs or []):
        config_block = c.get('config', {}) or {}
        cid = c.get('id', '?')
        if 'template' not in config_block:
            print(f"  {cf} -> config id='{cid}'")
            count += 1
if count == 0:
    print("  None - all configs have template fields.")
