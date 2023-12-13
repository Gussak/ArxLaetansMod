#!/bin/bash

source <(secinit)

strFlBN="ArxLibertatis.ForArxLaetansMod.SourceCode.SnapShot.Compiled.`SECFUNCdtFmt --filename`"

tar \
	--exclude="ArxLibertatis.github/build/CMakeFiles" \
	-vcf "${strFlBN}.tar" \
	ArxLibertatis.github/build/*

7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on -mmt16 "${strFlBN}.tar.7z" "${strFlBN}.tar"

trash "${strFlBN}.tar"
