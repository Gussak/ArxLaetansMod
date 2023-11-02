#!/bin/bash

# Copyright 2023 Gussak<https://github.com/Gussak>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -eEu

set -x
cd ArxLibertatis.github
pwd
mkdir -vp build && cd build
pwd
cmake -DDEVELOPER=ON ..
make -j "`grep "core id" /proc/cpuinfo |wc -l`"
set +x 

: ${bAutoDeploy:=true} #help
if ! $bAutoDeploy;then echoc -w deploy;fi
set -x
while ! cp -vR * ../../../ArxLibertatis.layer7057.CoreNewerThanOverhaul-arx-libertatis-1.3-dev-2023-06-24-LinuxBuild/;do
  echoc -w retry
done
set +x
