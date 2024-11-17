#!/bin/sh
if test "$(id -ru)" -ne 0
then
	sudo "$0"
else
	# Set options like --verbose-conflicts, --complete-graph, --autounmask=n,
	# --backtrack, --jobs, --load-average, etc. in EMERGE_DEFAULT_OPTS
	emerge -auqvND @system @selected @world && \
		emerge -a @preserved-rebuild --autounmask-keep-masks && \
		emerge -a --depclean && \
		revdep-rebuild -p -i
fi
