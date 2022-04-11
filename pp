#!/bin/sh
#  pp - the text preprocessor
#  Copyright (C) 2020  Joe Jenne

die() {
    echo "Error: $1" >&2
	echo "Usage: ${0##*/} v0.2.0" >&2
 	echo "  * STDIN | ${0##*/} > output -- See pp(1) for details and examples" >&2
	echo "Syntax:" >&2
	echo "  * Lines beginning !! are replaced with the following text evaluated" >&2
    echo "    as a shell command." >&2
	echo "  * Section !{...}! on one line is replaced by the output of cmd '...'" >&2
	echo "  * Variables to use: \$ln for line no. \$line for line itself" >&2
    exit 1
}

middle() {
	no_front=${1#*\!{}
	eval "${no_front%\}\!*}" || die "Line $ln: section evaluation error"
}

process(){
	while IFS= read -r line; do ln=$((ln+1))
		case $line in
			!!*) eval "${line##!!}" 2>/dev/null || die "LINE $ln: evaluation error";;
			*!\{*\}!*) printf '%s%s%s\n' "${line%%\!{*}" "$(middle "$line")" "${line##*\}\!}";;
			*) echo "$line";;
		esac
	done < "$1"
}

[ $# -ne 0 ] && die "No arguments are taken"
[ -t 0 ] && die "No input text provided"
process "/dev/stdin"
