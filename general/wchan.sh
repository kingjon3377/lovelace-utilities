#!/bin/bash
wchan() {
	ps -o pid,comm,wchan "$@"
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	wchan "$@"
fi
