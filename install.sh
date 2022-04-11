#!/bin/sh
USR_BIN='/usr/local/bin'
USR_MAN='/usr/local/share/man/man1'

echo 'Installation requires pandoc and will remove any files at the following locations:'
printf '\033[31m * %s\033[m\n' "$USR_BIN/pp" "$USR_MAN/pp.1"
echo 'and replace them with ones in this repository'
echo 'Press Enter to continue... (CTRL-C to abort)'
read -r _

set +x
rm -f "$USR_BIN/pp"
cp ./pp "$USR_BIN/pp"

rm -f "$USR_MAN/pp.1"
pandoc --standalone ./pp.1.md --to man > "$USR_MAN/pp.1"
