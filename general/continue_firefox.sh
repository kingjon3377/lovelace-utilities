#!/bin/bash
# We want to use a bashism, a shell array, below, so we use the nonportable but
# more reliable way of detecting sourceing.
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
