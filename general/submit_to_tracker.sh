#!/bin/bash
# We use a few bashisms below, according to shellcheck (type, [[ =~ ]], etc.)

# Unlike most scripts in this collection, we don't define reasonable defaults
# for the configuration variables: the function project_name_to_id defaults to
# an alias for true, and TRACKER_TOKEN defaults to invalidtoken
# shellcheck source=./lovelace-utilities-source-config.sh
. "${BASH_SOURCE[0]%/*}/lovelace-utilities-source-config.sh"
submit_to_tracker() {
	lovelace_utilities_source_config
	if test $# -lt 5; then
		echo "Usage: submit_to_tracker project type points tags name [state] [desc]" 1>&2
		return 1
	fi
	if ! type project_name_to_id > /dev/null 2>&1; then
		echo "Define project_name_to_id function in environment to use symbolic names"
		echo "instead of Tracker project ID #s"
		alias project_name_to_id=echo
	fi
	local PROJECT=${PROJECT:-${1}}
	PROJECT=$(project_name_to_id "${PROJECT}")
	proj_ret=$?
	if test ${proj_ret} -ne 0; then return ${proj_ret};fi
	local STORY_TYPE=${STORY_TYPE:-${2}}
	case "${STORY_TYPE}" in
		bug|feature|chore) : ;;
		release) echo "Use submit_tracker_release to create releases" 1>&2; return 3 ;;
		*) echo "Story type must be one of bug, feature, or chore" 1>&2; return 3 ;;
	esac
	local POINTS=${POINTS:-${3}}
	if [[ "$(declare -p PROJECTS_WITHOUT_CHORE_PTS 2>/dev/null)" =~ "declare -a" ]]; then
		for proj in "${PROJECTS_WITHOUT_CHORE_PTS[@]}";do
			if test "${PROJECT}" = "${proj}" -a \
					"${STORY_TYPE}" = "chore" -a \
					-n "${POINTS}" -a "${POINTS}" != "0"; then
				echo "Project ${PROJECT} doesn't support chores with point values" 1>&2
				return 3
			fi
		done
	fi
	local TAGS="${TAGS:-${4}}"
	local STORY_NAME="${STORY_NAME:-${5}}"
	STORY_NAME="$(echo "${STORY_NAME}" | sed -e 's@\\@\\\\@g' -e 's@"@\\"@g')"
	local STATE="${STATE:-${6}}"
	local DESC="${DESC:-${7}}"
	test -n "${TAGS}" && TAGS='"labels":['"$(echo "${TAGS}" | sed -e 's@^@"@' -e 's@$@"@' -e 's@,@","@g')"'], '
	test -n "${POINTS}" && POINTS='"estimate": '"$((POINTS)), "
	test -n "${STATE}" && STATE='"current_state":"'"${STATE}"'", '
	test -n "${DESC}" && DESC='"description":"'"$(echo "${DESC}" | sed -e 's@\\@\\\\@g' -e 's@"@\\"@g')"'", '
	json="{ ${TAGS}${POINTS}${STATE}${DESC} \"name\":\"${STORY_NAME}\", \"story_type\":\"${STORY_TYPE}\"}"
#	echo "${json}" | jq '.'
	submit_tracker_json() {
		curl -H "X-TrackerToken: ${TRACKER_TOKEN:-invalidtoken}" -H "Content-type: application/json" \
			-X POST -d "${1}" "https://www.pivotaltracker.com/services/v5/projects/${PROJECT}/stories"
	}
	if type jq > /dev/null; then
		id=$(submit_tracker_json "${json}" 2>/dev/null | jq -e '.id')
		if test $? != 0 || test "${id}" = null; then
			echo "Adding story apparently failed"
			return 4
		else
			echo "Story is now ID #${id}"
		fi
	else
		submit_tracker_json "${json}" || return 4
	fi
}
submit_tracker_release() {
	if test $# -lt 4; then
		echo "Usage: submit_tracker_release project tags name due_date [state] [desc]" 1>&2
		return 1
	fi
	local PROJECT=${PROJECT:-${1}}
	if ! type project_name_to_id > /dev/null 2>&1; then
		echo "Define project_name_to_id function in environment to use symbolic names"
		echo "instead of Tracker project ID #s"
		alias project_name_to_id=echo
	fi
	PROJECT=$(project_name_to_id "${PROJECT}")
	proj_ret=$?
	if test ${proj_ret} -ne 0; then return ${proj_ret};fi
	local TAGS="${TAGS:-${2}}"
	local STORY_NAME="${STORY_NAME:-${3}}"
	local DUE="${DUE:-${4}}"
	local STATE="${STATE:-${5}}"
	local DESC="${DESC:-${6}}"
	test -n "${TAGS}" && TAGS="<labels>${TAGS}</labels>"
	STORY_NAME="<name>${STORY_NAME}</name>"
	DUE="<deadline type=\"datetime\">${DUE}</deadline>"
	test -n "${STATE}" && STATE="<current_state>${STATE}</current_state>"
	test -n "${DESC}" && DESC="<description>${DESC}</description>"
	curl -H "X-TrackerToken: ${TRACKER_TOKEN:-invalidtoken}" \
		-H "Content-type: application/xml" \
		-X POST \
		-d "<story><story_type>release</story_type>${STORY_NAME}${TAGS}${STATE}${DESC}${DUE}</story>" \
			"https://www.pivotaltracker.com/services/v3/projects/${PROJECT}/stories" || return 4
}
