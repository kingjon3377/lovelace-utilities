#!/bin/sh
# FIXME: Support alternate suspend command, loading it from config
# We want to use substitution on the parameters array, which I think is a bashism
case $# in
    0) pid=$(pidof -x emerge)
        while test -d /proc/${pid:-invalid};do
            sleep 720
        done && sudo pm-suspend ;;
    1) while test -d "/proc/${1}";do
        sleep 720
    done && sudo pm-suspend ;;
*) firstpid=${1};shift
    while test -d "/proc/${firstpid}" ${@/#/-o /proc/};do
        sleep 720
    done && sudo pm-suspend ;;
esac
