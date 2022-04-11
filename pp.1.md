% PP(1) v0.2.0 April 2020 | pp-preprocessor manual

NAME
====

**pp** - the POSIX sh text preprocessor

SYNOPSIS
========

stdin | **pp** > output

DESCRIPTION
===========

**pp** preprocesses text from standard input, expanding macros written in shell.
This can be used before compiling to its final format (e.g. piping into a markdown compiler).
The marked shell commands (see _SYNTAX_) are replaced by their evaluated output when written to the standard output.

There are no dependencies as **pp** is written in POSIX sh.

SYNTAX
======
!!
: An input line beginning **!!** is replaced by the output of the evaluated _sh_ command that follows. Therefore,
```
foo
!! echo "Insert Text"
bar
```
becomes,
```
foo
Insert Text
bar
```

!{...}!
: A section marked out with the above command brackets is replaced with the evaluated command '...'. Therefore,
```
On !{date}! it is my birthday
```
becomes,
```
On Mon 11 Apr 2022 it is my birthday
```


$line and $ln
: Two variables may be used when writing macros. **\$line** is the contents of the line that is currently being evaluated. **\$ln** is the local line number. These can be used for more complex operations and side effects. For example,
```
foo
!! echo "$line" && touch myfile
bar
```
touches _myfile_ and becomes,
```
foo
!! echo "$line" && touch myfile
bar
```

EXAMPLES 
========

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

BUGS
====

Via the GitHub issue tracker: <https://github.com/jhjn/pp/issues>

AUTHOR
======
Joe Jenne <joe@jenne.uk>
