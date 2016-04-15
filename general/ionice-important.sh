#!/bin/bash
# We want to use a bashism, a shell array, below, so we use the nonportable but
# more reliable way of detecting the script's directory
# shellcheck source=./lovelace-utilities-source-config.sh
. "${BASH_SOURCE[0]%/*}/lovelace-utilities-source-config.sh"
ionice_important() {
    lovelace_utilities_source_config_bash
    if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
        IO_IMPORTANT_PROGRAMS=( X Xorg xfwm4 gnome-terminal screen xfce4-notifyd xfce4-session xfconfd 
                                xfce4-panel xfdesktop xfce4-power-manager xfce4-clipman xfce4-mixer-plugin
                                xfce4-sensors-plugin xfce4-cpufreq-plugin xfce4-power-manager xfsettingsd
                                agetty wpa_supplicant dhcpcd plugin-container xfce4-terminal nscd cfg80211
                                mplayer mate-session marco lightdm mate-panel caja mate-screensaver 
                                mate-power-manager mate-settings-daemon pekwm links mate-terminal
                                gnome-pty-helper )
    fi
    # ionice takes PIDs as separate arguments, and pidof produces a
    # space-separated list, so they need to be separated by the shell.
    # shellcheck disable=SC2046
	sudo ionice -c 1 -p $(pidof "${IO_IMPORTANT_PROGRAMS[@]}")
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
        ionice_important "$@"
fi
