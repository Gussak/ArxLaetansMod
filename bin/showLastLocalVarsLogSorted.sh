#!/bin/bash

strPathHere="$(dirname "$(realpath "$0")")"

astrSecCmd=(
	sed -r 
	
	-e 's".*Global variables:"0&"'
	-e 's"^#" 1 &"' 
	-e 's"^&" 2 &"' 
	-e 's"^\$" 3 &"' 
	-e 's"^\^" 4 &"' 
	
	-e 's".*Local variables for"5&"'
	-e 's"^§" 6 &"' 
	-e 's"^@" 7 &"' 
	-e 's"^£" 8 &"' 
)

while true;do
	strFlLog="${strPathHere}/../../log/arx.linux.log"
	strFlLog="$(realpath "$strFlLog")"
	echo "'$strFlLog'"
	nLastLocalVarsIniLine="$(cat "$strFlLog" |egrep "Local variables for" -n |cut -d: -f1 |tail -n 1)";
	tail -n +$((nLastLocalVarsIniLine)) "$strFlLog" |egrep -v "MySimpleDbg" |"${astrSecCmd[@]}" |sort -n #TODO was showing dups or more, it is wrong..
	echoc -w
done


