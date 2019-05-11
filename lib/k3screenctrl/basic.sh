#!/bin/sh
. /etc/os-release
. /etc/openwrt_release

PRODUCT_NAME_FULL=$(cat /etc/board.json | jsonfilter -e "@.model.name")
PRODUCT_NAME=${PRODUCT_NAME_FULL#* } # Remove first word to save space

WAN_IFNAME=$(uci get network.wan.ifname)
MAC_ADDR=$(ifconfig $WAN_IFNAME | grep -oE "([0-9A-Z]{2}:){5}[0-9A-Z]{2}")

CPU_TEMP=$(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))

HW_VERSION_CACHE_FILE=/tmp/hw_version
if [ -e "$HW_VERSION_CACHE_FILE" ]; then
    HW_VERSION=$(cat $HW_VERSION_CACHE_FILE)
else
    HW_VERSION=$(nvram get hd_version)
    echo $HW_VERSION > $HW_VERSION_CACHE_FILE
fi

FW_VERSION=${DISTRIB_REVISION:0:17}

echo $PRODUCT_NAME
if [ $(uci get k3screenctrl.@general[0].cputemp) -eq 1 ]; then
    echo $HW_VERSION $CPU_TEMP
else
    echo $HW_VERSION
fi

echo $FW_VERSION
echo $FW_VERSION
echo $MAC_ADDR