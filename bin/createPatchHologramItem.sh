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

#help   PARAMS: [strArxLibertatisFolder]
#help
#help   This script will look for every .asl script where potions are added to the inventory and will also add a hologram there.
#help   This script is necessary to not need to create and keep updated a patch to each other mod out there.
#help   To properly patch all required files, it is important to extract all data pak files somewhere like: ArxLibertatis.layer0050.AllProprietaryArxFatalisUnpakedData (this example is a low priority mergerfs folder prepared with `secOverrideMultiLayerMountPoint.sh ArxLibertatis` that loses to every other mod in higher priority layers).
#help   It seems to require to restart the dungeon level for the Holograms appear in corpses inventories at least (probably other containers too). I had to load a previous save to let it work, but there may have some developer console command to workaround that may be?

set -Eeu

trap 'echo "WARN: Ctrl+c pressed, exiting...";exit 2' INT
trap 'nExit=$?;if((nExit!=0));then set -x;declare -p BASH_COMMAND;echo "$BASH_COMMAND";echo "ERROR: LINE=$LINENO;EXIT=$nExit;";set +x;fi' EXIT

function FUNCtrash() {
  trash "$@" 2>&1 |egrep -i trashed
}

function FUNCecho() {
  echo
  echo "$@"
}

function FUNCask() {
  echo
  read -n 1 -p "QUESTION: $@ (y/...)" strResp;
  if [[ "${strResp}" =~ [yY] ]];then return 0;fi
  return 1
}

function FUNCexec() {
  local lstrBCMD="BASH_COMMAND=$BASH_COMMAND; \$@=${@-}"&&:
  local lbForceVerbose=false;if [[ "$1" == -v ]];then lbForceVerbose=true;shift;fi
  : ${bVerbose:=false} #help show commands being executed
  if $lbForceVerbose || $bVerbose;then 
    echo
    echo "EXEC: $@";
  fi
  if ! "$@";then
    echo "lstrBCMD='$lstrBCMD'" >&2
    return 1
  fi
  return 0
}

egrep "[#]help" "$0"

################### VALIDATIONS

: ${strArxLibertatisFolder:="${1-}"} #help you can set this var or pass it as param
declare -p strArxLibertatisFolder
if [[ -d "$strArxLibertatisFolder" ]];then
  cd "$strArxLibertatisFolder"
else
  strArxLibertatisFolder="$(pwd)"
fi

pwd
if ! [[ -f "arx" ]];then
  FUNCecho "ERROR: the above doesn't seem to be the ArxLibertatis folder where the main executable is installed."
  exit 1
fi

: ${strModPath:="${strArxLibertatisFolder}/../ArxLibertatis.layer9055.Gameplay-HologramInventoriesAutoPatch/"} #help this is where all the patched files will be written. If you install another new mod that has potions added to inventories, run this script again. The Hologram mod is expected to be already installed in another layer like layer9050 for this example.
strModPathTmp="${strModPath}/TMP.AutoPatch.WorkFolder"
strModPathCmpTmp="${strModPath}/TMP.AutoPatch.WorkFolder.OriginalCopyToCompare"
declare -p strModPath
if [[ -d "$strModPath" ]] && FUNCexec -v ls -ld "$strModPath/"*;then
  #FUNCexec -v ls -ld "$strModPath/"* &&:
  #echo;read -n 1 -p "QUESTION: trash the above patch folder contents? (this will grant it is up to date with all other mods installed. If using mergerfs, this may be a high priority folder and you NEED to clean it, otherwise the comparison with the merged folder will not work.) (y/...)" strResp;if [[ "${strResp}" =~ [yY] ]];then
  if ! FUNCask "keep (do not trash) the above patch folder contents? Tho, trashing will grant it is up to date with all other mods installed. If using mergerfs, this may be a high priority folder and you NEED to clean it, otherwise the comparison with the merged folder will not work. If unsure, just hit Enter.";then
    FUNCtrash -v "$strModPath/"* &&: #wont directly delete the mod path as it may be already mounted with mergerfs
  fi
fi

############################ MAIN

FUNCecho "INFO: Going to patch each file into a new file that you can apply later as a mod using some mod install tool or mergerfs."
echo;read -n 1 -p "Hit a key to continue."

FUNCecho "INFO: Looking for files that add a potions to some inventory, please wait..."
IFS=$'\n' read -d '' -r -a astrFlList < <(
  #egrep 'INVENTORY *ADD *"Magic[\]Potion_mana[\]Potion_mana"' --include="*.asl" --include="*.ASL" -iRna * 
  egrep '^[ \t]*INVENTORY[ \t]*(ADD|ADDMULTI)[ \t]*"MAGIC[\]*POTION_[a-zA-Z0-9_]*[\]*POTION_[a-zA-Z0-9_]*"' --include="*.asl" --include="*.ASL" -iRna * \
    |sed -r 's@(.*[.]asl)(:[0-9]*:.*)@\1@'
)&&:
declare -p astrFlList |tr '[' '\n'

if [[ -z "${astrFlList[@]}" ]];then 
  FUNCexec pwd
  FUNCecho "ERROR: no .asl file containing potions found here..."
  exit 1
fi

FUNCexec mkdir -vp "$strModPathTmp"
for strFl in "${astrFlList[@]}";do
  #if $bVerbose;then 
    ls -l "$strFl";
  #fi
  strPath="$(dirname "$strFl")"
  
  FUNCexec mkdir -p "$strModPathTmp/$strPath"
  FUNCexec mkdir -p "$strModPathCmpTmp/$strPath"
  #FUNCtrash "$strModPathTmp/$strFl"&&:
  ######################### PATCH THAT PLACES HOLOGRAMS WHERE POTIONS ARE
  cat "$strFl"  \
    |dos2unix   \
    |sed -r     \
      -e 's@^([ \t]*)(INVENTORY[ \t]*ADD[ \t]*"Magic[\]*potion_[a-zA-Z0-9_]*[\]*potion_[a-zA-Z0-9_]*")(.*)@\1\2\3\n\1Inventory Add "Magic\\Hologram\\Hologram"\3@i'       \
      -e 's@^([ \t]*)(INVENTORY[ \t]*ADDMULTI[ \t]*"Magic[\]*Potion_[a-zA-Z0-9_]*[\]*Potion_[a-zA-Z0-9_]*")(.*)@\1\2\3\n\1Inventory AddMulti "Magic\\Hologram\\Hologram"\3@i'  \
    >"$strModPathTmp/$strFl"
  FUNCexec cp "$strFl" "$strModPathCmpTmp/$strPath/"
  FUNCexec chmod u+w "$strModPathCmpTmp/$strFl"
  
  FUNCexec -v unbuffer colordiff --ignore-all-space "$strFl" "$strModPathTmp/$strFl" &&: # |sed -r 's@^$@@'&&:
  FUNCexec unbuffer egrep --color=always "Hologram" -i -B1 "$strModPathTmp/$strFl"
  : ${bManualPatch:=true} #help you can manually patch the final file if this autopatch fails, and report the problem so I can fix it, or drop a pull request thx!
  if ! egrep -q "Hologram" "$strModPathTmp/$strFl";then
    FUNCecho "WARN: failed to patch, no Hologram patch found at final patch file."
    if ! $bManualPatch;then exit 1;fi
    FUNCexec -v meld "$strFl" "$strModPathTmp/$strFl"
  fi
  if(($(egrep "inventory.*add.*Potion_[a-zA-Z0-9_]*" -ia "$strFl" |wc -l)!=$(egrep "inventory.*add.*Hologram" -ia "$strModPathTmp/$strFl" |wc -l)));then
    FUNCecho "WARN: failed to patch, count for Potion(s) is not the same for Hologram(s) at final patch file. Hint: this problem may also happen if you are using mergerfs and edited some file manually, check the write folder for new things that should not be there."
    if ! $bManualPatch;then exit 1;fi
    FUNCexec -v meld "$strFl" "$strModPathTmp/$strFl"
  fi
done

if FUNCask "Compare changes with meld too?";then
  FUNCexec -v meld "$strModPathCmpTmp/" "$strModPathTmp/"
fi

if ! FUNCask "is the above correct? if so, all tmp work files will be moved to the auto patch mod folder.";then exit 1;fi
FUNCexec -v mv -v "$strModPathTmp/"* "$strModPath/"
FUNCtrash -v "$strModPathTmp/" "$strModPathCmpTmp/"

#(
  #FUNCexec cd "$strModPath/"
  #FUNCecho "INFO: you can check each file below too using meld:"
  #FUNCexec pwd
  #FUNCexec find -iname "*.asl" -exec echo meld "'${strArxLibertatisFolder}/{}'" "`pwd`'{}'" \;
#)

FUNCecho "INFO: if all went well, you can install this patch from '$strModPath'"
