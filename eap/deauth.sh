#!/bin/bash

mdk4 mon0 d -w <(getmac -i wlan0) $* | while read line 
do echo "$line"
done
