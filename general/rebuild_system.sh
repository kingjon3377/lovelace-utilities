#!/bin/sh
called_path=$_
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" != "$0" ]; then
#if [ "${BASH_SOURCE}" != "$0" ]; then
        echo "Don\'t source this!"
	return 1
elif [ "$(id -ru)" -ne 0 ]; then
	exec sudo "$0"
else
	emerge -auvND --emptytree world && \
	emerge -a --depclean && \
	revdep-rebuild -p
fi
