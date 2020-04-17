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
$ cat foo.bar
foo
!! echo "${PWD}$IN"
bar

$ pp foo.bar && cat foo.bar
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
ln -s pp /usr/local/bin
ln -s pp.1 /usr/local/share/man/man1
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
