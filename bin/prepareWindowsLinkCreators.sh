#!/bin/bash

FUNCwindowsLinkCreator() { 
  local lstrSymlink="$1"
  
  echo "==================================="
  
  local lstrTarget="$(readlink "$lstrSymlink" |sed -r -e 's@^[.]/@@' -e 's@//@/@g' -e 's@/./@/@g' -e 's@/@\\@g')"
  local lstrWLnkBN="`basename "$lstrSymlink"`"
  local lstrWBatch="${lstrSymlink}.CreateWindowsLink.bat"
  declare -p lstrSymlink lstrTarget lstrWLnkBN lstrWBatch
  
  echo "mklink ${lstrWLnkBN} %~dp0${lstrTarget}" >"${lstrWBatch}"
  ls -l "${lstrWBatch}"
  cat "${lstrWBatch}"
  
  local lstrWBatchToCall="$(echo "${lstrWBatch}" |sed -r -e 's@^[.]/@@' -e 's@^[^/]*/@@' -e 's@/@\\@g')" #this also removes the 1st part of the folder
  declare -p lstrWBatchToCall
  echo "CALL ${lstrWBatchToCall}" >>"$strWBatchCallAll"
  cat "${strWBatchCallAll}"
};export -f FUNCwindowsLinkCreator;

#export strWBatchCallAll="`basename "$0"`.bat"
export strWBatchCallAll="createWindowsLinks.bat"

strModNm="$(basename "$(pwd)")";
strModNm="${strModNm%.github}";
strModNm="${strModNm%-main}"; # if it was downloaded from github as zip
declare -p strModNm

echo "cd ${strModNm}" >"$strWBatchCallAll"
find -type l -exec bash -c "FUNCwindowsLinkCreator '{}'" \;
