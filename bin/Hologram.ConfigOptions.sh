#!/bin/bash

strPathHere="$(realpath "$(dirname "$0")")"
strFlHolog="${strPathHere}/../Mod.AncientDevices/ArxLaetansMod/AncientDevices/Scripts/Hologram.asl"

#                                              123456789,123456789,123456789,123456789,12
nItemsPerFace=11
nFaces=6
nTot=$((nItemsPerFace*nFaces))
strSpacesFaceFullW="                                              "

declare -a astrOptions astrCfgVar
function FUNCaddOpt() { # index cfgVarID comment
	i=$1;
	astrCfgVar[$i]="&G_HologCfgOpt_${2}"; #globals
	astrOptions[$i]="${astrCfgVar[$i]:14} ${3}"
}
#obs.: options doesnt need to have the same name size it is cohincidence for now...
FUNCaddOpt 33 ClassFocus "(TODO/WIP)"
FUNCaddOpt 58 ShowLocals "(DEBUG)"
FUNCaddOpt 59 DebugTests "(DEBUG)"

nRmSpaces=1 #before the %
((nRmSpaces+=2))&&: #from the %02d as max is nTot that is less than 100
((nRmSpaces+=2))&&: #the ') '
((nRmSpaces+=1))&&: #was needed...

iColumn1=$(((nItemsPerFace*1)+1))
iColumn2=$(((nItemsPerFace*2)+1))
iColumn3=$(((nItemsPerFace*3)+1))
iColumn4=$(((nItemsPerFace*4)+1))
for((i=1;i<=nTot;i++));do
	strOpt="${astrOptions[$i]}"
	if(( (${#strOpt}+nRmSpaces) > ${#strSpacesFaceFullW} ));then 
		declare -p nRmSpaces strOpt strSpacesFaceFullW |sed -r 's@="@\n"@' >&2
		echo "$(printf "\"%$((nRmSpaces+${#strOpt}))s\"" "${strOpt}")" >&2
		echoc -p "opt is too large";
		exit 1;
	fi
	
	bTopBottom=false;if((i<=nItemsPerFace)) || ((i>(nTot-nItemsPerFace)));then bTopBottom=true;fi
	
	nAdjustRmSp=0;if ! $bTopBottom;then nAdjustRmSp=1;fi
	
	strOptOk="${strOpt}${strSpacesFaceFullW:$((${#strOpt}+nRmSpaces+nAdjustRmSp))}"
	
	if $bTopBottom;then
		printf "${strSpacesFaceFullW}%02d) ${strOptOk}\n" $i;
		echo " " #an empty line with a single space to separate them clearly
	else # left front right back
		if(((i+nItemsPerFace-2)%4 == 2));then echo -n " ";fi; #before column1 in the line
		
		if(((i+nItemsPerFace-2)%4 == 2));then iIndexForColumn=$((iColumn1++));fi #column 1
		if(((i+nItemsPerFace-2)%4 == 3));then iIndexForColumn=$((iColumn2++));fi #column 2
		if(((i+nItemsPerFace-2)%4 == 0));then iIndexForColumn=$((iColumn3++));fi #column 3
		if(((i+nItemsPerFace-2)%4 == 1));then iIndexForColumn=$((iColumn4++));fi #column 4
		
		if((i>nItemsPerFace));then printf " %02d) ${strOptOk}" $((iIndexForColumn));fi;
		if(((i+nItemsPerFace-2)%4 == 0));then 
			echo; #new line at end of the line
			echo " "; #an empty line with a single space to separate them clearly
		fi; 
	fi
	
	if((i>1));then
		strPrefixPng="./Hologram.ConfigOptions.index"
		if [[ -f "${strPrefixPng}00001.Clear.png" ]];then
			ln -vsf "${strPrefixPng}00001.Clear.png"   "${strPrefixPng}`printf %05d $i`.Clear.png"     >&2
		fi
		if [[ -f "${strPrefixPng}00001.Enabled.png" ]];then
			ln -vsf "${strPrefixPng}00001.Enabled.png"   "${strPrefixPng}`printf %05d $i`.Enabled.png"   >&2
		fi
		if [[ -f "${strPrefixPng}00001.Highlight.png" ]];then
			ln -vsf "${strPrefixPng}00001.Highlight.png" "${strPrefixPng}`printf %05d $i`.Highlight.png" >&2
		fi
	fi
done >$0.txt
echoc --info "updating text: select all text in gimp least the first char, paste, hit home and del 1st char"
echoc --info "fixing: between top/front and front/bottom, the font needs to be 29 size for the single space there to better align everything at front and bottom."
echoc --info "@s@{lyB}TODO:@S autogen asl code for options"
echoc --info "@s@{lyB}TODO:@S pages of options with named tabs"
echoc --info "@s@{lrB}ISSUE:@S half of the top and half of the bottom options will be weird to click as they should be upside down. may be this can be fixed on the UV !!!?"
