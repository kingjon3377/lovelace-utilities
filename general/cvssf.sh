#!/bin/sh
called_path=$_
cvssf() {
	ORIG_PWD="${PWD}"
	mkdir "${1}" && \
	cd "${1}" && \
	cvs "-d:pserver:anonymous@${1}.cvs.sf.net:/cvsroot/${1}" co .
	cd "${ORIG_PWD}" || return
}

# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        cvssf "$@"
fi
