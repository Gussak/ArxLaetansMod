#!/bin/bash

source <(secinit)

set -Eeu

strFlTxNmC="MagicVial"
strFlTxNmL="`echo "$strFlTxNmC" |tr '[:upper:]' '[:lower:]'`"
strDefaultColorAtBaseFtl="R255G000B000"

function FUNCdoItB() {
  local lstrColor="$1";shift
  
  local lstrFlNew="${strFlTxNmC}.${lstrColor}.ftl.unpack"
  
  echoc -w "creating with: $lstrFlNew"
  
  # prepare folder, copy file with new name and create symlink
  strings "$strFlTxNmC.ftl.unpack" |egrep "${strFlTxNmC}" -i 
  SECFUNCexecA -ce cp -fvT "$strFlTxNmC.ftl.unpack" "${lstrFlNew}"
  
  # patch the file with the new color id
  SECFUNCexecA -ce sed -i -r "s@${strDefaultColorAtBaseFtl}@${lstrColor}@i" "${lstrFlNew}"
  SECFUNCexecA -ce ls -l "${lstrFlNew}"
  strings "${lstrFlNew}" |egrep "${strFlTxNmC}" -i&&:
  if ! egrep "${strFlTxNmC}.*\.png" "${lstrFlNew}" -iaoH;then
    echoc -p "FAILED"
    exit 1
  fi
}

FUNCdoItB r000g255b000

SECFUNCexecA -ce egrep "${strFlTxNmC}.*\.png" *.ftl.* -iaoH
