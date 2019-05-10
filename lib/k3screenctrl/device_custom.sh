#!/bin/sh
file=/tmp/k3screenctrl/device_custom
x=$(uci show k3screenctrl | grep -c =device_custom)
for i in $(seq 1 $x)
do
        uci_get="uci -q get k3screenctrl.@device_custom[$(($i - 1))]"
        mac=$($uci_get.mac)
        name=$($uci_get.name)
        icon=$($uci_get.icon)
        [ -z "$name" ] && name="?"
        [ $icon -eq 0 ] && icon=""
        echo $mac $name $icon >> $file
done
echo $x >> $file