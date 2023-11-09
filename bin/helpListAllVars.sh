#!/bin/bash

set -x

#cd ../ArxLibertatis
cd "`dirname "$0"`" # it is at 10.DevWork
pwd
strFl="`realpath .`/help.script.vars.txt";
declare -p strFl

cd ..
pwd

astr=(
  "§	"$'\xA7'"	A7	entity	int"
  "@	"$'\x40'"	40	entity	number"
  "£	"$'\xA3'"	A3	entity	string"
  "^	"$'\x5E'"	5E	system	(mixed)"
  "&	"$'\x26'"	26	global	number"
  "$	"$'\x24'"	24	global	string"
  "#	"$'\x23'"	23	global	int"
)
#strFl="../10.DevWork/help.script.vars.txt";
echo "//auto generated with $0" >"$strFl"
>>"$strFl"
for str in "${astr[@]}";do echo " $str" >>"$strFl";done
echo >>"$strFl"
for str in "${astr[@]}";do 
  echo "`date`: $str";
  echo "///////////// $str /////////////" >>"$strFl";
  strChar="`echo "$str" |cut -f2`";
  strHexa="`echo "$str" |cut -f3`";
  #strRegex='\'"${str:0:1}[a-zA-Z0-9_]{2}"
  # " "$'\xA7'"fighting"
  # $'\xA7'
  strRegex='\'"${str:0:1}[a-zA-Z0-9_]{2,}|${strChar}[a-zA-Z0-9_]{2,}"
  egrep "${strRegex}" * -iRhoa --include="*.asl" |sed -r "s@\x${strHexa}@${str:0:1}@" |tr '[:lower:]' '[:upper:]' |sort -u >>"$strFl";
  echo >>"$strFl";
done
