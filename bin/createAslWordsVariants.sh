#!/bin/bash

# this mess below tries to create many upper and lower case (and '_' less) variants of commands, variables and other static words used in ASL scripts

: ${strInputDumpWithWords:="tmp.ManyAslCommandsVarusAndWords.txt"} #help
: ${strOutputDumpWithVariants:="tmp.geanyAslFileType.txt"} #help

strData="`cat "${strInputDumpWithWords}"`"
strData2="$(echo "$strData" |tr ' ' "\n" |sed -r -e 's@^".*@&#@' |egrep -v '^".*' |tr -d '"' |sort -u |sed -r -e 's@(set)([a-z])(.*)@\1\2\3\n \1\u\2\3\n \1_\2\3@' |sed -r -e 's@(_)([a-z])@\1\u\2@g' |sort -u )"
echo "$(
	echo "$strData2";
	echo "$strData2" |tr '[:lower:]' '[:upper:]';
	
	echo "$strData2" |sed -r 's@^[a-z]@\u&@';
	echo "$strData2" |sed -r 's@^[a-z]@\u&@' |tr '[:lower:]' '[:upper:]';
	
	echo "$strData2" |sed -r 's@^[a-z]@\u&@' |tr -d '_';
	echo "$strData2" |sed -r 's@^[a-z]@\u&@' |tr -d '_' |tr '[:lower:]' '[:upper:]';
	
	echo "$strData2" |tr -d '_';
	echo "$strData2" |tr -d '_' |tr '[:lower:]' '[:upper:]';
	
	echo "$strData2" |tr '[:upper:]' '[:lower:]';
	echo "$strData2" |tr '[:upper:]' '[:lower:]' |tr '[:lower:]' '[:upper:]';
)" |sort -u |tr '\n' ' ' >"${strOutputDumpWithVariants}"
