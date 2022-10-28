#!/bin/sh
#  pp - the text preprocessor
#  Copyright (C) 2020  Joe Jenne

die() {
    echo "Error: $1" >&2
    echo "Usage: ${0##*/} v0.3.0" >&2
    echo "  * ${0##*/} < input > output -- See pp(1)" >&2
    echo "Syntax:" >&2
    echo "  * Evaluate lines beginning !! as sh commands" >&2
    echo "  * Variable \$line contains the line itself" >&2
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
[ -t 0 ] && die "Input text must be provided via stdin"
process "/dev/stdin"
