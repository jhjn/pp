<p align="center">
<img src="https://i.postimg.cc/jqDnvm4b/pplogo.png" width="35%">
</p>
<p align="center">
<b>The text preprocessor</b>
</p>

**pp** is a [shellcheck](https://github.com/koalaman/shellcheck) linted POSIX sh script that processes text files before their final compilation (e.g. using [pandoc](https://github.com/jgm/pandoc)). It is a single executable script, under 100 sloc, that is super simple to use.

Intro
-----
This processor has one simple rule and two variables that together offer a large degree of flexibility.

**Rule**: Beginning a line with `!!` indicates a shell one-liner follows. All text until a newline will be evaluated with `sh` and the output - `/dev/stdout` - will replace the marked line in the output file. Without specifying an output, the input file is overwritten.

**Variables**: `$IN` and `$OUT` will be replaced by the names of the input text file and output text file respectively *before* the command is run on all marked lines.

**Example**:
~~~
~$ cat foo.bar
foo
!! echo "${PWD}$IN"
bar

~$ pp foo.bar && cat foo.bar
foo
/path/to/foo.bar
bar

~~~

Use the manual `man pp` for more information.

Install
-------
**Dependencies**
- GNU SED 4.2+ - for macOS users `brew install gnu-sed`

To download and install, the recommended path for system wide usage is given below:
~~~
git clone https://github.com/jhjn/pp
cd pp
ln -s ./pp /usr/local/bin
ln -s ./pp.1 /usr/local/share/man/man1
~~~
To add a little Vim "plugin" to instantly format and update your document when you type `<leader>p` run:
~~~
echo 'nnoremap <leader>p :w! \| :!pp -f %<CR>:e!<Enter>' >> $HOME/.vimrc
~~~

Examples
--------
To import an html body, `body.txt`, and title an html document with the name of the file `home.html`, the input file would look like:
~~~
<title>
!! echo "$IN" | sed -r 's/\..*$//'
</title>
<h1>Hello World!</h1>
<body>
!! cat "body.txt"
</body>
~~~
by running `pp home.html` the file becomes,
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

To use a command **in the middle of a line** format the output around the rest of the text using `xargs` and `printf`
~~~
!! command | xargs -0 printf 'I am using the ouput below\n-->%s<--\n'
~~~

---

Say one has three auxiliary texts and one main file, **pp** can be called from within the `main.md` file and so compile the incoming files before importing them.

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

All in a couple simple commands. Every time the command is run the information input is new.
