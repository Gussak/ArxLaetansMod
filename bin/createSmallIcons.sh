#!/bin/bash

function FUNCconv() {
	source <(secinit)
	local lstrFl="$1"
	local lstrFlSmall="$(echo "${lstrFl}" |sed -r -e 's@\.1k@@i')"
	SECFUNCexec -ce convert "${lstrFl}" -resize 32x "${lstrFlSmall}"
};export -f FUNCconv

find \
	-iname "*.1k\[icon\]*" \
	-exec bash -c "FUNCconv '{}'" \;

