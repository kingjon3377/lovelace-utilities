#!/bin/sh
# We want to use a bashism, a shell array, below, so we use the nonportable but
# more reliable way of detecting sourceing.
# TODO: Should we source the config file unconditionally? If so, should we define IO_IMPORTANT_PROGRAMS globally?
if [ "${BASH_SOURCE}" = "$0" ];then
    if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
            [ -f "${HOME}/Library/Application Support/lovelace-utilities/config-bash" ]; then
        source "${HOME}/Library/Application Support/lovelace-utilities/config-bash"
    elif [ -n "${XDG_CONFIG_HOME:-${HOME}/.config}" ] && [ -d "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities" ] && \
            [ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config-bash" ]; then
        source "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config-bash"
    else
        IO_IMPORTANT_PROGRAMS=( X Xorg xfwm4 gnome-terminal screen xfce4-notifyd xfce4-session xfconfd 
                                xfce4-panel xfdesktop xfce4-power-manager xfce4-clipman xfce4-mixer-plugin
                                xfce4-sensors-plugin xfce4-cpufreq-plugin xfce4-power-manager xfsettingsd
                                agetty wpa_supplicant dhcpcd plugin-container xfce4-terminal nscd cfg80211
                                mplayer mate-session marco lightdm mate-panel caja mate-screensaver 
                                mate-power-manager mate-settings-daemon pekwm links mate-terminal
                                gnome-pty-helper )
    fi
fi
ionice_important() {
	sudo ionice -c 1 -p $(pidof "${IO_IMPORTANT_PROGRAMS[@]}")
}
if [ "${BASH_SOURCE}" = "$0" ]; then
        ionice_important "$@"
fi
