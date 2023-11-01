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

cd ..
cd ArxLibertatis

function FUNCsaveList() { 
    find "$HOME/.local/share/arx/save" -iname "gsave.sav" -exec ls --full-time '{}' \; |sort -k6; 
}
FUNCsaveList
nNewestSaveIndex=$((10#`FUNCsaveList |tail -n 1 |sed -r 's@.*/save(....)/.*@\1@'`))&&:;

acmdParams=(
  --data-dir="../Arx Fatalis" #TODOA could just place data*.pak at libertatis path? or on a layer?
  --debug="warn,error" #TODOA this works???
  --debug-gl
);
strNewestSaveFile="`FUNCsaveList |tail -n 1 |sed -r "s@.*($HOME/.*)@\1@"`"
if [[ -n "$nNewestSaveIndex" ]] && echoc -t 6 -q "load newest savegame $nNewestSaveIndex ($strNewestSaveFile)?@Dy";then
  #acmdParams+=(--loadslot="$nNewestSaveIndex"); #this doesnt seem to work?
  acmdParams+=(--loadsave "$strNewestSaveFile");
fi
acmd=(./arx "${acmdParams[@]}" "$@")

#./arx --data-dir="../Arx Fatalis" --debug="warn,error" --debug-gl
echoc --info "EXEC: ${acmd[@]}"
"${acmd[@]}"
