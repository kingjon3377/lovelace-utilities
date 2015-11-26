#!/bin/sh
called_path=$_
ionice_important() {
	sudo ionice -c 1 -p $(pidof X Xorg xfwm4 gnome-terminal screen xfce4-notifyd xfce4-session xfconfd xfce4-panel xfdesktop xfce4-power-manager xfce4-clipman xfce4-mixer-plugin xfce4-sensors-plugin xfce4-cpufreq-plugin xfce4-power-manager xfsettingsd agetty wpa_supplicant dhcpcd plugin-container xfce4-terminal nscd cfg80211 mplayer mate-session marco lightdm mate-panel caja mate-screensaver mate-power-manager mate-settings-daemon pekwm links mate-terminal gnome-pty-helper)
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        ionice_important "$@"
fi
