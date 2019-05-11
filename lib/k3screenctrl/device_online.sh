#!/bin/sh
file=/tmp/k3screenctrl/device_online
if [ $# -eq 0 ]; then
    device_list=$(cat $(uci get dhcp.@dnsmasq[0].leasefile) | grep $(uci get network.lan.ipaddr | awk -F . '{print $1"."$2"."$3"."}') | awk '{print $3}')
    [ -s $file ] || {
        for device in $device_list
        do
            echo "$device 0" >> $file
        done
    }
    for device in $device_list
    do
        $0 $device >/dev/null 2>&1 &
    done
else
    device=$1
    arping -f -q -w 3 -I br-lan $device
    c=$?
    i="$(grep $device $file)"
    if [ -z "$i" ]; then
        echo "$device $c" >> $file
    else
        sed -i 's/'"$i"'/'$device' '$c'/' $file
    fi
fi