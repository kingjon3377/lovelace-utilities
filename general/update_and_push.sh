#!/bin/sh
called_path=$_
update_and_push() {
	for arg in "$@"; do
		case ${arg} in
		*/.hg)
			OLD_PWD="${PWD}"
			cd "${arg}/.." || break
			hg pull -u
			grep -q kingjon .hg/hgrc && hg push
			cd "${OLD_PWD}" ;;
		*) if [ -d "${arg}/.hg" ] ; then
				OLD_PWD="${PWD}"
				cd "${arg}" || break
				hg pull -u
				grep -q kingjon .hg/hgrc && hg push
				cd "${OLD_PWD}"
			else
				echo "${arg} is not a Hg repo"
			fi ;;
		esac
	done
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
[ "${called_path}" = "$0" ] && update_and_push "$@"
#[ "${BASH_SOURCE}" = "$0" ] && update_and_push "$@"
