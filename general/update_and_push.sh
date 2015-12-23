#!/bin/sh
called_path=$_
if [ "${cm_called_path}" = "$0" ]; then
    if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
            [ -f "${HOME}/Library/Application Support/lovelace-utilities/config" ]; then
        . "${HOME}/Library/Application Support/lovelace-utilities/config"
    elif [ -n "${XDG_CONFIG_HOME}" ] && [ -d "${XDG_CONFIG_HOME}/lovelace-utilities" ] && \
            [ -f "${XDG_CONFIG_HOME}/lovelace-utilities/config" ]; then
        . "${XDG_CONFIG_HOME}/lovelace-utilities/config"
    else
        # To avoid trying to push to read-only Hg and git repos, we grep for our username in the URLs.
        # TODO: Find a better heuristic: probably ssh vs. https clone URLs?
        UPSTREAM_USERNAME_STRING=${USER}
    fi
fi
update_and_push() {
    # FIXME: Support git at least. Or combine this with the other script to the same purpose in this collection
	for arg in "$@"; do
		case ${arg} in
		*/.hg)
			OLD_PWD="${PWD}"
			cd "${arg}/.." || break
			hg pull -u
			grep -q "${UPSTREAM_USERNAME_STRING}" .hg/hgrc && hg push
			cd "${OLD_PWD}" ;;
		*) if [ -d "${arg}/.hg" ] ; then
				OLD_PWD="${PWD}"
				cd "${arg}" || break
				hg pull -u
				grep -q UPSTREAM_USERNAME_STRINGkingjon .hg/hgrc && hg push
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
