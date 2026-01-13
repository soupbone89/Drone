#!/bin/bash

dumpfile="pmkid-$(date +'%H:%M:%S_%d.%m.%Y')"

hcxdumptool -i mon0 --enable_status=7 -o $dumpfile.pcapng \
--disable_client_attacks --disable_deauthentication $* | while read line
do
    if echo "$line" | grep -q 'PMKIDROGUE:'; then
        led yellow on 2> /dev/null
    fi
done

tcpdump -r $dumpfile.pcapng -nn -w $dumpfile.pcap
rm -f $dumpfile.pcapng
