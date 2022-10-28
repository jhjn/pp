#!/bin/sh
#  pp - the text preprocessor - Copyright (C) 2020  Joe Jenne
[ $# -ne 0 ] || [ -t 0 ] && echo -e "pp < input > output\ntry: pp <<< \$'hi\\\\n!! ls'" >&2 && exit 1
while read -r L; do case $L in !!*) eval "${L##!!}" || exit 1;; *) echo "$L";; esac; done
