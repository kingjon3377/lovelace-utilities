#!/bin/bash
#
# bash-based (YES!) cpu governor and frequency control utility, version 0.1
# released under GPLv3 by Walter Dnes 2015/04/21
# This utility assumes symmetrical multi-processing, and takes shortcuts
# that are valid only in that environment.  E.g. available and current CPU
# governors and/or speeds are read only for CPU0, and assumed to be valid
# for all CPUs.
#
# The subroutine to list available governors.  It also lists speeds if
# "userspace" mode is in effect.
dolistgov() {
	# Read current governor from CPU0
	read -r currgov < "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"

	# Read list of available governors for CPU0, and store in array "governor"
	read -r -a governor < "/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors"
	govmax=${#governor[@]}

	# If current governor is "userspace", also enable listing/setting of
	# CPU frequencies.
	if [ "${currgov}" = "userspace" ]; then

		# Read current frequency from CPU0
		read -r currfreq < "/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq"

		# Read list of available frequencies from CPU0
		read -r -a freqlist < "/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies"

		# Append frequency list to governor list
		governor=("${governor[@]}" "${freqlist[@]}")
	fi
	echo "Available cpu settings"

	# Set loop start and end values
	pointer=0
	arraysize=${#governor[@]}
	while [ ${pointer} -lt "${arraysize}" ]; do
		# Array starts from zero, but selection numbering starts from
		# 1, so add 1 to index pointer
		pointerplus=$(( pointer + 1))
		outputline="  [${pointerplus}]   ${governor[${pointer}]}"

		# Append an asterisk to output if current value matches
		if [ "${governor[${pointer}]}" = "${currgov}" ]; then
			outputline="${outputline} *"
		fi
		if [ "${governor[${pointer}]}" = "${currfreq}" ]; then
			outputline="${outputline} *"
		fi
		echo "${outputline}"
		pointer=$(( pointer + 1 ))
	done
}

# Governor/speed setting subroutine
dosetgov() {
	echo "Please select a governor; enter 0 to cancel..."

	# The listing routine is called here to initialize the list of
	# available governors/speeds.  It cannot be skipped.  The helpful
	# listing for the end-user is a serendipitous side-effect.
	dolistgov

	# Read a numeric choice from the keyboard.
        read -r choice

	# Exit if not a valid choice.
	if ! [[ ${choice} =~ ^[-+]?[0-9]+$ ]]; then
		echo "ERROR: expecting an integer in the range 0 to ${arraysize}"
		exit
	fi
	if [ "${choice}" -eq 0 ]; then
		exit
	elif [ "${choice}" -lt 0 ]; then
		echo "Error: Invalid value"
		exit
	elif [ "${choice}" -gt "${arraysize}" ]; then
		echo "Error: Invalid value"
		exit

	# If a governor is selected, apply to all CPUs
	elif [ "${choice}" -le "${govmax}" ]; then
		choiceminus=$(( choice - 1 ))
		for core in /sys/devices/system/cpu/cpu[0-9]*/
		do
			echo "${governor[${choiceminus}]}" > "${core}cpufreq/scaling_governor"
			cpunum="${core:27:2}"
			if [ "${cpunum:1:1}" = "/" ]; then
				cpunum="${core:27:1}"
			fi
			echo -n "CPU ${cpunum} set to "
			cat "${core}cpufreq/scaling_governor"
		done

	# If a speed is selected, apply to all CPUs
	elif [ "${choice}" -gt "${govmax}" ]; then
		choiceminus=$(( choice - 1 ))
		for core in /sys/devices/system/cpu/cpu[0-9]*/
		do
			echo "${governor[${choiceminus}]}" > "${core}cpufreq/scaling_setspeed"
			cpunum="${core:27:2}"
			if [ "${cpunum:1:1}" = "/" ]; then
				cpunum="${core:27:1}"
			fi
			echo -n "CPU ${cpunum} set to "
			cat "${core}cpufreq/scaling_cur_freq"
		done
	fi
}

# CPU frequency scaling support requires the presence of a "cpufreq"
# subdirectory.  If not found, bail out.
if [ ! -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
	echo "ERROR: This machine does not appear to have the necessary hardware"
	echo "and/or software support for frequency scaling."
	exit
fi

# If "list" selected, go to appropriate subroutine
if [ "${1}" == "list" ]; then
	dolistgov

# If "set" selected, go to appropriate subroutine
elif [ "${1}" == "set" ]; then
	dosetgov

# Otherwise it's an error.  So give brief usage instructions
else 
	echo "Usage: this utility can list or set (with root permissions) cpu governors"
	echo "and speeds, from a list of available values.  To list available values..."
	echo ""
	echo "cpugov list"
	echo ""
	echo "To set cpu values..."
	echo ""
	echo "cpugov set"
fi

