#!/bin/bash

egrep "[#]help" "$0"

set -Eeu

if [[ "$1" == "--dupscale" ]];then #help <w> <h> min "OR" sizes to accept file
	shift
	export wChk=$1;shift
	export hChk=$1;shift
	
	FUNCdupscayl() {
		fl="$1";
		
		szCode="$(identify "$fl" |sed -r 's@.* PNG ([0-9]*)x([0-9]*) .*@w=\1;h=\2;@' )";
		if [[ -z "${szCode-}" ]];then return;fi
		eval "$szCode";
		#declare -p fl szCode w h wChk hChk
		
		if((w <= wChk || h <= hChk));then
			echo "mv -f \"${fl}\" ./ # $szCode" |tee -a ./moveSmallFiles.sh;
		fi
	};export -f FUNCdupscayl;
	
	: ${folder:=upscayl_png_ultrasharp_4x} #help
	#find "${folder}/" -iname "*.png" -exec bash -c "FUNCdupscayl '{}'" \;;
	ls *.bmp |while read strFl;do sem -j+0 FUNCdupscayl "$strFl" ';' echo "ThreadDone:$strFl";done
	sort -u ./moveSmallFiles.sh >./moveSmallFilesUnique.sh;
	trash ./moveSmallFiles.sh
	chmod +x ./moveSmallFilesUnique.sh
fi
