#!/bin/bash
#
# This is much like submit_to_tracker.sh, q.v., only for manipulating stories
# already in a project.
#
# We take as arguments the project, number (or name if project_name_to_id is
# defined and works), and the number of the story after which to file the
# stories we will be given; we then read subsequent story IDs on the standard
# input and reschedule them, in the order given, after that story.

# shellcheck source=./lovelace-utilities-source-config.sh
. "${BASH_SOURCE[0]%/*}/lovelace-utilities-source-config.sh"

file_stories_after() {
	lovelace_utilities_source_config
	if test $# -ne 2; then
		echo "Usage: file_stories_after project starting_story" 1>&2
		return 1
	fi
	if ! type project_name_to_id > /dev/null 2>&1; then
		echo "Define project_name_to_id function in environment to use symbolic names"
		echo "instead of Tracker project ID #s"
		project_name_to_id() { echo "$@"; }
	fi
	local PROJECT=${1}
	PROJECT=$(project_name_to_id "${PROJECT}")
	proj_ret=$?
	test "${proj_ret}" -eq 0 || return "${proj_ret}"
	old_story=${2}
	ran_once=false

	while read -r story; do
		test -z "${story}" && continue;
		curl \
			-X PUT \
			-H "X-TrackerToken: ${TRACKER_TOKEN}" \
			-H "Content-Type: application/json" \
			-d '{"after_id": '"${old_story}"'}' \
			"https://www.pivotaltracker.com/services/v5/projects/${PROJECT}/stories/${story}"
		curl_ret=$?
		if test "${curl_ret}" -eq 0; then
			old_story=${story}
			sleep 1
			ran_once=true
		else
			echo "Failed on ${story}" 1>&2
			return "${curl_ret}"
		fi
    done
    test "${ran_once}" = true && echo
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	file_stories_after "$@"
fi
