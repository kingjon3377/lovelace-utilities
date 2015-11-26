#!/bin/sh
if pidof xfdesktop > /dev/null ; then
	if [ -z "${DBUS_SESSION_BUS_ADDRESS}" ] ; then
        	newest_script="${HOME}/.dbus/session-bus/$(ls -rt "${HOME}/.dbus/session-bus/" | tail -1)"
		. "${newest_script}"
        	export DBUS_SESSION_BUS_ADDRESS
	fi
	MONITOR=${1:-0}
	PROPERTY="/backdrop/screen0/monitor${MONITOR}/image-path"
	IMAGE_PATH=$(xfconf-query -c xfce4-desktop -p "${PROPERTY}")
	xfconf-query -c xfce4-desktop -p "${PROPERTY}" -s ""
	xfconf-query -c xfce4-desktop -p "${PROPERTY}" -s "${IMAGE_PATH}"
fi
