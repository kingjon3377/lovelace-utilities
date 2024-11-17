#!/bin/bash
find_largest_packages_with_deps() {
	while read -r atom; do
		printf "%s" "${atom}: " && \
			emerge -peq "${atom}" | \
			grep ebuild | \
			sed 's/^\[ebuild[ 	]*[NSRUD]*[ 	]*[~#fF]*[ 	]//' | \
			xargs qsize -f -S
	done < /var/lib/portage/world
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	if [ $# -gt 0 ]; then
		find_largest_packages_with_deps | tee "$1" | less
	else
		find_largest_packages_with_deps | less
	fi
fi
