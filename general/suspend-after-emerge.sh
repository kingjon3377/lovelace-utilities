#!/bin/sh
called_path=$_
# FIXME: Support alternate suspend command, loading it from config
# We want to use substitution on the parameters array, which I think is a bashism

# Configured by $MAX_SUSPEND_TIME, which is assumed to be produced by $(date +%s).
suspend_if_not_too_late() {
	if test -z "${MAX_SUSPEND_TIME}"; then
		sudo pm-suspend
	elif test "$(date +%s)" -lt "${MAX_SUSPEND_TIME}"; then
		sudo pm-suspend
	else
		echo "Suspend canceled"
	fi
}
suspend_after_emerge() {
    case $# in
        0)
            # We want each PID to be checked individually
            # shellcheck disable=SC2046
            suspend_after_emerge $(pidof -x emerge) ;;
    1) while test -d "/proc/${1}";do
        sleep 720
    done && suspend_if_not_too_late ;;
    *) firstpid=${1};shift
        # We want this to be "double split" so the -o becomes a separate argument
	# TODO: If we require bash, generate and use an array here instead.
        # shellcheck disable=SC2068
        while test -d "/proc/${firstpid}" ${@/#/-o /proc/};do
            sleep 720
        done && suspend_if_not_too_late ;;
    esac
}
# Takes the wake time (as if produced by $(date +%s)) and any number of PIDs.
suspend_but_wake() {
	wake_time="${1}"
	shift
	if test $# -eq 0; then
		sudo rtcwake -m mem -t "${wake_time}"
	else
		sudo rtcwake -m no -t "${wake_time}"
		MAX_SUSPEND_TIME=$((wake_time - 120)) suspend_after_emerge "$@"
	fi
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	suspend_after_emerge "$@"
fi
