#!/bin/sh
pid=${1:-$(pidof -x emerge)}
while test -d "/proc/${pid:-invalid}";do sleep 720;done&&\
	sudo pm-suspend
