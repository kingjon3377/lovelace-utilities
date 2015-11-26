#!/bin/sh
synchronize_repo() {
	if [ $# -ne 2 ]; then
		echo "Usage: synchronize-repo hidden_repo_path hostname" 1>&2
		return 1
	elif [ ! -d "${1}" ]; then
		echo "Usage: synchronize-repo hidden_repo_path hostname" 1>&2
		return 2
	fi
	case "${1}" in
	*/.hg) REPO_BASE=${1%/.hg} VCSCMD=hg ;;
	*/.hg/) REPO_BASE=${1%/.hg/} VCSCMD=hg ;;
	*) echo "Unsupported repo type, or not a DVCS repo" 1>&2 ; return 3 ;;
	esac
	OLD_PWD="${PWD}"
	cd "${REPO_BASE}" || return
	case "${VCSCMD}" in
	hg) hg pull -u "ssh://${2}/${1}" && hg push "ssh://${2}/${1}" ;;
	esac
	cd "${OLD_PWD}"
}
