#!/usr/bin/env bash
# 🌦  14°C — погода для статус-бара tmux (dracula, плагин weather).
# Вызывается из weather_wrapper.sh, он же кэширует ответ (INTERVAL=1200).
# Эмодзи намеренно без U+FE0F: iTerm рисует его в 1 колонку, tmux считает 2 -> серая дырка в баре.
export LC_ALL=en_US.UTF-8

LATITUDE=59.95
LONGITUDE=30.4
LAST="/tmp/.weather-last"  # не TMPDIR: у tmux-сервера он свой

# WMO weather code -> эмодзи, https://open-meteo.com/en/docs
function code_to_emoji() {
  case "$1" in
  0)              printf '☀'  ;;
  1 | 2)          printf '🌤'  ;;
  3)              printf '☁'  ;;
  45 | 48)        printf '🌫'  ;;
  51 | 53 | 55)   printf '🌦'  ;;
  56 | 57)        printf '🌨'  ;;
  61 | 63 | 65)   printf '🌧'  ;;
  66 | 67)        printf '🌧❄' ;;
  71 | 73 | 75 | 77) printf '❄' ;;
  80 | 81 | 82)   printf '🌦'  ;;
  85 | 86)        printf '🌨'  ;;
  95)             printf '⛈'  ;;
  96 | 99)        printf '⛈🧊' ;;
  *)              printf '🌡'  ;;
  esac
}

current=$(curl -sf --max-time 3 \
  "https://api.open-meteo.com/v1/forecast?latitude=${LATITUDE}&longitude=${LONGITUDE}&current=temperature_2m,weather_code" |
  jq -r '.current | "\(.temperature_2m) \(.weather_code)"')

if [ -z "$current" ] || [ "$current" = "null null" ]; then
  cat "$LAST" 2>/dev/null  # сеть отвалилась, а wrapper уже обнулил свой кэш -> держим свой
  exit
fi

read -r temperature weather_code <<<"$current"
printf '%s  %.0f°C' "$(code_to_emoji "$weather_code")" "$temperature" | tee "$LAST"
