#!/bin/bash
# We use a few bashisms below, according to shellcheck (type, [[ =~ ]], etc.)

# shellcheck source=./lovelace-utilities-source-config.sh
. "${BASH_SOURCE[0]%/*}/lovelace-utilities-source-config.sh"

# With Pivotal Tracker now having shut down, the functions in this file now use the
# Push library <https://github.com/vaeth/push/> to save the input in a file (by
# default under ${HOME}/todo) for later entry into a successor system.

PUSH_LOCATION=${PUSH_LOCATION:-/usr/share/push/push.sh}

test -f "${PUSH_LOCATION}" || PUSH_LOCATION="push.sh"

if PUSH_INIT=$(cat "${PUSH_LOCATION}" 2>/dev/null);then
	eval "${PUSH_INIT}"
	PUSH_INITIALIZED=true
else
	echo "push.sh not on PATH, or PUSH_LOCATION not set" >&2
	PUSH_INITIALIZED=false
fi

# Unlike most scripts in this collection, we don't define reasonable defaults
# for the configuration variables: the function project_name_to_id defaults to
# an alias for true, and TRACKER_TOKEN defaults to invalidtoken
submit_to_tracker() {
	if test "${PUSH_INITIALIZED:-false}" != true; then
		echo "Push library not detected, and Tracker is gone ..." >&2
		return 5
	fi
	local PROVIDED_TRACKER_TOKEN=${TRACKER_TOKEN}
	lovelace_utilities_source_config
	TRACKER_TOKEN=${PROVIDED_TRACKER_TOKEN:-${TRACKER_TOKEN}}
	info_echo() {
		test "${STT_QUIET:-false}" = true || echo "$@"
	}
	warn_echo() {
		echo "$@" 1>&2
	}
	if test "$1" = "--quiet"; then
		STT_QUIET=true
		shift
	fi
	if test $# -lt 5; then
		warn_echo "Usage: submit_to_tracker [--quiet] project type points tags name [state] [desc] [tasks ...]"
		return 1
	fi
	if test "${TRACKER_SOMEHOW_UP:-false}" != true; then
		Push -c v submit_to_tracker "$@"
		# shellcheck disable=2154
		printf '%s\n' "$v" >> "${TRACKER_BACKUP_FILE:-${HOME}/todo/submitted_tasks.sh}"
		return 0
	fi
	if ! type project_name_to_id > /dev/null 2>&1; then
		info_echo "Define project_name_to_id function in environment to use symbolic names"
		info_echo "instead of Tracker project ID #s"
		project_name_to_id() { echo "$@"; }
	fi
	local PROJECT=${PROJECT:-${1}}
	PROJECT=$(project_name_to_id "${PROJECT}")
	proj_ret=$?
	if test "${proj_ret}" -ne 0; then return "${proj_ret}";fi
	local STORY_TYPE=${STORY_TYPE:-${2}}
	case "${STORY_TYPE}" in
		bug|feature|chore) : ;;
		release) warn_echo "Use submit_tracker_release to create releases"; return 3 ;;
		*) warn_echo "Story type must be one of bug, feature, or chore"; return 3 ;;
	esac
	local POINTS=${POINTS:-${3}}
	if [[ "$(declare -p PROJECTS_WITHOUT_CHORE_PTS 2>/dev/null)" =~ "declare -a" ]]; then
		for proj in "${PROJECTS_WITHOUT_CHORE_PTS[@]}";do
			if test "${PROJECT}" = "${proj}" -a \
					"${STORY_TYPE}" = "chore" -a \
					-n "${POINTS}" -a "${POINTS}" != "0"; then
				warn_echo "Project ${PROJECT} doesn't support chores with point values"
				return 3
			fi
		done
	fi
	local TAGS="${TAGS:-${4}}"
	local STORY_NAME="${STORY_NAME:-${5}}"
	STORY_NAME="$(echo "${STORY_NAME}" | sed -e 's@\\@\\\\@g' -e 's@"@\\"@g')"
	local STATE="${STATE:-${6}}"
	local DESC="${DESC:-${7}}"
	shift;shift;shift;shift;shift;shift;shift
	local TASKS
	if test $# -ne 0; then
		TASKS=', "tasks":['
		while test $# -gt 1; do
			TASKS="${TASKS}{\"description\":\"$(echo -n "${1}" | sed 's@"@\\"@g')\"},"
			shift
		done
		TASKS="${TASKS}{\"description\":\"$(echo -n "${1}" | sed 's@"@\\"@g')\"}]"
	else
		TASKS=""
	fi
	test -n "${TAGS}" && TAGS='"labels":['"$(echo "${TAGS}" | sed -e 's@^@"@' -e 's@$@"@' -e 's@,@","@g')"'], '
	test -n "${POINTS}" && POINTS='"estimate": '"$((POINTS)), "
	test -n "${STATE}" && STATE='"current_state":"'"${STATE}"'", '
	test -n "${DESC}" && DESC='"description":"'"$(echo "${DESC}" | sed -e 's@\\@\\\\@g' -e 's@"@\\"@g')"'", '
	json="{ ${TAGS}${POINTS}${STATE}${DESC} \"name\":\"${STORY_NAME}\", \"story_type\":\"${STORY_TYPE}\"${TASKS}}"
#	echo "${json}" | jq '.'
	submit_tracker_json() {
		curl -H "X-TrackerToken: ${TRACKER_TOKEN:-invalidtoken}" -H "Content-type: application/json" \
			-X POST -d "${1}" "https://www.pivotaltracker.com/services/v5/projects/${PROJECT}/stories"
	}
	if type jq > /dev/null; then
		ret_json=$(submit_tracker_json "${json}" 2>/dev/null)
		id=$(echo "${ret_json}" | jq -e '.id')
		if test $? != 0 || test "${id}" = null; then
			warn_echo "Adding story apparently failed"
			if test "${STT_QUIET:-false}" != true -a "${STT_DEBUG:-false}" = true; then
				info_echo "You submitted:"
				echo "${json}" | jq '.'
				info_echo; info_echo "They replied:"
				echo "${ret_json}" | jq '.'
			fi
			return 4
		else
			info_echo "Story is now ID #${id}"
		fi
	else
		submit_tracker_json "${json}" || return 4
	fi
}

# Create a Tracker "release" story. Note that this now requires the *GNU*
# "date" command; if on MacOS, install GNU coreutils using Homebrew, MacPorts,
# Gentoo Prefix, or some other way and use your PATH or an alias so that this
# sees that rather than the MacOS default /bin/date.
submit_tracker_release() {
	if test "${PUSH_INITIALIZED:-false}" != true; then
		echo "Push library not detected, and Tracker is gone ..." >&2
		return 5
	fi
	local PROVIDED_TRACKER_TOKEN=${TRACKER_TOKEN}
	lovelace_utilities_source_config
	TRACKER_TOKEN=${PROVIDED_TRACKER_TOKEN:-${TRACKER_TOKEN}}
	info_echo() {
		test "${STT_QUIET:-false}" = true || echo "$@"
	}
	warn_echo() {
		echo "$@" 1>&2
	}
	if test "$1" = "--quiet"; then
		STT_QUIET=true
		shift
	fi
	if test $# -lt 4; then
		warn_echo "Usage: submit_tracker_release project tags name due_date [state] [desc]"
		return 1
	fi
	if test "${TRACKER_SOMEHOW_UP:-false}" != true; then
		Push -c v submit_tracker_release "$@"
		# shellcheck disable=2154
		printf '%s\n' "$v" >> "${TRACKER_BACKUP_FILE:-${HOME}/todo/submitted_tasks.sh}"
		return 0
	fi
	local PROJECT=${PROJECT:-${1}}
	if ! type project_name_to_id > /dev/null 2>&1; then
		warn_echo "Define project_name_to_id function in environment to use symbolic names"
		warn_echo "instead of Tracker project ID #s"
		project_name_to_id() { echo "$@"; }
	fi
	PROJECT=$(project_name_to_id "${PROJECT}")
	proj_ret=$?
	if test "${proj_ret}" -ne 0; then return "${proj_ret}";fi
	local TAGS="${TAGS:-${2}}"
	local STORY_NAME="${STORY_NAME:-${3}}"
	local DUE="${DUE:-${4}}"
	local STATE="${STATE:-${5}}"
	local DESC="${DESC:-${6}}"
	test -n "${TAGS}" && TAGS=', "labels":['"$(echo "${TAGS}" | sed -e 's@^@"@' -e 's@$@"@' -e 's@,@","@g')"']'
	test -n "${DUE}" && DUE=', "deadline":"'"$(date -d "${DUE}" --iso-8601=seconds)"'"'
	test -n "${STATE}" && STATE=', "current_state":"'"${STATE}"'"'
	test -n "${DESC}" && DESC=', "description":"'"$(echo "${DESC}" | sed -e 's@\\@\\\\@g' -e 's@"@\\"@g')"'"'
	json="{ \"story_type\":\"release\", \"name\":\"${STORY_NAME}\"${TAGS}${STATE}${DUE}${DESC} }"
	submit_tracker_json() {
		curl -H "X-TrackerToken: ${TRACKER_TOKEN:-invalidtoken}" -H "Content-type: application/json" \
			-X POST -d "${json}" "https://www.pivotaltracker.com/services/v5/projects/${PROJECT}/stories"
	}
	if type jq > /dev/null; then
		id=$(submit_tracker_json "${json}" 2>/dev/null | jq -e '.id')
		if test $? != 0 || test "${id}" = null; then
			warn_echo "Adding release apparently failed"
			return 4
		else
			info_echo "Release is now ID #${id}"
		fi
	else
		submit_tracker_json "${json}" || return 4
	fi
}
