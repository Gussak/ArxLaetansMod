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
FUNCaddOpt 21 ShowLocals "(DEBUG)"
FUNCaddOpt 22 DebugTests "(DEBUG)"
SECFUNCarrayShow -v astrOptions
SECFUNCarrayShow -v astrCfgVar

strEmptyLineWithNL=" \n" #an empty line with a single space to separate them clearly

strCodeGenUpdateCfgOpt=""
strCodeGenDefaultsCfgOpt=""

nRmSpaces=1 #before the %
((nRmSpaces+=2))&&: #from the %02d as max is nTot that is less than 100
((nRmSpaces+=2))&&: #the ') '
((nRmSpaces+=1))&&: #was needed...

: ${bSwapColumnRightWithBottom:=true} #help

iFront=$(((nItemsPerFace*0)+1))
iBottomDefault=$(((nItemsPerFace*5)+1))
iBottom=$iBottomDefault
iColumn1=$(((nItemsPerFace*1)+1)) #front face
iColumn2Default=$(((nItemsPerFace*2)+1)) #right face
iColumn2=$iColumn2Default
if $bSwapColumnRightWithBottom;then 
	iColumn2=$iBottomDefault
	iBottom=$iColumn2Default
fi
iColumn3=$(((nItemsPerFace*3)+1)) #back face
iColumn4=$(((nItemsPerFace*4)+1)) #left face

: ${iStartIndex:=1} #help can add pages later TODO not working yet
: ${bReverseOrder:=false} #help TODO if true is not working yet
if $bReverseOrder;then iControl=$nTot;else iControl=$iStartIndex;fi
#for((iControl=iStartIndex;iControl<=nTot;iControl++));do
#for((iControl=nTot;iControl>=iStartIndex;iControl--));do
while true;do
	if $bReverseOrder;then  #loop control
		if ! ((iControl>=iStartIndex));then break;fi
	else
		if ! ((iControl<=nTot));then break;fi
	fi
	# FIRST THING ABOVE: LOOP CONTROL
	
	#strOpt="${astrOptions[$iControl]-}"
	#if(( (${#strOpt}+nRmSpaces) > ${#strSpacesFaceFullW} ));then 
		#declare -p nRmSpaces strOpt strSpacesFaceFullW |sed -r 's@="@\n"@' >&2
		#echo "$(printf "\"%$((nRmSpaces+${#strOpt}))s\"" "${strOpt}")" >&2
		#echoc -p "opt is too large";
		#exit 1;
	#fi
	
	bTop=false;if((iControl<=nItemsPerFace));then bTop=true;fi
	bBottom=false;if((iControl>(nTot-nItemsPerFace)));then bBottom=true;fi
	
	nAdjustRmSp=0;if ! $bTop && ! $bBottom;then nAdjustRmSp=1;fi
	
	#strOptOk="${strOpt}${strSpacesFaceFullW:$((${#strOpt}+nRmSpaces+nAdjustRmSp))}"
	
	if $bTop || $bBottom;then
		iWork=$iControl
		if((iWork>=iBottomDefault));then iWork=$((iWork-iBottomDefault+iBottom));fi
		iIndexForColumn=$iWork
		strSpacesBefore="${strSpacesFaceFullW}"
		strNL=""
		#if((iWork==(nTot-nItemsPerFace+1)));then strNL+="${strEmptyLineWithNL}";fi #fist bottom line
		if $bTop;then strNL+="\n${strEmptyLineWithNL}";fi
		if $bBottom;then strNL+="\n${strEmptyLineWithNL}";fi
		#if((iWork==nItemsPerFace));then strNL+="${strEmptyLineWithNL}";fi #last top line
		#printf "${strSpacesBefore}%02d) ${strOptOk}${strNL}" $iIndexForColumn;
		#echo " " #an empty line with a single space to separate them clearly
	else # left front right back
		strSpacesBefore=" "
		#if(((iWork+nItemsPerFace-2)%4 == 2));then echo -n " ";fi; #before column1 in the line
		if(((iControl+nItemsPerFace-2)%4 == 2));then strSpacesBefore+=" ";fi; #before column1 in the line
		
		if(((iControl+nItemsPerFace-2)%4 == 2));then iIndexForColumn=$((iColumn1++));fi #column 1
		if(((iControl+nItemsPerFace-2)%4 == 3));then iIndexForColumn=$((iColumn2++));fi #column 2
		if(((iControl+nItemsPerFace-2)%4 == 0));then iIndexForColumn=$((iColumn3++));fi #column 3
		if(((iControl+nItemsPerFace-2)%4 == 1));then iIndexForColumn=$((iColumn4++));fi #column 4
		
		#if((iWork>nItemsPerFace));then printf " %02d) ${strOptOk}" $((iIndexForColumn));fi;
		strNL=""
		if(( (iControl+nItemsPerFace-2)%4 == 0 ));then 
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
	
	if((iWork>1));then
		strPrefixPng="./Hologram.ConfigOptions.index"
		if [[ -f "${strPrefixPng}00001.Clear.png" ]];then
			ln -vsf "${strPrefixPng}00001.Clear.png"   "${strPrefixPng}`printf %05d $iWork`.Clear.png"     >&2
		fi
		if [[ -f "${strPrefixPng}00001.Enabled.png" ]];then
			ln -vsf "${strPrefixPng}00001.Enabled.png"   "${strPrefixPng}`printf %05d $iWork`.Enabled.png"   >&2
		fi
		if [[ -f "${strPrefixPng}00001.Highlight.png" ]];then
			ln -vsf "${strPrefixPng}00001.Highlight.png" "${strPrefixPng}`printf %05d $iWork`.Highlight.png" >&2
		fi
	fi
	
	# validate the script
	if [[ -n "${astrCfgVar[$iControl]-}" ]];then 
		strCodeGenUpdateCfgOpt+="		Set @CFUNCconfigOptionUpdate_check ${astrCfgVar[$iControl]} GoSub CFUNCconfigOptionUpdate\n"
		strCodeGenDefaultsCfgOpt+="	if(${astrCfgVar[$iControl]} == 0) Set ${astrCfgVar[$iControl]} ${iControl}.0\n"
		
		strRegexVar="`echo "${astrCfgVar[$iControl]}" |sed 's@.@[&]@g'`" 
		echo "VALIDATING[$iControl]: ${astrCfgVar[$iControl]} '$strRegexVar'" >&2;
		egrep "${strRegexVar}" "${strFlHolog}" -ai >&2
		strRegexChk="${strRegexVar}[ =!><]*"
		echo ">>--> chk >>-->" >&2
		if egrep "${strRegexChk}.*[0-9]" "${strFlHolog}" -ai |egrep -v "${strRegexChk}(0|${iControl})" -wai >&2;then
			echoc -p "A: Invalid use at .asl script (${astrCfgVar[$iControl]}, $iControl)" >&2
		fi
		if egrep "${strRegexChk}.*[0-9]" "${strFlHolog}" -ai |egrep -v "${strRegexChk}${iControl}" -wai >&2;then
			echoc -p "B: Invalid use at .asl script (${astrCfgVar[$iControl]}, $iControl)" >&2
		fi
		echo >&2
	fi
	
	#LAST THING: loop control
	if $bReverseOrder;then ((iControl--))&&:;else ((iControl++))&&:;fi #loop control
done >"$0.txt"

echo "TOKEN_AUTOPATCH_strCodeGenUpdateCfgOpt_BEGIN"
echo -e "$strCodeGenUpdateCfgOpt"
echo "TOKEN_AUTOPATCH_strCodeGenUpdateCfgOpt_END"
echo
echo "TOKEN_AUTOPATCH_strCodeGenDefaultsCfgOpt_BEGIN"
echo -e "$strCodeGenDefaultsCfgOpt"
echo "TOKEN_AUTOPATCH_strCodeGenDefaultsCfgOpt_END"

echoc --info "updating text: select all text in gimp least the first char, paste, hit home and del 1st char"
echoc --info "fixing: between top/front and front/bottom, the font needs to be 29 size for the single space there to better align everything at front and bottom."

echoc --info "@s@{lyB}TODO:@S autogen asl code for options"
echoc --info "@s@{lyB}TODO:@S pages of options with named tabs"

echoc --info "@s@{lrB}ISSUE:@S half of the top and half of the bottom options will be weird to click as they should be upside down. may be this can be fixed on the UV !!!?"
