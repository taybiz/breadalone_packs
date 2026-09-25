# Scripture sources — provenance & licensing

This directory holds the **raw source texts** that `tools/bible_ingest` turns into
the version packs at build time. Everything here is committed to source-control so
the packs are fully reproducible and their provenance is self-contained.

## Layout

```
sources/
  fetch_sources.sh   # downloads the sources (idempotent; skips files already present)
  usfm/              # per-version USFM zips from eBible.org
  gutenberg/         # plain-text classics from Project Gutenberg
  PROVENANCE.md      # this file
```

## How to regenerate the packs

```bash
cd <repo root>
dart run tools/bible_ingest/bin/bible_ingest.dart
# writes apps/bible_app/assets/bible/*.json  (gitignored build output)
```

`fetch_sources.sh` will re-download any missing source file into this directory
(the USFM zips + Gutenberg texts). Run it from anywhere; it resolves its own
location, so it always targets this directory. To re-fetch a specific file,
delete it here and re-run the script.

## Origins

Two independent source shapes are parsed (see `docs/design.md` § Ingestion):

- **USFM zips** — from eBible.org (`https://ebible.org/Scriptures/<code>_usfm.zip`),
  one zip per version, for 29 of the 30 packs. Code list is in `fetch_sources.sh`.
- **Project Gutenberg** plain text — the KJV (`pg10`), plus Douay-Rheims NT/OT
  for cross-checking, for the 30th pack (`kjv-g`, the Gutenberg KJV).

## Licensing

Only **public-domain or freely redistributable** texts are used. No copyrighted
translation is bundled (NKJV, NIV, ESV, NASB and the like cannot be
redistributed). The ingest `versionSeeds` and the `fetch_sources.sh` header both
declare the redistributable set.

Every generated pack carries its own provenance in the `version.source` field
(e.g. `"eBible.org · public domain (1611/1769)"`) plus `year`, `language`,
`languageCode` and `canon`. The same attribution is shown in Settings.

## Mapping to pack ids

Version ids in `versions.json` / pack filenames come from `versionSeeds`
(`tools/bible_ingest/lib/src/version_seeds.dart`), which pairs each id with its
source stem (`sourceStem`, the eBible.org code) or Gutenberg file
(`gutenbergFile`, the 30th pack). The USFM zips here match those source stems;
the Gutenberg texts match the `gutenbergFile` names.
