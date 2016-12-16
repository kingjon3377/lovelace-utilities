#!/bin/bash
# This is a bash, rather than a portable-sh, script because it relies on the "export -f" bashism
if [ "${0}" = "${BASH_SOURCE[0]}" ]; then
	echo "Executing this is useless; source it instead."
	exit 1
fi
# Takes at least two arguments: the user to run the function as, and the
# function to call.
sudo_function() {
	if [ $# -lt 2 ]; then
		echo "Usage: sudo_function user funcname [args]"
		return 1
	fi
	# Exporting the expansion is the point
	# shellcheck disable=SC2163
	export -f "${2}"
	username="${1}"
	shift
	su "${username}" -c "$@"
}
