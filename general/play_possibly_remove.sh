#!/bin/sh
called_path=$_
# TODO: Should we source the config file unconditionally? If so, should we define PLAYER_COMMAND globally?
if [ "${cm_called_path}" = "$0" ]; then
    if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
            [ -f "${HOME}/Library/Application Support/lovelace-utilities/config" ]; then
        . "${HOME}/Library/Application Support/lovelace-utilities/config"
    elif [ -n "${XDG_CONFIG_HOME}" ] && [ -d "${XDG_CONFIG_HOME}/lovelace-utilities" ] && \
            [ -f "${XDG_CONFIG_HOME}/lovelace-utilities/config" ]; then
        . "${XDG_CONFIG_HOME}/lovelace-utilities/config"
    else
        PLAYER_COMMAND="mplayer -vo x11"
        # PLAYER_COMMAND="mplayer -novideo"
    fi
fi
play_possibly_remove() {
    local PLAYER_COMMAND=${PLAYER_COMMAND:-mplayer -novideo}
	for a in "$@"; do
		${PLAYER_COMMAND} "${a}" && rm -i "${a}"
	done
}

# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        play_possibly_remove "$@"
fi
