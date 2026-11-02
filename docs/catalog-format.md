# Catalog format (`versions.json`)

The single entry point. A client reads this first, learns what's available, then fetches the
pack files it wants.

```json
{
  "versions": [
    {
      "id": "kjv",
      "name": "King James Version",
      "abbr": "KJV",
      "language": "English",
      "languageCode": "en",
      "canon": "protestant",
      "verseCount": 31102,
      "chapterCount": 1189,
      "bookCount": 66,
      "packBytes": 4240684,
      "source": "eBible.org · public domain (1611/1769)",
      "year": 1769,
      "original": false,
      "bundled": true,
      "notes": "..."
    }
  ]
}
```

| Field | Meaning |
|---|---|
| `id` | Stable pack identifier; also the filename `<id>.json` |
| `bundled` | `true` = shipped inside the app binary; `false` = downloadable on demand |
| `canon` | `protestant`, `catholic`, `orthodox`, or `jewish` |
| `original` | `true` if this is an original-language version (Hebrew/Greek) |
| `source` / `year` | Human-read provenance, shown in the app's Settings |

## Pack file format

See [`FORMAT.md`](../FORMAT.md) for the full schema. In short, `format: 1` with a version
header and a compact `books → chapters → verses` tree, plus optional per-chapter `headings`
(e.g. the Psalms "BOOK I–V" dividers).

The format is **machine-enforced**: see `schema/` and `tools/validate.py`. CI runs the
validator on every push, so a malformed pack or a catalog/pack mismatch fails the build
rather than shipping.
