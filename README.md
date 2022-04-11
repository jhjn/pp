<p align="center">
<img src="https://i.postimg.cc/jqDnvm4b/pplogo.png" width="35%">
</p>
<p align="center">
<b>The POSIX sh text preprocessor</b>
</p>


**pp** expands inline shell commands:
* UNIX philosophy: `stdin` for input, `stdout` for output
* Nothing new: flexible and familiar by design by accepting shell commands
* Minimal: [shellcheck](https://github.com/koalaman/shellcheck) linted <30 s.l.o. POSIX sh script


```
Today (!{date '+%Y-%m-%d'}!) there's a lot to do:
!! cat ~/tasks.txt
Tomorrow's tasks can wait. !{# Change wording? }!
```
becomes
```
Today (2022-04-11) there's a lot to do:
* Wash clothes
* Read pure sh bible
* Write README
Tomorrow's tasks can wait.
```

Check out [more examples](#examples).

Use Cases
---------

* Pre-processing markdown files before compilation (e.g. pipe into pandoc [pandoc](https://github.com/jgm/pandoc) `cat file.md | pp | pandoc -o file.pdf`) extending markdown to add anything that may appear in stdout.
* Writing a book/static website in markdown? Import text from different files, using a common header/footer with a custom body (see [examples](#examples))
* Create always up to date, dynamic notebooks. Want a date at the top of the file that is always correct? A short up to date git log statement? Enter the commands and every time **pp** is run on the file, the output is up to date.

Documentation
-------------
See the manpage `PP(1)`.

Install
-------
Use the install script to copy the `pp` script to your user bin and compile the markdown manpage, outputting at the user man path.
```
git clone https://github.com/jhjn/pp
cd pp/
./install.sh
```
NOTE: The manpage `pp.1` build requires [pandoc](https://pandoc.org).

Examples
========

Whole Line
----------
Use the command line syntax to insert command output
```
!! which ls
```

Inline
------
Use the section command syntax to insert inline output.
```
foo !{command}! bar
```

Keep Line
---------
Print the `$line` to keep the macro command in the output when run. Begin your command with:
```
!! echo "$line" && command
```


Import files
------------
To import text into a document (_instructions.txt_) during pre-processing, the **cat** command can be used:
```
The following metadata, stored at /etc/mydata.txt, will be used:
!! cat /etc/mydata.txt
This is updated nightly...
```
running `cat instruction.txt | pp` gives the output,
```
The following metadata, stored at /etc/mydata.txt, will be used:
name  time    location 
----------------------
ava   2301    upstairs
bob   1832  downstairs
----------------------
This is updated nightly...
```

For more complicated inline expressions a separate script in the repository can be used. For instance,
```
Check out all this data:
!! bash ./scripts/gen-data.sh
This was calculated automatically when creating the document.
```


Templates
---------
Similarly, using environment variable control, a single template file can be expanded into a full html page. The pattern may look like:
```
<head>
...
</head>
!! markdown $INPUT_FILE
<footer>
...
</footer>
```
running `cat template.html | INPUT_FILE=blog.md pp > blog.html` could be used to fill the template with the desired content at runtime.

Comments
--------
Note that the _#_ character is used for shell comments, this still applies in macros. Therefore,
```
!!# This document is written by Tom
Important !{#Make bold?}! content
```
becomes,
```
Important content
```

Markdown
--------
The stdin-stdout model is well suited to chains of processing. For instance, a markdown file could be processed using awk, piped into **pp** and finally compiled into html. This pattern would look like:
```
for file in $(ls *.md); do
    awk -f $file | INPUT=$file pp | cmark > ${file%%.md}.html
done
```

Nesting
-------
```
foo
!! pp next.md
bar
```
Multiple `pp` instances can be nested like above.

---
Pull requests welcome!
