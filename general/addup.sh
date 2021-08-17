#!/bin/bash
addup() {
	# Word splitting is desired, and ((  )) can't work on sed output AFAIK
	# shellcheck disable=SC2046,SC2003
	expr $(sed -e :a -e '$!N;s/\n/ + /;ta')
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	addup "$@"
fi

