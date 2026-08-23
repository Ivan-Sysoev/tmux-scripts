#!/usr/bin/env bash
export LC_ALL=en_US.UTF-8

SCRIPT_DIR="$HOME/tmux"

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

is_liked() {
  local id=$1 result
  result=$(api "me/tracks/contains?ids=$id" | jq -r '.[0]' 2>/dev/null)
  if [ "$result" != "true" ] && [ "$result" != "false" ]; then
    spotify_player get key playback &>/dev/null
    result=$(api "me/tracks/contains?ids=$id" | jq -r '.[0]' 2>/dev/null)
  fi
  [ "$result" = "true" ]
}

IFS=$'\n' state=($(osascript "$SCRIPT_DIR/get_current_state.applescript"))
track_name=${state[3]}
track_uri=${state[5]}
player_state=${state[6]}

if [ -z "$track_uri" ]; then
  echo "$IDLE_ICON"
  exit 0
fi

if [ "$player_state" == "true" ]; then
  play_icon="$PLAY_ICON"
else
  play_icon="$PAUSE_ICON"
fi

if is_liked "${track_uri##*:}"; then
  liked="$LIKED_ICON"
else
  liked="$UNLIKED_ICON"
fi

echo "$play_icon $track_name $liked"
