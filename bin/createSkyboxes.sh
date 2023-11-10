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

#help download all the collections of skyboxes from: https://opengameart.org/content/humus-skyboxes
#help extract them all somewhere
#help place a symlink to this script (and the empty png) there too
#help run this script w/o parameters, will montage all tiles into skyboxes textures
#help run this script with --prepareHologramIndexedSkyboxes param, it will prepare the skybox to the hologram item
#help obs.: there are many var options you can tweak if you want here.

source <(secinit)

: ${strFlSkyBoxOutput:="skybox.png"};export strFlSkyBoxOutput #help
: ${iIndexCount:=0};export iIndexCount  #help this is there the index count will begin
: ${strSkyboxFlPrefix:="Hologram.skybox.index"};export strSkyboxFlPrefix #help

nRealCpuCores="$(cat /proc/cpuinfo |grep "core id" |sort -u |egrep "[0-9]*" -o |sort -n |tail -n 1)";((nRealCpuCores++))&&:
declare -p nRealCpuCores
: ${bMultithread:=false};export bMultithread #help
: ${nThreads:=${nRealCpuCores}};export nThreads #help

FUNCfinish() {
  echoc --info "you can now update the related skyboxes script max index with the value: $iIndexCount (the .asl  requires it to be +1 for random exclusive max (ex.: from 0 to 10 it needs to be ^rnd_11) so: ^rnd_${iIndexCount}"
  echoc -p "YOU MUST MAKE IT SURE ALL THE LICENSE FILES ARE CORRECT."
}

if [[ "${1-}" == --help ]];then #help
  egrep "[#]help" $0
  exit
fi

#TODO resize: convert "$strFl" -resize 1024x "${strFl}.new"

if [[ "${1-}" == --reindex ]];then #help use this after --prepareHologramIndexedSkyboxes and after having removed files 
  IFS=$'\n' read -d '' -r -a astrFlList < <(find -mindepth 1 -maxdepth 1 -iregex ".*index[0-9]*\.png")&&:
  if [[ -d reindexed ]];then
    (
      cd reindexed
      ls -1 |egrep -v "license|index[0-9]*.png" |sed -r -e 's@Hologram.skybox.index[0-9]*.@@' -e 's@[.]png@@' -e 's@_@-skyboxes/@' |sort
    )
    echoc -p "delete folder reindexed please"
    exit 1
  fi
  mkdir -vp reindexed
  : ${iIndexCount:=0} #help start at 
  for strFl in "${astrFlList[@]}";do
    SECFUNCdrawLine " $strFl "
    strFl="${strFl#./}"
    strFlLic="${strFl%.png}"
    strFlLic="`ls -1 "${strFlLic}"*.txt`"
    strFlDesc="${strFl%.png}"
    strFlDesc="`find -mindepth 1 -maxdepth 1 -type l -iname "${strFlDesc}*"`"
    strFlDesc="${strFlDesc#./}"
    strDesc="$(echo "$strFlDesc" |sed -r 's@.*index[0-9]*[.](.*)[.]png@\1@')"
    declare -p strFl strFlLic strFlDesc strDesc
    
    SECFUNCexecA -ce cp -v "$strFl" "reindexed/${strSkyboxFlPrefix}${iIndexCount}.png"
    SECFUNCexecA -ce cp -v "$strFlLic" "reindexed/${strSkyboxFlPrefix}${iIndexCount}.png.license.txt"
    (
      cd "reindexed"
      SECFUNCexecA -ce ln -vsfT "./${strSkyboxFlPrefix}${iIndexCount}.png" "${strSkyboxFlPrefix}${iIndexCount}.${strDesc}.png"
    )
    
    ((iIndexCount++))&&:
  done
  FUNCfinish
  exit
fi

if [[ "${1-}" == --prepareHologramIndexedSkyboxes ]];then #help this works with path naming for https://opengameart.org/content/humus-skyboxes
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
  FUNCfinish
  exit
fi

#cube, 6 sides,  tiles 4x3
# suggested
#          up    +y
#left  -x  front +z  right +x  back  -z
#          down  -y

# default cfg works with http://www.humus.name
: ${sEmpt:="`pwd`/createSkyboxesEmpty.png"}  #help
if [[ ! -f "$sEmpt" ]];then
  echoc --info "the empty square image will fill the empty tiles for the skybox"
  echoc -p "the file sEmpt='$sEmpt' has to be created manually for now as 16x16 in transparent color"
  exit 1
fi
: ${sT0x0:="${sEmpt}"}; : ${sT0x1:="posy.jpg"}; : ${sT0x2:="${sEmpt}"}; : ${sT0x3:="${sEmpt}"};  #help
: ${sT1x0:="negx.jpg"}; : ${sT1x1:="posz.jpg"}; : ${sT1x2:="posx.jpg"}; : ${sT1x3:="negz.jpg"};  #help
: ${sT2x0:="${sEmpt}"}; : ${sT2x1:="negy.jpg"}; : ${sT2x2:="${sEmpt}"}; : ${sT2x3:="${sEmpt}"};  #help
export sT0x0; export sT0x1; export sT0x2; export sT0x3; 
export sT1x0; export sT1x1; export sT1x2; export sT1x3; 
export sT2x0; export sT2x1; export sT2x2; export sT2x3; 

function FUNCskybox() {
  strFlRef="$1";shift
  
  if $bMultithread;then
    #while true;do
      #ls -l createSkyBox.Thread.*.tmp
      #nRunningThreads=$(ls -1 createSkyBox.Thread.*.tmp |wc -l)
      #if((nRunningThreads>=nThreads));then
        #echoc -t 1 -w "waiting other $nRunningThreads threads end";
        #continue
      #fi
      #break
    #done
    strFlThread="`pwd`/createSkyBox.Thread.$$.tmp"
    echo >"$strFlThread"
  fi
  
  nTileSz="$(identify "$strFlRef" |sed -r 's@.* ([0-9]*)x[0-9]* .*@\1@')"
  strPath="$(dirname "$strFlRef")"
  
  cd "$strPath"
  SECFUNCdrawLine " $(basename "$(pwd)") "
  pwd
  declare -p nTileSz
  
  strIdSB="";
  if [[ -f "$strFlSkyBoxOutput" ]];then
    strIdSB="$(identify "${strFlSkyBoxOutput}")"
  fi
  #if [[ -f "${strFlSkyBoxOutput}" ]];then 
  bWorkFinished=false
  if [[ "$(echo "${strIdSB}" |sed -r 's@.* ([0-9]*x[0-9]*) .*@\1@')" == "$((nTileSz*4))x$((nTileSz*3))" ]];then
    echoc --info "ALREADY PREPARED."
  else
    SECFUNCexecA -ce ls -l \
      "${sT0x0}" "${sT0x1}" "${sT0x2}" "${sT0x3}" \
      "${sT1x0}" "${sT1x1}" "${sT1x2}" "${sT1x3}" \
      "${sT2x0}" "${sT2x1}" "${sT2x2}" "${sT2x3}" #if something is missing this will fail as montage wont
    # this works with http://www.humus.name
    SECFUNCexecA -ce montage -background none -geometry ${nTileSz}x -tile 4x3 \
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
  if $bMultithread;then
    rm -v "$strFlThread";
    #echoc -w;
  else
    if $bWorkFinished && $bWaitCpuCooldown;then echoc -w -t 60 "let the cpu cooldown";fi
  fi
};export -f FUNCskybox

function FUNCskyboxMultithread() {
  SECFUNCdrawLine " $1 "
  while true;do
    ls -l createSkyBox.Thread.*.tmp
    nRunningThreads=$(ls -1 createSkyBox.Thread.*.tmp |wc -l)
    if((nRunningThreads>=nThreads));then
      echoc -t 1 -w "waiting other $nRunningThreads threads end";
      continue
    fi
    break
  done
  xterm -e bash -c "FUNCskybox '$1'"&
  sleep 1
};export -f FUNCskyboxMultithread

if $bMultithread;then
  rm -v createSkyBox.Thread.*.tmp&&:
  find -iname "posx.*" -exec bash -c "FUNCskyboxMultithread '{}'" \;
else
  find -iname "posx.*" -exec bash -c "FUNCskybox '{}'" \;
fi
