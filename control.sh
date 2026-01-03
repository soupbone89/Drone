#!/bin/bash

console=$(xdotool getactivewindow)

control=$(xwininfo | grep 'xwininfo:' | awk '{print $4}')
xdotool windowfocus $control

X=$(xwininfo -id $control | grep 'Absolute upper-left X:' | awk '{print $4}')
Y=$(xwininfo -id $control | grep 'Absolute upper-left Y:' | awk '{print $4}')

left_stick_x=$[$X+123]
left_stick_y=$[$Y+321]
right_stick_x=$[$X+456]
right_stick_y=$[$Y+321]

xdotool windowfocus $console

while read -rsn 1 key
do
    case "$key" in
        'A')
            echo 'throttle up'
            xdotool mousemove $left_stick_x $left_stick_y
            xdotool mousedown 1
            xdotool mousemove_relative -- '0' '-50'
            xdotool mouseup 1
        ;;
        'B')
            echo 'throttle down'
            xdotool mousemove $left_stick_x $left_stick_y
            xdotool mousedown 1
            xdotool mousemove_relative -- '0' '50'
            xdotool mouseup 1
        ;;
        'w')
            echo 'pitch forward'
            xdotool mousemove $right_stick_x $right_stick_y
            xdotool mousedown 1
            xdotool mousemove_relative -- '0' '-50'
            xdotool mouseup 1
        ;;
        's')
            echo 'pitch back'
            xdotool mousemove $right_stick_x $right_stick_y
            xdotool mousedown 1
            xdotool mousemove_relative -- '0' '50'
            xdotool mouseup 1
        ;;
        'a')
            echo 'roll left'
            xdotool mousemove $right_stick_x $right_stick_y
            xdotool mousedown 1
            xdotool mousemove_relative -- '-50' '0'
            xdotool mouseup 1
        ;;
        'd')
            echo 'roll right'
            xdotool mousemove $right_stick_x $right_stick_y
            xdotool mousedown 1
            xdotool mousemove_relative -- '50' '0'
            xdotool mouseup 1
        ;;
        'q')
            echo 'yaw left'
            xdotool mousemove $left_stick_x $left_stick_y
            xdotool mousedown 1
            xdotool mousemove_relative -- '-50' '0'
            xdotool mouseup 1
        ;;
        'e')
            echo 'yaw right'
            xdotool mousemove $left_stick_x $left_stick_y
            xdotool mousedown 1
            xdotool mousemove_relative -- '50' '0'
            xdotool mouseup 1
        ;;
    esac
done

xdotool windowfocus $console
