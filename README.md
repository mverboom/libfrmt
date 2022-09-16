## libfrmt

This is a very basic library that can be used to format output in a shellscript
to a specific standard. Instead of having to define multiple ways to print output
for a wiki, this library will do it for you.

To initialise, specify a new frmt "object" name for a specific format. Currently
the following formats are implmemented:
* ascii
* dokuwiki
* mediawiki

```frmt new objectname dokuwiki```

To output tekst in the correct format, the objectname can be used. There is a
limited set of outputs that are supported:
* h1-h3: Header level 1 through 3
* bold: Bold printing text
* pre: Preformatted text
* foldstart/foldend: Make a folding section
* tables

To output bold text:

```objectname bold "my bold text"```

To create a folding section section with content:

```
objectname foldstart "My fold name"
objectname bold "This is a line in the fold"
objectname foldend
```

To create a basic table:

```
objectname t_head "Column 1" "Column 2" "Column 3"
objectname t_line "Item 1" "Item 3" "Item 5"
objectname t_line "Item 2" "Item 4" "Item 6"
objectname t_end
```

Per default output is generated on stdout, but can also be send to a file:

```objectname output /tmp/outputfile```
