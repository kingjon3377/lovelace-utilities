#!/bin/bash
if [ "${BASH_SOURCE[0]}" != "$0" ]; then
        echo "Don't source this!"
	return 1
elif [ "$(id -ru)" -ne 0 ]; then
	exec sudo "$0"
else
	emerge -auvND --emptytree world && \
	emerge -a --depclean && \
	revdep-rebuild -p
fi
