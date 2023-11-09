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

#help download all the collections of skyboxes from: https://opengameart.org/art-search?keys=humus
#help extract them all somewhere
#help place a symlink to this script there too
#help run this script w/o parameters, will montage all tiles into skyboxes textures
#help run this script with --prepareHologramIndexedSkyboxes param, it will prepare the skybox to the hologram item
#help obs.: there are many var options you can tweak if you want here.

source <(secinit)

egrep "[#]help" $0

: ${strFlSkyBoxOutput:="skybox.png"} #help

if [[ "${1-}" == --prepareHologramIndexedSkyboxes ]];then #help this works with path naming for https://opengameart.org/art-search?keys=humus
  : ${iIndexCount:=0} #help this is there the index count will begin
  : ${strSkyboxFlPrefix:="Hologram.skybox.index"} #help
  if ls -l "graph/obj3d/textures/${strSkyboxFlPrefix}"*;then
    echoc --info "there are the above files already there. If you are recreating, you should delete them all before continuing."
    if echoc -q "are you instead really appending new skyboxes?";then 
      if((iIndexCount==0));then
        iIndexCount="$(ls -l "graph/obj3d/textures/${strSkyboxFlPrefix}"* |sed -r 's@.*index([0-9]*).*@\1@g' |sort -n |tail -n 1)"
        ((iIndexCount++))&&:
        declare -p iIndexCount
        if ! echoc -q "you must set a new iIndexCount, to append indexed skyboxes there. Is the above correct?";then
          exit 1
        fi
      fi
    fi
  fi
  
  mkdir -vp "graph/obj3d/textures"
  IFS=$'\n' read -d '' -r -a astrFlList < <(find -iname "${strFlSkyBoxOutput}" |sort -u)&&:
  for strFl in "${astrFlList[@]}";do
    #strBNDesc="$(basename "$(dirname "$strFl")")"
    strDN="$(dirname "$strFl")"
    strLicense="$(ls -1 "$strDN/"*.txt)"
    if((`echo "$strLicense" |wc -l`!=1));then
      echoc -p "strLicense='$strLicense' should there have exactly one text file there, and it must be the license."
      exit 1
    fi
    if ! egrep "license" -i "$strLicense";then
      echoc -p "the license file strLicense='$strLicense' doesnt appear to be valid"
      exit 1
    fi
    
    if ls -l "graph/obj3d/textures/${strSkyboxFlPrefix}${iIndexCount}."*;then
      echoc -p "there are indexed files already there for the above. Remove them first or use a bigger iIndexCount!"
      exit 1
    fi
    strDesc="$(echo "$strDN" |sed -r -e 's@[/.]@@g' -e 's@-skyboxes@_@g')"
    SECFUNCexecA -ce cp -v "$strFl" "graph/obj3d/textures/${strSkyboxFlPrefix}${iIndexCount}.png"
    SECFUNCexecA -ce cp -v "$strLicense" "graph/obj3d/textures/${strSkyboxFlPrefix}${iIndexCount}.png.license.txt"
    (
      #cd "$(dirname "$strFl")"
      cd "graph/obj3d/textures"
      SECFUNCexecA -ce ln -vsfT "./${strSkyboxFlPrefix}${iIndexCount}.png" "${strSkyboxFlPrefix}${iIndexCount}.${strDesc}.png"
    )
    ((iIndexCount++))&&:
  done
  echoc -p "now, you (not me who just created this helper script) YOU!!! YOU MUST be sure all the license files are correct"
  echoc -w "I AGREEE TO MAKE IT SURE ALL THE LICENSE FILES ARE CORRECT."
  echoc --info "you can now update the related skyboxes script max index with the value: $iIndexCount (the .asl  requires it to be +1 for random exclusive max so: ^rnd_$((iIndexCount+1))"
  exit
fi

#cube, 6 sides,  tiles 4x3
# suggested
#          up    +y
#left  -x  front +z  right +x  back  -z
#          down  -y

# default cfg works with http://www.humus.name
: ${sEmpt:="`pwd`/empty.png"}  #help
: ${sT0x0:="${sEmpt}"}; : ${sT0x1:="posy.jpg"}; : ${sT0x2:="${sEmpt}"}; : ${sT0x3:="${sEmpt}"};  #help
: ${sT1x0:="negx.jpg"}; : ${sT1x1:="posz.jpg"}; : ${sT1x2:="posx.jpg"}; : ${sT1x3:="negz.jpg"};  #help
: ${sT2x0:="${sEmpt}"}; : ${sT2x1:="negy.jpg"}; : ${sT2x2:="${sEmpt}"}; : ${sT2x3:="${sEmpt}"};  #help
export sT0x0; export sT0x1; export sT0x2; export sT0x3; 
export sT1x0; export sT1x1; export sT1x2; export sT1x3; 
export sT2x0; export sT2x1; export sT2x2; export sT2x3; 

function FUNCskybox() {
  strFlRef="$1";shift
  nTileSz="$(identify "$strFlRef" |sed -r 's@.* ([0-9]*)x[0-9]* .*@\1@')"
  strPath="$(dirname "$strFlRef")"
  
  cd "$strPath"
  SECFUNCdrawLine " $(basename "$(pwd)") "
  pwd
  declare -p nTileSz
  
  strIdSB="$(identify "${strFlSkyBoxOutput}")"&&:
  #if [[ -f "${strFlSkyBoxOutput}" ]];then 
  bWorkFinished=false
  if [[ "$(echo "$strIdSB" |sed -r 's@.* ([0-9]*x[0-9]*) .*@\1@')" == "$((nTileSz*4))x$((nTileSz*3))" ]];then
    echoc --info "ALREADY PREPARED."
  else
    SECFUNCexecA -ce ls -l \
      "${sT0x0}" "${sT0x1}" "${sT0x2}" "${sT0x3}" \
      "${sT1x0}" "${sT1x1}" "${sT1x2}" "${sT1x3}" \
      "${sT2x0}" "${sT2x1}" "${sT2x2}" "${sT2x3}" #if something is missing this will fail as montage wont
    # this works with http://www.humus.name  , the empty.jpg has to be created manually for now as 1024x1024 in black color
    SECFUNCexecA -ce montage -geometry ${nTileSz}x -tile 4x3          \
      "${sT0x0}" "${sT0x1}" "${sT0x2}" "${sT0x3}" \
      "${sT1x0}" "${sT1x1}" "${sT1x2}" "${sT1x3}" \
      "${sT2x0}" "${sT2x1}" "${sT2x2}" "${sT2x3}" \
      "${strFlSkyBoxOutput}"
      #empty.jpg posy.jpg empty.jpg empty.jpg \
      #negx.jpg  posz.jpg posx.jpg  negz.jpg  \
      #empty.jpg negy.jpg empty.jpg empty.jpg \
      #
    bWorkFinished=true
  fi
  
  identify "${strFlSkyBoxOutput}"
  ls -l "`realpath "${strFlSkyBoxOutput}"`"
  : ${bWaitCpuCooldown:=false}  #help
  if $bWorkFinished && $bWaitCpuCooldown;then echoc -w -t 60 "let the cpu cooldown";fi
};export -f FUNCskybox
  
find -iname "posx.*" -exec bash -c "FUNCskybox '{}'" \;
