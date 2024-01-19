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

source <(secinit)

set -eEu

: ${bRetryingBuild:=false}; declare -p bRetryingBuild #help
fQuestionDelay=9;if $bRetryingBuild;then fQuestionDelay=0.01;fi

cd ArxLibertatis.github
strLoggedPath="`pwd`"
pwd
mkdir -vp build && cd build
pwd
#  -DARX_DEBUG=1
#cmake -DDEVELOPER=ON -DCMAKE_CXX_FLAGS=" -DARX_DEBUG_SHADOWBLOB " .. #changes at DCMAKE_CXX_FLAGS forces recompile everything tho...
#FAIL: export CMAKE_CXX_STANDARD=20 #this works like -std=c++20 ?
#FAIL: cmake -DDEVELOPER=ON -DCMAKE_CXX_FLAGS=" -DCMAKE_CXX_STANDARD=20 " .. #changes at DCMAKE_CXX_FLAGS forces recompile everything tho...
if ! lsb_release -r -c |grep "22.04";then
  if ! echoc -t ${fQuestionDelay} -q "this script is ready to make it work with ubuntu 22.04, continue anyway?";then
    exit 1
  fi
fi  

if ! dpkg -s qtbase5-dev >/dev/null;then
  echoc -p "
  Trying to let -std=c++20 be accepted so some implementations will not cause warn messages.
  But at CMakeLists.txt, Qt_VERSION is not being set (it is empty), and that downgrades from 20 to 17.
  To let it work, cmake must end up finding qt5 dev.
  For that the package 'qtbase5-dev' (>= 5.4 right?) is required.
  "
  exit 1;
fi

astrVarValoldValnew=(
	"CMAKE_BUILD_TYPE:STRING"      ""    "Debug"
	"CMAKE_CXX_FLAGS_DEBUG:STRING" -g    "-ggdb -O0 -fno-omit-frame-pointer"
	"SET_OPTIMIZATION_FLAGS:BOOL"  ON    OFF  # like -O0 above I guess
	"CMAKE_VERBOSE_MAKEFILE:BOOL"  FALSE TRUE
)
function FUNCshowSettings() {
	for((i=0;i<${#astrVarValoldValnew[*]};i+=3));do
		strVar="${astrVarValoldValnew[i+0]}"
		egrep "${strVar}=" ./CMakeCache.txt
	done
}
if echoc -t ${fQuestionDelay} -q "run cmake?";then
	cmake -DDEVELOPER=ON .. #changes at DCMAKE_CXX_FLAGS forces recompile everything tho...
	#sed -i.`SECFUNCdtFmt --filename`.bkp -r \
		#-e 's@SET_OPTIMIZATION_FLAGS:BOOL=ON@SET_OPTIMIZATION_FLAGS:BOOL=OFF@' \
		#"./CMakeCache.txt" #at build folder. This unoptimizes all the code so breakpoints hit perfectly in nemiver!
	echo "BEFORE:";FUNCshowSettings
	for((i=0;i<${#astrVarValoldValnew[*]};i+=3));do
		strVar="${astrVarValoldValnew[i+0]}"
		strValOld="${astrVarValoldValnew[i+1]}"
		strValNew="${astrVarValoldValnew[i+2]}"
		sed -i.`SECFUNCdtFmt --filename`.bkp -r \
			-e "s'^${strVar}=.*$'${strVar}=${strValNew}'" \
			"./CMakeCache.txt" #at build folder. This unoptimizes all the code so breakpoints hit perfectly in nemiver!
	done
fi
echo "AFTER:";FUNCshowSettings

#make -j "`grep "core id" /proc/cpuinfo |wc -l`"
: ${iMaxCores:=0} #help if the cpu is overheating, set this to 1. set to 0 to auto detect max cores.
if((iMaxCores<1));then iMaxCores="`grep "core id" /proc/cpuinfo |wc -l`";fi
astrMakeCmd=(make -j "$iMaxCores")
if echoc -q -t ${fQuestionDelay} "check coding style for warnings?";then
	"${astrMakeCmd[@]}" style
fi
#does not work :( astrMakeCmd+=(-e CPPFLAGS=-O0) #-O0 is important to let line breakpoints work in debuggers
if echoc -t ${fQuestionDelay} -q "do not remake it all, just touch the files? (this is useful if you know it doesnt need to recompile like in case you just changed a branch, but you need to touch the .cpp .h files that differ from previous branch tho)";then # --old-file=FILE may be usefull too
  astrMakeCmd+=(--touch)
fi
#doesnt work :( CPPFLAGS=-O0 "${astrMakeCmd[@]}"
SECFUNCexecA -ce "${astrMakeCmd[@]}" |tee ArxLibertatisBuildWithAllMakeCommands.log
sed -i.bkp -r \
	-e "s@${strLoggedPath}@\${strLoggedPath}@g" \
	-e "s@(make.*Entering directory ').*(/build.*)'@\1\${strLoggedPath}\2@" \
	ArxLibertatisBuildWithAllMakeCommands.log
if egrep -i "$USER" ArxLibertatisBuildWithAllMakeCommands.log;then
	echoc -p "found private data at log file"
fi

: ${bAutoDeploy:=true} #help
if ! $bAutoDeploy;then echoc -w deploy;fi

function FUNCmakeRO() {
	pwd
	if [[ ! -d "$1/" ]];then echoc -p "invalid path '$1/'";fi
	SECFUNCexec -ce find "$1/" \( -perm -u+w -or -perm -g+w -or -perm -o+w \) -exec chmod ugo-w '{}' \;
}
function FUNCmakeRW() {
	pwd
	if [[ ! -d "$1/" ]];then echoc -p "invalid path '$1/'";fi
	SECFUNCexec -ce find "$1/" \( -perm -u-w \) -exec chmod u+w '{}' \;
}

strDeployPath="../../../ArxLibertatis.layer7057.CoreNewerThanOverhaul-arx-libertatis-1.3-dev-2023-06-24-LinuxBuild/"
FUNCmakeRW "$strDeployPath"
SECFUNCexecA -ce cp -Ru * "$strDeployPath"
#while ! SECFUNCexecA -ce cp -Ru * "$strDeployPath";do
	##FUNCmakeRO "$strDeployPath"
  #echoc -w retry
#done
SECFUNCexecA -ce mkdir -vp "${strDeployPath}/data/"
# localization and misc (from data/core) must end at data/ and not data/core/
SECFUNCexecA -ce cp -vRu ../data/core/* "${strDeployPath}/data/"
FUNCmakeRO "${strDeployPath}/"
