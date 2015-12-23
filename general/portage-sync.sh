#!/bin/bash
called_path=$_
if [ "${BASH_SOURCE}" != "$0" ]; then
#if [ "${called_path}" != "$0" ]; then
        echo "Don\'t source this!"
	return 1
#elif [ $UID -ne 0 ]; then
elif [ "$(id -ru)" -ne 0 ]; then
	exec sudo TARGET_DIR="${TARGET_DIR:-${HOME}/eix.out}" TARGET_USER="${TARGET_USER:-${USER}}" SYNC_FLAG="${SYNC_FLAG:-""}" "$0"
else
    TARGET_DIR="${TARGET_DIR:-${HOME}/eix.out}"
    TARGET_USER="${TARGET_USER:-${USER}}"
	if test \! -d "${TARGET_DIR}"; then
		mkdir -p "${TARGET_DIR}" || exit 2
	fi
	export FORCE_USECOLORS="${FORCE_USECOLORS:-true}" 
	DATE=$(date --rfc-3339=date)
	eix-sync ${SYNC_FLAG:-} | tee -a "${TARGET_DIR}/${DATE}.$$" || exit 3
#	eix-sync -w | tee -a "${TARGET_DIR}/${DATE}.$$" || exit 3 # emerge-webrsync
#	eix-sync -W | tee -a "${TARGET_DIR}/${DATE}.$$" || exit 3 # emerge-delta-webrsync
	chown "${TARGET_USER}" "${TARGET_DIR}/${DATE}.$$" || exit 4
fi
