#!/bin/bash
# Shell arrays are a bashism, so we use the nonportable but more reliable way
# of detecting the script's location
# shellcheck source=./lovelace-utilities-source-config.sh
. "${BASH_SOURCE[0]%/*}/lovelace-utilities-source-config.sh"
synchronize() {
	lovelace_utilities_source_config_bash
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		DIRS_TO_SYNC=(  )
		HOSTS_TO_SYNC=( )
	fi
	[ -n "${DISPLAY}" ] && [ -z "${GRAPHICAL_SYNC}" ] && local DISPLAY=""
	cd "${HOME}" || return 2
	same_uname() {
		test "$(uname)" = "$(ssh "${1}" uname)" || test "${IGNORE_UNAME:-false}" = true
	}
	ALIVE_HOSTS=()
	for host in "${HOSTS_TO_SYNC[@]}"; do
		if [ "${host}" = "$(hostname)" ]; then
			# Don't synchronize with ourself
			continue
		elif ping -c1 "${host}.local" > /dev/null 2>&1; then
			if same_uname "${host}.local"; then
				ALIVE_HOSTS+=( "${host}.local" )
			else
				echo "${host} is booted into a different OS, skipping ..." 1>&2
				continue
			fi
		elif ping -c1 "${host}" > /dev/null 2>&1; then
			if same_uname "${host}"; then
				ALIVE_HOSTS+=( "${host}" )
			else
				echo "${host} is booted into a different OS, skipping ..." 1>&2
				continue
			fi
		else
			echo "${host} is not available" 1>&2
			continue
		fi
	done
	for a in "${DIRS_TO_SYNC[@]}"
	do
		for host in "${ALIVE_HOSTS[@]}"
		do
			if [ ! -d "${a}" ]; then
				echo "No such directory ~/${a}" 1>&2
				continue
			fi
			if [ -x "${a}/.synchronize.sh" ]; then
				if pushd "${a}" > /dev/null; then
					./.synchronize.sh "${host}" || return $?
					if ! popd > /dev/null; then
						echo "Failed to return from ${a}. Aborting!" 1>&2
						return 5
					fi
				else
					echo "Failed to enter ${a} for pre-unison sync" 1>&2
				fi
			fi
			unison "${a}" "ssh://${host}/${a}" || return $?
			if [ -x "${a}/.postsync.sh" ];then
				if pushd "${a}" > /dev/null; then
					./.postsync.sh "${host}" || return $?
					if ! popd > /dev/null; then
						echo "Failed to return from ${a}. Aborting!" 1>&2
						return 5
					fi
				else
					echo "Failed to enter ${a} for post-unison script" 1>&2
				fi
			fi
		done
	done
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	synchronize "$@"
fi
