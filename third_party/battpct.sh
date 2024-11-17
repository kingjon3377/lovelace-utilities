#!/bin/bash
#
# If no battery found, bail out
if [ ! -d /sys/class/power_supply/BAT1 ]; then
	echo "***ERROR***; Battery not detected"
	exit
fi
#
# Get line containing full design charge value
full=$(grep POWER_SUPPLY_CHARGE_FULL_DESIGN /sys/class/power_supply/BAT1/uevent)
#
# Strip out everything except the actual number itself
full1="${full#POWER*=}"
#
# Get half of the full value, for use in emulating "round offs" in integer
# arithmetic.
half=$(( full / 2 ))
while true
do
#
# Get line containing current charge value and strip out everything
# except the actual number itself
	now=$(grep POWER_SUPPLY_CHARGE_NOW /sys/class/power_supply/BAT1/uevent)
	now1="${now#POWER*=}"
#
# Multiply by 1000, so that the following division is actually 10 times
# the percentage.
	now2=$(( now1 * 1000 ))
	percent=$(( now2 / full1 ))
#
# Get the remainder of the division.  If it's greater than or equal to
# half the divisor (as determined above) add 1 to the percent x 10 value.
	remainder=$(( now2 % full1 ))
	if [ ${remainder} -ge ${half} ]; then
		percent=$(( percent + 1 ))
	fi
#
# Treating ${percent} as a string, figure out where to place a decimal
# point to fake 10ths of a percent.
	pointer=$(( ${#percent} - 1 ))
	percent1="${percent:0:${pointer}}.${percent:${pointer}}"
#
# Backtrack the cursor up to 7 columns, and display the new value
	echo -n "[7D${percent1} %"
#
# Wait 5 seconds and update again.  This is an infinite loop.
	sleep 5
done

