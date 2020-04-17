#!/bin/sh
#  pp - the text preprocessor
#  Copyright (C) 2020  Joe Jenne
#  
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#  

VERSION=0.0.1

die() {
	# Fail in style, exit with 1
	#
	printf '\033[1;33m%s \033[1;36m%s\033[m %s\n' "${3-!>}" "$1" "$2" >&2
	exit 1
}

args(){
	# Parse script arguments using a simple case for input followed by getopts
	#
	# Parse either side of input-file hvf(maybe o) on one side, 
	# o on the other
	while getopts :hvf-o: _opt; do
		case $_opt in
			-) case "$OPTARG" in
				force)
					FORCED=true
					;;
				help)
					usage
					exit
					;;
				version)
					printf '%s - preprocessing script\nversion: %s\nlicense: GNU General Public License, version 3\n' "${0##*/}" "$VERSION" 
					exit
					;;
				*)
					;;
				esac;;
			f)	FORCED=true
				;;
			h)
				usage
				exit
				;;
			o)
				OUT=$OPTARG
				;;
			v)	
				printf '%s - preprocessing script\nversion: %s\nlicense: GNU General Public License, version 3\n' "${0##*/}" "$VERSION" 
				exit
				;;
			\?)
				die "FLAG_ERR" "unrecognized option \`-$OPTARG'"
				;;
		esac
	done
	shift $((OPTIND-1))
	# The interruption to the flags must be the input file
	FILE="$1" && shift
	# Reset getopts' counter and check for an output flag
	OPTIND=0
	while getopts :o: _opt; do
		case $_opt in
			o)
				OUT=$OPTARG
				;;
			\?)
				die "FLAG_ERR" "unrecognized option \`-$OPTARG'"
				;;
		esac
	done
	shift $((OPTIND-1))
}

file_check(){
	# Making sure input file has been correctly set and no unwanted
	# overwriting is happening in ouput.
	#
	# After args() if [no input set] (i.e. the -o went before the 
	# input file) but still have [non zero $1] then $1 = input
	[ -z "$FILE" ] && [ -n "$1" ] && FILE="$1"
	# If there is still [no input] or [input doesn't exist] then exit
	[ -z "$FILE" ] || [ ! -f "$FILE" ] && die "ERR" "${0##*/} requires a valid input file"
	# If output [already exists] and [don't want explicitly overwrite]
	# and haven't said [output should be input] then exit
	[ -f "$OUT" ] && [ $FORCED != true ] && [ "$OUT" != "$FILE" ] && die "OUT_ERR" "file \`$OUT' already exists, use flag \`-f' to overwrite"
}

gnu_check() {
	# Test if SED is GNU-SED, it is necessary for method of evaluating
	#
	sed v /dev/null > /dev/null 2>&1 || die "NO_GNU_SED_ERR" "macOS users try \`brew install gnu-sed' first!"
}

process(){
	# Captures the content on all lines beginning `!!' evaluating the
    # shell command and replacing the line with the STDOUT output.
    # Prints information about the process and avoids overwriting.	
	# 
	COMMAND='/^!!/{s/\$IN/'${FILE}'/g;s/\$OUT/'${OUT}'/g};s/^!!(.*)$/\1/e'
	# Counts number of matches
	NUM=$( sed -n '/^!!/p' "$FILE" | wc -l | sed 's/^[[:blank:]]*//' )

	# Run SED -i or >output.file dependent on if output.file is 
	# inputfile) or something else)
	case "$OUT" in
		"")
			[ "$FORCED" != true ] && printf '\033[1;33m-->  \033[31m%s\033[m will be overwritten with the processed copy\nPress Enter to continue or Ctrl+c to abort now...' "'$FILE'" && read -r _
			sed -i -r "$COMMAND" "$FILE"
			printf 'Processed %s->%s: with %s shell expansion(s)\n' "$FILE" "$FILE" "$NUM"

			;;
		*) 
			sed -r "$COMMAND" "$FILE" > "$OUT"
			printf 'Processed %s->%s: with %s shell expansion(s)\n' "$FILE" "$OUT" "$NUM"
			;;
	esac
}

usage() {
	# Print help message
	#
	printf '\nUsage: %s [-f] INPUT [-o OUTPUT]\n' "${0##*/}"
	printf '  -f                        Force overwriting of files\n'
	printf '  -h                        Display help\n'
	printf '  -o                        Processed as OUTPUT, if left blank the input file\n                            will be processed itself\n'
	printf '  -v                        Print version information\n'
	printf '\n'
}


FORCED=false
gnu_check
args "$@"
file_check "$@"
process
