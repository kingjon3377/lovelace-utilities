#!/bin/sh
called_path=$_
# FIXME: Support alternate suspend command, loading it from config
# We want to use substitution on the parameters array, which I think is a bashism
suspend_after_emerge() {
    case $# in
        0)
            # We want each PID to be checked individually
            # shellcheck disable=SC2046
            suspend_after_emerge $(pidof -x emerge) ;;
    1) while test -d "/proc/${1}";do
        sleep 720
    done && sudo pm-suspend ;;
    *) firstpid=${1};shift
        # We want this to be "double split" so the -o becomes a separate argument
        # shellcheck disable=SC2068
        while test -d "/proc/${firstpid}" ${@/#/-o /proc/};do
            sleep 720
        done && sudo pm-suspend ;;
    esac
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	suspend_after_emerge "$@"
fi
