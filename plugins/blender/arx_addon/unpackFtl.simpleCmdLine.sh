#!/bin/bash
# Copyright 2023 Gussak<https://github.com/Gussak>
#
# This file is part of Arx Laetans Mod.
#
# Arx Libertatis is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Arx Libertatis is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Arx Libertatis. If not, see <http://www.gnu.org/licenses/>.

source <(secinit)

: ${bVerbose:=false} #help
outputTo="/dev/stderr"
if ! $bVerbose;then outputTo="/dev/null";fi

strSelf="$0";declare -p strSelf >"$outputTo"
egrep "[#]help" "$strSelf" >&2
#help params: <file.ftl>

strFl="`realpath "$1"`";declare -p strFl >"$outputTo"

#if [[ -L "$strSelf" ]];then
	#strLink="`readlink "$strSelf"`"
#else
	strLink="$strSelf"
#fi
#declare -p strLink >"$outputTo"

astrPath=()

astrPath+=("$(dirname "$strSelf")")

echoc --info "guessing lib path"
IFS=$'\n' read -d '' -r -a astrList < <(
	pwd >"$outputTo"
	declare -p strLink >"$outputTo"
	while true;do
		strRP="$(realpath -s "$strLink")"&&:;declare -p strRP >"$outputTo"
		dirname "$strRP" # OUTPUT
		strDir="$(dirname "${strLink}")"&&:;declare -p strDir >"$outputTo"
		cd "$strDir";pwd >"$outputTo"
		strBN="$(basename "$strLink")";declare -p strBN >"$outputTo"
		strLink="$(readlink "${strBN}")"&&:;declare -p strLink >"$outputTo"
		if [[ -z "$strLink" ]];then break;fi;
	done
)&&:
astrPath+=("${astrList[@]}")

astrPath+=("$(dirname "$(realpath "$strSelf" )" )")

SECFUNCarrayShow -v astrPath >"$outputTo"

strLib="LIB_NOT_FOUND"
for strPath in "${astrPath[@]}";do
	strLib="${strPath}/libArxIO.so.0"
	
	echo "checking PATH: $strPath" >"$outputTo"
	if [[ ! -d "$strPath" ]];then continue;fi
	
	echo "checking LIB: $strLib" >"$outputTo"
	if [[ ! -f "$strLib" ]];then continue;fi
	
	break;
done
#echoc -p "invalid path '$strPath'";

#strLib="${strPath}/libArxIO.so.0";declare -p strLib
if [[ ! -f "$strLib" ]];then echoc -p "invalid lib '$strLib'";fi
echoc --info "GOOD PATH! '$strPath'"
echoc --info "LIB FOUND! '$strLib'"

pwd >"$outputTo";cd "$strPath";pwd >"$outputTo" #not realpath because the symlink can point to another symlink that will be where libArxIO.so.0 can be found!
#if ! ls -l "libArxIO.so.0";then echoc -pw "libArxIO.so.0 not found here: `pwd`";exit 1;fi
if [[ ! -f "libArxIO.so.0" ]];then echoc -p "`basename $strSelf`: libArxIO.so.0 not found here: `pwd`";echoc -w;exit 1;fi

if [[ -f "${strFl}.unpack" ]];then
  mv -vf "${strFl}.unpack" "${strFl}.unpack.old" >"$outputTo"
fi

strOutput="`PYTHONPATH="${PYTHONPATH-}:/$(pwd)" SECFUNCexecA -ce python3 unpackFtl.simpleCmdLine.py "$strFl"`";

if [[ ! -f "${strFl}.unpack" ]];then
  if [[ "$strOutput" == "file is not packed" ]];then
    cp -v "${strFl}" "${strFl}.unpack" >"$outputTo"
  else
    echoc -p "failed unpacking file '${strFl}'"
    exit 1
  fi
fi
ls -l "${strFl}" "${strFl}.unpack"&&: >"$outputTo"
