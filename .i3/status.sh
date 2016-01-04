#!/bin/sh
# shell script to prepend i3status with more stuff

i3status | while :
do
        uname=$(uname -r)
        read line
        echo "$uname | $line" || exit 1
done
