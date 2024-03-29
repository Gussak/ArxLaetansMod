# Arx Laetans Mod

"Sic aedificabitur ut eo frui possis dum in Arx mundum respiras!"  

New lore: all bottles are made of magic glass that adapts it's shape to it's contents type (powder/water(unchanged), magical, hazardous, restoration), so all empty bottles will look the same.  

___

# __INSTALLING:__  

Extract each compressed package you want (and the respective setup package from https://github.com/Gussak/ArxLaetansModSetup) at the game folder.  

Obs.: The setup package is important to create compatibility with Arx Fatalis/Libertatis and to keep the models work independent. As they are CC-BY they can be re-used and adapted to work elsewhere too if you want.  

My new mods' scripts found here will probably not fully work unless you merge/compile this branch:  
  https://github.com/Gussak/ArxLibertatis/tree/ForArxLaetansMod  
or the newest (that was compiled and tested but not extensively and may be unstable):  
  https://github.com/Gussak/ArxLibertatis/tree/ForArxLaetansMod_TEST2 (or TEST3 ...)  

TODO:OBS.: windows .bat files to create windows file links are WIP and still needs testing. createWindowsLinks.bat is not ready yet.  

PS.: it is WIP, not ready for release, and I have only tested it in one other machine, but that test may have happened before I made updates here. So, if something is not working, open an issue.

___

# __PULL Request Branches:__  

About 'PR_.*' branches at https://github.com/Gussak/ArxLibertatis:  

These branches are meant to create pull requests to main Arx Libertatis project.  

They may all be already merged into ForArxLaetansMod branch after they are working properly and will (probably) be required for new mods I create here.  

If you want you can improve them and/or also create a pull request (every 2nd link) at Arx Libertatis from these branches instead of me (if unable, it means there is a PR there already for that branch).  

**IMPORTANT**:  
It is too many branches already for me to have time to keep them all ready for a PR to main repo.  
As it is becoming overly complex, I will mainly work at my newest TEST branch from now on, this means the TEST branch may have updates to some other PR branch that you like; so if you would like to create such PR or merge it in your fork, I can update the PR branch with the news from the TEST branch, just open an issue; or you can do it yourself, then open a PR to my PR branch, thx! :)  
If you like something it will probably be only working there at:  
  https://github.com/Gussak/ArxLibertatis/tree/ForArxLaetansMod_TEST2 (or TEST3 ..., the newest one)  
Btw, the sketch code branches are not compiled yet (or just broken after compilation), and have mainly ideas, like:
  https://github.com/Gussak/ArxLibertatis/tree/ForArxLaetansMod_SketchCode_Tmp1   

Obs.: Tip: I use 3-way meld compare, with the cmp3way.sh script, to split from that branch into PR_ branches.

Obs.: If some PR_ branch does not compile, the missing parts or fixes will all be at my newest TEST branch.  

Obs.: The new wiki patches may be at https://github.com/Gussak/ArxLaetansMod/tree/main/docs/WikiPatches (read them raw).  

Obs.: The branches (if I had time to test them) were compiled to c++20 on ubuntu22.04 with qtbase5-dev package.  
  
.  
.  
.  
***Most breanches below are ready (a few are WIP tho). They were cleaned and prepared for a PR:***  

___

## NEW END USER FEATURES:

https://github.com/Gussak/ArxLibertatis/tree/PR_QOLcombineItemsKey  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_QOLcombineItemsKey  
QOL: new control (default key 'N') to combine items w/o having to double click

https://github.com/Gussak/ArxLibertatis/tree/PR_TakeAllItemsKey  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_TakeAllItemsKey  
QOL: new Key to TakeAllItems from g_secondaryInventoryHud without having to aim the mouse on the tiny button there.

https://github.com/Gussak/ArxLibertatis/tree/PR_QOLUnstackItemsKey  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_QOLUnstackItemsKey  
QOL: New unstak key to unstack one item from the stack in the current inventory.  

## NEW CORE FEATURES LIKE PERFORMANCE:

https://github.com/Gussak/ArxLibertatis/tree/PR_CallSeekPerformance  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_CallSeekPerformance  
GoTo/GoSub call seek performance improvement:  
Creates a sorted cache map (that considers overrides) and avoids seeking them on every call.  

https://github.com/Gussak/ArxLibertatis/tree/PR_LimitShadowBlobs  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_LimitShadowBlobs  
src/graphics/effects/BlobShadow.cpp: limit blob shadows for high poly models  
High poly dropped items' models create a very dark ugly shadow.  
This patch limits the amount of shadows for them still using strided().  

## NEW MOD DEVELOPMENT FEATURES:

https://github.com/Gussak/ArxLibertatis/tree/PR_ModdingScriptsWithLoadOrder  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_ModdingScriptsWithLoadOrder  
Mod .asl scripts with load order.  
1st - Auto-patches a script using the patch command line from a diff file.  
2nd - Prepend an override to GoTo/GoSub calls or events into existing .asl scripts while following a mod load order.  
So it is now possible to just apply minor changes instead of having to override full scripts.  
Set environment variable ARX_MODDING=1 to grant changes to .asl and mod files will be detected everytime, otherwise cached modded files prevails.  
Obs.: tests for the above PR, for now can be found at: https://github.com/Gussak/ArxLaetansMod/tree/main/tests/ScriptsOverridingAndPatching

https://github.com/Gussak/ArxLibertatis/tree/PR_DebugLineColumnInfo2  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_DebugLineColumnInfo2  
Debug Line and Column Info  
Terminal log will show line and column of the .asl script where the problem happened.  

https://github.com/Gussak/ArxLibertatis/tree/PR_WarnMsgShowsGotoGosubCallStack  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_WarnMsgShowsGotoGosubCallStack  
logs with more details for mod developers  
  warnings will show GoTo/GoSub call stack.  
  showlocals and showvars will also show event and params, and the GoTo/GoSub call stack.  
  the script call stack now shows position, line and collumn from where each call was made.  

https://github.com/Gussak/ArxLibertatis/tree/PR_DebugBreakPointFromScriptCall  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_DebugBreakPointFromScriptCall  
A debug breakpoint can be triggered from a script condition calling a function that contains 'debugbreakpoint' in it's name  
This also contains:  
 user custom command can be run  
 user custom command to open system dialog popup  
 all the code about line and column where the asl script is being executed  
 string applyTokenAt()  

https://github.com/Gussak/ArxLibertatis/tree/PR_SaveLoadConsoleHistory  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_SaveLoadConsoleHistory  
Load and append console commands to consolehistory.txt  
load the full consolehistory.txt file when the console is first opened (lazy)  
and append every new entry to it  
the file is located at fs::getUserDir()  

## NEW SCRIPT CODING FEATURES:

https://github.com/Gussak/ArxLibertatis/tree/PR_LogicalOperators2  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_LogicalOperators2  
Logical Operators for "if" command  
and(... && ... && ...) //only accepts '&&' or ',' and if nesting needs to end with ';'  
or(... || ... || ...) //only accepts '||' or ',' and if nesting needs to end with ';'  
not(and(... && ... && ...))  
not(or(... || ... || ...))  
and nesting: if(and(... && not(or( ... || ... || and(... , ... , ...); );) && ...);)  
where '...' are the existing comparisons that use == != >= <= > < or the ones with words  
they can also be multiline and each line can have a comment!  
PS.: the hologram.asl has many tests for this.  

https://github.com/Gussak/ArxLibertatis/tree/PR_CalcCommand  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_CalcCommand  
new Calc command that can nest calculations also in multi-lines with comments  
ex.: \[ ... + ... - \[ ... % ... \] / ... * ... % ... ^ ... \]  
Obs.: the branches about remainder, power and nthroot are here too.  
PS.: the hologram.asl has some tests for this.  

https://github.com/Gussak/ArxLibertatis/tree/PR_IncAddDecSub  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_IncAddDecSub  
QOL: can use Inc or Add now. Can use Dec or Sub now.  

https://github.com/Gussak/ArxLibertatis/tree/PR_Pow  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_Pow  
Power of var to <exponent>  

https://github.com/Gussak/ArxLibertatis/tree/PR_NthRoot  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_NthRoot  
NthRoot of var to <anyRootValue>

https://github.com/Gussak/ArxLibertatis/tree/PR_SetOtherEntityVar_GetArrayValAtIndex_GetItemCountFromInv  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_SetOtherEntityVar_GetArrayValAtIndex_GetItemCountFromInv  
The command Set now has extra options  
Set can now -r read from and -w write to other entities (no need to expand their unique IDs).  
It also can get a value from a string containing an array at specified index: -a  
It can get the count of one item from any entity inventory: -i  
It can get an array of items from any inventory: -l  
It can get a 2D array of "item count item count..." from any inventory: -m  

https://github.com/Gussak/ArxLibertatis/tree/PR_CmdLootInventory  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_CmdLootInventory  
new ^lootinventory if another entity inventory is being looted, this will return it's id  

https://github.com/Gussak/ArxLibertatis/tree/PR_objOnTopExtraBoundary  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_objOnTopExtraBoundary  
^$objontop_<extraBoundaryXZ> can check for a larger area above the entity  

https://github.com/Gussak/ArxLibertatis/tree/PR_FormatString3  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_FormatString3  
Format expanded variables thru printf syntax  

https://github.com/Gussak/ArxLibertatis/tree/PR_NewVarFPS  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_NewVarFPS  
New variable ^fps to get the frame rate  

https://github.com/Gussak/ArxLibertatis/tree/PR_Interpolate2  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_Interpolate2  
Interpolate command  
Interpolate an entity near a target. No need to expand their IDs.  

https://github.com/Gussak/ArxLibertatis/tree/PR_LifeOfOtherEnt  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_LifeOfOtherEnt  
new ^life_<entityID> ^lifemax_<entityID> ^lifemodmax_<entityID>  

https://github.com/Gussak/ArxLibertatis/tree/PR_InInventory  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_InInventory  
new ^ininventory returns entity id   

https://github.com/Gussak/ArxLibertatis/tree/PR_RemainderOperation3  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_RemainderOperation3  
Added Remainder arithmetic operation  

https://github.com/Gussak/ArxLibertatis/tree/PR_CmdInventoryAddAtOtherEntity  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_CmdInventoryAddAtOtherEntity  
inventory command can now add items to other entities   
so we can now dynamically patch NPCs, no need to edit/override .asl files for this.   

https://github.com/Gussak/ArxLibertatis/tree/PR_DegreesVariables2  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_DegreesVariables2  
Added ^degrees... variables  
only degrees, also for pitch x and roll z now  

https://github.com/Gussak/ArxLibertatis/tree/PR_DistanceToLocation2  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_DistanceToLocation2  
^dist_ variable now can use an absolute location as target  
ex.: ^dist_\[8000.25,7800.44,8500.32\]  

https://github.com/Gussak/ArxLibertatis/tree/PR_LocationVariables3  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_LocationVariables3  
added ^locationx_ ^locationy_ ^locationz_ to get absolute position of any entity  

https://github.com/Gussak/ArxLibertatis/tree/PR_HoverFar  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_HoverFar  
^hover_<dist> returns any entity at most at specified distance.  

https://github.com/Gussak/ArxLibertatis/tree/PR_DropItems  
https://github.com/arx/ArxLibertatis/compare/master...Gussak:ArxLibertatis:PR_DropItems  
New command: dropitem Can drop one or all items of any entity inventory where it is or in front of the player.  

## ETC:

Obs.: other PR_.* branches may not be ready yet, may contain backup/untested commits, complicated code and loads of unecessary comments and commented dead code.  

PS.: These are tests and may not be working yet or may just be useless:  
/PR_UsemeshOtherEnt command 'usemesh' now accepts other entityID to apply it. No need to expand the ID.  
/PR_WeaponCmdOtherEnt weapon command accepts an entity to apply it now. no need to expand the ID  
/PR_CmtAtOtherEnt_Behavior_Setmovemode_Settarget Let other entities be set by these commands: behavior, setmovemode, settarget. No need to expand their IDs.  

___

# __LICENSES__  

The licenses are inside each folder and are related to all files there.

___

# Development Environment  

These models were prepared using these linux scripts (that may run on windows cygwin but were only tested on linux ubuntu 22.04, so I suggest using a VirtualMachine with minimal linux on it):  

This file have many dependencies and config requirements.  
It will try to prepare the development environment and guide you to complete that.  
If you have any problems, open an issue detailing it.  
If some dependency doesnt work well, check one of my forks, this script should work with them.  
`tools/interim/convertOBJtoFTL.sh`  
If everything is working correcly, running it to update changes from blender, may be as simple as this and may take less than a minute, ex.:  
`./convertOBJtoFTL.sh --noprompt WineBottle bottle_wine`

These 2 files need to be placed at the same folder where blender addon is installed or extracted:  
```
 plugins/blender/arx_addon/unpackFtl.simpleCmdLine.py
 plugins/blender/arx_addon/unpackFtl.simpleCmdLine.sh
```

The setup package has relative symlinks that can be easily created in `nemo` or `nautilus` using an action calling `sec.Symlink.MakeRelative.NautilusScript.sh`.

On `git gui`, using these tools to easify splitting changes into many branches to create pull requests:  
`https://github.com/AquariusPower/CppDebugMessages/tree/master/.devsPrefs/AquariusPower/git%20tools`  

On blender, you can prepare materials with all textures for basecolor, normal, emission, metalic, rugness etc.  
Then add some lights and bake with cycles (w/o clearing the texture), it will bake into the base color, then +- confirm in material preview without scene lights and scene world options.  
When exporting to .obj .mtl it will export all the textures, but convertOBJtoFTL.sh will only use the basecolor to prepare the .ftl file.  
The game engine seems to use alpha from png textures, but seems to be +- like if alpha < 0.5 it is 100% transparent, if >= 0.5 it is 100% opaque.

In game: save F5 then on every load F9 it will update most models and at least png textures. Tho, new textures requires a restart.

Lower all textures resolution on the current folder:  
`ls |while read strFl;do convert "$strFl" -resize 512x "${strFl}.new";mv -vf "${strFl}.new" "$strFl";done`  
`ls |while read strFl;do convert "$strFl" -resize 1024x "${strFl}.new";mv -vf "${strFl}.new" "$strFl";done`  

___

# Mod Merging (or mixing with overriding priorities) Suggestion  

Suggestion: Instead of overwriting exiting files with mods' ones, I use mergerfs thru `secOverrideMultiLayerMountPoint.sh ArxLibertatis`, but you can just run something like (btw, all folders and files must be readonly only least the write layer) ex.:  
```
"mergerfs" "-o" "defaults,allow_other,use_ino,category.action=ff,category.create=ff,category.search=ff" \
  "ArxLibertatis.0.WriteLayer\
:./ArxLibertatis.layer9900._DevTests\
:./ArxLibertatis.layer9055.Gameplay-HologramInventoriesAutoPatch\
:./ArxLibertatis.layer9050.Gameplay-Hologram\
:./ArxLibertatis.layer9000.GFX-ArxLaetansMod\
:./ArxLibertatis.layer8900._FixesMixingPreviousLayerPriorityMods\
:./ArxLibertatis.layer8060.Gameplay-Stacks Maps and Tweaks-6-1-0-1635347154\
:./ArxLibertatis.layer8030.GamePlay-arx-mod-rune-randomizer-v1.0.0\
:./ArxLibertatis.layer8020.GamePlay-arx-mod-potion-guard-v1.0.0\
:./ArxLibertatis.layer8010.GamePlay-arx-mod-golden-armor-fix-v1.0.0\
:./ArxLibertatis.layer8005.GFX-AI Upscaled Megapack-8-1-0-1688092942\
:./ArxLibertatis.layer8000.GFX-Arx_Neuralis_0.9\
:./ArxLibertatis.layer7060.Patch-_FixMixing_ Insanity0.4.71 + liberatis1.3-2023-06-24\
:./ArxLibertatis.layer7057.CoreNewerThanOverhaul-arx-libertatis-1.3-dev-2023-06-24-LinuxBuild\
:./ArxLibertatis.layer7055.CoreNewerThanOverhaul-arx-libertatis-1.3-dev-2023-06-24-windows\
:./ArxLibertatis.layer7050.Overhaul-Arx_Insanity_Demo_v0.4.71_Complete\
:./ArxLibertatis.layer2600.GFX+Gameplay-ArxFatalisExtended - AFE235\
:./ArxLibertatis.layer2590.GFX+Gameplay-Arx_Better_Balance_Mod_v1.0_eng - 123_Arx_Better_Bala\
:./ArxLibertatis.layer2580.GFX+Gameplay-Arx_Second_Life_v1.2.1\
:./ArxLibertatis.layer2500.Gameplay-Enchant_and_Balance_Mod_V1\
:./ArxLibertatis.layer1110.Gameplay-portable_containers_v1\
:./ArxLibertatis.layer1100.Gameplay-Arx_Fatalis_Lockipick_Mod (lockpicks durability)"\
  "ArxLibertatis"
```
Obs.: this is not a recommended layer sort order, this is just an example as I have not fully tested if all are working as intended.  

___

# Issues/Todo  
	
 - TODO: material names like sM=@Origin can be used to configure special groups in the json file. probably sM=@HIT_10 with tiny transparen SPECIALTX_HIT_10.png, will help a lot on the script to prepare the section on .json file before converting to .ftl. This can also be used to prepare these sections when replacing door models and other models too I guess. To configure it in blender, the isolated part of the mesh must have 3 vertexes and one face, so the material can be set to it. After that, just snap all 3 vertexes to the same position (place the 3d cursor there first). Check also if it is possible to export to OBJ the vertex groups, I read they become polygroups and require to be at least faces (3 vertexes).  
 - TODO: put a vertex/face amount check on the script, it should not go too much beyond 2000 vertexes per ftl model ISSUE: if there are many high poly objects on the view sight, it will degrade the FPS. TODO:WIP: do more cleanup on the existing models' meshes while keeping visual quality.     
 - TODO: windows automatic setup compatibility (generate the .bat files to prepare the relative links with mklink and prepare a top .bat that will call all the others)    
 - TODO: Crafting/mixing/etc could optionally drop new (droppable/non-quest?) things on the ground. Increases challenge (like in that you need a place to craft things, even if it is on the ground) but also let the user appreciate new crafted models.    
 - TODO: hitting a wall with bare hands should damage the player or the melee weapon.  

updating forked branches:  
  github.com/Gussak/ArxLibertatis/compare/insanity...arx-insanity:ArxLibertatis:insanity  
  
## __Done__  

 - DONE at PR_LimitShadowBlobs: TODO: fix the dropped items' shadows, they are too big and too dark not matching replaced models' shadows.  
