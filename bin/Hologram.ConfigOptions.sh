#!/bin/bash

source <(secinit)

strPathHere="$(realpath "$(dirname "$0")")"
strFlHolog="${strPathHere}/../Mod.AncientDevices/ArxLaetansMod/AncientDevices/Scripts/Hologram.asl"

#                                              123456789,123456789,123456789,123456789,12
nItemsPerFace=11
nFaces=6; #cubemap skybox has 4  Horizon Faces
nTot=$((nItemsPerFace*nFaces))
strSpacesFaceFullW="                                              "

declare -a astrOptions astrCfgVar
function FUNCaddOpt() { # index cfgVarID comment
	i=$1;
	astrCfgVar[$i]="&G_HologCfgOpt_${2}"; #globals
	astrOptions[$i]="${astrCfgVar[$i]:14} ${3}"; #cfg text
}
#obs.: options doesnt need to have the same name size it is cohincidence for now...
FUNCaddOpt 17 ClassFocus "(TODO/WIP)"
FUNCaddOpt 58 ShowLocals "(DEBUG)"
FUNCaddOpt 59 DebugTests "(DEBUG)"
SECFUNCarrayShow -v astrOptions
SECFUNCarrayShow -v astrCfgVar

strEmptyLineWithNL=" \n" #an empty line with a single space to separate them clearly

nRmSpaces=1 #before the %
((nRmSpaces+=2))&&: #from the %02d as max is nTot that is less than 100
((nRmSpaces+=2))&&: #the ') '
((nRmSpaces+=1))&&: #was needed...

iColumn1=$(((nItemsPerFace*1)+1))
iColumn2=$(((nItemsPerFace*2)+1))
iColumn3=$(((nItemsPerFace*3)+1))
iColumn4=$(((nItemsPerFace*4)+1))

: ${iStartIndex:=1} #help can add pages later TODO
for((i=iStartIndex;i<=nTot;i++));do
	#strOpt="${astrOptions[$i]-}"
	#if(( (${#strOpt}+nRmSpaces) > ${#strSpacesFaceFullW} ));then 
		#declare -p nRmSpaces strOpt strSpacesFaceFullW |sed -r 's@="@\n"@' >&2
		#echo "$(printf "\"%$((nRmSpaces+${#strOpt}))s\"" "${strOpt}")" >&2
		#echoc -p "opt is too large";
		#exit 1;
	#fi
	
	bTop=false;if((i<=nItemsPerFace));then bTop=true;fi
	bBottom=false;if((i>(nTot-nItemsPerFace)));then bBottom=true;fi
	
	nAdjustRmSp=0;if ! $bTop && ! $bBottom;then nAdjustRmSp=1;fi
	
	#strOptOk="${strOpt}${strSpacesFaceFullW:$((${#strOpt}+nRmSpaces+nAdjustRmSp))}"
	
	if $bTop || $bBottom;then
		iIndexForColumn=$i
		strSpacesBefore="${strSpacesFaceFullW}"
		strNL=""
		#if((i==(nTot-nItemsPerFace+1)));then strNL+="${strEmptyLineWithNL}";fi #fist bottom line
		if $bTop;then strNL+="\n${strEmptyLineWithNL}";fi
		if $bBottom;then strNL+="\n${strEmptyLineWithNL}";fi
		#if((i==nItemsPerFace));then strNL+="${strEmptyLineWithNL}";fi #last top line
		#printf "${strSpacesBefore}%02d) ${strOptOk}${strNL}" $iIndexForColumn;
		#echo " " #an empty line with a single space to separate them clearly
	else # left front right back
		strSpacesBefore=" "
		#if(((i+nItemsPerFace-2)%4 == 2));then echo -n " ";fi; #before column1 in the line
		if(((i+nItemsPerFace-2)%4 == 2));then strSpacesBefore+=" ";fi; #before column1 in the line
		
		if(((i+nItemsPerFace-2)%4 == 2));then iIndexForColumn=$((iColumn1++));fi #column 1
		if(((i+nItemsPerFace-2)%4 == 3));then iIndexForColumn=$((iColumn2++));fi #column 2
		if(((i+nItemsPerFace-2)%4 == 0));then iIndexForColumn=$((iColumn3++));fi #column 3
		if(((i+nItemsPerFace-2)%4 == 1));then iIndexForColumn=$((iColumn4++));fi #column 4
		
		#if((i>nItemsPerFace));then printf " %02d) ${strOptOk}" $((iIndexForColumn));fi;
		strNL=""
		if(( (i+nItemsPerFace-2)%4 == 0 ));then 
			#new line at end of the line
			strNL="\n${strEmptyLineWithNL}"
		fi; 
	fi
	
	strOpt="${astrOptions[$iIndexForColumn]-}"
	if(( (${#strOpt}+nRmSpaces) > ${#strSpacesFaceFullW} ));then 
		declare -p nRmSpaces strOpt strSpacesFaceFullW |sed -r 's@="@\n"@' >&2
		echo "$(printf "\"%$((nRmSpaces+${#strOpt}))s\"" "${strOpt}")" >&2
		echoc -p "opt is too large";
		exit 1;
	fi
	strOptOk="${strOpt}${strSpacesFaceFullW:$((${#strOpt}+nRmSpaces+nAdjustRmSp))}"
	printf "${strSpacesBefore}%02d) ${strOptOk}${strNL}" $iIndexForColumn;
	
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
	
	if [[ -n "${astrCfgVar[$i]-}" ]];then 
		echo "${astrCfgVar[$i]}" >&2;
		strRegexVar="`echo "${astrCfgVar[$i]}" |sed 's@.@[&]@g'`"
		if ! egrep "[\t ]*if\(${strRegexVar} == 0\) Set ${strRegexVar} ${i}[.]0" "${strFlHolog}" >&2;then
			echoc -p "The above line is missing at .asl script" >&2
		fi
	fi
done >$0.txt
echoc --info "updating text: select all text in gimp least the first char, paste, hit home and del 1st char"
echoc --info "fixing: between top/front and front/bottom, the font needs to be 29 size for the single space there to better align everything at front and bottom."
echoc --info "@s@{lyB}TODO:@S autogen asl code for options"
echoc --info "@s@{lyB}TODO:@S pages of options with named tabs"
echoc --info "@s@{lrB}ISSUE:@S half of the top and half of the bottom options will be weird to click as they should be upside down. may be this can be fixed on the UV !!!?"
