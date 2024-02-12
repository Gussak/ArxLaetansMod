#!/bin/bash
: ${bFast:=false} #help
fWaitTime=9999; if $bFast;then fWaitTime=0.01;fi

set -Eeu

mkdir -vp build
cd build
cmake -DDEVELOPER=ON ..

if echoc -t $fWaitTime -q "check style?";then make style;fi

if ! make -j "`grep "core id" /proc/cpuinfo |wc -l`";then exit 1;fi

if echoc -t $fWaitTime -q "copy executable to deploy folder?@Dy";then echoc -x cp -vf arx "../../../ArxLibertatis.layer7057.CoreNewerThanOverhaul-arx-libertatis-1.3-dev-2023-06-24-LinuxBuild/";fi
