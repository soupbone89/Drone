#!/bin/bash

essid="$1"

cp /opt/eaphammer/local/hostapd-eaphammer/hostapd/hostapd.conf /tmp/
hostapd-eaphammer.conf
sed -i "s/interface=.*/interface=wlan0/g" /tmp/hostapd-eaphammer.conf
sed -i "s/ssid=.*/ssid=$essid/g" /tmp/hostapd-eaphammer.conf
line
sudo /opt/eaphammer/local/hostapd-eaphammer/hostapd/hostapd-
eaphammer -x /tmp/hostapd-eaphammer.conf | while read
do
  if echo "$line" | fgrep -q 'AP-STA-CONNECTED'; then
    led green on 2> /dev/null
  elif echo "$line" | fgrep -q 'AP-STA-DISCONNECTED'; then
    led green off 2> /dev/null
  elif echo "$line" | fgrep -q 'STA'; then
    led yellow on 2> /dev/null
  elif echo "$line" | fgrep -q 'username:'; then
    led red on 2> /dev/null
  fi
done
