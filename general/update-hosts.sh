#!/bin/bash
update_hosts() {
	if [ $# -ne 3 ]; then
		echo "Usage: ${0##*/} source old dest"
		echo "source is the just-downloaded hpHosts file, and won't be modified"
		echo "old is probably /etc/hosts"
		echo "dest is what to write the result to, either a test file or /etc/hosts"
		return 1
	fi
	# $1 is the new host file, which should not be modified; $2 is the old
	# host file, probably /etc/hosts; $3 is where to put the modified
	# version, probably also /etc/hosts
	lineno=$(grep -n "End local header" "${2}" | sed 's/:.*$//')
	if [ -z "${lineno}" ]; then
		header=""
	else
		header="$(head -n "${lineno}" "${2}")"
	fi
	awkscr=$(mktemp)
	{
		echo "BEGIN {"
		printf '	print "%s";\n' "${header}"
		echo '}'
		echo "/^127.0.0.1	localhost/ { print; next; }"
		sed -n -e 's:#0.0.0.0\(.*\)$:/^127.0.0.1\1$/ { printf "#0.0.0.0\1\\n"; next; }:p' "${2}"
		echo "/^127.0.0.1	/ { printf \"0.0.0.0	\"; print \$2; next; }"
		echo "{ print; }"
	} >> "${awkscr}"
#	less "${awkscr}"
	sed -e 's/\r$//' "${1}" | awk -f "${awkscr}" > "${3}"
#	rm -i "${awkscr}"
	rm "${awkscr}"
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	update_hosts "$@"
fi
