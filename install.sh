#!/bin/sh
DEF_EX='/usr/local/bin'
DEF_MAN='/usr/local/share/man/man1'

printf 'This command will remove any files at the locations
\033[31m%s/pp
%s/pp.1\033[m
and replace them with ones in this repository
Press Enter to continue or ctrl-c to abort...' "$DEF_EX" "$DEF_MAN"
read -r _

echo "rm -f ${DEF_EX}/pp"
rm -f ${DEF_EX}/pp
echo "ln -s ./pp ${DEF_EX}/pp"
ln -s "${PWD}/pp" ${DEF_EX}/pp

echo "rm -f ${DEF_MAN}/pp.1"
rm -f ${DEF_MAN}/pp.1
echo "ln -s ./pp.1 ${DEF_MAN}/pp.1"
ln -s "${PWD}/pp.1" ${DEF_MAN}/pp.1
