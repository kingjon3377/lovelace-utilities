#!/bin/bash
# called_path=$_
# We use arrays for MUSIC_ROOT_DIRS and MUSIC_FAVORITES_DIRS, so bash-only
# shellcheck source=./lovelace-utilities-source-config.sh
. "${BASH_SOURCE[0]%/*}/lovelace-utilities-source-config.sh"
fml_link() {
	if [ -n "${VERBOSE}" ];then
		echo "Linking ${1} to ${2}"
	fi
	ln -f "${1}" "${2}"
}
fix_music_links() {
	lovelace_utilities_source_config_bash
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		MUSIC_COLLECTION=${MUSIC_COLLECTION:-${HOME}/music}
		MUSIC_ROOT_DIRS=( sorted )
		MUSIC_FAVORITES_DIRS=( favorites xmas easter )
	fi
	ORIG_PWD="${PWD}"
	cd "${MUSIC_COLLECTION}" || return
	for root_dir in "${MUSIC_ROOT_DIRS[@]}"; do
		for favorite_dir in "${MUSIC_FAVORITES_DIRS[@]}"; do
			regexOne="s:^Files ${favorite_dir}/${root_dir}/\\([^ ]*\\) and ${root_dir}/\\1 differ\$:\\1:"
			regexTwo="s:^Files ${root_dir}/\\([^ ]*\\) and ${favorite_dir}/${root_dir}/\\1 differ\$:\\1:"
			for file in $(diff -rq "${root_dir}" "${favorite_dir}/${root_dir}"|\
					grep -v -e "^Only in ${root_dir}"\
						-e "^Only in ${favorite_dir}/${root_dir}"|\
					sed -e "${regexOne}" -e "${regexTwo}");do
				fml_link "${root_dir}/${file}" "${favorite_dir}/${root_dir}/${file}"
			done
		done
	done
	cd "${ORIG_PWD}" || return
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
#if [ "${called_path}" = "$0" ]; then
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	fix_music_links "$@"
fi
