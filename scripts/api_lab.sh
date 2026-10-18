#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

LOG_FILE="logs/lab3.log"
DATA_DIR="data"

log() {
  echo "$1" >> "$LOG_FILE"
}

cleanup () {
  log "LAB3_END"
}
trap cleanup EXIT

mkdir -p scripts data logs

for tool in curl jq; do
  command -v "$tool" >/dev/null || { echo "$tool is missing"; exit 1; }
done

log "BASH_OK"

# adding in Dad Jokes

JOKE_URL="https://icanhazdadjoke.com/"
JOKE_JSON="$DATA_DIR/dad_joke.json"
JOKE_TXT="$DATA_DIR/dad_joke.txt"

status=$(curl -sS -H 'Accept: application/json' -w '%{http_code}' -o "$JOKE_JSON" "$JOKE_URL")

if [ "$status" -ne 200 ]; then
  log "CURL_JOKE_FAIL"
  exit 1
fi
log "CURL_JOKE_OK"

jq -r '.id, .joke' "$JOKE_JSON" > "$JOKE_TXT"
log "JQ_JOKE_OK"

# adding in Deck of Cards

DECK_CREATE_URL="https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1"
DECK_CREATE_JSON="$DATA_DIR/deck_create.json"
DECK_DRAW_JSON="$DATA_DIR/deck_draw.json"
DECK_SUMMARY="$DATA_DIR/deck_summary.txt"

status=$(curl -sS -H 'Accept: application/json' -w '%{http_code}' -o "$DECK_CREATE_JSON" "$DECK_CREATE_URL")
if [ "$status" -ne 200 ]; then
  log "DECK_CREATE_FAIL"
  exit 1
fi
log "DECK_CREATE_OK"

deck_id=$(jq -r '.deck_id' "$DECK_CREATE_JSON")

DECK_DRAW_URL="https://deckofcardsapi.com/api/deck/$deck_id/draw/?count=2"
status=$(curl -sS -H 'Accept: application/json' -w '%{http_code}' -o "$DECK_DRAW_JSON" "$DECK_DRAW_URL")
if [ "$status" -ne 200 ]; then
  log "DECK_DRAW_FAIL"
  exit 1
fi
log "DECK_DRAW_OK"

jq -r '.cards[] | "\(.value) of \(.suit)"' "$DECK_DRAW_JSON" > "$DECK_SUMMARY"
echo "Remaining: $(jq -r '.remaining' "$DECK_DRAW_JSON")" >> "$DECK_SUMMARY"
log "JQ_DECK_OK"
