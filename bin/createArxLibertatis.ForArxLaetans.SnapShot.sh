#!/bin/bash

egrep "[#]help" "$0"

if ! which secinit;then 
	PATH="$PATH:$HOME/ScriptEchoColor/ScriptEchoColor/bin"
fi
source <(secinit)

: ${bCompiledMode:=false} #help

: ${strBPath:="ArxLibertatis.github"} #help

strBranch="$(cd "${strBPath}";git branch |egrep "^[*]" |cut -f2 -d' ')"

if $bCompiledMode;then
	strWhat="Compiled"
	astrTarParams=(
		--exclude="${strBPath}/build*/CMakeFiles"
	)
else
	strWhat="SourceCode"
	astrTarParams=(
		--exclude="${strBPath}/build*"
		--exclude="${strBPath}/.git"
	)
fi
strFlBN="${strBPath}.ForArxLaetansMod.${strWhat}.Branch_${strBranch}.SnapShot.$(SECFUNCdtFmt --filename)"

tar "${astrTarParams[@]}" -vcf "${strFlBN}.tar" "${strBPath}/"*

7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on -mmt16 "${strFlBN}.tar.7z" "${strFlBN}.tar"

trash "${strFlBN}.tar"
