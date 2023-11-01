#!/bin/bash
# Copyright 2023 Gussak<https://github.com/Gussak>
#
# This file is part of Arx Laetans Mod.
#
# Arx Libertatis is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Arx Libertatis is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Arx Libertatis. If not, see <http://www.gnu.org/licenses/>.

egrep "[#]help" "$0" >&2
#help params: <file.ftl>

strFl="`realpath "$1"`";declare -p strFl

cd "`dirname "$(readlink "$0")"`";pwd
#if ! ls -l "libArxIO.so.0";then echoc -pw "libArxIO.so.0 not found here: `pwd`";exit 1;fi
if [[ ! -f "libArxIO.so.0" ]];then echoc -pw "libArxIO.so.0 not found here: `pwd`";exit 1;fi

if [[ -f "${strFl}.unpack" ]];then
  mv -vf "${strFl}.unpack" "${strFl}.unpack.old"
fi

set -x;
strOutput="`PYTHONPATH="${PYTHONPATH}:/$(pwd)" python3 unpackFtl.simpleCmdLine.py "$strFl"`";
set +x

if [[ ! -f "${strFl}.unpack" ]];then
  if [[ "$strOutput" == "file is not packed" ]];then
    cp -v "${strFl}" "${strFl}.unpack"
  else
    echoc -p "failed unpacking file '${strFl}'"
    exit 1
  fi
fi
ls -l "${strFl}" "${strFl}.unpack"&&:
