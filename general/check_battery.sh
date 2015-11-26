#!/bin/sh
SYS_DIR=/sys/class/power_supply/BAT1
bat_status=$(cat ${SYS_DIR}/status)
en_now=$(cat ${SYS_DIR}/energy_now)
en_full=$(cat ${SYS_DIR}/energy_full)
percentage=$(echo "${en_now}" / "${en_full}" '*' 100 | bc -l | sed 's/\..*//')
echo "${bat_status}: ${en_now} / ${en_full} (${percentage}%)"
upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep -E 'state|time\ to|percentage'
#echo "$(cat ${SYS_DIR}/status): $(cat ${SYS_DIR}/energy_now) / $(cat ${SYS_DIR}/energy_full)"
#cat /proc/acpi/battery/BAT1/state
