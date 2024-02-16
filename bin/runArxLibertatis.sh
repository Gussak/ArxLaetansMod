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

: ${bLoop:=true} #help
while true;do
	: ${bClear:=false} #help
	if $bClear;then clear;fi
	
	: ${strDbgWhatFile:="src"} # value for arx param ex.: --debug="src"
	#strDbgWhatFile="`echoc -t 3 -S "Debug what file (ex.: ScriptedAnimation)?"`" # src/script/ScriptedIOProperties.cpp
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
				if $bLoop;then
					echoc -w "fix the code and retry";
					bRetryingBuild=true
				else
					exit 1
				fi
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

	################ manually set
	#export ARX_MaxTextureSize=512 #EXPERIMENTAL
	export ARX_LimitShadowBlobsForVertexes=9
	export ARX_MODDING=1 # this forces patching and overriding scripts everytime they are loaded and ignores the cache
	export ARX_ScriptErrorPopupCommand='yad --no-markup --selectable-labels --title="%{title}" --text="%{message}" --form --field="%{details}":LBL --scroll --on-top --center --button="Edit:0" --button="Ignore:1" --button="Ignore10s:2" --button="Ignore60s:3" --button="Ignore10m:4" --button="Ignore1h:5"'
	export ARX_ScriptCodeEditorCommand='geany "%{file}":%{line}'
	export ARX_AllowScriptPreCompilation=1 #EXPERIMENTAL
	export ARX_WarnGoSubWithLocalScopeParams=true
	export ARX_LogDateTimeFormat="h:m:s"
	export ARX_TimerLabelMismatchWarn="hologram.asl"
	export ARX_TimerCallingGoSubWarn="hologram.asl"
	
	################ updated from: env -lvd
	export ARX_ConsoleColumns="180"; # how many text lines shall the console show. min=50;max=2147483647;
	export ARX_ConsoleLines="50"; # how many text lines shall the console show. min=10;max=50;
	export ARX_Debug=";.*;ARX_PLAYER_|getEnv|EnvVar;.*"; # ex.: ";ArxGame;LOD;.*". 
	export ARX_DebugFile=".*"; # . 
	export ARX_DebugFunc="ARX_PLAYER_|getEnv|EnvVar"; # . 
	export ARX_DebugLine=".*"; # . 
	export ARX_LODDeltaFPS="10"; # this is how much FPS above the minimum that will allow LOD to be improved for one item per iteration and for the distant LOD levels thru ARX_LODDistStep. min=1;max=2147483647;
	export ARX_LODDistStep="300"; # this is the distance between each LOD activation. min=1;max=2147483647;
	export ARX_LODFPSdelay="0.330000"; # a more responsive FPS check (less than 1s), so LOD can change faster. min=0.100000;max=1.000000;
	export ARX_LODFullUpdateDelay="0.250000"; # instead of every frame, LOD will be computed after this delay in seconds. min=0.000000;max=340282346638528859811704183484516925440.000000;
	export ARX_LODMax="perfect"; # set max LOD allowed. 
	export ARX_LODMin="icon"; # set min LOD allowed. 
	export ARX_LODMinimumFPS="15"; # this is the minimum FPS you think is acceptable to play the game at any time. min=1;max=2147483647;
	export ARX_LODNearHighQualityAmount="1"; # how many nearby entities will be granted high LOD quality. min=0;max=2147483647;
	export ARX_LODPlayerMoveDistToRecalcLOD="25.000000"; # how far shall player move to recalculate LOD after player moves this distance. min=10.000000;max=340282346638528859811704183484516925440.000000;
	export ARX_LODRecalcDelay="0.500000"; # after this delay in seconds, LOD distance will be recalculated. min=0.100000;max=340282346638528859811704183484516925440.000000;
	export ARX_LODallowPerfectOnHigh="true"; # . 
	export ARX_LimitShadowBlobsForVertexes="9"; # . min=0;max=2147483647;
	export ARX_LogDateTimeFormat="h:m:s"; # simplified date/time format "Y:M:D-h:m:s". 
	export ARX_MaxTextureSize="0"; # . min=0;max=2147483647;
	export ARX_MovementDetectedDistance="3.000000"; # . min=0.500000;max=340282346638528859811704183484516925440.000000;
	export ARX_TimerCallingGoSubWarn="hologram.asl"; # (coding style suggestion) Timers should only call GoTo. This regex filters what scripts will show the warning.. 
	export ARX_TimerLabelMismatchWarn="hologram.asl"; # (coding style suggestion) Timer label should match the begin of GoTo label. This regex filters what scripts will show the warning.. 	
	
	: ${ARX_Debug:=":.*/ArxGame.cpp:.*LOD.*:^(?!.*1856).*$"};export ARX_Debug # the first char ':' is the custom delimiter you can change. in console you can type this to ignore line 1856 and show only line 1708: env -s ARX_Debug ":.*/ArxGame.cpp.*.*:.*LOD.*:^(?!.*1856).*$|1708" nop env -s ARX_Debug ":.*:.*(ARX_CHANGELEVEL_Push_IO|LOD).*:^(?!.*(1856|1863)).*$" nop env -l
	declare |egrep "^ARX_"
	
	# KEEP: linux command to generate some doc, but they can all be listed with console command `env -l` now! LC_ALL=C egrep 'platform::getEnvironmentVariableValue' --include="*.h" --include="*.cpp" -iRhI * |sed -r -e 's@.*platform::getEnvironmentVariableValue([^\(]*).*"(ARX_[^"]*)",[^,]*,[^,]*, *([^,\)]*).*@export \2=\3 # \1@' -e 's@.*platform::getEnvironmentVariableValue([^\(]*).*"(ARX_[^"]*).*@export \2=? # \1@'
	
	#./arx --data-dir="../Arx Fatalis" --debug="warn,error" --debug-gl
	echoc --info "EXEC: ${acmd[@]}"
	ln -vsfT "$strFlLog" "`dirname "$strFlLog"`/arx.linux.log" #lastest
	rxvt -geometry 100x1 -e tail -F "$strFlLog"&disown #rxvt wont stack with xterm windows group on ubuntu windows docks
	"${acmd[@]}" 2>&1 |tee "$strFlLog"
	
	if ! $bLoop;then break;fi
	echoc -w "re-run (BUT HIT CTRL+C if it is not reading the newest changes you implemented, chache problem? RAM not ECC problem???)"
done
