<p align="center">
<img src="https://i.postimg.cc/jqDnvm4b/pplogo.png" width="35%">
</p>
<p align="center">
<b>The text preprocessor</b>
</p>

**pp** is a [shellcheck](https://github.com/koalaman/shellcheck) linted POSIX sh script that replaces marked shell script with its output. It is a single executable script, under 100 sloc, that is super simple to use.

**Uses Include**:

* Preprocess text files before their final compilation (e.g. using [pandoc](https://github.com/jgm/pandoc)) extending markdown to add anything that can appear in STDOUT.
* Writing a book/website in markdown. Import text from different files, using a common header/footer while substituting relevant information (see [examples](#examples))
* Don't leave your editor, enter a command on a line in your file, in vim tap in the shortcut (see [install](#install)) and it'll expand. `!! which python` expands to `/usr/local/opt/python/libexec/bin/python`.
* Create always up to date, dynamic text files. Want a date at the top of the file that is always correct? A short up to date git log statement? Enter the commands and every time **pp** is run on the file, the output is up to date.
> ...anything your command line can do...
> because it **is** your *command*... line

Intro
-----
This processor has one simple rule, two variables and line tags that together offer a large degree of flexibility.

**Rule**: Beginning a line with `!!` indicates a shell one-liner follows. All text until a newline will be evaluated with `sh` and the output - `/dev/stdout` - will replace the marked line in the output file. Without specifying an output, the input file is overwritten.

**Variables**: `$IN` and `$OUT` will be replaced by the names of the input text file and output text file respectively *before* the commands are run.

**Tags**: Ending a line with a `#` followed by one of the 62 alpha-numeric characters tags that line's line number. A reference anywhere using `$` followed by the same tag character is replaced by the tagged line number *before* the commands are run.

**Example**:
~~~
~$ cat foo.bar
foo
! echo "word"
bar
!! echo "${PWD}$IN" #a
baz
!! echo "$a$ 

~$ pp foo.bar && cat foo.bar
foo
word
bar
/path/to/foo.bar
baz
4

~~~

Use the manual `man pp` for more information.

Install
-------
**Dependencies**
- GNU SED 4.2+ - for macOS users `brew install gnu-sed`

To download and install put `pp` executable in your `$PATH` and `pp.1` in your `$MANPATH`.

I.e. (recommended given no existing file `pp`) 
~~~
git clone https://github.com/jhjn/pp
cd pp
ln -s ./pp /usr/local/bin
ln -s ./pp.1 /usr/local/share/man/man1
~~~
To add a little Vim shortcut to instantly format and update your document when you type `<leader>p` run:
~~~
echo 'nnoremap <leader>p :w! \| :!pp -q %<CR>:e!<Enter>' >> $HOME/.vimrc
~~~

Examples
--------
### Import text? Use `cat`.
To import an html body, `body.txt`, and title an html document with the name of the file `home.html`, the input file would look like:
~~~
<title>
!! echo "$IN" | sed -r 's/\..*//'
</title>
<h1>Hello World!</h1>
<body>
!! cat "body.txt"
</body>
~~~
by running `pp -q home.html` the file becomes,
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
### Want to keep your command in the line? Use `sed &&`.
To keep the command line (e.g. on line 42) when run, begin your command with:
~~~
!! sed 42!d $IN && command
~~~
To not have to worry about line number you can use tags and a self replicating sed script, it's a little longer. Tag your line at the end so the line number can be referenced. `t` is just an example tag character.
~~~
!! sed '$t!d;s/$t!/$''t!/g' $IN && command; #t
~~~

---
### Want to chain multiple preprocesses together? Use `pp`.
There are three auxiliary texts `{header,footer,body}_main.md` and one main file `main.md`, **pp** can be called from within `main.md` to compile the auxiliary files before importing each one in the appropriate location.

~~~
~$ cat header_main.md
---
title: MAIN
subtitle: Generated with pp
!! whoami | xargs -0 printf 'author: %s'
!! date +%F | xargs -0 printf 'date: %s'
---

~$ cat body_main.md
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque bibendum, urna sed posuere egestas, mauris erat finibus dui, at convallis odio mi non velit.
~$ cat footer_main.md
---
<center> [home](/index.md)
!! date +%Y | xargs -0 printf '<center> Copyright (C) %s - by me </center>'
~~~

and the main file

~~~
~$ cat footer_main.md
!! pp -f header_$IN
!! cat header_$IN

!! echo "$IN"
==============
!!# This is a comment for the unprocessed file and will be
!!# removed by pp

This file
!! echo "($OUT)"
is all about...

!! figlet "$IN"


Intro
-----

!! pp -f body_$IN
!! cat "body_$IN"

Project
-------

!! tree --charset=ascii

* Past progress 

!! git log -5 --pretty="%h %ar %B"

* Tasks still left to do

!! task next

!! pp -f footer_$IN
!! cat footer_$IN
~~~
By running the **pp** on `main.md` one can specify to run pp on a file before outputting the text in the file. The finished result will be:

~~~
~$ pp -f main.md && cat main.md
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
<center> [home](/index.md)
<center> Copyright (C) 2020 - by me </center>
~~~

All in a couple simple commands. Every time the command is run the output is up to date!
