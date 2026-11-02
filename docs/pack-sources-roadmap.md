# Pack sources — the roadmap

**Status: design context, not yet built.** Today the app reads packs bundled in its binary.
The forward design lets the app configure **multiple git repos as pack sources**, applied in
order:

- **Canon source** — this repo (built by the app's author, so it's the reference for
  book/chapter structure).
- **Overlay / tertiary sources** — anyone can author their own pack source (including a
  *copyrighted* translation, published under their own terms) and layer it *over* the canon.
  Because packs are plain text JSON keyed by stable book/chapter/verse identifiers, an overlay
  can add a version or replace a canon one without forking or editing the canon repo.

Implementation of *that* is app-side work — the pack format and the `versions.json` contract
in [`catalog-format.md`](catalog-format.md) are all a third party needs to build a compatible
source.
