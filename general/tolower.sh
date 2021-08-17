#!/bin/bash
tolower() {
	for f in "$@";do
		mv -iv "${f}" "$(echo "${f}" | tr '[:upper:]' '[:lower:]')"
	done
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	tolower "$@"
fi
