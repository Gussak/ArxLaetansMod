#!/bin/bash

function FUNCchk() {
  #strE="`uchardet "$1"`" #no, differs from geany
  strE="`file -b --mime-encoding "$1"`"
  echo "ENCODING='$strE': $1"
  
  if [[ "$strE" =~ ^iso-8859-1$ ]];then
    return 0
  fi
  
  if [[ "$strE" =~ ^iso-8859-1 ]];then
    echoc --info "WARN: expecting 'iso-8859-1' but found '$strE' that may be compatible too"
    return 0
  fi
  
  echoc -p "invalid encoding strE='$strE', the engine will fail to load this file with errors like: 'unknown type for: §identify'. The problem is that ex.: UTF-8 is 0xC2A7 instead of just 0xA7 for '§' token."
  return 1
};export -f FUNCchk

if [[ -n "$1" ]];then
  FUNCchk "$1"
else
  #find -iregex ".*\.\(asl\)" -exec bash -c 'FUNCchk "{}"' \;
  find -iregex ".*\.\(asl\)" |while read strFl;do
    FUNCchk "$strFl"
  done
fi
