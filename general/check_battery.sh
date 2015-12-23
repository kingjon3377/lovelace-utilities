#!/bin/sh
# TODO: Should we source the config file unconditionally? If so, should we define BATT_DIR globally?
if [ "${BASH_SOURCE}" = "$0" ];then
    if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
            [ -f "${HOME}/Library/Application Support/lovelace-utilities/config" ]; then
        source "${HOME}/Library/Application Support/lovelace-utilities/config"
    elif [ -n "${XDG_CONFIG_HOME}" ] && [ -d "${XDG_CONFIG_HOME}/lovelace-utilities" ] && \
            [ -f "${XDG_CONFIG_HOME}/lovelace-utilities/config" ]; then
        source "${XDG_CONFIG_HOME}/lovelace-utilities/config"
    else
        BATT_DIR=${BATT_DIR:-/sys/class/power_supply/BAT1}
        BATT_STATUS_FILE=${BATT_STATUS_FILE:-${BATT_DIR}/status}
        BATT_EN_NOW_FILE=${BATT_EN_NOW_FILE:-${BATT_DIR}/energy_now}
        BATT_EN_FULL_FILE=${BATT_EN_FULL_FILE:-${BATT_DIR}/energy_full}
    fi
fi
SYS_DIR=/sys/class/power_supply/BAT1
bat_status=$(cat "${BATT_STATUS_FILE}"})
en_now=$(cat "${BATT_EN_NOW_FILE}")
en_full=$(cat "${BATT_EN_FULL_FILE}")
percentage=$(echo "${en_now}" / "${en_full}" '*' 100 | bc -l | sed 's/\..*//')
echo "${bat_status}: ${en_now} / ${en_full} (${percentage}%)"
if test -x /usr/bin/upower; then
    upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep -E 'state|time\ to|percentage'
fi
#echo "$(cat ${SYS_DIR}/status): $(cat ${SYS_DIR}/energy_now) / $(cat ${SYS_DIR}/energy_full)"
#cat /proc/acpi/battery/BAT1/state
