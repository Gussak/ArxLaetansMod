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

strPathIni="`pwd`"
strPathRun="`realpath ../ArxLibertatis`"
strFlLog="`realpath .`/log/arx.linux.`SECFUNCdtFmt --filename`.log"
mkdir -vp "`dirname "$strFlLog"`"

while true;do
	: ${bClear:=false} #help
	if $bClear;then clear;fi
	
	strDbgWhatFile="`echoc -t 3 -S "Debug what file (ex.: ScriptedAnimation)?"`" # src/script/ScriptedIOProperties.cpp
	declare -p strDbgWhatFile
	
	: ${bBuildB4Run:=true} #help
	if $bBuildB4Run;then 
		cd "$strPathIni"
		fQuestionDelay=9;
		: ${bRetryingBuild:=false}; export bRetryingBuild #detected by buildArxLibertatis.sh
		if ! $bRetryingBuild && echoc -t ${fQuestionDelay} -q "fast prompts?@Dy";then bRetryingBuild=true;fi
		if $bRetryingBuild;then fQuestionDelay=0.01;fi
		if echoc -q -t ${fQuestionDelay} "re-build it?@Dy";then
			while ! ./buildArxLibertatis.sh;do 
				echoc -w "fix the code and retry";
				bRetryingBuild=true
			done;
		fi
	fi
	
	if [[ ! -f "$strPathRun/arx" ]];then
		cd "$strPathIni"
		cd ..
		secOverrideMultiLayerMountPoint.sh ArxLibertatis
	fi

	cd "$strPathRun"
	
	#strPrettyData="`ls -1d ../../ArxLibertatis.layer*.GFX-Arx_Neuralis*/graph/obj3d/textures*DISABLED*`"
	strPrettyDataAt="../../ArxLibertatis.layer*.GFX-Arx_Neuralis*/graph/obj3d/textures"
	strPrettyData="`ls -1d ${strPrettyDataAt}`"&&:
	if [[ ! -d "$strPrettyData" ]];then
		echoc -p "having this path disabled will break/crash loading the game just after falling in the hole '$strPrettyDataAt'"
	fi
	
	: ${strMainModFile:="${strPathIni}/ArxLaetansMod.github/Mod.AncientDevices/ArxLaetansMod/AncientDevices/Scripts/hologram.asl"} #help
	SECFUNCexecA -ce chmod -v u+w "$strMainModFile"
	
	function FUNCsaveList() { 
			find "$HOME/.local/share/arx/save" -iname "gsave.sav" -exec ls --full-time '{}' \; |sort -k6; 
	}
	FUNCsaveList
	nNewestSaveIndex=$((10#`FUNCsaveList |tail -n 1 |sed -r 's@.*/save(....)/.*@\1@'`))&&:;
	
	strFlDbg="src/script/ScriptUtils.cpp"
	nDbgLine="$(egrep "iDbgBrkPCount\+\+" "${strPathIni}/ArxLibertatis.github/${strFlDbg}" -n |cut -d: -f 1)"
	echoc --info "On Nemiver create a breakpoint to function: @rDebugBreakpoint or ${strFlDbg} ${nDbgLine}"
	acmdParams=(
		--data-dir="../Arx Fatalis" #TODOA could just place data*.pak at libertatis path? or on a layer?
		#--debug="warn,error,debug" #TODOA this works???
		#--debug="debug,info,console,warning,error,critical"
		--debug-gl
	);
	#if echoc -t $fQuestionDelay -S asdf@Dskjfh todoa
	if [[ -n "$strDbgWhatFile" ]];then
		acmdParams+=(--debug="$strDbgWhatFile");
	fi
	strNewestSaveFile="`FUNCsaveList |tail -n 1 |sed -r "s@.*($HOME/.*)@\1@"`"
	if [[ -n "$nNewestSaveIndex" ]] && echoc -t 6 -q "load newest savegame $nNewestSaveIndex ($strNewestSaveFile)?@Dy";then
		#acmdParams+=(--loadslot="$nNewestSaveIndex"); #this doesnt seem to work?
		acmdParams+=(--loadsave "$strNewestSaveFile");
	fi
	
	acmd=()
	: ${bTermLogWithColors:=true} #help
	if $bTermLogWithColors;then
		acmd+=(unbuffer)
	fi
	: ${bForceDebugger:=false} #help
	if $bForceDebugger || egrep "CMAKE_BUILD_TYPE:STRING=Debug" "${strPathIni}/ArxLibertatis.github/build/CMakeCache.txt";then
		acmd+=(nemiver --use-launch-terminal)
		if ! egrep "CMAKE_CXX_FLAGS_DEBUG:STRING.*O0.*fno-omit-frame-pointer" "${strPathIni}/ArxLibertatis.github/build/CMakeCache.txt";then
			echoc --alert "using a light debug mode that misses a lot the breakpoints!!!"
		fi
	fi
	acmd+=(./arx "${acmdParams[@]}" "$@")

	export ARX_LimitShadowBlobsForVertexes=9
	export ARX_MODDING=1 # this forces patching and overriding scripts everytime they are loaded and ignores the cache
	export ARX_ScriptErrorPopupCommand='yad --no-markup --selectable-labels --title="%{title}" --text="%{message}" --form --field="%{details}":LBL --scroll --on-top --center --button="Edit:0" --button="Ignore:1" --button="Ignore10s:2" --button="Ignore60s:3" --button="Ignore10m:4" --button="Ignore1h:5"'
	export ARX_ScriptCodeEditorCommand='geany "%{file}":%{line}'
	export ARX_AllowScriptPreCompilation=1 #EXPERIMENTAL
	export ARX_WarnGoSubWithLocalScopeParams=true
	export ARX_LogDateTimeFormat="h:m:s"
	export ARX_WarnTimerIdMismatchCallLabel="hologram.asl"
	export ARX_WarnTimerCallingGoSub="hologram.asl"
	#export ARX_MaxTextureSize=512

	#./arx --data-dir="../Arx Fatalis" --debug="warn,error" --debug-gl
	echoc --info "EXEC: ${acmd[@]}"
	ln -vsfT "$strFlLog" "`dirname "$strFlLog"`/arx.linux.log" #lastest
	rxvt -geometry 100x1 -e tail -F "$strFlLog"&disown #rxvt wont stack with xterm windows group on ubuntu windows docks
	"${acmd[@]}" 2>&1 |tee "$strFlLog"
	
	echoc -w "re-run (BUT HIT CTRL+C if it is not reading the newest changes you implemented, chache problem? RAM not ECC problem???)"
done
