#!/bin/sh
called_path=$_
find_largest_packages_with_deps() {
	while read -r atom; do
		printf "%s" "${atom}: " && \
		emerge -peq "${atom}" | \
			grep ebuild | \
			sed 's/^\[ebuild[ 	]*[NSRUD]*[ 	]*[~#fF]*[ 	]//' | \
			xargs qsize -f -S
	done < /var/lib/portage/world
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	if [ $# -gt 0 ]; then
		find_largest_packages_with_deps | tee "$1" | less
	else
		find_largest_packages_with_deps | less
	fi
fi
