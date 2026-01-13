#!/bin/bash

kismet -c mon0 | while read line
do
    echo "$line"
    if echo "$line" | fgrep -q 'success'; then
        led yellow on 2> /dev/null
    fi
done
