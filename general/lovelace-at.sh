#!/bin/bash
# This script is designed to run from a cron job. It takes a directory, either
# as the first command-line argument, as the environment variable TASK_DIR, or
# by editing the script to set it (unlike most of my scripts this does *not*
# use the lovelace-config mechanism, due to the difficulty of getting
# environment variables right in a cron job). For each file in that directory
# whose name, with any extension we support (just `.sh` for now) removed and
# any '_' changed to ' ', is a date (capable of being parsed by the `date`
# command), we test whether that date is prior to the current date and time,
# and if so we run that file (for .sh files, as a script; later on I hope to
# add support for something with a more declarative syntax), then if that
# appears to succeed removes it. We do some locking to avoid unwanted
# double-execution, but tasks are only removed on success to allow retrying
# later (such as if a task requires Internet access and the network is down at
# the time).
TASK_DIR_INNER=${1:-${TASK_DIR:-${XDG_DATA_HOME:-${HOME}/.local/share}/lovelace-at-tasks}}
if ! test -d "${TASK_DIR_INNER}";then
	mkdir -p "${TASK_DIR_INNER}"
	exit 0
fi
restore=$(shopt -p nullglob)
shopt -s nullglob
task_list=( "${TASK_DIR_INNER}"/* )
if test "${#task_list[@]}" -eq 0; then
#	echo "No tasks in directory" 1>&2
	${restore}
	exit 0
fi
LOCK_DIR_INNER="${LOCK_DIR:-${XDG_RUNTIME_DIR:-/dev/shm}/lovelace-at-locks}"
mkdir -p "${LOCK_DIR_INNER}"
base_timestamp=$(date +%s)
for file in "${task_list[@]}";do 
	case "${file}" in
	*.sh) file_timestamp="${file%%.sh}" ;;
	*) echo "${file##*/}: Not a supported extension" 1>&2 ; continue ;;
	esac
	file_timestamp="${file_timestamp##*/}"
	file_timestamp="$(date --date="${file_timestamp}" +%s)"
	test "${file_timestamp}" -gt "${base_timestamp}" && continue # TODO: multi-level logging, with this at debug level
	if ! test -x "${file}"; then
		echo "${file##*/}: Not executable" 1>&2
		continue
	fi
	if ! mkdir "${LOCK_DIR_INNER}/${file##*/}"; then
		echo "Couldn't acquire lock for ${file##*/}" 1>&2
		continue
	fi
	if "${file}"; then
		rm "${file}"
		rmdir "${LOCK_DIR_INNER}/${file##*/}"
	else
		echo "Running task ${file##*/} failed!" 1>&2
		rmdir "${LOCK_DIR_INNER}/${file##*/}"
		${restore}
		exit 2
	fi
done
${restore}
