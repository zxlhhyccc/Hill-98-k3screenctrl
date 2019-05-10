#!/bin/sh

. /lib/network/config.sh
. /lib/functions.sh


function encodeurl(){
	url=`echo $1 | tr -d '\n' | od -x |awk '{
		w=split($0,linedata," ");
		for (j=2;j<w+1;j++)
		{
			for (i=7;i>0;i=i-2)
			{
				if (substr(linedata[j],i,2) != "00") {printf "%" ;printf toupper(substr(linedata[j],i,2));}
			}
		}
	}'`
	url_tmp=`echo $url | sed 's/.\{2\}/&%/g' | sed 's/.$//'`
	echo %$url_tmp
}

update_weather=0

update_time=$(uci get k3screenctrl.@general[0].update_time 2>/dev/null)

if [ -z "$update_time" ]; then
	update_time=3600
fi


cur_time=`date +%s`
last_time=`cat /tmp/weather_time 2>/dev/null`
if [ -z "$last_time" ]; then
	update_weather=1
	echo $cur_time > /tmp/weather_time
else
	time_tmp=`expr $cur_time - $last_time`
	if [ $time_tmp -ge $update_time ]; then
		update_weather=1
		echo $cur_time > /tmp/weather_time
	fi	
fi


DATE=$(date "+%Y-%m-%d %H:%M")
DATE_DATE=$(echo $DATE | awk '{print $1}')
DATE_TIME=$(echo $DATE | awk '{print $2}')
DATE_WEEK=$(date "+%u")
if [ "$DATE_WEEK" == "7" ]; then
	DATE_WEEK=0
fi


city_checkip=0
city_checkip=$(uci get k3screenctrl.@general[0].city_checkip 2>/dev/null)


if [ "$city_checkip" = "1" ]; then
	city_tmp=`cat /tmp/weather_city 2>/dev/null`
	if [ -z "$city_tmp" ]; then
		wan_city=`curl -s http://pv.sohu.com/cityjson | awk -F"=" '{print $2}' | sed 's/;//g'`
		wanip=`echo $wan_city | jq ".cip" | sed 's/"//g'`
		city_json=`curl -s http://ip.taobao.com/service/getIpInfo.php?ip=$wanip`
		ip_city=`echo $city_json | jq ".data.city" | sed 's/"//g'`
		ip_county=`echo $city_json | jq ".data.county" | sed 's/"//g'`
		if [ "$ip_county" != "XX" ]; then
			city=`echo $ip_county`
		else
			city=`echo $ip_city`
		fi
		echo $city > /tmp/weather_city
		uci set k3screenctrl.@general[0].city=$city
		uci commit k3screenctrl
	else
		city=`echo $city_tmp`
	fi
else
	city=$(uci get k3screenctrl.@general[0].city 2>/dev/null)
fi
#echo $city

weather_info=$(cat /tmp/k3-weather.json 2>/dev/null)
if [ -z "$weather_info" ]; then
	update_weather=1
fi

: << !
#get weather data
if [ "$update_weather" = "1" ]; then
	rm -rf /tmp/k3-weather.gz
	wget http://wthrcdn.etouch.cn/weather_mini?city=$city -O /tmp/k3-weather.gz 2>/dev/null
	gzip -d -c /tmp/k3-weather.gz > /tmp/k3-weather.json
fi

weather_json=$(cat /tmp/k3-weather.json 2>/dev/null)
WENDU=`echo $weather_json | jq ".data.wendu" | sed 's/"//g'`
TYPE=`echo $weather_json | jq ".data.forecast[0].type" | sed 's/"//g'`

!

if [ "$update_weather" = "1" ]; then
	city_name=$(encodeurl $city)
	rm -rf /tmp/k3-weather.json
	wget "http://api.seniverse.com/v3/weather/now.json?key=smtq3n0ixdggurox&location=$city_name&language=zh-Hans&unit=c" -O /tmp/k3-weather.json 2>/dev/null
fi

weather_json=$(cat /tmp/k3-weather.json 2>/dev/null)
WENDU=`echo $weather_json | jq ".results[0].now.temperature" | sed 's/"//g'`
TYPE=`echo $weather_json | jq ".results[0].now.code" | sed 's/"//g'`

#output weather data
echo $city
echo $WENDU
echo $DATE_DATE
echo $DATE_TIME
echo $TYPE
echo $DATE_WEEK
echo 0



