#!/bin/bash

cd "$(dirname "$0")"
pwd
strSrc=".gitignore.ForArxLibertatisFork"
strTarget="../../../ArxLibertatis.github/.gitignore"
ls -l "$strTarget"
cp -vfT "$strSrc" "$strTarget"
ls -l "$strTarget"
echoc -w
