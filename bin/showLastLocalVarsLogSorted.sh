#!/bin/bash

strPathHere="$(dirname "$(realpath "$0")")"

while true;do
	strFlLog="${strPathHere}/../../log/arx.linux.log"
	nLastLocalVarsIniLine="$(cat "$strFlLog" |egrep "Local variables for" -n |cut -d: -f1 |tail -n 1)";
	tail -n +$((nLastLocalVarsIniLine+1)) "$strFlLog" |sort
	echoc -w
done
