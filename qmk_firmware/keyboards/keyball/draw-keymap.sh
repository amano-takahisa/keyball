#!/usr/bin/env bash
# Usage: ./draw-keymap.sh [keymap_name]
set -euo pipefail

KM="${1:-takahisa}"
KB="keyball/keyball44"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
QMK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BASE_YAML="$SCRIPT_DIR/keyball44_base.yaml"
OUT_SVG="$SCRIPT_DIR/keymap_${KM}.svg"

cd "$QMK_ROOT"

TMP_JSON="/tmp/qmk_c2json_${KB//\//_}_${KM}.json"
TMP_PARSED=$(mktemp /tmp/keymap_parsed_XXXXXX.yaml)
trap 'rm -f "$TMP_PARSED"' EXIT

qmk c2json --no-cpp -kb "$KB" -km "$KM" -o "$TMP_JSON"
keymap parse -q "$TMP_JSON" -o "$TMP_PARSED"

# Prepend local layout definition (strip existing layout section from parsed YAML)
{
  cat "$BASE_YAML"
  awk '/^layout:/{skip=1;next} skip && /^[^ \t]/{skip=0} !skip{print}' "$TMP_PARSED"
} | keymap draw - > "$OUT_SVG"

echo "$OUT_SVG"
