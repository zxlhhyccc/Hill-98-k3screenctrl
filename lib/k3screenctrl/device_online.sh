#!/bin/sh
file=/tmp/k3screenctrl/device_online
if [ $# -eq 0 ]; then
    pid=$(pidof $(basename $0) | sed 's/'$$'//')
    kill -9 $pid >/dev/null 2>&1
    # echo $$ > $pid_file
    # device_list=$(grep -w br-lan /proc/net/arp | grep -w 192.168 | awk '{print $1}')
    device_list=$(cat $(uci get dhcp.@dnsmasq[0].leasefile) | awk '{print $3}')
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
    sleep 60
    $0 &
    # rm $pid_file
else
    device=$1
    arping -I br-lan -f -w 1 -q $device
    c=$?
    i="$(grep $device $file)"
    if [ -z "$i" ]; then
        echo "$device $c" >> $file
    else
        sed -i 's/'"$i"'/'$device' '$c'/' $file
    fi
fi