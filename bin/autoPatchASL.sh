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
#help   This script, default regex values example, will look for every .asl script where potions are added to the inventory and will also add a hologram there.
#help   This script is necessary to not need to create and keep updated a patch to each other mod out there.
#help   To properly patch all required files, it is important to extract all data pak files somewhere like: ArxLibertatis.layer0050.AllProprietaryArxFatalisUnpakedData (this example is a low priority mergerfs folder prepared with `secOverrideMultiLayerMountPoint.sh ArxLibertatis` that loses to every other mod in higher priority layers).
#help   It seems to require to restart the dungeon level for the new items added to inventories appear in corpses inventories at least (probably other containers too). I had to load a previous save of before that dungeon level load to let it work, but there may have some developer console command to workaround that may be?

set -Eeu

trap 'echo "WARN: Ctrl+c pressed, exiting...";exit 2' INT
trap 'nExit=$?;if((nExit!=0));then set -x;declare -p BASH_COMMAND;echo "$BASH_COMMAND";echo "ERROR: LINE=$LINENO;EXIT=$nExit;";set +x;fi' EXIT

function FUNCtrash() {
  trash "$@" 2>&1 |egrep -i trashed
}

function FUNCecho() {
  echo
  echo " <i> $@"
}

function FUNCask() {
  echo
  read -n 1 -p " <?> QUESTION: $@ (y/...)" strResp;
  if [[ "${strResp}" =~ [yY] ]];then return 0;fi
  return 1
}

function FUNCexec() {
  local lstrBCMD="BASH_COMMAND=$BASH_COMMAND; \$@=${@-}"&&:
  local lbForceVerbose=false;if [[ "$1" == -v ]];then lbForceVerbose=true;shift;fi
  : ${bVerbose:=false} #help show commands being executed
  if $lbForceVerbose || $bVerbose;then 
    echo
    echo " <\$> EXEC: $@";
  fi
  if ! "$@";then
    echo "lstrBCMD='$lstrBCMD'" >&2
    return 1
  fi
  return 0
}

function FUNCdep() { if ! which "$1" >/dev/null;then FUNCecho "ERROR: missing dependency '$1'";exit 1;fi; }

egrep "[#]help" "$0"

################### VALIDATIONS

FUNCdep unbuffer
FUNCdep dos2unix
FUNCdep colordiff
: ${strMergeTool:=meld} #help on cygwin use winmerge
FUNCdep "${strMergeTool}"
FUNCdep trash
# :)
FUNCdep chmod
FUNCdep sed
FUNCdep egrep
FUNCdep pwd

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
strModPathOriginalToCmpTmp="${strModPath}/TMP.AutoPatch.WorkFolder.OriginalCopyToCompare"
declare -p strModPath
if [[ -d "$strModPath" ]] && FUNCexec -v ls -ld "$strModPath/"*;then
  #FUNCexec -v ls -ld "$strModPath/"* &&:
  #echo;read -n 1 -p "QUESTION: trash the above patch folder contents? (this will grant it is up to date with all other mods installed. If using mergerfs, this may be a high priority folder and you NEED to clean it, otherwise the comparison with the merged folder will not work.) (y/...)" strResp;if [[ "${strResp}" =~ [yY] ]];then
  if ! FUNCask "keep (do not trash) the above patch folder contents? Tho, trashing will grant it is up to date with all other mods installed. If using mergerfs, this may be a high priority folder and you NEED to clean it, otherwise the comparison with the merged folder will not work. If unsure, just hit Enter.";then
    FUNCtrash -v "$strModPath/"* &&: #wont directly delete the mod path as it may be already mounted with mergerfs
  fi
fi

############################ MAIN

FUNCecho "INFO: Going to patch each file into a new file that you can install later as a mod using some mod install tool or mergerfs."

  #egrep '^[ \t]*INVENTORY[ \t]*(ADD|ADDMULTI)[ \t]*"MAGIC[\]*POTION_[a-zA-Z0-9_]*[\]*POTION_[a-zA-Z0-9_]*"'
      #-e 's@^([ \t]*)(INVENTORY[ \t]*ADD[ \t]*"Magic[\]*potion_[a-zA-Z0-9_]*[\]*potion_[a-zA-Z0-9_]*")(.*)@\1\2\3\n\1Inventory Add "Magic\\Hologram\\Hologram"\3@i'       \
      #-e 's@^([ \t]*)(INVENTORY[ \t]*ADDMULTI[ \t]*"Magic[\]*Potion_[a-zA-Z0-9_]*[\]*Potion_[a-zA-Z0-9_]*")(.*)@\1\2\3\n\1Inventory AddMulti "Magic\\Hologram\\Hologram"\3@i'  \
#
: ${strRegexMatch:='^(.*)([ \t]*)(INVENTORY[ \t]*)(ADD|ADDMULTI)([ \t]*"MAGIC[\]*POTION_[a-zA-Z0-9_]*[\]*POTION_[a-zA-Z0-9_]*")(.*)'} #help will look for this to be replaced. This is also used by grep to determine what files need to be patched. Tip: This is an example for the Hologram mod adding it to inventories where there are potions.
: ${strRegexReplace:='\1\2\3\4\5\6\n\1\2\3\4 "Magic\\Hologram\\Hologram"\6'} #help will replace strRegexMatch. \1 may contain an if condition, may be a comment, but if it is a timer it may require more logic to be coded manually...

FUNCecho "INFO: Looking for files that add a potions to some inventory, please wait..."
IFS=$'\n' read -d '' -r -a astrFlList < <(
  #egrep 'INVENTORY *ADD *"Magic[\]Potion_mana[\]Potion_mana"' --include="*.asl" --include="*.ASL" -iRna * 
  #egrep '^[ \t]*INVENTORY[ \t]*(ADD|ADDMULTI)[ \t]*"MAGIC[\]*POTION_[a-zA-Z0-9_]*[\]*POTION_[a-zA-Z0-9_]*"' 
  egrep "$strRegexMatch" --include="*.asl" --include="*.ASL" -iRna -c * \
    |egrep -v ":0$" \
    |sed -r 's@(.*[.]asl)(:[0-9]*)$@\1@'
    #|sed -r 's@(.*[.]asl)(:[0-9]*:.*)@\1@'
)&&:
declare -p astrFlList |tr '[' '\n'

if [[ -z "${astrFlList[@]}" ]];then 
  FUNCexec pwd
  FUNCecho "ERROR: no .asl file containing potions found here..."
  exit 1
fi

FUNCexec mkdir -vp "$strModPathTmp"
echo;read -p "hit Enter to proccess the above files."
: ${strGrepCheckOld:="inventory.*(add|addmulti).*Potion_[a-zA-Z0-9_]*"} #help set this to count the old matches vs the count of new patches
: ${strGrepCheckNew:="inventory.*(add|addmulti).*Hologram"} #help set this to check/validate the results: count old VS new matches
for strFl in "${astrFlList[@]}";do
  #if $bVerbose;then 
    ls -l "$strFl";
  #fi
  strPath="$(dirname "$strFl")"
  
  FUNCexec mkdir -p "$strModPathTmp/$strPath"
  FUNCexec mkdir -p "$strModPathOriginalToCmpTmp/$strPath"
  #FUNCtrash "$strModPathTmp/$strFl"&&:
  ######################### PATCH THAT PLACES HOLOGRAMS WHERE POTIONS ARE
      #-e 's@^([ \t]*)(INVENTORY[ \t]*ADD[ \t]*"Magic[\]*potion_[a-zA-Z0-9_]*[\]*potion_[a-zA-Z0-9_]*")(.*)@\1\2\3\n\1Inventory Add "Magic\\Hologram\\Hologram"\3@i'       \
      #-e 's@^([ \t]*)(INVENTORY[ \t]*ADDMULTI[ \t]*"Magic[\]*Potion_[a-zA-Z0-9_]*[\]*Potion_[a-zA-Z0-9_]*")(.*)@\1\2\3\n\1Inventory AddMulti "Magic\\Hologram\\Hologram"\3@i'  \
      #
  cat "$strFl"  \
    |dos2unix   \
    |sed -r -e "s@${strRegexMatch}@${strRegexReplace}@i" \
    >"$strModPathTmp/$strFl"
  FUNCexec cp "$strFl" "$strModPathOriginalToCmpTmp/$strPath/"
  FUNCexec chmod u+w "$strModPathOriginalToCmpTmp/$strFl"
  
  # force comment on lines with timer that may require much(?) more logic TODO try auto patch them too with ex.: timerTstHologram ...
  FUNCexec sed -i -r -e "s@.*timer.*${strGrepCheckNew}@//&@i" "$strModPathTmp/$strFl" #there may have an if before the timer too
  
  FUNCexec -v unbuffer colordiff --ignore-all-space "$strFl" "$strModPathTmp/$strFl" &&: # |sed -r 's@^$@@'&&:
  echo "=== grep '${strGrepCheckNew}' ==="
  FUNCexec unbuffer egrep --color=always "${strGrepCheckNew}" -i -B1 "$strModPathTmp/$strFl"
  : ${bManualPatch:=true} #help you can manually patch the final file if this autopatch fails, and report the problem so I can fix it, or drop a pull request thx!
  if ! egrep -qi "${strGrepCheckNew}" "$strModPathTmp/$strFl";then
    FUNCecho "WARN: failed to patch, no '${strGrepCheckNew}' patch found at final patch file."
    if ! $bManualPatch;then exit 1;fi
    FUNCexec -v "${strMergeTool}" "$strFl" "$strModPathTmp/$strFl"
  fi
  
  if(($(egrep "${strGrepCheckOld}" -ia "$strFl" |wc -l)!=$(egrep "${strGrepCheckNew}" -ia "$strModPathTmp/$strFl" |wc -l)));then
    FUNCecho "WARN: failed to patch, count for Potion(s) is not the same for '${strGrepCheckNew}' at final patch file. Hint: this problem may also happen if you are using mergerfs and edited some file manually, check the write folder for new things that should not be there."
    if ! $bManualPatch;then exit 1;fi
    FUNCexec -v "${strMergeTool}" "$strFl" "$strModPathTmp/$strFl"
  fi
  
  if egrep ".*timer.*${strGrepCheckNew}" -i "$strModPathTmp/$strFl";then
    if FUNCask "there are timer(s), and it require manually patching. They are commented for now. Edit them?";then
      FUNCexec -v "${strMergeTool}" "$strFl" "$strModPathTmp/$strFl"
    fi
  fi
  
  : ${bMinimumPatch:=false} #help this will keep only the first match, so if adding an item to inventory, it will only keep the first command doing that. If it is too simple, you will be asked to edit manually too for each file where it may be required.
  if $bMinimumPatch && (($(egrep "${strGrepCheckNew}" -i "$strModPathTmp/$strFl" |egrep -vi "//.*${strGrepCheckNew}" |wc -l)>1));then
    FUNCecho "bMinimumPatch=$bMinimumPatch: More than one non commented line with the patch found. Keeping only the first one."
    bManuallyPatched=false
    if FUNCask "To do this, all commented new patched lines must be removed, edit it manually first?";then
      FUNCexec -v "${strMergeTool}" "$strFl" "$strModPathTmp/$strFl"
      bManuallyPatched=true
    fi
    if ! $bManuallyPatched || FUNCask "After patching manually, you still want to keep only the first match?";then
      FUNCexec -v sed -i.bkp -r -e "/\/\/.*${strGrepCheckNew}/Id" "$strModPathTmp/$strFl"
      FUNCexec -v unbuffer colordiff --ignore-all-space "$strModPathTmp/${strFl}.bkp" "$strModPathTmp/$strFl" &&: # |sed -r 's@^$@@'&&:
      
      nLnFirst="$(egrep "${strGrepCheckNew}" -n "$strModPathTmp/$strFl" |head -n 1 |cut -d: -f1)"
      nLnFrom=$((nLnFirst+1))&&:
      FUNCexec -v sed -i.bkp -r -e "${nLnFrom},"'$'" s@.*${strGrepCheckNew}.*@//&@i" "$strModPathTmp/$strFl"
      FUNCexec -v unbuffer colordiff --ignore-all-space "$strModPathTmp/${strFl}.bkp" "$strModPathTmp/$strFl" &&: # |sed -r 's@^$@@'&&:
      
      FUNCexec -v egrep -n "${strGrepCheckNew}" "$strModPathTmp/$strFl" |egrep -v "//.*${strGrepCheckNew}"
    fi
  fi
done

if FUNCask "Compare changes with ${strMergeTool} too? (select all files, but not folders, and hit Enter there in meld at least)";then
  FUNCexec -v "${strMergeTool}" "$strModPathOriginalToCmpTmp/" "$strModPathTmp/"
fi

#if ! FUNCask "is the above correct? if so, all tmp work files will be moved to the auto patch mod folder.";then exit 1;fi
#FUNCexec -v mv -v "$strModPathTmp/"* "$strModPath/"
FUNCecho "copying all patched files to mod folder '$strModPath/'"
FUNCexec -v cp -vr "$strModPathTmp/"* "$strModPath/"

if ! FUNCask "keep the temp folders (you can use to review later with ${strMergeTool})?";then
  FUNCtrash -v "$strModPathTmp/" "$strModPathOriginalToCmpTmp/"
fi

#(
  #FUNCexec cd "$strModPath/"
  #FUNCecho "INFO: you can check each file below too using ${strMergeTool}:"
  #FUNCexec pwd
  #FUNCexec find -iname "*.asl" -exec echo "${strMergeTool}" "'${strArxLibertatisFolder}/{}'" "`pwd`'{}'" \;
#)

FUNCecho "INFO: if all went well, you can install this patch from '$strModPath'"
