#!/bin/bash

strPathHere="$(dirname "$(realpath "$0")")"

while true;do
	strFlLog="${strPathHere}/../../log/arx.linux.log"
	strFlLog="$(realpath "$strFlLog")"
	echo "'$strFlLog'"
	nLastLocalVarsIniLine="$(cat "$strFlLog" |egrep "Local variables for" -n |cut -d: -f1 |tail -n 1)";
	tail -n +$((nLastLocalVarsIniLine)) "$strFlLog" |egrep -v "MySimpleDbg" |sort -u #TODO was showing dups or more, it is wrong..
	echoc -w
done
