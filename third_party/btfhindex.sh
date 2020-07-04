#! /bin/bash

# Global Variables
simples=("" One Two Three Four Five Six Seven Eight Nine Ten Eleven Twelve Thirteen Fourteen Fifteen Sixteen Seventeen Eighteen Nineteen)
aughts=("" -one -two -three -four -five -six -seven -eight -nine)
tens=("" "" Twenty Thirty Forty Fifty Sixty Seventy Eighty Ninety)
pres=(Foreword Introduction Intro Prologue Prolog)
posts=(Epilogue Epilog)
started=0

# Functions
to_roman() {
	input=$1
	output=""
	len=${#input}   # Initial length to count down

	roman_val() {
		N=$1
		one=$2
		five=$3
		ten=$4
		out=""

		case $N in
		0)      out+="" ;;
		[123])  while [[ $N -gt 0 ]]; do
				out+="$one"
				N=$((N-1))
			done ;;
		4)      out+="$one$five"        ;;
		5)      out+="$five"    ;;
		[678])  out+="$five"
			N=$((N-5))
			while [[ $N -gt 0 ]]; do
				out+="$one"
				N=$((N-1))
			done ;;
		9)      while [[ $N -lt 10 ]]; do
				out+="$one"
				N=$((N+1))
			done
			out+="$ten" ;;
		esac
		echo "$out"
	}

	while [[ $len -gt 0  ]]; do
		num=${input:0:1}
		case $len in
		1) output+="$(roman_val "$num" I V X)" ;;
		2) output+="$(roman_val "$num" X L C)" ;;
		3) output+="$(roman_val "$num" C D M)" ;;
		*) # 10'000 gets a line above, 100'000 gets a line on the left.. how to?
			num=${input:0:(-3)}
			while [[ $num -gt 0 ]]; do
				output+="M"
				num=$((num-1))
			done ;;
		esac
		input=${input:1} ; len=${#input}
	done
	echo $output
}

chapter_found() {
	if (( ! started )); then
		echo "<html>"
		author_line=$(grep '<h3 class="center">By .*</h3>' "${1}")
		if [ -n "${author_line}" ]; then
			author=$(echo "${author_line}" | sed 's/.*<h3 class="center">By //' | sed 's/<\/h3>$//')
		fi
		echo "<head>"
		if [ -z "${title}" ]; then
			title_line=$(grep '<h2 class="center">.*</h2>' "${1}")
			if [ -n "${title_line}" ]; then
				title=$(echo "${title_line}" | sed 's/.*<h2 class="center">//' | sed 's/<\/h2>$//')
			fi
		fi
		if [ -n "${title}" ]; then
			echo "<title>${title//_/ }</title>"
		fi
		if [ -n "${author}" ]; then
			echo '<meta name="Author" content="'"${author}"'"/>'
		fi
		echo "</head>"
		echo "<body>"
		if [ -n "${title}" ]; then
			echo "<h1>${title//_/ }</h1>"
		fi
		echo "<h2>Table of Contents</h2>"
		echo "<p>"
		started=1
		fi
		chapter_name="${2//_/ }"
		echo "<a href="'"'"${1}"'"'">${chapter_name}</a><br/>"
}

handle_chapter() {
	if [ -a "${1}.htm" ]; then
		chapter_found "${1}.htm" "${1}"
	elif [ -a "${1}.html" ]; then
		chapter_found "${1}.html" "${1}"
	elif [ -a "_${1}.htm" ]; then
		chapter_found "_${1}.htm" "${1}"
	elif [ -a "_${1}.html" ]; then
		chapter_found "_${1}.html" "${1}"
	fi
}

handle_chapters() {
	count=$2
	for (( i = 0; i < count; i++ )); do
		this="$1[$i]"
		handle_chapter "${!this}"
	done
}

generate_html() {
	handle_chapters pres ${#pres[@]}
	for (( chapter_num=1; chapter_num < 100; chapter_num++ )) ; do
		if [ $chapter_num -lt 20 ]; then
			number=${simples[$chapter_num]}
		else
			((aught=chapter_num % 10))
			((ten=chapter_num / 10 % 10))
			number=${tens[$ten]}${aughts[${aught}]}
		fi
		handle_chapter Part_${chapter_num}
		handle_chapter "Part_${number}"
		handle_chapter "Part_$(to_roman ${chapter_num})"
		handle_chapter Chapter_${chapter_num}
		handle_chapter "Chapter_${number}"
		handle_chapter "Chapter_$(to_roman ${chapter_num})"
	done
	handle_chapters posts ${#posts[@]}

	if (( started )); then
		echo "</p>"
		echo "</body>"
		echo "</html>"
	else
		echo NO CHAPTERS FOUND!
	fi
}

 # Main program
if [ -z "$1" ]; then
	generate_html > story.html
	if [ -n "${title}" ]; then
		mv story.html "${title}.html"
	fi
else
	title="$1"
	generate_html > "${title}.html"
fi
