#!/bin/bash
# sourcing-detection idea from 
# <http://www.linuxquestions.org/questions/prog+ramming-9/detect-bash-script-source-vs-direct-execution-685193/>
# We leave it as is, rather than using the more portable implementation, because mycat relies on arrays, a bashism.
# cat implementation from http://blog.eatnumber1.com/2009/05/pure-bash-cat.html

mycat() {
	INPUTS=( "${@:-"-"}" )
	for i in "${INPUTS[@]}"; do
		if [ "$i" != "-" ]; then
			exec 3< "$i" || exit 1
		else
			exec 3<&0
		fi
		while read -ru 3; do
			echo -E "$REPLY"
		done
	done
}

if [ "${BASH_SOURCE}" = "$0" ]; then
	mycat "$@"
fi
