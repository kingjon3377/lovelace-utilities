#!/bin/sh
find "${1:-.}" -type f -print0 | \
	xargs -0 midentify 2>/dev/null | \
	perl -nle '/ID_LENGTH=([0-9\.]*)/ && ($t += $1) && printf "%d days %02d:%02d:%02d\n",$t/86400,$t% 86400 / 3600,$t/60%60,$t%60' | \
	tail -n 1 | \
	sed -e 's@^0 days @@' \
		-e 's@^\(00:\)*@@g' \
		-e 's@^[0-9]*$@& seconds@' \
		-e 's@^\([0-9][0-9]\):\([0-9][0-9]\)$@\1 minutes \2 seconds@' \
		-e 's@^\([0-9][0-9]\):\([0-9][0-9]\):\([0-9][0-9]\)$@\1 hours \2 minutes \3 seconds@' \
		-e 's@^0@@'
