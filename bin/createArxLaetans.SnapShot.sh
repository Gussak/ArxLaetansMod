#!/bin/bash

source <(secinit)

strFlBN="ArxLaetansMod.SnapShot.`SECFUNCdtFmt --filename`"

tar \
	--exclude="ArxLaetansMod.github/build" \
	--exclude="ArxLaetansMod.github/.git" \
	-vcf "${strFlBN}.tar" \
	ArxLaetansMod.github/*

7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on -mmt16 "${strFlBN}.tar.7z" "${strFlBN}.tar"

trash "${strFlBN}.tar"
