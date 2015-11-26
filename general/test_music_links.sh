#!/bin/sh
called_path=$_
test_music_links() {
	OLD_PWD="${PWD}"
	cd ~/music || return
	for dir in favorites/sorted easter/sorted xmas;do
		regex="s:^Files ${dir}/\([^ ]*\) and sorted/\1 differ\$:\1:"
		diff -rq ${dir} sorted|grep -v -e "^Only in sorted" \
				-e "^Only in xmas: itunes$" \
				-e "^Only in xmas: choirs$" |sed -e "${regex}"
	done
	for dir in xmas/itunes favorites/itunes easter/itunes ;do
		regex="s:^Files ${dir}/\([^ ]*\) and itunes/\1 differ\$:\1:"
		diff -rq ${dir} itunes|grep -v "^Only in itunes[:/]"|\
			sed -e "${regex}"
	done
	for dir in xmas/choirs favorites/choirs easter/choirs ;do
		regex="s:^Files ${dir}/\([^ ]*\) and choirs/\1 differ\$:\1:"
		diff -rq ${dir} choirs|grep -v "^Only in choirs[:/]"|\
			sed -e "${regex}"
	done
	cd "${OLD_PWD}"
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        test_music_links "$@"
fi
