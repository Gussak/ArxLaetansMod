#!/bin/bash

strFlRelativeBase="${1-}"
if [[ -z "$strFlRelativeBase" ]];then
	strFlRelativeBase="$(echoc -S "paste file to compare 3-way")"
fi

strFl1="$(ls -1 "ArxLibertatis.1of3wayCmp."*".github/$strFlRelativeBase")" #top main development branch, with everything mixed
strFl2="$(ls -1 "ArxLibertatis.2of3wayCmp."*".github/$strFlRelativeBase")" #development branch in a commit previous to the PR ones
strFl3="$(ls -1 "ArxLibertatis.3of3wayCmp."*".github/$strFlRelativeBase")" #PR to copy changes to

if [[ ! -f "$strFl1" ]];then echoc -p "invalid strFl1='$strFl1'";exit 1;fi
if [[ ! -f "$strFl2" ]];then echoc -p "invalid strFl2='$strFl2'";exit 1;fi
if [[ ! -f "$strFl3" ]];then echoc -p "invalid strFl3='$strFl3'";exit 1;fi

meld "$strFl1" "$strFl2" "$strFl3"
