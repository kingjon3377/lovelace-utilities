#!/bin/bash
# Shell arrays are a bashism, so we use the nonportable but more reliable way
# of detecting sourceing.
if [ "${BASH_SOURCE}" = "$0" ];then
    if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
            [ -f "${HOME}/Library/Application Support/lovelace-utilities/config-bash" ]; then
        source "${HOME}/Library/Application Support/lovelace-utilities/config-bash"
    elif [ -n "${XDG_CONFIG_HOME:-${HOME}/.config}" ] && [ -d "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities" ] && \
            [ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config-bash" ]; then
        source "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config-bash"
    else
        DIRS_TO_SYNC=(  )
        HOSTS_TO_SYNC=( )
    fi
fi
synchronize() {
#	case $(hostname) in
#	myrriddium)
	[ -n "${DISPLAY}" ] && [ -z "${GRAPHICAL_SYNC}" ] && local DISPLAY=""
	cd "${HOME}" || return 2
	ALIVE_HOSTS=()
	for host in "${HOSTS_TO_SYNC[@]}"; do
		if [ "${host}" = "$(hostname)" ]; then
			# Don't synchronize with ourself
			continue
		elif ping -c1 "${host}.local" > /dev/null 2>&1; then
			ALIVE_HOSTS+=( "${host}.local" )
		elif ping -c1 "${host}" > /dev/null 2>&1; then
			ALIVE_HOSTS+=( "${host}" )
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
				pushd "${a}" > /dev/null
				./.synchronize.sh "${host}" || return $?
				popd > /dev/null
			fi
			unison "${a}" "ssh://${host}/${a}" || return $?
			if [ -x "${a}/.postsync.sh" ];then
				pushd "${a}" > /dev/null
				./.postsync.sh "${host}" || return $?
				popd > /dev/null
			fi
		done
	done
}

if [ "${BASH_SOURCE}" = "$0" ]; then
        synchronize "$@"
fi
