#!/bin/bash

egrep "[#]help" "$0"

source <(secinit)

: ${bCompiledMode:=false} #help

: ${strBPath:="ArxLibertatis.github"} #help

strBranch="$(cd "${strBPath}";git branch |egrep "^[*]" |cut -f2 -d' ')"

strFlBN="${strBPath}.ForArxLaetansMod.SourceCode.Branch_${strBranch}.SnapShot.`SECFUNCdtFmt --filename`"

if $bCompiledMode;then
	astrTarParams=(
		--exclude="${strBPath}/build/CMakeFiles"
	)
else
	astrTarParams=(
		--exclude="${strBPath}/build"
		--exclude="${strBPath}/.git"
	)
fi

tar "${astrTarParams[@]}" -vcf "${strFlBN}.tar" "${strBPath}/"*

7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on -mmt16 "${strFlBN}.tar.7z" "${strFlBN}.tar"

trash "${strFlBN}.tar"
