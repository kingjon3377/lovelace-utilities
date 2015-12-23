#!/bin/sh
cm_called_path=$_
if [ "${cm_called_path}" = "$0" ]; then
    if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
            [ -f "${HOME}/Library/Application Support/lovelace-utilities/config" ]; then
        . "${HOME}/Library/Application Support/lovelace-utilities/config"
    elif [ -n "${XDG_CONFIG_HOME}" ] && [ -d "${XDG_CONFIG_HOME}/lovelace-utilities" ] && \
            [ -f "${XDG_CONFIG_HOME}/lovelace-utilities/config" ]; then
        . "${XDG_CONFIG_HOME}/lovelace-utilities/config"
    else
        MUSIC_COLLECTION=/home/kingjon/music/favorites
    fi
fi
get_favorites_duration() {
    find ""${MUSIC_COLLECTION}"" -type f -print0 | xargs -0 midentify 2>/dev/null | perl -nle '/ID_LENGTH=([0-9\.]*)/ && ($t += $1) && printf "%d days %02d:%02d:%02d\n",$t/86400,$t% 86400 / 3600,$t/60%60,$t%60' | tail -n 1
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
[ "${cm_called_path}" = "$0" ] && get_favorites_duration "$@"
#[ "${BASH_SOURCE}" = "$0" ] && get_favorites_duration "$@"
