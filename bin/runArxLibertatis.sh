#!/bin/bash
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
