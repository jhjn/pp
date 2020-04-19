<p align="center">
<img src="https://i.postimg.cc/jqDnvm4b/pplogo.png" width="35%">
</p>
<p align="center">
<b>The POSIX sh text preprocessor</b>
</p>

**pp** is a [shellcheck](https://github.com/koalaman/shellcheck) linted, script written in ~50 s.l.o. POSIX sh that expands inline macros - also written in shell. **pp** is a much simpler processor than the *well-documented* [m4](https://www.gnu.org/software/m4/m4.html) without all the new commands and variables to learn. This program also adheres to the UNIX philosophy: doing one thing and doing it well, accepting stdin and writing to stdout. It is super easy and flexible to use, check out the [examples](#examples).

**Uses Include**:

* Preprocessing text files before their final compilation (e.g. pipe into pandoc [pandoc](https://github.com/jgm/pandoc) `pp file.md | pandoc -o file.pdf`) extending markdown to add anything that may appear in stdout.
* Writing a book/website in markdown. Import text from different files, using a common header/footer while substituting relevant information (see [examples](#examples))
* Don't leave your editor, enter a command on a line in your file, in vim tap in the shortcut (see [install](#install)) and it'll expand. `!! which python` expands to `/usr/local/opt/python/libexec/bin/python`.
* Create always up to date, dynamic text files. Want a date at the top of the file that is always correct? A short up to date git log statement? Enter the commands and every time **pp** is run on the file, the output is up to date.
* Basically anything you do in the command line can automatically be filled in - in your text file.

Intro
-----
This processor has one simple rule and three variables that together offer a large degree of flexibility.

**Rule**: Beginning a line with `!!` marks that the rest of the line (until newline) is a shell command to evaluate. The output then replaces the marked line when written to stdout.

**Variables**: `$FILE, $line and $ln` are preset variables when appearing on marked lines. `$FILE` is the name of the marked up file. `$line` is a variable containing the contents of the marked line after the initial `!!` and any whitespace that may follow. `ln` is the line number of the current marked command.

**Example**:
~~~
~$ cat foo.bar
foo
!! echo "word"
bar
!! echo "${PWD}/${FILE}"
baz
!! echo "$ln"

~$ pp foo.bar
foo
word
bar
/path/to/foo.bar
baz
6

~~~

Use the manual `man pp` for more information.

Install
-------
Clone the repository and enter, then run the install script which will prompt you if the default install location is correct. Edit the file if need be for `pp` in your `$PATH` and `pp.1` in your `$MANPATH`.

~~~
git clone https://github.com/jhjn/pp
cd pp
./install.sh
~~~
To add a little Vim shortcut to open the expanded form in a new vim window when you type `<leader>p` run:
~~~
echo 'nnoremap <leader>p :w! \| !pp % \| vim -<Enter>' >> $HOME/.vimrc
~~~

Examples
--------
### Import text? Use `cat`.
To import an html body, `body.txt`, and title an html document with the name of the file `home.html`, the input file would look like:
~~~
<title>
!! echo "${FILE##*/}"
</title>
<h1>Hello World!</h1>
<body>
!! cat "body.txt"
</body>
~~~
the output of `pp home.html` is then,
~~~
<title>
home
</title>
<h1>Hello World!</h1>
<body>
Lorem ipsum,
dolor sit amet.
</body>
~~~

---
### Want output in the middle of a line? Use `xargs`.
Format the output of your line by using `xargs -0` into a `printf` command. Where your `%s` is, your previous outputs will appear. With `printf` remember to put a newline at the end.
~~~
!! command | xargs -0 printf 'foo %s bar\n'
~~~
---
### Want to keep your command in the line? Use `echo &&`.
To keep the command line (e.g. on line 42) when run, begin your command with:
~~~
!! echo '!! '"$line" && command
~~~
Make sure the exclamation marks aren't in double quotes where in shells the have a different meaning.

---
### Want comments in your markdown file? Use `!!#`
The shell will ignore whatever is between a `#` and a newline.
~~~
!!# This is a comment and will only be visible before processing
~~~

---
### Want to chain multiple preprocesses together? Use `pp`.
There are three auxiliary texts `{header,footer,body}.md` and one main file `main.md`, **pp** can be called from within `main.md` to compile the auxiliary files before importing each one in the appropriate location.

~~~
~$ cat header.md
---
title: MAIN
subtitle: Generated with pp
!! whoami | xargs -0 printf 'author: %s'
!! date +%F | xargs -0 printf 'date: %s'
---

~$ cat body.md
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque bibendum, urna sed posuere egestas, mauris erat finibus dui, at convallis odio mi non velit.

~$ cat footer.md
---
<center> [home](/index.md) </center>
!! date +%Y | xargs -0 printf '<center> Copyright (C) %s - by me </center>'
~~~

and the main file

~~~
~$ cat footer_main.md
!! pp header.md > header_${FILE}
!! cat header_${FILE}

!! echo "$FILE"
==============
!!# This is a comment for the unprocessed file and will be
!!# removed by pp

This file
!! echo "(${FILE})"
is all about...

!! figlet "$FILE"


Intro
-----

!! pp body.md > body_${FILE}
!! cat "body_${FILE}"

Project
-------

!! tree --charset=ascii

* Past progress 

!! git log -5 --pretty="%h %ar %B"

* Tasks still left to do

!! task next

!! pp footer.md > footer_${FILE}
!! cat footer_${FILE}
~~~
By running the **pp** on `main.md` it has already been specified in the text that pp will run on the auxiliary files before they are imported into the text. The result will look like:

~~~
~$ pp main.md
---
title: MAIN
subtitle: Generated with pp
author: username
date: 2020-04-17
---

main.md
==============



This file
(main.md)
is all about...

                 _                       _ 
 _ __ ___   __ _(_)_ __    _ __ ___   __| |
| '_ ` _ \ / _` | | '_ \  | '_ ` _ \ / _` |
| | | | | | (_| | | | | |_| | | | | | (_| |
|_| |_| |_|\__,_|_|_| |_(_)_| |_| |_|\__,_|
                                           


Intro
-----

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque bibendum, urna sed posuere egestas, mauris erat finibus dui, at convallis odio mi non velit.

Project
-------

.
|-- body_main.md
|-- footer_main.md
|-- header_main.md
|-- main.md
`-- main.md

0 directories, 9 files

* Past progress 

b30905f 2 hours ago Added more latin

c8b0c4c 2 hours ago Made the copyright date automatically find the year

ca52330 4 hours ago Added a little figlet script

23326b7 4 hours ago Thought about adding figlet text

05b2007 5 hours ago Initial commit

* Tasks still left to do


ID Age Due  Description                             
-- --- ---- --------------------------------------------------
 5 9mo -8mo Is pp a good name for a program?? Answer soon
 1 11w      Start writing bash scripts not POSIX shell
 2 6mo      Go for a run
 3 4mo      Default task
            YAML header time
 4 4mo      Need to start thinking about use of fake latin in body

5 tasks

---
<center> [home](/index.md) </center>
<center> Copyright (C) 2020 - by me </center>
~~~

All in a couple simple commands. Every time the command is run the output is up to date!

---
Submit a pull request for this README if you can think of a super cool use of this preprocessor.
