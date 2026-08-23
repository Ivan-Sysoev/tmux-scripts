#!/usr/bin/env bash
# 🌦️  +15°C — погода без локации. Вызывается из weather_wrapper.sh,
# он же кэширует ответ (INTERVAL=1200), поэтому здесь просто curl.
# Аргументы дракулы: $1 fahrenheit, $2 show_location, $3 location, $4 hide_errors
export LC_ALL=en_US.UTF-8

LOCATION="${3:-Saint-Petersburg}"

weather=$(curl -sf --max-time 3 "https://wttr.in/${LOCATION// /%20}?format=%c%t&m" | tr -d '+')
weather=${weather//$'\xef\xb8\x8f'/}  # U+FE0F: iTerm рисует его в 1 колонку, tmux считает 2 -> серая дырка справа
[ -n "$weather" ] && printf '%s  %s' "${weather%% *}" "${weather#* }"
