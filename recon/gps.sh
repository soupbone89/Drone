#!/bin/bash

gpsd -N /dev/ttyACM0 -D 5 | while read line
do
    echo "$line"
    if echo "$line" | fgrep -q 'GPS:'; then
        led green on 2> /dev/null
    fi
done
