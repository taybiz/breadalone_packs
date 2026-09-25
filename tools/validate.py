#!/usr/bin/env python3
"""Validate every pack and the catalog against the JSON Schemas in schema/.

Exit 0 when everything conforms and the catalog/pack-file sets agree; exit 1
otherwise. Use as a local gate and in CI:

    python3 tools/validate.py
    # -> "30 packs OK, catalog OK"

Requires the `jsonschema` package (pip install jsonschema).
"""
from __future__ import annotations

import glob
import json
import os
import sys

from jsonschema import Draft202012Validator

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load(name: str):
    with open(os.path.join(ROOT, name)) as fh:
        return json.load(fh)


def main() -> int:
    pack_schema = load("schema/pack.schema.json")
    catalog_schema = load("schema/catalog.schema.json")
    for s, label in ((pack_schema, "pack"), (catalog_schema, "catalog")):
        Draft202012Validator.check_schema(s)
        print(f"schema OK: {label}")

    pack_validator = Draft202012Validator(pack_schema)
    catalog_validator = Draft202012Validator(catalog_schema)

    pack_files = sorted(
        f
        for f in glob.glob(os.path.join(ROOT, "packs", "*.json"))
        if not f.endswith("versions.json")
    )
    failures = 0
    for f in pack_files:
        doc = load(os.path.relpath(f, ROOT))
        errors = list(pack_validator.iter_errors(doc))
        if errors:
            failures += 1
            print(f"FAIL {os.path.relpath(f, ROOT)}: {errors[0].message}")
    ok = len(pack_files) - failures
    print(f"packs validated: {ok} ok, {failures} fail")

    catalog = load("packs/versions.json")
    errors = list(catalog_validator.iter_errors(catalog))
    print("catalog validates:", "FAIL" if errors else "OK")
    if errors:
        print(" ", errors[0].message)

    # Cross-check: every catalog id has a pack file, and vice versa.
    ids = {v["id"] for v in catalog["versions"]}
    packs = {os.path.basename(f)[: -len(".json")] for f in pack_files}
    for missing in sorted(ids - packs):
        print(f"FAIL catalog id {missing!r} has no pack file")
        failures += 1
    for orphan in sorted(packs - ids):
        print(f"FAIL pack file {orphan!r} is not in the catalog")
        failures += 1

    overlaps = f"(catalog {len(ids)} / packs {len(packs)} agree)" if ids == packs else ""
    print(f"catalog vs packs: {overlaps}")
    return 1 if failures or errors else 0


if __name__ == "__main__":
    sys.exit(main())
