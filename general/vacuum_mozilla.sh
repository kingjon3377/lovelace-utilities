#!/bin/sh
called_path=$_
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
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        vacuum_mozilla "$@"
fi

