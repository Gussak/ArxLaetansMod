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

#TODO set default facetypes to missing tx cfgs: cat ManaPotion_OBJToFTL/ManaPotion.ftl.unpack.ugly25textureContainers.json |egrep '"filename"' |sed -r 's@\{"filename":"([^"]*)".*@\1@'

if ! which ScriptEchoColor;then 
  echo "ERROR: this scripts depends on ScriptEchoColor https://sourceforge.net/projects/scriptechocolor."
  echo "install .deb packages"
  echo " https://sourceforge.net/projects/scriptechocolor/files/Ubuntu%20.deb%20packages/"
  echo "OR for single user on any distro with latests updates:"
  echo " https://sourceforge.net/projects/scriptechocolor/files/Ubuntu%20.deb%20packages/secSingleUserInstall.sh/download"
  echo "Obs.: echoc and SECFUNC... may be easily replaced with equivalent cmds, then remove this check line."
fi
source <(secinit) #init echoc and SECFUNC... #set -eEu #ScriptEchoColor

strSelf="`realpath "$0"`"

#if [[ "${1-}" == --help ]];then shift;egrep "[#]help" "${strSelf}";exit 0;fi
#help most options, when you hit enter, will accept the asked question by default. it is when the 'y' in the yes option is in yellow color.

#To recreate/sync this list: egrep "POLY_" src/graphics/GraphicsTypes.h |tr -d '\t ,' |sed -r 's@(.*)=(.*)@export \1=$((\2))\&\&:;@'
export POLY_NO_SHADOW=$((1<<0))&&:; #helpft all textures must be set with POLY_NO_SHADOW or it will have a pseudo generic shadow? ISSUE: may fail and still drop shadow? is shadow based on the number of faces or vertices? review source code ..
export POLY_DOUBLESIDED=$((1<<1))&&:; #helpft found in plates, both face sides will be rendered
export POLY_TRANS=$((1<<2))&&:; #helpft this requires a transparent value to be set like: >=0.0<1.0 normal alpha (dark). >=1.0<2.0 add alpha (works like light emission, makes it bright). >=2.0 multiply alpha (like add effect but what is the difference?). ISSUE: 1.00to1.10 ends up transparent?
export POLY_WATER=$((1<<3))&&:; #helpft this will make the texture move slowly a bit
export POLY_GLOW=$((1<<4))&&:; #helpft
export POLY_IGNORE=$((1<<5))&&:; #todo test all these below or look for docs what they mean to objects at least, or are they about terrain?
export POLY_QUAD=$((1<<6))&&:;
export POLY_TILED=$((1<<7))&&:;
export POLY_METAL=$((1<<8))&&:;
export POLY_HIDE=$((1<<9))&&:;
export POLY_STONE=$((1<<10))&&:;
export POLY_WOOD=$((1<<11))&&:;
export POLY_GRAVEL=$((1<<12))&&:;
export POLY_EARTH=$((1<<13))&&:;
export POLY_NOCOL=$((1<<14))&&:;
export POLY_LAVA=$((1<<15))&&:;
export POLY_CLIMB=$((1<<16))&&:;
export POLY_FALL=$((1<<17))&&:;
export POLY_NOPATH=$((1<<18))&&:;
export POLY_NODRAW=$((1<<19))&&:;
export POLY_PRECISE_PATH=$((1<<20))&&:;
export POLY_NO_CLIMB=$((1<<21))&&:;
export POLY_ANGULAR=$((1<<22))&&:;
export POLY_ANGULAR_IDX0=$((1<<23))&&:;
export POLY_ANGULAR_IDX1=$((1<<24))&&:;
export POLY_ANGULAR_IDX2=$((1<<25))&&:;
export POLY_ANGULAR_IDX3=$((1<<26))&&:;
export POLY_LATE_MIP=$((1<<27))&&:;
function FUNCfacetypeInfo() {
  egrep "[P]OLY_" "${strSelf}"
  echoc --info "use the above bit combination (there are many more tho) to cfg the texture faces ex.: POLY_NO_SHADOW|POLY_TRANS|POLY_WATER"
}

#COPY FROM HERE: for simple scripts. The top line is also required: source <(secinit)
declare -p SECstrUserScriptCfgPath >&2
strExample="DefaultValue"
bExample=false
bExitAfterConfig=false
: ${bShowTextFiles:=true};export bShowTextFiles #help
: ${fPromptTm:=9999};export fPromptTm #help just not go sleep
: ${bDoBkpEverything:=false};export bDoBkpEverything #help will create historical bkp files for anything it touches
bDaemon=false #do not export
: ${bSpeak:=false};export bSpeak #help speak important events
: ${SECnSayVolume:=75};export SECnSayVolume #help set this from 0 to 100 to change the speech volume
export strMTSuffix="MultiThreadWorking"
CFGstrTest="Test"
CFGstrSomeCfgValue=""
astrRemainingParams=()
astrAllParams=("${@-}") # this may be useful

strSedBkpOpt="-i" #to edit inplace always
if $bDoBkpEverything;then
  strSedBkpOpt="-i`SECFUNCdtFmt --filename`.bkp" #will also bkp
fi

SECFUNCcfgReadDB ########### AFTER!!! default variables value setup above, and BEFORE the skippable ones!!!

: ${bWriteCfgVars:=true} #help false to speedup if writing them is unnecessary
: ${strEnvVarUserCanModify:="test"}
export strEnvVarUserCanModify #help this variable will be accepted if modified by user before calling this script
export strEnvVarUserCanModify2 #help test

while ! ${1+false} && [[ "${1:0:1}" == "-" ]];do # checks if param is set
	SECFUNCsingleLetterOptionsA;
	if [[ "$1" == "--help" ]];then #help show this help
		SECFUNCshowHelp --colorize "\t#MISSING DESCRIPTION script main help text goes here"
		SECFUNCshowHelp --colorize "\tConfig file: '`SECFUNCcfgFileName --get`'"
		echo
		SECFUNCshowHelp
		exit 0
	elif [[ "$1" == "-c" || "$1" == "--configoption" ]];then #help <CFGstrSomeCfgValue> MISSING DESCRIPTION
		shift;CFGstrSomeCfgValue="${1-}"
		bExitAfterConfig=true
	elif [[ "$1" == "-e" || "$1" == "--exampleoption" ]];then #help <strExample> MISSING DESCRIPTION
		shift;strExample="${1-}"
	elif [[ "$1" == "-E" || "$1" == "--exampleoptionthrupipeopt" ]];then #help <strExample> MISSING DESCRIPTION
		shift;strExample="${1-}";if [[ -z "${strExample}" ]];then read strExample;fi #this param can be received thru the pipe too this way but must be the last param...
	elif [[ "$1" == "-d" || "$1" == "--daemon" ]];then #help monitors changes to obj and auto converts into ftl, implies --noprompt
		bDaemon=true
    fPromptTm=0.1
    bShowTextFiles=false
	elif [[ "$1" == "-f" || "$1" == "--facetype" ]];then #help ~single paste facetype ex.: POLY_NO_SHADOW|POLY_TRANS and this will return an integer to use in blender sFT material name
    FUNCfacetypeInfo
		strFaceTypeCalc="`echoc -S "Paste facetype (if you want no bit cfg use just 0)"`"
    echo "sFT=$((${strFaceTypeCalc-0}));"
    exit
	elif [[ "$1" == "-P" || "$1" == "--noprompt" ]];then #help accepts all defaults, ask no questions
    bShowTextFiles=false
		fPromptTm=0.1
	elif [[ "$1" == "-B" || "$1" == "--simpleBooleanSwitchOptionFalse" ]];then #help MISSING DESCRIPTION
		bExample=false
	elif [[ "$1" == "-v" || "$1" == "--verbose" ]];then #help shows more useful messages
		SECbExecVerboseEchoAllowed=true #this is specific for SECFUNCexec, and may be reused too.
	elif [[ "$1" == "--cfg" ]];then #help <strCfgVarVal>... Configure and store a variable at the configuration file with SECFUNCcfgWriteVar, and exit. Use "help" as param to show all vars related info. Usage ex.: CFGstrTest="a b c" CFGnTst=123 help
		shift
		pSECFUNCcfgOptSet "$@";exit 0;
	elif [[ "$1" == "--" ]];then #help params after this are ignored as being these options, and stored at astrRemainingParams. TODO explain how it will be used
		shift #astrRemainingParams=("$@")
		while ! ${1+false};do	# checks if param is set
			astrRemainingParams+=("$1")
			shift&&: #will consume all remaining params
		done
	else
		echoc -p "invalid option '$1'"
		#"$SECstrScriptSelfName" --help
		$0 --help #$0 considers ./, works best anyway..
		exit 1
	fi
	shift&&:
done
# IMPORTANT validate CFG vars here before writing them all...
if $bWriteCfgVars;then SECFUNCcfgAutoWriteAllVars;fi #this will also show all config vars
if $bExitAfterConfig;then exit 0;fi
### collect optional/required named params
#help params: [strFlCoreName] | <strFlCoreName> [strFlCoreNameProprietary] #strFlCoreName can be any filename you create. strFlCoreNameProprietary can be the current folder name (ex.: bottle_wine) or must be a proprietary model name that does not match the folder name ex.: game/graph/obj3d/interactive/items/movable/bones/bone_bassin.ftl (only the basename, w/o the path and the extension .ftl)
strFlCoreName="${1-}";shift&&:
strFlCoreNameProprietary="${1-}";shift&&:

#help ISSUE/LIMITATION: while a ftl exporter in blender could provide each face with a specific transparency value, this script can only provide one transparency value for all the faces using each texture container TODO:NO:OverlyComplex: code a gradient transparency min/max && (up/down &&/|| left/right) based on vertex locations

#CFG
#help config these environment variables to your need
: ${WINEPREFIX:="$HOME/Wine/ArxFatalis.64bits"} #help this let you run the windows build but it also let you run the linux build (I run the linux build tho but is on the same path)
declare -p WINEPREFIX
: ${strArxInstallPath:="$WINEPREFIX/drive_c/Program Files/JoWood"}
export strArxInstallPath;declare -p strArxInstallPath
: ${strPathFtlToObj:="${strFlCoreName}_FTLToOBJ"} #help
export strPathFtlToObj;mkdir -vp "$strPathFtlToObj";declare -p strPathFtlToObj
: ${strPathObjToFtl:="${strFlCoreName}_OBJToFTL"} #help
export strPathObjToFtl;mkdir -vp "$strPathObjToFtl";declare -p strPathObjToFtl
: ${strBlenderSafePath:="_blenderSafeWork"};mkdir -vp "$strBlenderSafePath" #help sometimes, blender (?) or some plugin (?) may completely erase the working path with everything inside it w/o sending files to trash... that's why _blenderSafeWork exists (and you should backup it often!) TODO do backup every time this script is run in a fast tar.gz or tar.bz2. Try to recreate the problem to grant what causes it.
export strBlenderSafePath;declare -p strBlenderSafePath
: ${strTXPathRelative:="graph/obj3d/textures"} #help
export strTXPathRelative;declare -p strTXPathRelative
: ${strDeveloperWorkingPath:="${strArxInstallPath}/10.DevWork/ArxLaetansMod.github"} #help
export strDeveloperWorkingPath;declare -p strDeveloperWorkingPath
ln -vsfT "${strDeveloperWorkingPath}/graph" "${strBlenderSafePath}/graph"
ln -vsfT "../${strPathObjToFtl}" "${strBlenderSafePath}/${strPathObjToFtl}"
if ! ls -l "$strBlenderSafePath/${strTXPathRelative}";then echoc -t 3 -p "WARN: textures path is empty";fi
(cd "$strBlenderSafePath";ln -vsfT "${strTXPathRelative}" "textures";)
: ${strArxUnpackedDataFolder:="${strArxInstallPath}/_ArxData"}
export strArxUnpackedDataFolder;declare -p strArxUnpackedDataFolder
: ${strPathTools:="${strArxInstallPath}/05.LinuxTools/"} #help
export strPathTools;declare -p strPathTools
: ${strPathDeployAtModInstallFolder:="${strArxInstallPath}/ArxLibertatis.layer9000.GFX-ArxLaetansMod"} #help
export strPathDeployAtModInstallFolder;declare -p strPathDeployAtModInstallFolder
: ${strAppTextEditor:="geany"} #help
export strAppTextEditor;declare -p strAppTextEditor
: ${strFlWFObj:="`realpath "${strPathObjToFtl}/${strFlCoreName}.obj"`"}&&: #wavefront obj3d file
export strFlWFObj;declare -p strFlWFObj
: ${strFlWFMtl:="`realpath "${strPathObjToFtl}/${strFlCoreName}.mtl"`"}&&: #wavefront obj3d file
export strFlWFMtl;declare -p strFlWFMtl
: ${strPathReleaseHelper:="`pwd`/RELEASE/ArxLaetansMod/$strFlCoreName/"} #help
export strPathReleaseHelper;declare -p strPathReleaseHelper
: ${strPathReleaseSetupHelper:="`pwd`/RELEASE/ArxLaetansModSetup/$strFlCoreName/"} #help
mkdir -vp "${strPathReleaseSetupHelper}"
export strPathReleaseSetupHelper;declare -p strPathReleaseSetupHelper
pwd
strRelativeDeployPath="`pwd |sed -r "s@.*${strDeveloperWorkingPath}/@@"`"  #AUTOCFG
#declare -p strRelativeDeployPath;exit
#strRelativeDeployPath="${strRelativeDeployPath%${strBlenderSafePath}}"
export strRelativeDeployPath
declare -p strRelativeDeployPath
if [[ "${strRelativeDeployPath:0:1}" == "/" ]];then
  echoc -p "strRelativeDeployPath='$strRelativeDeployPath' should be a relative path from strDeveloperWorkingPath='$strDeveloperWorkingPath', move this folder inside there. Or on the terminal, paste the path from the filemanager in case you are in a path tree that have symlinks in between."
  exit 1
fi

if [[ -n "$strFlCoreName" ]];then
  if [[ -z "$strFlCoreNameProprietary" ]];then
    if $bDaemon;then
      strFlCoreNameProprietary=""
      echoc --info "the daemon is used after everything is already setup and the user is only updating things on the model, therefore strFlCoreNameProprietary is uneccessary and also shall not have an automatic default."
    else
      strFlCoreNameProprietary="$(basename "$(pwd)" |tr '[:upper:]' '[:lower:]')"
      if ! echoc -t $fPromptTm -q "the automatic reference file will be  strFlCoreNameProprietary='$strFlCoreNameProprietary' ok? if not it will just be ignored.@Dy";then
        strFlCoreNameProprietary=""
      elif [[ ! -f "${strArxUnpackedDataFolder}/${strRelativeDeployPath}/${strFlCoreNameProprietary}.ftl" ]];then
        echoc --info "strFlCoreNameProprietary='$strFlCoreNameProprietary' does not exist, ignoring it."
        strFlCoreNameProprietary=""
      fi
    fi
  fi
else
  echoc -p "invalid strFlCoreName=''"
  echoc --info "you must provide a model name to work with."
  echoc --info "It could be a new model name you create to be new thing in game or to replace some existing model."
  echoc --info "But it can also be the same name as the current path like '$(basename "$(pwd)")' or of some .ftl model here too."
  exit 1
fi
# automatic detection is unnecessarily complex..
#if [[ -n "$strFlCoreName" ]];then
  #strFlCoreNameProprietary="${1-}";shift&&:
  #if [[ -z "$strFlCoreNameProprietary" ]];then
    #strFlCoreNameProprietary="$(basename "$(pwd)")" #AUTOCFG
  #fi
#else
  #strFlBlendFound="$(find -iname "*.blend" -not -iregex ".*\(copy\|autosave\|quit\|copybuffer_material\).*")"&&:
  #declare -p strFlBlendFound #echo there may have more than one blender file
  #if [[ -f "$strFlBlendFound" ]];then
    #ls -l "$strFlBlendFound"
    #strFlCoreName="`basename "$strFlBlendFound"`"
    #if echoc -q "the above blender file was found, is this the new model name '$strFlCoreName'?";then
      #strFlCoreNameProprietary="$(basename "$(pwd)")" #AUTOCFG
    #fi
  #else
    #strFlCoreName="$(basename "$(pwd)")" #AUTOCFG
    #strFlCoreNameProprietary="${strFlCoreName}"
  #fi
#fi
export strFlCoreName
export strFlCoreNameProprietary
declare -p strFlCoreName strFlCoreNameProprietary

# Main code
if SECFUNCarrayCheck -n astrRemainingParams;then :;fi

# SECFUNCuniqueLock --waitbecomedaemon # if a daemon or to prevent simultaneously running it

#VALIDATE ALL PARAMS HERE
#if [[ -z "$strExample" ]];then echoc -p "invalid strExample='$strExample'";exit 1;fi

# List filler helper
#IFS=$'\n' read -d '' -r -a astrFlList < <(find)&&: #inside <() use any command that creates a list, one item per line

#COPY TO HERE: for simple scripts

function FUNCchkDep() { local lstrMsg="$1";shift;if ! SECFUNCexecA -ce "$@";then echoc --info "${lstrMsg} (may exit now)";return 1;fi; }
function FUNCchkVersion() { local lstrCmd="$1";shift;local lstrVersion="$1";shift;if [[ "`"$lstrCmd" --version |head -n 1`" != "$lstrVersion" ]];then echoc --info "WARN: '$lstrCmd' version is not '$lstrVersion' and may not work properly.";fi; }

#FUNCchkDep "install uchardet" which uchardet #no, results doesnt match geany
FUNCchkDep "install file" which file

FUNCchkDep "install moreutils" which sponge

FUNCchkDep "install python3" which python3;
FUNCchkVersion python3 "Python 3.10.12"

#if [[ -z "`(nvm --version)`" ]];then echoc -p "install arx-convert dependency: https://stackoverflow.com/a/76318697/1422630";exit 1;fi
FUNCchkDep "install nvm (to make it easy to install the arx-convert dependency correct version of node.js): https://stackoverflow.com/a/76318697/1422630 : curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash; bash; nvm install 18; nvm use 18; #obs.: to be able to use nvm, you need to run a new bash instance to let is update access to nvm on every terminal you need to use it" declare -p NVM_DIR
if ! bash -ci "nvm --version" |egrep -q "0\.39\.3";then FUNCchkVersion nvm "0.39.3";fi #nvm needs subshell with login to load the .bashrc file with it's configs and activate self, so this is a trick

FUNCchkDep "install arx-covert: npm i arx-convert -g" arx-convert --version
FUNCchkVersion arx-convert "arx-convert - version 7.1.0"

FUNCchkDep "install blender" blender --version&&: #skippable in case you have many blender versions and do not use a global one
FUNCchkVersion blender "Blender 3.6.4" #help this new version is important as the exported .obj .mtl may fail to be converted if from older blender versions

#function FUNCexecEcho() { echo;echo "EXEC: $@" >&2;"$@"; };export -f FUNCexecEcho
#function FUNCexecEcho() { echo;SECFUNCexecA -ce "$@" };export -f FUNCexecEcho
export strPathMain="`pwd`"

: ${fFaceTranspVal:=0} #help 1.6 works well for glass facetype 5
export fFaceTranspVal
: ${iFaceType:=1} #help glass would be 5
export iFaceType

astrJSONSectionList=(
  header #0
  vertices #1
  faces #2
  textureContainers #3
  groups #4
  actions #5
  selections #6
)
astrJSONSubsectionList=(
  origin #at header
  vector #at vertices
  faceType #at faces
  filename #at textureContainers
  name #at groups
  name #at actions
  name #at selections
)

function FUNCapplyTweaksFinalize() {
  echo ">>>>>>>>>>>>>>>>>>> finalize ugly json <<<<<<<<<<<<<<<"
  local lstrFlUgly="${strFlCoreName}.ftl.unpack.ugly"
  echo -n >"${lstrFlUgly}30final.json"; #clear/create
  local liTotTx
  : ${liTotTx:=1000} #helpf just a trick to blindly use all available
  
  echo '"faces":[' >"${lstrFlUgly}25faces.json"
  local li;for((li=0;li<liTotTx;li++));do
    if [[ ! -f "${lstrFlUgly}25faces.tx${li}.json" ]];then break;fi
    #cat "${lstrFlUgly}25faces.tx${li}.json" >>"${lstrFlUgly}25faces.json"
    cat "${lstrFlUgly}25faces.tx${li}.json" |tr -d '\n' |sed -r -e "s@}}],@}},@" >>"${lstrFlUgly}25faces.json" #this sed trick will grant the faces section will be properly closed by removing the existing closure '}}],' and recreating it at the end of the file, see below
  done
  sed ${strSedBkpOpt} -r -e 's@(.*)}},$@\1}}],@' "${lstrFlUgly}25faces.json" # recreates the faces section closure
  
  local li;for((li=1;li<=${#astrJSONSectionList[@]};li++));do
    strFlSect="${lstrFlUgly}25${astrJSONSectionList[li-1]}.json"
    cat "$strFlSect" |tr -d '\n' >>"${lstrFlUgly}30final.json";
  done
  
  ls -l "${lstrFlUgly}"* |egrep -v ".bkp$"
  cp -vf "${lstrFlUgly}30final.json" "${lstrFlUgly}.json"
  
  if ! SECFUNCexecA -ce python3 -m json.tool "${lstrFlUgly}.json" >"${strFlCoreName}.ftl.unpack.json";then #prettyfy
    ls -l "${lstrFlUgly}.json"
    exit 1
  fi
  ls -l "${strFlCoreName}.ftl.unpack.json"
};export -f FUNCapplyTweaksFinalize
function FUNCapplyTweaks() { #helpf
  #local lbFinalize=true;if [[ "$1" == --nofinalize ]];then lbFinalize=false;shift;fi #useful to multithread process many textures at once
  #echo "PARAMS: '$1' '$2' '$3' '$4'"
  echo "PARAMS: '$1' '$2' '$3'"
  #local lstrModel="$1";shift #h elpf basename w/o .ftl
  #local lstrTexture="$1";shift #helpf filename to become transparent
  local liTxIndex="$1";shift #helpf index of the texture container
  local lfFaceTranspVal="$1";shift #helpf transparent value to set
  local liFaceType="$1";shift #helpf face type value from POLY_ bool combinations
  #declare -p lstrModel lstrTexture lfFaceTranspVal liFaceType
  #declare -p lstrTexture lfFaceTranspVal liFaceType
  declare -p liTxIndex lfFaceTranspVal liFaceType
  
  #clear;
  #cd "${strFlCoreName}"_OBJToFTL;
  
  local lstrFlUgly="${strFlCoreName}.ftl.unpack.ugly"
  
  #local lastrSections=(
    #header #0
    #vertices #1
    #faces #2
    #textureContainers #3
    #groups #4
    #actions #5
    #selections #6
  #)
  #local lastrSubsection=(
    #origin #at header
    #vector #at vertices
    #faceType #at faces
    #filename #at textureContainers
    #name #at groups
    #name #at actions
    #name #at selections
  #)
  
  if [[ "${lstrFlUgly}.json" -nt "${lstrFlUgly}25textureContainers.json" ]];then  # SPLITTER: a face w/o texture just wont be rendered, so texture is required. btw, any vars inside here must not be required outside
    local lstrSectionsRegex="`echo "${astrJSONSectionList[@]:1}" |tr ' ' '|'`" #the first "header" will already stay on the 1st line!
    cat "${lstrFlUgly}.json" |sed -r -e 's@"('"${lstrSectionsRegex}"')"@\n"\1"@g' >"${lstrFlUgly}20splitInLines.json"; #each section will be in one line here
    cat "${lstrFlUgly}20splitInLines.json" |head -n $((i+1)) |tail -n 1 |head -c 25 |tr -d '\n';echo; #TODO auto check beggining if my sed regex worked
    local li;for((li=0;li<${#astrJSONSectionList[@]};li++));do
      local lstrFlSect="${lstrFlUgly}25${astrJSONSectionList[li]}.json"
      local lstrSubsect="${astrJSONSubsectionList[li]}"
      echo ">>>>>>>>>>>>>>>> PREPARING: SECTION=$lstrFlSect, SUB=$lstrSubsect li=$li <<<<<<<<<<<<<<<<"
      head -n $((li+1)) "${lstrFlUgly}20splitInLines.json" |tail -n 1 >"$lstrFlSect"
      SECFUNCexecA -ce sed ${strSedBkpOpt} -r 's@[{]"('"${lstrSubsect}"')"@\n{"\1"@g' "$lstrFlSect" #one per line
      #cat "$lstrFlSect"
      wc -l "$lstrFlSect"
    done
  fi
  
  echo ">>>>>>>>>>>>>>>>>>> WORKWITH:faces <<<<<<<<<<<<<<<<<<<<"
  local liTotTx="`egrep "filename" "${lstrFlUgly}25textureContainers.json" |wc -l`"
  local li;for((li=0;li<liTotTx;li++));do # SPLITTER
    #egrep '"faceType":[0-9]*,.*"textureIdx":'"$li"',.*"transval":[0-9.]*,' "${lstrFlUgly}25faces.json"
    if [[ "${lstrFlUgly}.json" -nt "${lstrFlUgly}25faces.tx${li}.json" ]];then
      egrep "\"textureIdx\":$li," "${lstrFlUgly}25faces.json" >"${lstrFlUgly}25faces.tx${li}.json"
    fi
  done
  #local liTxIndex="`egrep "filename" "${lstrFlUgly}25textureContainers.json" |egrep "$lstrTexture" -in |sed -r 's@^([0-9]*):.*@\1@'`";((liTxIndex--))&&: # get requested texture index
  #declare -p liTxIndex
  function FUNCreport(){
    egrep '"textureIdx":'"${liTxIndex}," "${lstrFlUgly}25faces.json" |head -n 3
    egrep '"textureIdx":'"${liTxIndex}," "${lstrFlUgly}25faces.json" |wc -l
  }
  FUNCreport
  #SECFUNCexecA -ce sed ${strSedBkpOpt} -r 's@("faceType":)([0-9]*)(,.*"textureIdx":'"$liTxIndex"',.*"transval":)[0-9.]*(,)@\1'"${liFaceType}"'\3'"${lfFaceTranspVal}"'\4@' "${lstrFlUgly}25faces.json" #patches the whole faces file
  SECFUNCexecA -ce sed ${strSedBkpOpt} -r 's@("faceType":)([0-9]*)(,.*"textureIdx":'"$liTxIndex"',.*"transval":)[0-9.]*(,)@\1'"${liFaceType}"'\3'"${lfFaceTranspVal}"'\4@' "${lstrFlUgly}25faces.tx${liTxIndex}.json" #patches each texture subset extracted from the bloated faces file
  SECFUNCtrash "${liTxIndex}.${strMTSuffix}"
  FUNCreport
  
  local lbFUNCapplyTweaks_FinalizeJSONFile;: ${lbFUNCapplyTweaks_FinalizeJSONFile:=true} #helpf
  if $lbFUNCapplyTweaks_FinalizeJSONFile;then
    FUNCapplyTweaksFinalize
  fi
};export -f FUNCapplyTweaks

: ${bJustApplyTweaks:=false} #help params for this will be directly passed to FUNCapplyTweaks, and just after running it the .ftl will be generated!
if $bJustApplyTweaks;then
  cd "${strFlCoreName}_OBJToFTL"
  FUNCapplyTweaks "$@"
  SECFUNCexecA -ce arx-convert "${strFlCoreName}.ftl.unpack.json" --from=json --to=ftl --output="${strFlCoreName}.ftl"
  ls -l "${strFlCoreName}.ftl"
  exit 0
fi

if $bDaemon;then
  bSpeak=true
  bProccessNow=false
  while true;do
    ls -l "${strFlWFObj}" "${strFlWFMtl}" "${strPathObjToFtl}/${strFlCoreName}.ftl" &&:
    #TODO grant files are not modified before starting processing them #strKey="$(sha1sum "${strFlWFObj}" "${strFlWFMtl}" "${strPathObjToFtl}/${strFlCoreName}.ftl")"&&:;echo "${strKey-}"
    if [[ "${strFlWFObj}" -nt "${strPathObjToFtl}/${strFlCoreName}.ftl" ]];then
      bProccessNow=true
    fi
    if ! $bProccessNow && [[ "${strFlWFMtl}" -nt "${strPathObjToFtl}/${strFlCoreName}.ftl" ]];then
      if echoc -t 3 -q "did you update '$strFlWFMtl' manually? if so, convert obj to ftl now? (beware tho, configs from blender exported in the .mtl will override your changes)";then
        bProccessNow=true
      fi
    fi
    if $bProccessNow;then
      if $bSpeak;then echoc --say "${strFlCoreName} modified";fi
      if ! "${strSelf}" "$strFlCoreName";then
        echoc -p "errored above"
        if $bSpeak;then echoc --say "${strFlCoreName} failed";fi
        if echoc -q "failed, try cleaning the cache? (but may be a bug in this script...)";then
          SECFUNCtrash "${strPathObjToFtl}/"*".json"
          echoc --info "please run this script again, if the problem persists, create a bug report."
        fi
      fi
    fi
    
    if echoc -t 3 -q "checking for changes, force once now?";then
      bProccessNow=true;
    else
      bProccessNow=false
    fi
  done
  exit
fi

FUNCchkDep "install ${strAppTextEditor}" which "${strAppTextEditor}"

: ${strFlChkArxData:="${strArxUnpackedDataFolder}/game/graph/obj3d/interactive/items/weapons/bone_weap/bone_weap.ftl"} #help
if [[ ! -f "$strFlChkArxData" ]];then
  if ! echoc -t $fPromptTm -q "strArxUnpackedDataFolder='$strArxUnpackedDataFolder' doesnt seems valid. btw strFlChkArxData='$strFlChkArxData'. Continue anyway?@Dy";then exit 1;fi
fi

FUNCchkDep "install https://github.com/fredlllll/ArxLibertatisFTLConverter/releases" ls -l  "$strPathTools/ArxLibertatisFTLConverter"
#if ! FUNCchkDep "install https://github.com/fredlllll/ArxLibertatisFTLConverter/releases" ls -l  "$strPathTools/ArxLibertatisFTLConverter";then
  #if ! FUNCchkDep "install https://github.com/fredlllll/ArxLibertatisFTLConverter/releases" ls -l  "./ArxLibertatisFTLConverter";then
    #exit 1
  #fi
#fi

SECFUNCexecA -ce mkdir -vp "${strPathObjToFtl}"
SECFUNCexecA -ce mkdir -vp "${strPathFtlToObj}"

export strGeanyWorkaround="you may need to 'menu:file/reload' on geany"

function FUNCprepareProprietaryModelAsJSON() { #helpf to help on fixing the new model with extra/missing data
  cd "$strPathMain"
  if [[ -z "$strFlCoreNameProprietary" ]];then return 0;fi
  strFlPrettyJSon="${strFlCoreNameProprietary}.proprietary.ftl.unpack.json"
  if [[ ! -f "${strFlPrettyJSon}" ]];then
    echoc --info "preparing the json of the proprietary/reference .ftl file"
    cp -vf "${strArxUnpackedDataFolder}/${strRelativeDeployPath}/${strFlCoreNameProprietary}.ftl" "./${strFlCoreNameProprietary}.proprietary.ftl"&&:
    if [[ -f "./${strFlCoreNameProprietary}.proprietary.ftl" ]];then
      SECFUNCexecA -ce ./unpackFtl.simpleCmdLine.sh "${strFlCoreNameProprietary}.proprietary.ftl"
      SECFUNCexecA -ce arx-convert "${strFlCoreNameProprietary}.proprietary.ftl.unpack" --from=ftl --to=json --output="${strFlCoreNameProprietary}.proprietary.ftl.unpack.ugly.json"
      SECFUNCexecA -ce python3 -m json.tool "${strFlCoreNameProprietary}.proprietary.ftl.unpack.ugly.json" >"${strFlPrettyJSon}"
    else
      if ! echoc -t $fPromptTm -q "the proprietary asset reference for '${strFlCoreNameProprietary}.ftl' does not exist, continue anyway?@Dy";then exit 1;fi
    fi
  fi
  if [[ -f "${strFlPrettyJSon}" ]];then
    if $bShowTextFiles;then 
      SECFUNCexecA -ce -m "${strGeanyWorkaround}" --child "$strAppTextEditor" "${strFlPrettyJSon}";
    fi
  fi
}
FUNCprepareProprietaryModelAsJSON
#if [[ ! -f "${strFlCoreNameProprietary}.ftl" ]];then 
  ##SECFUNCexecA -ce "${strSelf}" --help
  #SECFUNCexecA -ce ls -l *.ftl&&:
  #if ! echoc -t $fPromptTm -q "can't find proprietary/reference .ftl file: '${strFlCoreNameProprietary}.ftl'. You may need to suply one param ex. if the above file is bottle_water.ftl, run as: \`$0 bottle_water\`, continue anyway?@Dy";then
    #exit 1;
  #fi
#fi

#if ! [[ "`pwd`" =~ .*${strDeveloperWorkingPath}.* ]];then
strRPCurrent="`realpath "pwd"`"
strRPWork="`realpath "${strDeveloperWorkingPath}"`"
declare -p strRPCurrent strRPWork
if ! [[ "${strRPCurrent}" =~ ^${strRPWork}.* ]];then
  pwd
  if ! echoc -q "the current path above is not child of this top working directory strDeveloperWorkingPath='${strDeveloperWorkingPath}', you should create it like \`mkdir -vp '$strDeveloperWorkingPath'\` or reconfigure it, continue anyway?";then exit 1;fi
fi

function FUNCfixTextureAccess() {
  cd "$strPathMain"
  strFlTX="`find "${strPathFtlToObj}/" -iregex ".*[.]\(bmp\|jpg\|png\)"`"&&:
  declare -p strFlTX strPathFtlToObj
  if [[ -f "$strFlTX" ]];then
    strFixFlTx="`echo "$strFlTX" |sed 's@\\\\@/@g'`"
    strPathTX="`dirname "${strFixFlTx}"`"
    SECFUNCexecA -ce mkdir -vp "$strPathTX"
    strFlOk="$strPathTX/`basename "$strFixFlTx"`"
    SECFUNCexecA -ce cp -vT "$strFlTX" "${strFlOk}"
    SECFUNCexecA -ce ls -l "$strFlTX" "${strFlOk}"
  fi
}
(SECFUNCexecA -ce FUNCfixTextureAccess)

: ${bFtlToObj:=false} #help
if $bFtlToObj;then #FTL TO OBJ ###################################################################
  cd "$strPathMain"
  
  #SECFUNCexecA -ce mkdir -vp "${strFlCoreName}_OBJToFTL"

  export WINEPREFIX="$HOME/Wine/ArxFatalis.64bits";
  strFl="`realpath "${strFlCoreName}.ftl"`"
  if [[ -f "${strPathFtlToObj}/${strFlCoreName}.obj" ]];then
    ls -l --color "${strPathFtlToObj}"
  else
    (
      cd "$strPathTools"; #must be run from where it is installed to find required deps: ArxLibertatisFTLConverter.pdb libArxIO.so.0
      pwd
      SECFUNCexecA -ce ./ArxLibertatisFTLConverter "$strFl"
    )
  fi

  # the texture may not be found and then it will create a text file instead...
  #export strPathArxData="`pwd |sed -r "s@(.*/${strArxUnpackedDataFolderBasename})/.*@\1@"`"
  cd "${strPathFtlToObj}"
  function FUNClnTexture() {
    local lstrFlIn="$1"
    
    if ! egrep "could not find texture" "$lstrFlIn";then return 0;fi #otherwise is just a text file and not a image
    
    declare -p lstrFlIn
    export lstrFlIn
    
    local lstrFl="`echo "$lstrFlIn" |tr '\\\\' '/' |tr '[:upper:]' '[:lower:]'`"
    declare -p lstrFl
    
    local lstrFlTXCoreNm="`basename "$lstrFl"`"
    lstrFlTXCoreNm="${lstrFlTXCoreNm%.[Bb][Mm][Pp]}"
    lstrFlTXCoreNm="${lstrFlTXCoreNm%.[Jj][Pp][Gg]}"
    lstrFlTXCoreNm="${lstrFlTXCoreNm%.[Pp][Nn][Gg]}"
    
    local lstrFlTXCoreNmSafeRegex="`echo "${lstrFlTXCoreNm}" |sed -r 's@.@[&]@g'`"
    
    function FUNClnTexture2() {
      if $bDoBkpEverything;then
        SECFUNCexecA -ce mv -v "$lstrFlIn" "${lstrFlIn}.`date +%Y_%m_%d-%H_%M_%S_%N`.bkp"
      fi
      SECFUNCexecA -ce ln -vsT "$1" "$lstrFlIn"
      SECFUNCexecA -ce ls -l "$1"
    };export -f FUNClnTexture2
    
    local lstrPathRelative="`dirname "$lstrFl"`"
    SECFUNCexecA -ce find "`basename "${strArxUnpackedDataFolder}"`/${lstrPathRelative}/" -iname "${lstrFlTXCoreNmSafeRegex}.*" -exec bash -c "FUNClnTexture2 '{}'" \;
  };export -f FUNClnTexture
  SECFUNCexecA -ce find -type f -iregex ".*[.]\(bmp\|jpg\|png\)" -exec bash -c "FUNClnTexture '{}'" \; &&:
  (SECFUNCexecA -ce FUNCfixTextureAccess)
  
  if echoc -t $fPromptTm -q "prepare json of this proprietary/reference file too? it will help you fix the final JSON@Dy";then
    FUNCprepareProprietaryModelAsJSON
  fi
else #OBJ TO FTL ###################################################################
  #MAIN
  cd "$strPathMain"
  
  SECFUNCexecA -ce mkdir -vp "$strPathObjToFtl"

  while ! SECFUNCexecA -ce ls -l "${strFlWFObj}";do
    echoc -wp "file strFlWFObj='${strFlWFObj}' is missing, may be you need to export it from blender? or may be it is not the correct filename strFlCoreName='$strFlCoreName' that should be passed as a param to this script. Btw, work with the .blend file at '$strBlenderSafePath'."
  done

  if $bDoBkpEverything;then
    cp -v "${strFlWFMtl}" "${strFlWFMtl}.bkp_`date +%Y_%m_%d-%H_%M_%S_%N`"
  fi

  #strNewMTL="`grep "newmtl" "${strFlWFMtl}" |sed -r -e 's@newmtl @@'`" # -e 's@[\]@\\\\@g'`"
  #declare -p strNewMTL
  #if((`echo "$strNewMTL" |wc -l`==1));then
    #declare -p strNewMTL
    #if ! [[ "$strNewMTL" =~ ^${strTexturesPath} ]];then 
      #echo "strNewMTL='$strNewMTL' seems wrong, should be at '$strTexturesPath'" >&2;
      #read -n 1 -p "hit ctrl+c to fix, any other key to continue.."
    #fi
    #strNewMTL="`echo "$strNewMTL" |sed -r -e 's@[\]@\\\\\\\\@g'`"
    #declare -p strNewMTL
    #SECFUNCexecA -ce sed ${strSedBkpOpt} -r "s@map_Kd .*@map_Kd ${strNewMTL}@" "${strFlWFMtl}" #will fix the .mtl
    #SECFUNCexecA -ce egrep "map_Kd" "${strFlWFMtl}"
  #else
  
  SECFUNCexecA -ce cat "${strFlWFMtl}"
  
  #bIsTxPathFixed=false
  #if egrep "map_Kd ${strTXPathRelative}" -i "${strFlWFMtl}";then bIsTxPathFixed=true;fi
  #bCanAutoFixTxPath=false;
  #if egrep "map_Kd .*${strTXPathRelative}" -i "${strFlWFMtl}";then bCanAutoFixTxPath=true;fi
  #declare -p bCanAutoFixTxPath 
  #bIsTxPathFixed
  
  #if ! egrep "newmtl .*sM=.*sFT=" -i "${strFlWFMtl}";then 
    #echoc --info 'yoy need to name a material in blender like this, to let that cfg be auto applied after exporting it to wavefront .obj .mtl: sM=Glass;sFT="POLY_NO_SHADOW|POLY_WATER";fTr=1.85; #obs.: sFT can be just a number too if the readable dont fit there'
    #exit 1
  #fi

  function FUNCchkAndSetFaceType() {
    if [[ -n "${strFaceTypeOpt-}" ]];then
      declare -p FUNCNAME strFaceTypeOpt iFaceTypeOpt&&:
      local liFaceTypeOptNew
      #eval "liFaceTypeOptNew=\$(($strFaceTypeOpt))";
      eval 'liFaceTypeOptNew=$(('"$strFaceTypeOpt"'))'
      if((${iFaceTypeOpt--1}!=liFaceTypeOptNew));then  #-1 is invalid
        iFaceTypeOpt=$liFaceTypeOptNew
        declare -p liFaceTypeOptNew
        return 0
      fi
    fi
    return 1
  }
  
  function FUNCtxNmRegex() { strTxNmRegex="`echo "$strTxNm" |sed -r 's@.@[&]@g'`"; declare -p strTxNmRegex; } 
  
  #function FUNCclearMaterialVars() { 
    #unset sM sFT fTr;
    #unset strTxNm strMaterialId fFaceTranspValOpt; 
    #unset iFaceTypeOpt strFaceTypeOpt strDescription;
    ## do not unset iTextureContainerIndex tho!
  #}
  
  declare -A astrAutoCfgList
  #if $bCanAutoFixTxPath && 
  echoc -w -t $fPromptTm "collecting blender material cfg (everything you properly configure in the blender material name will override cfgs from this script config file for each model. material name in blender ex.: sM=Glass;sFT=\"WATER|TRANS\";fTr=1.85; These are the POLY_... bit options. So, copy this there and just adjust the values if you need. sFT can be just a number too if the readable dont fit there. fTr is optional, will default to 0)"
  sed ${strSedBkpOpt} -r -e 's@\\@/@g' "${strFlWFMtl}" #before checking for strTXPathRelative. do not use windows folder separator to avoid too much complexity, only the final result must have it!
  if egrep "map_Kd .*${strTXPathRelative}" -i "${strFlWFMtl}";then
    # preview
    astrCmdAutoFixParams=(-r -e "s@map_Kd .*${strTXPathRelative}/(.*)@map_Kd ${strTXPathRelative}/\1@i" -e 's@/@\\@gi' "${strFlWFMtl}")
    SECFUNCexecA -ce sed "${astrCmdAutoFixParams[@]}"
    #strResp=""
    #if $bCanAutoFixTxPath;then
      #read -n 1 -p "fix the above manually (if not, will apply the above auto patch) (y/...)?" strResp;
    #fi
    #if ! ${bCanAutoFixTxPath} || [[ "${strResp}" == y ]];then
    ##read -n 1 -p "press a key to fix '${strFlWFMtl}' file manually"
      #SECFUNCexecA -ce -m "${strGeanyWorkaround}" --child geany "${strFlWFMtl}"
      #echoc -w
    #else
      #SECFUNCexecA -ce sed ${strSedBkpOpt} "${astrCmdAutoFixParams[@]}"
    #fi
    if echoc -t $fPromptTm -q "are the above relative texture paths correct (only map_Kd matters for now tho)? (if not will open a text editor)@Dy";then
      SECFUNCexecA -ce sed ${strSedBkpOpt} "${astrCmdAutoFixParams[@]}"
    else
      SECFUNCexecA -ce -m "${strGeanyWorkaround}" --child "$strAppTextEditor" "${strFlWFMtl}"
      echoc -w
    fi
  fi
  #IFS=$'\n' read -d '' -r -a astrAutoCfgTmpList < <(egrep "newmtl|map_Kd" "${strFlWFMtl}" |sed -r -e "s@newmtl (.*)@strCfgLn='\1';@" -e "s@map_Kd (.*)@strTxNm='\1';@" |tr -d "\n" |sed -r -e 's@strCfgLn.*@\n&@')&&:
  IFS=$'\n' read -d '' -r -a astrAutoCfgTmpList < <( \
    egrep "newmtl|map_Kd" "${strFlWFMtl}" \
      |sed -r \
        -e 's@\\@/@g' \
        -e "s@map_Kd (.*)@;strTxNm='\1';_TOKEN_ADDNEWLINE_@i" \
        -e 's@;;@;@g' \
        -e "s@newmtl (.*)@\1@" \
      |tr -d '\n' \
      |sed -r -e 's@_TOKEN_ADDNEWLINE_@\n@g' \
  )&&:
  SECFUNCarrayShow -v astrAutoCfgTmpList
  #sed -i -r -e 's@\\@/@g' "${strFlWFMtl}" #undo windows folder separator to avoid overcomplexity
  iTextureContainerIndex=-1
  bErrorCfgMissing=false
  for strAutoCfg in "${astrAutoCfgTmpList[@]}";do
    ((iTextureContainerIndex++))&&:
    declare -p strAutoCfg
    if ! [[ "$strAutoCfg" =~ ^sM=.*sFT= ]];then echo "SKIP, no valid cfg found above";bErrorCfgMissing=true;continue;fi
    #if ! echo "$strAutoCfg" |egrep "newmtl sM=.*sFT=";then echo "SKIP, no valid cfg found";continue;fi
    #newmtl sM=Bottle;sFT="POLY_NO_SHADOW|POLY_TRANS";fTr=0.95;
    eval "$strAutoCfg"
    declare -p sM sFT strTxNm #required
    declare -p fTr&&: #optional
    if [[ -z "${sM-}" ]];then echo "SKIP, no valid sM (strMaterialId) found above";bErrorCfgMissing=true;continue;fi
    ##strTxNm="`basename "$strTxNm"`" #astrCmdAutoFixParams=(-r -e "s@map_Kd .*${strTXPathRelative}/(.*)@map_Kd ${strTXPathRelative}/\1@i" -e 's@/@\\@gi' "${strFlWFMtl}")
    #strTxNm="$(echo "$strTxNm" |sed -r -e "s@.*${strTXPathRelative}/(.*)@\1@")" #inside strTXPathRelative path, there may exist a subpath and it shall be part of the texture name
    ##strLTxNm="`echo "$strTxNm" |tr '[:upper:]' '[:lower:]'`" #strLTxNm="`echo "$strTxNm" |sed -r 's@.*/([^/]*)@\1@'`"
    strMaterialId="$sM"
    #astrAutoCfgList["${sM}"]="iTextureContainerIndex=$iTextureContainerIndex; strTxNm='$strTxNm'; strMaterialId='$strMaterialId'; strFaceTypeOpt='${sFT}'; ${fTr+fFaceTranspValOpt='${fTr}';}"
    if ! [[ "${fTr-0}" =~ ^[0-9.]*$ ]];then #TODO RM this check, unnecessary now
      echoc -p "invalid fTr='$fTr', did you add a ';' at the end of the material name? (it is the last var and shall have a separator before strTxNm that will be appended here)"
      exit 1
    fi
    if [[ "$sFT" =~ ^[a-zA-Z] ]];then
      if ! [[ "$sFT" =~ POLY_ ]];then #add POLY_ to all parts to let it calc
        sFT="$(echo "$sFT" |tr "|" "\n" |sed -r -e 's@.*@POLY_&|@' |tr -d "\n")0" #final 0 is to complete the a|b|c| as a|b|c|0 to let it calc
        declare -p sFT
      fi
    fi
    astrAutoCfgList["${strMaterialId}"]="iTextureContainerIndex=$iTextureContainerIndex; strTxNm='$strTxNm'; strMaterialId='$strMaterialId'; strFaceTypeOpt='${sFT}'; iFaceTypeOpt=$(($sFT)); fFaceTranspValOpt=${fTr-0};"
    echoc --info "BlenderAutoCfg[$strMaterialId]=${astrAutoCfgList[${strMaterialId}]}"
    #FUNCclearMaterialVars #cleanup to not mess next
    #cleanup to not mess next
    unset sM sFT fTr;
    unset strTxNm strMaterialId strFaceTypeOpt iFaceTypeOpt fFaceTranspValOpt; 
    # do not unset iTextureContainerIndex tho as it is being calculated here!
  done
  SECFUNCarrayShow -v astrAutoCfgList
  if $bErrorCfgMissing;then
    echoc -p 'yoy need to name a material in blender like this, to let that cfg be auto applied after exporting it to wavefront .obj .mtl: sM=Glass;sFT="POLY_NO_SHADOW|POLY_WATER";fTr=1.85; #obs.: sFT can be just a number too (see --facetype option here) if the readable dont fit there'
    exit 1
  fi
  
  ##if $bCanAutoFixTxPath;then
  #if egrep "map_Kd .*${strTXPathRelative}" -i "${strFlWFMtl}";then
    ## preview
    #astrCmdAutoFixParams=(-r -e "s@map_Kd .*${strTXPathRelative}/(.*)@map_Kd ${strTXPathRelative}/\1@i" -e 's@/@\\@gi' "${strFlWFMtl}")
    #SECFUNCexecA -ce sed "${astrCmdAutoFixParams[@]}"
    
    ##strResp=""
    ##if $bCanAutoFixTxPath;then
      ##read -n 1 -p "fix the above manually (if not, will apply the above auto patch) (y/...)?" strResp;
    ##fi
    ##if ! ${bCanAutoFixTxPath} || [[ "${strResp}" == y ]];then
    ###read -n 1 -p "press a key to fix '${strFlWFMtl}' file manually"
      ##SECFUNCexecA -ce -m "${strGeanyWorkaround}" --child geany "${strFlWFMtl}"
      ##echoc -w
    ##else
      ##SECFUNCexecA -ce sed ${strSedBkpOpt} "${astrCmdAutoFixParams[@]}"
    ##fi
    #if echoc -t $fPromptTm -q "are the above relative texture path correct? (if not will open a text editor)@Dy";then
      #SECFUNCexecA -ce sed ${strSedBkpOpt} "${astrCmdAutoFixParams[@]}"
    #else
      #SECFUNCexecA -ce -m "${strGeanyWorkaround}" --child "$strAppTextEditor" "${strFlWFMtl}"
      #echoc -w
    #fi
  #fi
  ##fi

  (
    SECFUNCexecA -ce cd "$strPathTools"; #must be run from where it is installed to find required deps: ArxLibertatisFTLConverter.pdb libArxIO.so.0
    SECFUNCexecA -ce ./ArxLibertatisFTLConverter "$strFlWFObj"
  )
  SECFUNCexecA -ce pwd

  ls -l "${strFlCoreName}_FTLToOBJ"&&:

  SECFUNCexecA -ce ls -l "${strPathObjToFtl}/${strFlCoreName}.ftl"

  #strLnHint="${strFlCoreName}.ftl.HIGH_POLY_LOCATION_HINT"
  #declare -p strLnHint
  #SECFUNCexecA -ce ln -vsfT "${strPathObjToFtl}/${strFlCoreName}.ftl" "${strLnHint}" #so you will know where it is
  #SECFUNCexecA -ce ls -l "${strLnHint}"

  strPathDeploy="${strPathDeployAtModInstallFolder}/${strRelativeDeployPath}/"
  declare -p strPathDeploy
  SECFUNCexecA -ce find "${strPathDeployAtModInstallFolder}/" -type d -perm -u-w -exec chmod -v u+w '{}' \;
  SECFUNCexecA -ce mkdir -vp "$strPathDeploy"
  if [[ -f "${strPathDeploy}/${strFlCoreName}.ftl" ]];then SECFUNCexecA -ce chmod -v u+w "${strPathDeploy}/${strFlCoreName}.ftl";fi
  
  if echoc -t $fPromptTm -q "prepare json file? (it will convert from ftl to json to fix the origin (hit spot) and let you manually fix it too)@Dy";then
    FUNCprepareProprietaryModelAsJSON
    
    cd "${strPathObjToFtl}"
    #guess the offset brute force: for((i=1;i<9955;i++));do echo $i;if explode skull.ftl --offset=$i --output=skull.ftl.unpacked;then break;fi;done #result=2549
    #this command is broken, try to import the ftl on blender and it will generate the unpack file: explode skull.ftl --offset=2549 --output=skull.ftl.unpacked --verbose
    SECFUNCexecA -ce ../unpackFtl.simpleCmdLine.sh "${strFlCoreName}.ftl"&&:
    while [[ ! -f "${strFlCoreName}.ftl.unpack" ]] || [[ "${strFlCoreName}.ftl" -nt "${strFlCoreName}.ftl.unpack" ]];do 
      ls -l "${strFlCoreName}.ftl" "${strFlCoreName}.ftl.unpack"&&:;
      echoc -p "try to import this .ftl on blender, even if it fails, the .unpack file will be created!"
      if echoc -q "strFlUnpack='${strFlCoreName}.ftl.unpack' not found or ftl is newer than ftl.unpack file. Continue anyway?";then break;fi
    done
    SECFUNCexecA -ce arx-convert "${strFlCoreName}.ftl.unpack" --from=ftl --to=json --output="${strFlCoreName}.ftl.unpack.ugly.json"
    SECFUNCexecA -ce python3 -m json.tool "${strFlCoreName}.ftl.unpack.ugly.json" >"${strFlCoreName}.ftl.unpack.json"
    
    # find a good lowest vertext to be the origin TODO: find the center one
    tabs -8
    #strVectorsY="`cat "${strFlCoreName}.ftl.unpack.json" |egrep 'vector|"y"' |egrep 'vector' -A 1 |egrep -v "[-][-]" |tr -d '"{:,' |tr -d '\n' |sed 's@vector@\nvector@g' |egrep -vn "^ *$" |sed -r 's@ +@ @g' |sort -n -k3`"
    strVectorsY="`cat "${strFlCoreName}.ftl.unpack.json" |egrep 'vector|"y"|"x"|"z"' |egrep 'vector' -A 3 |egrep -v "[-][-]" |tr -d '"{:,' |tr -d '\n' |sed 's@vector@\nvector@g' |egrep -v "^ *$" |egrep -vn "^ *$" |sed -r 's@ +@\t@g' |sort -n -k5`" # "^ *$" is to clean the top empty line created by 's@vector@\nvector@g'
    echo "$strVectorsY"
    iOriginVectorIndex="`echo "$strVectorsY" |tail -n 1 |cut -d: -f1`"
    declare -p iOriginVectorIndex
    iOriginVectorIndex=$((iOriginVectorIndex-1))&&:
    declare -p iOriginVectorIndex
    if iOriginVectorIndex="$(echoc -t $fPromptTm -S "set iOriginVectorIndex='$iOriginVectorIndex'? You can also chose one from the above list (then, as this is a index, subtract 1 from it) if this one is not good, it must be the vertex that will hit the ground when dragging the object in-game, so usually the lowest one from the model@D${iOriginVectorIndex}")";then
      SECFUNCexecA -ce egrep '"origin":' "${strFlCoreName}.ftl.unpack.json"
      SECFUNCexecA -ce sed ${strSedBkpOpt} -r 's@(.*"origin": *)[0-9]*(,.*)@\1'"$iOriginVectorIndex"'\2@' "${strFlCoreName}.ftl.unpack.json" "${strFlCoreName}.ftl.unpack.ugly.json"
    fi
    
    echo '
      "actions": [
          {
              "name": "HIT_10",
              "vertexIdx": 1,
              "action": 0,
              "sfx": 0
          },
          {
              "name": "HIT_10",
              "vertexIdx": 2,
              "action": 0,
              "sfx": 0
          },
          {
              "name": "PRIMARY_ATTACH",
              "vertexIdx": 0,
              "action": 0,
              "sfx": 0
          }
      ],
    '
    echoc --info "MELEE WEAPONS:"
    echo 'Look at the above "actions", they are required for melee weapons: 
    Melee weapons need a section like that. 
    See the vertexIdx? it should be the vertex index you can see in blender:
      enable menu/edit/preferences/interface/developerExtras
      enable menu/edit/preferences/experimental/assetIndexing
      enable overlays(the 2 circles icon)/developer/indices
    Now, look at these empty plainAxes and Speres: PRIMARY_ATTACH HIT_10 (or HIT_15 etc).
    They are placed inside the weapon mesh, in some vertex that is part of a tiny face with a few vertexes nearby.
    Use some zoom/magnifier OS tool (like xzoom on linux, click on its window and draw outside to let it work) to see the tiny index in blue color if you need.
    You have to set the correct vertexIdx matching the empties.
    Obs.:TODO:TEST/TRY: if it is not the index from blender, you can find out their index by creating a tiny triangle there and setting that face to a dummy texture named like HIT_10.png. When exporting to wavefront obj, and then to ftl, the HIT_10 faces for that texture HIT_10.png, will have the corresponding axes you can choose from. WIP:TODO: compare with blender vertex index.
    '

    echoc --info "GROUPS: for now copy the '\"groups\": [' section from the vanilla ftl (if it is filled there) that was converted to json, and set origin to the same origin from header section"
    
    bUpdatedCfg=false
    
    SECFUNCarrayShow -v astrAutoCfgList
    if echoc -t $fPromptTm -q "Apply all material cfgs now?@Dy";then
      : ${bMultiThreadFaceTxProccess:=false} #help
      if $bMultiThreadFaceTxProccess;then echo "$$" >"${strFlCoreName}.${strMTSuffix}";fi
      for strLnCmd in "${astrAutoCfgList[@]}";do
        eval "$strLnCmd"
        SECFUNCdrawLine --left "EXEC CFG Line" # for '$strTxNm'"
        echoc --info "TEXTURE: $strTxNm"
        declare -p strLnCmd iFaceTypeOpt
        export acmdMultiThread=(FUNCapplyTweaks "$iTextureContainerIndex" "$fFaceTranspValOpt" "$iFaceTypeOpt")
        if $bMultiThreadFaceTxProccess;then
          export lbFUNCapplyTweaks_FinalizeJSONFile=false;
          SECFUNCarraysExport #for acmdMultiThread 
          echo "$$" >"${iTextureContainerIndex}.${strMTSuffix}" #the tweak func will remove this thread lock file
          (SECFUNCexecA -ce xterm -e bash -c "SECFUNCarraysRestore;${acmdMultiThread[@]};echoc -w -t 60"&disown)
        else
          SECFUNCexecA -ce "${acmdMultiThread[@]}"
        fi
      done
      if $bMultiThreadFaceTxProccess;then trash "${strFlCoreName}.${strMTSuffix}";fi
      while ls -l *".${strMTSuffix}";do echoc -t 1 -w "waiting all threads finalize, hit a key to check now";done
      FUNCapplyTweaksFinalize
    fi
    
    declare -p bShowTextFiles bDaemon
    if $bShowTextFiles;then 
      declare -p LINENO
      SECFUNCexecA -ce -m "${strGeanyWorkaround}" --child "$strAppTextEditor" "${strFlCoreName}.ftl.unpack.json";
    fi
    
    if echoc -t $fPromptTm -q "apply the changes to json creating a new ftl file?@Dy";then
      if $bDoBkpEverything;then
        SECFUNCexecA -ce mv -vT "${strFlCoreName}.ftl" "${strFlCoreName}.ftl.`date +%Y_%m_%d-%H_%M_%S_%N`.bkp"
      fi
      SECFUNCexecA -ce arx-convert "${strFlCoreName}.ftl.unpack.json" --from=json --to=ftl --output="${strFlCoreName}.ftl"
    fi
  fi
  
  echoc --info "deploying at mod folder"
  cd "$strPathMain"
  while ! SECFUNCexecA -ce cp -vf "${strPathObjToFtl}/${strFlCoreName}.ftl" "$strPathDeploy";do echoc -w "deploy failed, hit a key to retry";done
  SECFUNCexecA -ce ls -l "${strPathDeploy}/${strFlCoreName}.ftl"
  if [[ -n "$strFlCoreNameProprietary" ]];then # prepare replacer/override at installed mod folder
    ( 
      SECFUNCexecA -ce cd "${strPathDeploy}";
      SECFUNCexecA -ce ln -vsfT "./${strFlCoreName}.ftl" "${strFlCoreNameProprietary}.ftl"
      #SECFUNCexecA -ce ls -l "./${strFlCoreName}.ftl" "${strFlCoreNameProprietary}.ftl"
    )
    SECFUNCexecA -ce ls -l "${strPathDeploy}/${strFlCoreName}.ftl" "${strPathDeploy}/${strFlCoreNameProprietary}.ftl"
  fi
  
  echoc -t $fPromptTm -w "hit a key to prepare release files"
  SECFUNCtrash "$strPathReleaseHelper/"
  SECFUNCtrash "$strPathReleaseSetupHelper/"
  mkdir -vp "${strPathReleaseHelper}/textures/NoBakedTextures/"
  if ! SECFUNCexecA -ce cp -vf "${strBlenderSafePath}/${strFlCoreName}.license.txt" "$strPathReleaseHelper/";then
    echoc -t 3 -p "license file not found"
  fi
  SECFUNCexecA -ce cp -vf "${strPathObjToFtl}/${strFlCoreName}.ftl" "$strPathReleaseHelper/"
  SECFUNCexecA -ce 7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on -mmt16 "$strPathReleaseHelper/${strFlCoreName}.blend.7z" "${strBlenderSafePath}/${strFlCoreName}.blend" #TODOA chk blender file if all is ok
  egrep "map_Kd" "$strFlWFMtl" |sed -r -e 's@\\@/@g' -e 's@map_Kd @@' |while read strFlRelatPathTx;do
    SECFUNCdrawLine "$strFlRelatPathTx"
    astrFlRelatPathTxCpList=("$strFlRelatPathTx")
    declare -p astrFlRelatPathTxCpList
    bHasManyIndexes=false
    if [[ "$strFlRelatPathTx" =~ .*[.]index[0-9]*[.].* ]];then #blender is only using one of these textures that will be changed/tweaked in-game from player actions probably
      bHasManyIndexes=true
      strFlRelatPathTxNmBase="$(echo "$strFlRelatPathTx" |sed -r 's@(.*[.]index)[0-9]*[.].*@\1@')"
      declare -p strFlRelatPathTxNmBase
      pwd
      IFS=$'\n' read -d '' -r -a astrFlRelatPathTxCpList < <(cd "${strBlenderSafePath}";ls -1 "${strFlRelatPathTxNmBase}"*)&&:
    fi
    declare -p astrFlRelatPathTxCpList
    SECFUNCarrayShow -v astrFlRelatPathTxCpList
    if((`SECFUNCarraySize astrFlRelatPathTxCpList`==0));then
      echoc -p "invalid empty astrFlRelatPathTxCpList"
      exit 1
    fi
    
    #textures
    pwd
    for strFlRelatPathTxCp in "${astrFlRelatPathTxCpList[@]}";do
      declare -p strBlenderSafePath strFlRelatPathTxCp strPathReleaseHelper strPathDeployAtModInstallFolder strTXPathRelative
      SECFUNCexecA -ce cp -vfL "${strBlenderSafePath}/$strFlRelatPathTxCp"* "${strPathReleaseHelper}/textures/"
      
      SECFUNCtrash "${strPathDeployAtModInstallFolder}/${strFlRelatPathTxCp}"* #this prevents overwriting symlinks target if any there
      SECFUNCexecA -ce cp -vfL "${strBlenderSafePath}/$strFlRelatPathTxCp"* "${strPathDeployAtModInstallFolder}/${strTXPathRelative}/"
      
      strFlNoBakeTx="${strBlenderSafePath}/$(dirname "$strFlRelatPathTxCp")/NoBakedTextures/$(basename "$strFlRelatPathTxCp")"
      if [[ -f "$strFlNoBakeTx" ]];then
        #TODO? SECFUNCtrash strFlNoBakeTx at "$strPathReleaseHelper/textures/NoBakedTextures/"
        SECFUNCexecA -ce cp -vf "$strFlNoBakeTx"* "$strPathReleaseHelper/textures/NoBakedTextures/"
      fi
    done
  done
  
  echoc --info "scripts etc"
  strRelativeScriptPath="`pwd |sed -r "s@.*${strDeveloperWorkingPath}/game/@@"`"  #AUTOCFG
  astrFlExtraList=("${strFlCoreName}[icon].png" "${strFlCoreName}.asl")
  for strFlExtra in "${astrFlExtraList[@]}";do
    if [[ -f "${strRelativeScriptPath}/${strFlExtra}" ]];then
      if [[ "$strFlExtra" =~ .*\.asl ]];then
        while ! "$(dirname "$strSelf")/../../bin/chkEncoding.sh" "${strRelativeScriptPath}/$strFlExtra";do
          pwd
          ls -l "${strRelativeScriptPath}/$strFlExtra"
          echoc -w "please fix above error."
        done
      fi
      # release folder
      SECFUNCexecA -ce mkdir -vp "${strPathReleaseSetupHelper}/${strRelativeScriptPath}/"
      SECFUNCexecA -ce cp -v "${strRelativeScriptPath}/${strFlExtra}"* "${strPathReleaseSetupHelper}/${strRelativeScriptPath}/"
      # mod folder
      SECFUNCexecA -ce mkdir -vp "${strPathDeployAtModInstallFolder}/${strRelativeScriptPath}/"
      SECFUNCtrash "${strPathDeployAtModInstallFolder}/${strRelativeScriptPath}/${strFlExtra}"* #there may have other files there so remove only what would be replaced (the cp error may happen if you symlinked the script there to your developement path script, it says is the same file)
      SECFUNCexecA -ce cp -v "${strRelativeScriptPath}/${strFlExtra}"* "${strPathDeployAtModInstallFolder}/${strRelativeScriptPath}/"
    fi
  done
  
  # report
  ls -lR "$strPathReleaseHelper"
  if $bSpeak;then echoc --say "${strFlCoreName} deployed";fi
fi

echo
echoc --info "SUCCESS!!! (expectedly...)"
