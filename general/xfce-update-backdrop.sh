#!/bin/sh
if pidof xfdesktop > /dev/null ; then
	if [ -z "${DBUS_SESSION_BUS_ADDRESS}" ] ; then
		newest_script="$(find "${HOME}/.dbus/session-bus" \
								-type f -printf '%T@ %p\n' | 
							sort -n | tail -n 1 | cut -f2- -d' ')"
        # shellcheck source=/dev/null
		. "${newest_script}"
        export DBUS_SESSION_BUS_ADDRESS
	fi
	MONITOR=${1:-0}
	PROPERTY="/backdrop/screen0/monitor${MONITOR}/image-path"
	IMAGE_PATH=$(xfconf-query -c xfce4-desktop -p "${PROPERTY}")
	xfconf-query -c xfce4-desktop -p "${PROPERTY}" -s ""
	xfconf-query -c xfce4-desktop -p "${PROPERTY}" -s "${IMAGE_PATH}"
fi
