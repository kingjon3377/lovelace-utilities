#!/bin/bash
# We want to use a bashism, a shell array, below, so we use the nonportable but
# more reliable way of detecting sourceing.
# TODO: Should we source the config file unconditionally? If so, should we define CONT_PROGS globally?
if [ "${BASH_SOURCE}" = "$0" ];then
    if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
            [ -f "${HOME}/Library/Application Support/lovelace-utilities/config-bash" ]; then
        source "${HOME}/Library/Application Support/lovelace-utilities/config-bash"
    elif [ -n "${XDG_CONFIG_HOME}" ] && [ -d "${XDG_CONFIG_HOME}/lovelace-utilities" ] && \
            [ -f "${XDG_CONFIG_HOME}/lovelace-utilities/config-bash" ]; then
        source "${XDG_CONFIG_HOME}/lovelace-utilities/config-bash"
    else
        CONT_PROGS=( nonexistentprogram )
    fi
fi
continue_firefox() {
	if declare -p CONT_PROGS > /dev/null 2>&1; then
		OLDCONTPROGS=( "${CONT_PROGS[@]}" )
	else
		OLDCONTPROGS=( nonexistentprogram )
	fi
	CONT_PROGS=( "${OLDCONTPROGS[@]}" firefox firefox-bin thunderbird thunderbird-bin)
	while pidof "${CONT_PROGS[@]}" >/dev/null
	do
		kill -CONT $(pidof "${CONT_PROGS[@]}")
		sync
		sleep 2
	done
}
if [ "${BASH_SOURCE}" = "$0" ]; then
        continue_firefox "$@" &
fi
