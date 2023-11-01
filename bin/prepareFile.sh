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

set -eEu

source <(secinit)

strModNm="$(basename "$(pwd)")";
strModNm="${strModNm%.github}";
strModNm="${strModNm%-main}"; # if it was downloaded from github as zip
export strModNm
declare -p strModNm

egrep "[#]help" $0 -n&&:

strMainPath="`pwd`"

if [[ -z "$@" ]];then
  IFS=$'\n' read -d '' -r -a astrWorkList < <(find -maxdepth 1 -type d -iname "${strModNm}*" -not -iname "*.Setup")&&:
else
  astrWorkList=("$@")
fi
declare -p astrWorkList

for strWork in "${astrWorkList[@]}";do
  SECFUNCdrawLine "$strWork"
  
  cd "$strMainPath";pwd
  
  declare -p strWork
  cd "$strWork";pwd
  
  if egrep "TODO" * -iRnI;then
    echoc -p "TODO above..."
    exit 1
  fi
  
  # VALIDATIONS
  
  echoc --info "validate relative symlinks"
  FUNCchkLnk() { 
    echo "SYMLINK: $1 '`readlink "$1"`'";
    local lstrLnk="$(readlink -v "$1")"
    if echo "$lstrLnk" |egrep "^/.*|.*${USER}.*";then
      ls -ld "$1";
      echoc -p "everything must be relative, no absolute paths.";
      bExit=true
    fi;
  };export -f FUNCchkLnk
  #find -type l -exec bash -c "FUNCchkLnk '{}'" \;
  bExit=false
  IFS=$'\n' read -d '' -r -a astrFoundList < <(find ./ "../../${strModNm}Setup.github/${strWork}.Setup/" -type l)&&:
  for strFound in "${astrFoundList[@]}";do
    FUNCchkLnk "$strFound"
  done
  if $bExit;then exit 1;fi
  
  echoc --info "validate lowercase (at setup only)"
  (
    cd "../../${strModNm}Setup.github/${strWork}.Setup/";pwd
    if find |egrep -v "^./${strModNm}$" |egrep "[A-Z]";then #ignores the folder that will not be on the package
      if echoc -q "Everything that will be installed must be lowercase. Fix it now?@Dy";then
        FUNCtoLower() { strFl="$1";strFlLw="`echo "$1" |tr '[:upper:]' '[:lower:]'`";if [[ "$strFl" != "$strFlLw" ]];then mv -vT "$1" "${strFlLw}";fi; };export -f FUNCtoLower
        find -iregex ".*[A-Z].*" -exec bash -c "FUNCtoLower '{}'" \;
      fi
    fi
  )
  
  echoc --info "validate no brokenlinks (main mod folder only)"
  strChkLinks="`find ./ -type l -and -xtype l -exec ls --color -ld '{}' \;`"
  if [[ -n "$strChkLinks" ]];then
    echo "$strChkLinks"
    echoc -p "broken links above? fix them"
    exit 1
  fi
  
  # FINALIZE
  
  echoc --info "PREPARE PACKAGE"
  strFlNewestFtl="`ls -1trd $(find -iname "*.ftl*") |tail -n 1`"
  strFlNewestFtl="${strFlNewestFtl#./}"
  declare -p strFlNewestFtl
  if [[ ! -L "$strFlNewestFtl" ]] && [[ ! -f "$strFlNewestFtl" ]];then echoc -p "invalid strFlNewestFtl='$strFlNewestFtl' (.ftl file not found? did you rename it from .ftl.unpack to .ftl?), shall be only one file also.";exit 1;fi
  export strFlNewestFtlRP="$(realpath "$strFlNewestFtl")"
  declare -p strFlNewestFtlRP
  
  if [[ "$strFlNewestFtl" -nt "../${strWork}.7z" ]] || echoc -q "strFlNewestFtl='$strFlNewestFtl' is not newer than '${strWork}.7z', continue anyway?";then
    (
      cd "$strMainPath";pwd
      function FUNCcreatePackage() {
        local lbExcludeHelperFolder=false;if [[ "$1" == --excludeHelperFolder ]];then lbExcludeHelperFolder=true;shift;fi
        
        local lstrDirPack="$1"
        declare -p lstrDirPack
        
        pwd
        
        local lstrFlPak="${lstrDirPack}.7z"
        declare -p lstrFlPak
        
        trash "${lstrFlPak}"&&:
        #local lstrIgnoreHelperPath="${lstrDirPack}/${strModNm}"
        #IFS=$'\n' read -d '' -r -a astrAddList < <(ls -1d "${lstrDirPack}/"* |egrep -v "")&&:
        local lacmdFind=(find "${lstrDirPack}/" -mindepth 1 -maxdepth 1)
        if $lbExcludeHelperFolder;then
          lacmdFind+=(-not -iname "${strModNm}")
          #SECFUNCexecA -ce find "${lstrDirPack}/" -mindepth 1 -maxdepth 1&&:
          #SECFUNCexecA -ce find "${lstrDirPack}/" -mindepth 1 -maxdepth 1 -not -iname "${strModNm}"&&:
          #IFS=$'\n' read -d '' -r -a astrAddList < <(find "${lstrDirPack}/" -mindepth 1 -maxdepth 1 -not -iname "${strModNm}")&&:
        #else
          #IFS=$'\n' read -d '' -r -a astrAddList < <(find "${lstrDirPack}/" -mindepth 1 -maxdepth 1)&&:
        fi
        IFS=$'\n' read -d '' -r -a astrAddList < <(SECFUNCexecA -ce "${lacmdFind[@]}")&&:
        declare -p astrAddList
        SECFUNCarrayShow -v astrAddList
        if ((`SECFUNCarraySize astrAddList`==0));then SECFUNCechoErrA "invalid astrAddList";exit 1;fi
        SECFUNCexecA -ce 7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on -mmt16 "${lstrFlPak}" "${astrAddList[@]}"
        SECFUNCexecA -ce ls -ld "${lstrFlPak}"
        SECFUNCexecA -ce touch -r "${strFlNewestFtlRP}" "${lstrFlPak}"
        SECFUNCexecA -ce ls -ld "${lstrFlPak}"
        
        strIgn="${lstrFlPak#../}"
        strIgn="${strIgn#./}"
        if ! egrep "[!]${strIgn}" .gitignore;then
          echo "!${strIgn}" >>.gitignore
          echoc -x cat .gitignore
        fi
      }
      FUNCcreatePackage "${strWork}"
      (
        cd "../${strModNm}Setup.github/"
        FUNCcreatePackage --excludeHelperFolder "${strWork}.Setup"
      )
    )
  fi
  #echoc -w
done
