#!/bin/sh
cm_called_path=$_
# shellcheck source=./lovelace-utilities-source-config.sh
. "${cm_called_path%/*}/lovelace-utilities-source-config.sh" || return 1
# TODO: Use bash arrays (specifying /bin/bash) for sites to test?
test_connection() {
	lovelace_utilities_source_config
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		SITES_TO_TEST="172.16.42.1 8.8.8.8 google.com"
	fi
	for a in ${SITES_TO_TEST}; do
		ping -c 1 "${a}" || { /sbin/route -n; return; }
	done
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${cm_called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	test_connection "$@"
fi
