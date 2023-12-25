#!/bin/bash
set -Eeu
mkdir -vp build
cd build
cmake -DDEVELOPER=ON ..
if echoc -q "check style?";then make style;fi
make -j "`grep "core id" /proc/cpuinfo |wc -l`"
