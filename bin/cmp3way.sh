#!/bin/bash

strFlRelativeBase="${1-}"
if [[ -z "$strFlRelativeBase" ]];then
	strFlRelativeBase="$(echoc -S "paste file to compare 3-way")"
fi

strFl1="$(ls -1 "ArxLibertatis.1of3wayCmp."*".github/$strFlRelativeBase")" 
declare -p strFl1
echoc --info "Step:A) top main development branch, with everything mixed. Compare this with the 2nd one."
echo

strFl2="$(ls -1 "ArxLibertatis.2of3wayCmp."*".github/$strFlRelativeBase")" 
declare -p strFl2
echoc --info "Step:B) main development branch in a commit previous to the PR ones. Apply changes from 1st into this 2nd one but do NOT SAVE IT, and imediatelly apply these visible changed lines at 3rd one too!"
echoc --info "Step:B.2) after commiting in the PR branch at Step:C, merge it into this branch to make it easier to see the differences to other PRs."
echo

strFl3="$(ls -1 "ArxLibertatis.3of3wayCmp."*".github/$strFlRelativeBase")" 
declare -p strFl3
echoc --info "Step:C) final PR branch 3rd, to copy changes to. Copy here ONLY diffs from the 1st to the 2nd!!!"
echo

if [[ ! -f "$strFl1" ]];then echoc -p "invalid strFl1='$strFl1'";exit 1;fi
if [[ ! -f "$strFl2" ]];then echoc -p "invalid strFl2='$strFl2'";exit 1;fi
if [[ ! -f "$strFl3" ]];then echoc -p "invalid strFl3='$strFl3'";exit 1;fi

echoc -w "compare 3-way with meld"
meld "$strFl1" "$strFl2" "$strFl3"
