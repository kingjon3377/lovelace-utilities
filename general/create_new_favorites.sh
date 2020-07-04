#!/bin/bash
# We use bashisms, namely bash arrays, so we use the more reliable but
# nonportable method of detecting this script's directory
# shellcheck source=./lovelace-utilities-source-config.sh
. "${BASH_SOURCE[0]%/*}/lovelace-utilities-source-config.sh"
# TODO: Make a way to handle multiple 'favorites' directories (e.g. favorites, easter, xmas) at once
# Creates, or maintains by asking only about files added to the main collection
# since last checked, a "favorites" directory or directories. This relies on
# several environment variables for configuration:
# MUSIC_COLLECTION is the root directory under which the collection is stored.
# MUSIC_ROOT_DIRS is an array of directories under that root to consider files from.
# MUSIC_FAVORITES_DIRS is an array of "favorites"-type directories to maintain,
# also under that root. Each will have "favorite" music hardlinked into it in a
# tree mirroring the main collection.
create_new_favorites() {
	lovelace_utilities_source_config_bash
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		MUSIC_COLLECTION=${MUSIC_COLLECTION:-/home/kingjon/music}
		MUSIC_ROOT_DIRS=( sorted )
		MUSIC_FAVORITES_DIRS=( favorites xmas easter )
		PLAYER_COMMAND=${PLAYER_COMMAND:-mplayer}
	fi
	if ! pushd "${MUSIC_COLLECTION}" > /dev/null; then
		echo "Couldn't enter MUSIC_COLLECTION root directory" 1>&2
		return 3
	fi
	for dir in "${MUSIC_FAVORITES_DIRS[@]}";do
		mkdir -p "${dir}"
	done
	PIPE=$(mktemp -u)
	mkfifo -m600 "${PIPE}"
	find "${MUSIC_ROOT_DIRS[@]}" -type f | sort >"${PIPE}" &
	exec 3<"${PIPE}"
	while read -r -u 3 file; do
		local missingfavorites=()
		for collection in "${MUSIC_FAVORITES_DIRS[@]}";do
			if ! grep -q -x -F "${MUSIC_COLLECTION}/${file}" "checked-${collection}.txt" && \
					! test -f "${MUSIC_COLLECTION}/${collection}/${file}"; then
				missingfavorites+=("${collection}")
			fi
		done
		if test "${#missingfavorites}" -eq 0; then
			continue
		fi
		"${PLAYER_COMMAND}" "${MUSIC_COLLECTION}/${file}" || return
		for collection in "${missingfavorites[@]}";do
			if ! pushd "${MUSIC_COLLECTION}/${collection}" > /dev/null; then
				echo "Couldn't enter subdirectory ${collection}; continuing ..." 1>&2
				continue
			fi
			response=$(grabchars -cyn -n1 -b -L -f -t10 -dn \
				-q"Include ${file} in '${collection}'? ")
			echo
			if test "${response}" = 'y'; then
				mkdir -p "$(dirname "${file}")"
				cp -l "${MUSIC_COLLECTION}/${file}" "${file}"
			elif test "${response}" = 'n'; then
				:
			else
				echo "grabchars isn't working anymore!" 1>&2
				break
			fi
			if ! popd > /dev/null; then
				echo "Failed to leave ${collection} subdirectory. Aborting!" 1>&2
				return 3
			fi
			echo "${MUSIC_COLLECTION}/${file}" >> "${MUSIC_COLLECTION}/checked-${collection}.txt"
		done
		response=$(grabchars -cyn -n1 -b -L -f -t10 -dy -q"Keep going? ")
		echo
		if test "${response}" = 'n'; then
			break
		elif test "${response}" = 'y'; then
			:
		else
			echo "grabchars isn't working anymore!" 1>&2
			break
		fi
	done
	rm "${PIPE}"
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	create_new_favorites "$@"
fi
