# Pack format — `format: 2`

A Breadalone **pack** is a single JSON file containing the full text of one Bible version.
This is the contract every pack source must satisfy. It is deliberately minimal,
stable, and text-only.

> Format verified against the 30 shipped packs (`format: 2`, 2026-10-08).

**Machine-enforced schema:** this format is defined as JSON Schema so it can be validated
automatically (not just documented):

- [`schema/pack.schema.json`](schema/pack.schema.json) — validates an individual pack file.
- [`schema/catalog.schema.json`](schema/catalog.schema.json) — validates the `versions.json` catalog.
- [`tools/validate.py`](tools/validate.py) — runs both over the whole `packs/` tree and cross-checks
  catalog↔pack file agreement. Run it locally `python3 tools/validate.py`, or let CI enforce it
  (see `.github/workflows/validate.yml`). Any tool implementing JSON Schema (draft 2020-12) can
  validate against the same files.

---

## Top level

```json
{
  "format": 2,
  "version": {
    "id": "kjv",
    "name": "King James Version",
    "abbr": "KJV",
    "language": "English",
    "languageCode": "en",
    "canon": "protestant",
    "verseCount": 31102,
    "chapterCount": 1189,
    "bookCount": 66,
    "source": "eBible.org · public domain (1611/1769)",
    "year": 1769,
    "original": false,
    "notes": ""
  },
  "books": [ ... ]
}
```

### `version` fields

| Field | Type | Meaning |
|---|---|---|
| `format` | int | **2** (current) |
| `id` | string | stable identifier; matches filename `<id>.json` and catalog entry |
| `name` | string | full version name |
| `abbr` | string | short abbreviation (e.g. `KJV`) |
| `language` | string | human-read language name |
| `languageCode` | string | ISO 639-1 code |
| `canon` | string | `protestant` \| `catholic` \| `orthodox` \| `jewish` |
| `verseCount` / `chapterCount` / `bookCount` | int | totals (quick client stats) |
| `source` | string | provenance shown in Settings |
| `year` | int (nullable) | publication year of this text |
| `original` | bool | true for Hebrew/Greek original-language versions |
| `notes` | string (nullable) | free-form |

---

## Books

```json
{
  "id": "Gen",
  "title": "Genesis",
  "order": 1,
  "chapters": [ ... ]
}
```

| Field | Type | Meaning |
|---|---|---|
| `id` | string | stable book id (USFM book code, e.g. `Gen`) |
| `title` | string | display title |
| `order` | int | canonical position 1..N within the version's canon |
| `chapters` | array | one entry per chapter |

---

## Chapters

```json
{
  "n": 1,
  "blocks": [ { "v": 1, "k": "p" }, { "v": 4, "k": "q" } ],
  "verses": ["...", "..."],
  "headings": [ { "v": 1, "t": "BOOK I" } ]
}
```

| Field | Type | Meaning |
|---|---|---|
| `n` | int | chapter number (1-based) |
| `blocks` | array of objects | reading-block layout — see Blocks below |
| `verses` | array of string | verse text; index `i` = verse `i+1` (1-based) |
| `headings` | array of objects (optional) | section/Psalm headings; **omitted when empty** |
| `loose` | bool (optional) | `true` when the chapter's verse numbering is loose; omitted otherwise |

### Headings

Each heading marks a position within the chapter:

```json
{ "v": 1, "t": "BOOK I" }
```

| Field | Type | Meaning |
|---|---|---|
| `v` | int | 1-based verse index this heading introduces |
| `t` | string | heading text |

Present today in ~2,000 headings (notably the Psalms "BOOK I–V" dividers). A chapter
that has no headings simply omits the `headings` key entirely.

### Blocks

`blocks` (added in format 2) records the source's paragraph/poetry layout so a fetched
edition renders exactly like a bundled one. One entry per block start, in verse order:

```json
{ "v": 4, "k": "q" }
```

| Field | Type | Meaning |
|---|---|---|
| `v` | int | 1-based verse index this block starts at |
| `k` | string | block kind — the source's USFM paragraph marker: `p` paragraph, `q` poetry/quote, `m` continuation paragraph, `l` list entry |

Every chapter carries `blocks` in format 2; a chapter with no explicit markers is a
single `p` block at verse 1.

---

## Conventions

- **Verses are 1-based** in the `verses` array (index 0 = verse 1).
- **UTF-8** everywhere. No escapes beyond normal JSON.
- **Compact output** (the builder emits no indentation) to keep `packBytes` low; but
  whitespace is not part of the contract — any valid JSON with the same structure is valid.
- **Optional keys omitted when empty.** `headings`, `loose` (and `version.notes`) only appear
  when populated. A reader must tolerate their absence.
- **Stable ids.** Book ids (`Gen`, `John`…) and version ids are the compatibility
  surface. Do not rename without a format bump.

---

## Versioning

`format: 2` is the current layout. A breaking change to the schema bumps this integer;
clients that only understand lower formats may refuse or ignore unknown packs. New
optional fields are additive and should not bump the format.

`format: 1` had no `blocks` — chapters were plain verse-by-verse. The bump to `2` added
the per-chapter `blocks` reading layout and the optional `loose` flag; a reader that
advertises format-2 support parses both.

---

## Relationship to `versions.json`

`versions.json` in a pack source lists the *descriptions* (see README). Each entry's
`id` must match a pack's `version.id`, and its `packBytes` should equal that pack's
byte size. A pack source is valid when: every catalog entry has a present pack, and
every pack present is either bundled or listed in the catalog.
