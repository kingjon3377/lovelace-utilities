#!/bin/bash
# shellcheck source=./lovelace-utilities-source-config.sh
. "${BASH_SOURCE[0]%/*}/lovelace-utilities-source-config.sh"
test_music_links() {
    lovelace_utilities_source_config_bash
    if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
        MUSIC_COLLECTION=${MUSIC_COLLECTION:-${HOME}/music}
        MUSIC_ROOT_DIRS=( choirs itunes sorted )
        MUSIC_FAVORITES_DIRS=( favorites xmas easter )
    fi
	OLD_PWD="${PWD}"
	cd "${MUSIC_COLLECTION}" || return
    for root_dir in "${MUSIC_ROOT_DIRS[@]}"; do
        for favorite_dir in "${MUSIC_FAVORITES_DIRS[@]}"; do
            regex="s:^Files ${favorite_dir}/${root_dir}/\([^ ]*\) and ${root_dir}/\1 differ\$:\1:"
            diff -rq "${root_dir}" "${favorite_dir}/${root_dir}"|grep -v "^Only in ${root_dir}"|\
                sed -e "${regex}"
        done
    done
    # No point in returning if last command in function fails
    # shellcheck disable=SC2164
	cd "${OLD_PWD}"
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
#if [ "${called_path}" = "$0" ]; then
if [ "${BASH_SOURCE}" = "$0" ]; then
        test_music_links "$@"
fi
