#!/bin/bash
# We want to use a bashism, a shell array, below, so we use the nonportable but
# more reliable way of detecting sourceing.
# shellcheck source=./lovelace-utilities-source-config.sh
. "${BASH_SOURCE[0]%/*}/lovelace-utilities-source-config.sh"
continue_firefox() {
    lovelace_utilities_source_config_bash
    if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
        CONT_PROGS=( nonexistentprogram )
    fi
	if declare -p CONT_PROGS > /dev/null 2>&1; then
		OLDCONTPROGS=( "${CONT_PROGS[@]}" )
	else
		OLDCONTPROGS=( nonexistentprogram )
	fi
	CONT_PROGS=( "${OLDCONTPROGS[@]}" firefox firefox-bin thunderbird thunderbird-bin)
	while pidof "${CONT_PROGS[@]}" >/dev/null
	do
        # pidof produces a space-separated list, each of which needs to be taken separately by kill
        # shellcheck disable=SC2046
		kill -CONT $(pidof "${CONT_PROGS[@]}")
		sync
		sleep 2
	done
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
        continue_firefox "$@" &
fi
