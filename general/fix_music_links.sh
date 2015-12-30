#!/bin/sh
called_path=$_
# TODO: Should we source the config file unconditionally? If so, should we define MUSIC_COLLECTION etc. globally?
if [ "${BASH_SOURCE}" = "$0" ];then
    if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
            [ -f "${HOME}/Library/Application Support/lovelace-utilities/config-bash" ]; then
        source "${HOME}/Library/Application Support/lovelace-utilities/config-bash"
    elif [ -n "${XDG_CONFIG_HOME:-${HOME}/.config}" ] && [ -d "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities" ] && \
            [ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config-bash" ]; then
        source "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config-bash"
    else
        MUSIC_COLLECTION=/home/kingjon/music
        MUSIC_ROOT_DIRS=( choirs itunes sorted )
        MUSIC_FAVORITES_DIRS=( favorites xmas easter )
    fi
fi
fml_link() {
	if [ -n "${VERBOSE}" ];then
		echo "Linking ${1} to ${2}"
	fi
	ln -f "${1}" "${2}"
}
fix_music_links() {
	ORIG_PWD="${PWD}"
	cd "${MUSIC_COLLECTION}" || return
    for root_dir in "${MUSIC_ROOT_DIRS[@]}"; do
        for favorite_dir in "${MUSIC_FAVORITES_DIRS[@]}"; do
            regex="s:^Files ${favorite_dir}/${root_dir}/\([^ ]*\) and ${root_dir}/\1 differ\$:\1:"
            for file in $(diff -rq "${root_dir}" "${favorite_dir}/${root_dir}"|grep -v "^Only in ${root_dir}"|\
                    sed -e "${regex}");do
                fml_link "${root_dir}/${file}" "${favorite_dir}/${root_dir}/${file}"
            done
		done
	done
	cd "${ORIG_PWD}" || return
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        fix_music_links "$@"
fi
