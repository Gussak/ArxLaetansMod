#!/bin/bash
set -Eeu
mkdir -vp build
cd build
cmake -DDEVELOPER=ON ..
if echoc -q "check style?";then make style;fi
while ! make -j "`grep "core id" /proc/cpuinfo |wc -l`";do echoc -w retry;done
if echoc -q "copy executable to deploy folder?";then echoc -x cp -vf arx "../../../ArxLibertatis.layer7057.CoreNewerThanOverhaul-arx-libertatis-1.3-dev-2023-06-24-LinuxBuild/";fi
