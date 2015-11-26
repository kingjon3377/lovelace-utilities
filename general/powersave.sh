#!/bin/sh
sudo -v || exit $?
for a in /sys/devices/system/cpu/cpu?/cpufreq/scaling_governor
do
	echo "${a}: $(cat "${a}")"
	echo "${1:-powersave}" | sudo -n tee "${a}" > /dev/null
done
