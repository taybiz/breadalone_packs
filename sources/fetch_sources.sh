#!/usr/bin/env bash
# Fetch public-domain / redistributable Bible sources into ~/hermes/data/bible-src.
# Sources: eBible.org (USFM, redistributable set) + Project Gutenberg (public domain).
set -u
DEST="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$DEST/usfm" "$DEST/gutenberg"

USFM_CODES="
eng-kjv2006 eng-kjv eng-asv engwebp engylt engDBY engBBE enggnv engDRA engwebster
engtnt engwyc2017 eng-rv engjps englee engnoy engoebus engmsb engULB englsv eng-Brenton
latVUC grctr grcbyz grclxx grcbrent hboWLC hebwlc deu1912 spaRV1909 fraLSG
"

for c in $USFM_CODES; do
  out="$DEST/usfm/${c}_usfm.zip"
  if [ -s "$out" ]; then echo "SKIP $c (have $(stat -c%s "$out") bytes)"; continue; fi
  code=$(curl -sL --max-time 300 -o "$out" -w "%{http_code}" "https://ebible.org/Scriptures/${c}_usfm.zip")
  if [ "$code" != "200" ]; then echo "FAIL $c http=$code"; rm -f "$out"; else
    echo "OK   $c $(stat -c%s "$out") bytes"
  fi
done

# Project Gutenberg (public domain) — classic English editions for cross-checking.
declare -A GUT=(
  [10]=kjv_gutenberg.txt
  [8300]=douayrheims_nt_gutenberg.txt
  [1581]=douayrheims_ot1_gutenberg.txt
)
for id in "${!GUT[@]}"; do
  out="$DEST/gutenberg/${GUT[$id]}"
  if [ -s "$out" ]; then echo "SKIP pg$id"; continue; fi
  url=$(curl -sL --max-time 60 "https://www.gutenberg.org/ebooks/$id" | grep -o 'https://www.gutenberg.org/cache/epub/'"$id"'/pg'"$id"'\.txt' | head -1)
  [ -z "$url" ] && url="https://www.gutenberg.org/cache/epub/$id/pg$id.txt"
  code=$(curl -sL --max-time 300 -o "$out" -w "%{http_code}" "$url")
  if [ "$code" != "200" ]; then echo "FAIL pg$id http=$code"; rm -f "$out"; else
    echo "OK   pg$id $(stat -c%s "$out") bytes"
  fi
done

echo "--- inventory ---"
du -sh "$DEST"; ls -1 "$DEST/usfm" | wc -l; ls -1 "$DEST/gutenberg" | wc -l
echo "DONE"
