#!/usr/bin/env bash
export LC_ALL=en_US.UTF-8

PLAY_ICON="▶"
PAUSE_ICON="⏸"
LIKED_ICON="💘"
UNLIKED_ICON="🤍"
IDLE_ICON="🎵"

API="https://api.spotify.com/v1"
TOKEN_FILE="${SPOTIFY_PLAYER_CACHE:-$HOME/.cache/spotify-player}/user_client_token.json"

api() {
  local response status
  response=$(curl -s -m 3 -w '%{http_code}' \
    -H "Authorization: Bearer $(jq -r .access_token "$TOKEN_FILE" 2>/dev/null)" \
    "$API/$1")
  status=${response: -3}
  printf '%s' "${response%???}"
  [[ $status == 2* ]]
}

command -v spotify_player &>/dev/null || exit 0

playback=$(api "me/player/currently-playing")
if [ $? -ne 0 ]; then
  spotify_player get key playback &>/dev/null
  playback=$(api "me/player/currently-playing") || exit 0
fi

track=$(jq -r '.item.id // empty' <<<"$playback" 2>/dev/null)
if [ -z "$track" ]; then
  echo "$IDLE_ICON"
  exit 0
fi

if [ "$(api "me/tracks/contains?ids=$track" | jq -r '.[0]' 2>/dev/null)" = "true" ]; then
  liked="$LIKED_ICON"
else
  liked="$UNLIKED_ICON"
fi

jq -r --arg play "$PLAY_ICON" --arg pause "$PAUSE_ICON" --arg liked "$liked" '
  (if .is_playing then $play else $pause end) + " " + .item.name + " " + $liked' <<<"$playback"
