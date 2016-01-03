#!/bin/sh
called_path=$_
addup() {
    # Word splitting is desired, and ((  )) can't work on sed output AFAIK
    # shellcheck disable=SC2046,SC2003
	expr $(sed -e :a -e '$!N;s/\n/ + /;ta')
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        addup "$@"
fi

