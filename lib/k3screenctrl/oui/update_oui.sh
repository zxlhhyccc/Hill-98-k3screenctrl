#!/bin/sh
md5=$(wget -qO- http://cdn.mivm.cn/OpenWrt/k3screenctrl/oui.txt.md5)
[ $? -ne 0 ] && exit 1
md5=$(echo $md5 | awk '{print $2}' | tr '[A-Z]' '[a-z]')
md5sum=$(md5sum /lib/k3screenctrl/oui/oui.txt | awk '{print $1}')
[ "$md5" = "$md5sum" ] && exit 0
wget http://cdn.mivm.cn/OpenWrt/k3screenctrl/oui.txt -qO /tmp/oui.txt
[ $? -eq 0 ] && mv /tmp/oui.txt /lib/k3screenctrl/oui/oui.txt