#!/bin/bash
set -eEu

set -x
cd ArxLibertatis.github
pwd
mkdir -vp build && cd build
pwd
cmake -DDEVELOPER=ON ..
make -j "`grep "core id" /proc/cpuinfo |wc -l`"
set +x 

echoc -w deploy
set -x
cp -vR * ../../../ArxLibertatis.layer7057.CoreNewerThanOverhaul-arx-libertatis-1.3-dev-2023-06-24-LinuxBuild/
set +x
