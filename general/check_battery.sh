#!/bin/sh
cb_called_path=$_
. "${cb_called_path%/*}/lovelace-utilities-source-config.sh" || return 1
check_battery() {
    lovelace_utilities_source_config
    if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
        BATT_NUM=${BATT_NUM:-BAT1}
        BATT_DIR=${BATT_DIR:-/sys/class/power_supply/${BATT_NUM}}
        BATT_STATUS_FILE=${BATT_STATUS_FILE:-${BATT_DIR}/status}
        BATT_EN_NOW_FILE=${BATT_EN_NOW_FILE:-${BATT_DIR}/energy_now}
        BATT_EN_FULL_FILE=${BATT_EN_FULL_FILE:-${BATT_DIR}/energy_full}
    fi
    SYS_DIR=/sys/class/power_supply/BAT1
    bat_status=$(cat "${BATT_STATUS_FILE}"})
    en_now=$(cat "${BATT_EN_NOW_FILE}")
    en_full=$(cat "${BATT_EN_FULL_FILE}")
    percentage=$(echo "${en_now}" / "${en_full}" '*' 100 | bc -l | sed 's/\..*//')
    echo "${bat_status}: ${en_now} / ${en_full} (${percentage}%)"
    if test -x /usr/bin/upower; then
        upower -i "/org/freedesktop/UPower/devices/battery_${BATT_NUM}" | grep -E 'state|time\ to|percentage'
    fi
    #echo "$(cat ${SYS_DIR}/status): $(cat ${SYS_DIR}/energy_now) / $(cat ${SYS_DIR}/energy_full)"
    #cat /proc/acpi/battery/BAT1/state
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
[ "${cb_called_path}" = "$0" ] && check_mp3 "$@"
#[ "${BASH_SOURCE}" = "$0" ] && check_mp3 "$@"
