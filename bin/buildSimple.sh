#!/bin/bash
set -Eeu
mkdir -vp build
cd build
cmake -DDEVELOPER=ON ..
if echoc -q "check style?";then make style;fi
while ! make -j "`grep "core id" /proc/cpuinfo |wc -l`";do echoc -w retry;done
