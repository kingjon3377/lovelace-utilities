#!/bin/bash
cm_called_path="${BASH_SOURCE[0]}"
# shellcheck source=./lovelace-utilities-source-config.sh
. "${cm_called_path%/*}/lovelace-utilities-source-config.sh" || return 1
# TODO: Use bash arrays for sites to test?
test_connection() {
	lovelace_utilities_source_config
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		SITES_TO_TEST="172.16.42.1 8.8.8.8 google.com"
	fi
	for a in ${SITES_TO_TEST}; do
		ping -c 1 "${a}" || { /sbin/route -n; return; }
	done
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	test_connection "$@"
fi
