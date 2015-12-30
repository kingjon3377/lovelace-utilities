#!/bin/sh
called_path=$_
# TODO: Use bash arrays (specifying /bin/bash) for sites to test?
if [ "${cm_called_path}" = "$0" ]; then
    if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
            [ -f "${HOME}/Library/Application Support/lovelace-utilities/config" ]; then
        . "${HOME}/Library/Application Support/lovelace-utilities/config"
    elif [ -n "${XDG_CONFIG_HOME:-${HOME}/.config}" ] && [ -d "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities" ] && \
            [ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config" ]; then
        . "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config"
    else
        SITES_TO_TEST="172.16.42.1 8.8.8.8 google.com"
    fi
fi
test_connection() {
	for a in ${SITES_TO_TEST}; do
		ping -c 1 "${a}" || { /sbin/route -n; return; }
	done
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        test_connection "$@"
fi
