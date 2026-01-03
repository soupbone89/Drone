#!/bin/bash

INTERVAL=1

control=$(xwininfo | grep 'xwininfo:' | awk '{print $4}')

while sleep $INTERVAL
do
    gm import -window $control /tmp/drone_telemetry.png

    gm convert /tmp/drone_telemetry.png -crop 240x60+740+58 /tmp/drone_telemetry-bat.png
    bat=$(tesseract /tmp/drone_telemetry-bat.png stdout -l eng 2>/dev/null | grep '^[0-9]' | awk '{print $1}')

    gm convert /tmp/drone_telemetry.png -crop 240x60+461+58 /tmp/drone_telemetry-alt.png
    alt=$(tesseract /tmp/drone_telemetry-alt.png stdout -l eng 2>/dev/null | grep '^[0-9]')

    if [ "$bat" -lt 10 ]; then
        echo 'low battery' | festival --tts --language english
    fi

    clear
    echo "$bat $alt"

done
