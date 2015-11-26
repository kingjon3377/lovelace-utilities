#!/bin/sh
called_path=$_
svnsf() {
	OLD_PWD="${PWD}"
	mkdir "${1}" && \
	cd "${1}" && \
	svn co "http://${1}.svn.sf.net/svnroot/${1}"
	cd "${OLD_PWD}"
}

# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
	svnsf "$@"
fi
