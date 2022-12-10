#!/usr/bin/env bash

. ./libfrmt.sh

c=testing
frmt new $c html || { echo "Error initialising frmt"; exit 1; }
$c h1 "Header level 1"
$c h2 "Header level 2"
$c print "This is a normal line\n"
$c bold "This is bold"
$c del

outfile=$(mktemp)
frmt new $c ascii -f "$outfile" || { echo "Error initialising frmt"; exit 1; }
$c h1 "Testing"
$c del
cat "$outfile"
rm -f "$outfile"
