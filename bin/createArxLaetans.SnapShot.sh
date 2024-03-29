#!/bin/bash

egrep "[#]help" "$0"

if ! which secinit;then 
	PATH="$PATH:$HOME/ScriptEchoColor/ScriptEchoColor/bin"
fi
source <(secinit)

: ${strFileNameDesc:="ArxLaetans"} #help

: ${bCompiledMode:=false} #help

: ${strBPath:="ArxLaetansMod.github"} #help

#IFS=$'\n' read -d '' -r -a astrFileList < <(cat "${strBPath}/.gitignore" |sed "s@^#[!]@!@" |egrep -v "/$|^$|^#|^[*]$" |sort -u |tr -d '!' |sed 's@.*@--include="&"@')&&:
#IFS=$'\n' read -d '' -r -a astrFileList < <(cat "${strBPath}/.gitignore" |sed "s@^#[!]@!@" |egrep -v "/$|^$|^#|^[*]$" |sort -u |tr -d '!' |sed "s@.*@${strBPath}/&@")&&:
: ${bUseReversedGitIgnore:=true} #help
if $bUseReversedGitIgnore;then
	IFS=$'\n' read -d '' -r -a astrRegexFileList < <(cat "${strBPath}/.gitignore" |sed "s@^#[!]@!@" |egrep -v "/$|^$|^#|^[*]$" |sort -u |tr -d '!' |sed -r -e 's@[*]@.*@g' -e "s@.*@${strBPath}/&@")&&:
	declare -p astrRegexFileList |tr '[' '\n'

	echoc --info "preparing find regex from .gitignore"

	astrFindRegexFileList=()
	for strRegexFile in "${astrRegexFileList[@]}";do
		if((`SECFUNCarraySize astrFindRegexFileList` > 0));then
			astrFindRegexFileList+=(-or)
		fi
		astrFindRegexFileList+=(-iregex)
		astrFindRegexFileList+=("$strRegexFile")
	done
	declare -p astrFindRegexFileList |tr '[' '\n'
	IFS=$'\n' read -d '' -r -a astrFileList < <(find "${strBPath}/" "${astrFindRegexFileList[@]}")&&:
else
	IFS=$'\n' read -d '' -r -a astrFileList < <(find "${strBPath}/")&&: # -iregex "$strFileFilter")&&:
fi

: ${strFileFilter:=""} #help to backup only text files, try strFileFilter=".*[.](txt|asl|info|md|sh|py|cfg|patch|d)$"
if [[ -n "${strFileFilter}" ]];then
	echoc --info "applying filter strFileFilter='$strFileFilter'"
	astrFileListTmp=("${astrFileList[@]}")
	astrFileList=()
	for strFile in "${astrFileListTmp[@]}";do
		if [[ "$strFile" =~ ${strFileFilter} ]];then
			astrFileList+=("${strFile}")
		fi
	done
fi
declare -p astrFileList |tr '[' '\n'

echoc --info "creating tar"

strBranch="$(cd "${strBPath}";git branch |egrep "^[*]" |cut -f2 -d' ')"

astrTarParams=(
	#--exclude="${strBPath}/build/CMakeFiles"
	#--exclude="${strBPath}/build"
	#--exclude="${strBPath}/.git"
)

strFlBN="${strBPath}.ForArxLaetansMod.${strFileNameDesc}.Branch_${strBranch}.SnapShot.`SECFUNCdtFmt --filename`"

SECFUNCexecA -ce tar "${astrTarParams[@]}" -vcf "${strFlBN}.tar" "${astrFileList[@]}"

echoc --info "compressing"

7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on -mmt16 "${strFlBN}.tar.7z" "${strFlBN}.tar"

trash "${strFlBN}.tar"
