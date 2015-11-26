#!/bin/bash
called_path=$_
TARGET_DIR="/home/kingjon/eix.out"
if [ "${BASH_SOURCE}" != "$0" ]; then
#if [ "${called_path}" != "$0" ]; then
        echo "Don\'t source this!"
	return 1
#elif [ $UID -ne 0 ]; then
elif [ "$(id -ru)" -ne 0 ]; then
	exec sudo "$0"
else
	if test \! -d "${TARGET_DIR}"; then
		mkdir -p "${TARGET_DIR}" || exit 2
	fi
	export FORCE_USECOLORS="${FORCE_USECOLORS:-true}" 
	DATE=$(date --rfc-3339=date)
	eix-sync | tee -a "${TARGET_DIR}/${DATE}.$$" || exit 3
#	eix-sync -w | tee -a "${TARGET_DIR}/${DATE}.$$" || exit 3 # emerge-webrsync
#	eix-sync -W | tee -a "${TARGET_DIR}/${DATE}.$$" || exit 3 # emerge-delta-webrsync
	chown kingjon "${TARGET_DIR}/${DATE}.$$" || exit 4
fi
