#!/bin/bash

# Copyright 2023 Gussak<https://github.com/Gussak>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
