#!/bin/bash
cm_called_path="${BASH_SOURCE[0]}"
# shellcheck source=./lovelace-utilities-source-config.sh
. "${cm_called_path%/*}/lovelace-utilities-source-config.sh" || return 1
update_and_push() {
	lovelace_utilities_source_config
	# To avoid trying to push to read-only Hg and git repos, we grep for our username in the URLs.
	# TODO: Find a better heuristic: probably ssh vs. https clone URLs?
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		UPSTREAM_USERNAME_STRING=${USER}
	fi
	# FIXME: Support git at least. Or combine this with the other script to the same purpose in this collection
	for arg in "$@"; do
		case ${arg} in
		*/.hg)
			OLD_PWD="${PWD}"
			cd "${arg}/.." || break
			hg pull -u
			grep -q "${UPSTREAM_USERNAME_STRING}" .hg/hgrc && hg push
			cd "${OLD_PWD}" || break ;;
		*) if [ -d "${arg}/.hg" ] ; then
				OLD_PWD="${PWD}"
				cd "${arg}" || break
				hg pull -u
				grep -q UPSTREAM_USERNAME_STRINGkingjon .hg/hgrc && hg push
				cd "${OLD_PWD}"|| break
			else
				echo "${arg} is not a Hg repo"
			fi ;;
		esac
	done
}
[ "${BASH_SOURCE[0]}" = "$0" ] && update_and_push "$@"
