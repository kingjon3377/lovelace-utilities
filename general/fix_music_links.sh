#!/bin/sh
called_path=$_
fml_link() {
	if [ -n "${VERBOSE}" ];then
		echo "Linking ${1} to ${2}"
	fi
	ln -f "${1}" "${2}"
}
fix_music_links() {
	ORIG_PWD="${PWD}"
	cd ~/music || return
	for dir in favorites/sorted xmas easter/sorted ; do
		regex="s:^Files ${dir}/\([^ ]*\) and sorted/\1 differ\$:\1:"
		for file in $(diff -rq ${dir} sorted|grep -v "^Only in sorted"|\
				grep -v '^Only in xmas: itunes$' |\
				grep -v '^Only in xmas: choirs$' |\
				sed -e "${regex}");do 
			fml_link "sorted/${file}" "${dir}/${file}"
		done
	done
	for dir in xmas/itunes favorites/itunes easter/itunes;do
		regex="s:^Files ${dir}/\([^ ]*\) and itunes/\1 differ\$:\1:"
		for file in $(diff -rq ${dir} itunes|\
				grep -v "^Only in itunes[:/]"|\
				sed -e "${regex}");do
			fml_link "itunes/${file}" "${dir}/${file}"
		done
	done
	for dir in xmas/choirs favorites/choirs easter/choirs ;do
		regex="s:^Files ${dir}/\([^ ]*\) and choirs/\1 differ\$:\1:"
		for file in $(diff -rq ${dir} choirs|\
				grep -v "^Only in choirs[:/]"|\
				sed -e "${regex}");do
			fml_link "choirs/${file}" "${dir}/${file}"
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
