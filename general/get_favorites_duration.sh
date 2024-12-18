#!/bin/bash
cm_called_path="${BASH_SOURCE[0]}"
# shellcheck source=./lovelace-utilities-source-config.sh
. "${cm_called_path%/*}/lovelace-utilities-source-config.sh" || return 1
get_favorites_duration() {
	lovelace_utilities_source_config
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		MUSIC_COLLECTION=${MUSIC_COLLECTION:-/home/kingjon/music/favorites}
	fi
	find "${MUSIC_COLLECTION}" -type f -print0 | xargs -0 midentify 2>/dev/null | perl -nle '/ID_LENGTH=([0-9\.]*)/ && ($t += $1) && printf "%d days %02d:%02d:%02d\n",$t/86400,$t% 86400 / 3600,$t/60%60,$t%60' | tail -n 1
}
[ "${BASH_SOURCE[0]}" = "$0" ] && get_favorites_duration "$@"
