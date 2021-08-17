#!/bin/bash
# Only run when databases not in use!
vacuum_mozilla() {
	if pidof firefox firefox-bin thunderbird thunderbird-bin > /dev/null ; then
		echo "Mozilla software still running"
		exit 1
	fi
	find . -xdev -name \*.sqlite -type f -print \
		-exec sqlite3 '{}' VACUUM \; \
		-exec sqlite3 '{}' REINDEX \;
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	vacuum_mozilla "$@"
fi

