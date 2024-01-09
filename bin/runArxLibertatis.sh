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
	: ${bBuildB4Run:=true} #help
	if $bBuildB4Run;then 
		cd "$strPathIni"
		if echoc -q -t 9 "re-build it?@Dy";then
			export bRetryingBuild=false #detected by buildArxLibertatis.sh
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
		--debug="debug"
		--debug-gl
	);
	strNewestSaveFile="`FUNCsaveList |tail -n 1 |sed -r "s@.*($HOME/.*)@\1@"`"
	if [[ -n "$nNewestSaveIndex" ]] && echoc -t 6 -q "load newest savegame $nNewestSaveIndex ($strNewestSaveFile)?@Dy";then
		#acmdParams+=(--loadslot="$nNewestSaveIndex"); #this doesnt seem to work?
		acmdParams+=(--loadsave "$strNewestSaveFile");
	fi
	acmd=(nemiver --use-launch-terminal ./arx "${acmdParams[@]}" "$@")

	export ARX_LimitShadowBlobsForVertexes=9
	export ARX_MODDING=1 # this forces patching and overriding scripts everytime they are loaded and ignores the cache
	export ARX_ScriptErrorPopupCommand='yad --selectable-labels --title="%{title}" --text="%{message}" --form --field="%{details}":LBL --scroll --on-top --center'
	export ARX_ScriptCodeEditorCommand='geany "%{file}":%{line}'
	#export ARX_AllowScriptPreCompilation=1 #EXPERIMENTAL

	#./arx --data-dir="../Arx Fatalis" --debug="warn,error" --debug-gl
	echoc --info "EXEC: ${acmd[@]}"
	ln -vsfT "$strFlLog" "`dirname "$strFlLog"`/arx.linux.log" #lastest
	rxvt -geometry 100x1 -e tail -F "$strFlLog"&disown #rxvt wont stack with xterm windows group on ubuntu windows docks
	unbuffer "${acmd[@]}" 2>&1 |tee "$strFlLog"
	
	echoc -w "re-run"
done
