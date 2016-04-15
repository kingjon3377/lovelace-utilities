#!/bin/sh
called_path=$_
truediff() {
	file_one="${1}"
	file_two="${2}"
	if diff "${file_one}" "${file_two}" ; then
		return 0
	elif [ \( ! -f "${file_one}" \) ] || [  \( ! -f "${file_two}" \) ]; then
		return 1
#	elif [ \( "$(basename "${file_one}" .gz)" != \
#				"$(basename "${file_one}")" \) -o \
#			\( "$(basename "${file_two}" .gz)" != \
#				"$(basename "${file_two}")" \) ]; then
	elif [ "${file_one%.gz}" != "${file_one}" ] || \
			[ "${file_two%.gz}" != "${file_two}" ]; then
		zdiff "${file_one}" "${file_two}"; return $?
	fi
#	if [ "$(basename "${file_one}" .lrz)" != \
#			"$(basename "${file_one}")" ]; then
	if [ "${file_one%.lrz}" != "${file_one}" ]; then
		real_file_one=/tmp/real_file_one.$$
		lrunzip -o ${real_file_one} "${file_one}" >/dev/null
		remove_real_one=1
	else
		real_file_one="${file_one}"
		remove_real_one=0
	fi
#	if [ "$(basename "${file_two}" .lrz)" != \
#			"$(basename "${file_two}")" ]; then
	if [ "${file_two%.lrz}" != "${file_two}" ]; then
		real_file_two=/tmp/real_file_two.$$
		lrunzip -o ${real_file_two} "${file_two}" >/dev/null
		remove_real_two=1
	else
		real_file_two="${file_two}"
		remove_real_two=0
	fi
	diff "${real_file_one}" "${real_file_two}"; exit_status=$?
	if [ "$remove_real_one" -eq 1 ]; then
		rm "${real_file_one}"
	fi
	if [ "$remove_real_two" -eq 1 ]; then
		rm "${real_file_two}"
	fi
	return ${exit_status}
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE[0]}" = "$0" ]; then
        truediff "$@"
fi
