#!/bin/sh
. /etc/os-release

# PRODUCT_NAME_FULL=$(cat /etc/board.json | jsonfilter -e "@.model.name")
# PRODUCT_NAME=${PRODUCT_NAME_FULL#* } # Remove first word to save space
PRODUCT_NAME=${LEDE_DEVICE_PRODUCT}

# WAN_IFNAME=$(uci get network.wan.ifname)
MAC_ADDR=$(cat /tmp/k3screenctrl/macaddr)

HW_VERSION=${LEDE_DEVICE_REVISION:0:2}
FW_VERSION=$(cat /etc/openwrt_version)

echo $PRODUCT_NAME

if [ $(uci get k3screenctrl.@general[0].cputemp) -eq 1 ]; then
    CPU_TEMP=$(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))
    echo $HW_VERSION $CPU_TEMP
else
    echo $HW_VERSION
fi

echo $FW_VERSION
echo $MAC_ADDR