#!/bin/sh
#  pp - the text preprocessor
#  Copyright (C) 2020  Joe Jenne

die() {
    echo "Error: $1" >&2
    echo "Usage: ${0##*/} v0.3.0" >&2
    echo "  * ${0##*/} < input > output -- See pp(1) for details and examples" >&2
    echo "Syntax:" >&2
    echo "  * Lines beginning !! are replaced with the following text evaluated" >&2
    echo "    as a shell command." >&2
    echo "  * Variables: \$ln for line no. \$line for line itself" >&2
    exit 1
}

process(){
    while IFS= read -r line; do ln=$((ln+1))
        case $line in
          !!*) eval "${line##!!}" || die "(line $ln): error";;
            *) echo "$line";;
        esac
    done < "$1"
}

[ $# -ne 0 ] && die "No arguments are taken"
[ -t 0 ] && die "No input text provided"
process "/dev/stdin"
