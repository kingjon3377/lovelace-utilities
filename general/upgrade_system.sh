#!/bin/sh
if test "$(id -ru)" -ne 0
then
	sudo "$0"
else
# --verbose-conflicts
	emerge -auqvND --complete-graph --autounmask=n @system @selected @world && \
#	emerge -auqvND --complete-graph --autounmask-keep-masks @system @selected @world && \
#	emerge -auqvND --complete-graph --backtrack=0 --autounmask-keep-masks @system @selected @world && \
#	emerge -auqvND --complete-graph --backtrack=4 --autounmask-keep-masks @system @selected @world && \
	emerge -a @preserved-rebuild --autounmask-keep-masks && \
#	emerge -auvND @system @selected @world --jobs=2 --load-average=4 && \
	emerge -a --depclean && \
	revdep-rebuild -p -i
fi
