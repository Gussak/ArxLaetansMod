# Arx Laetans Mod

"Sic aedificabitur ut eo frui possis dum in Arx mundum respiras!"  

New lore: all bottles are made of magic glass that adapts it's shape to it's contents type (powder/water(unchanged), magical, hazardous, restoration), so all empty bottles will look the same.  

___

# __INSTALLING:__  

Extract each compressed package you want (and the respective setup package from https://github.com/Gussak/ArxLaetansModSetup) at the game folder.  

Obs.: The setup package is important to create compatibility with Arx Fatalis/Libertatis and to keep the models work independent. As they are CC-BY they can be re-used and adapted to work elsewhere too if you want.  

My new mods' scripts found here will probably not fully work unless you merge/compile this branch:  https://github.com/Gussak/ArxLibertatis/tree/ForArxLaetansMod  
or the newest (that may be unstable or just broken as may contain WIP and backup commits):  
https://github.com/Gussak/ArxLibertatis/tree/ForArxLaetansMod_TEST (or TEST2 ...)  

TODO:OBS.: windows .bat files to create windows file links are WIP and still needs testing. createWindowsLinks.bat is not ready yet.  

___

# __PULL Request Branches:__  

About 'PR_.*' branches at https://github.com/Gussak/ArxLibertatis:  

These branches are meant to create pull requests to main Arx Libertatis project.  

They may all be already merged into ForArxLaetansMod branch after they are working properly and will (probably) be required for new mods I create here.  

If you want you can improve them and/or also create a pull request at Arx Libertatis from these branches instead of me.  

Obs.: The wiki patches are at https://github.com/Gussak/ArxLaetansMod/tree/main/docs/WikiPatches (read them raw).  

Obs.: it was all compiled to c++20 on ubuntu22.04 with qtbase5-dev package.  
  
.  
.  
.  
***These below are possibly ready. They were cleaned and prepared for a PR:***  

https://github.com/Gussak/ArxLibertatis/tree/PR_LogicalOperators2  
Logical Operators for "if" command  
and(... && ... && ...) //only accepts '&&' or ','  
or(... || ... || ...) //only accepts '||' or ','  
!and(... && ... && ...)  
!or(... || ... || ...)  
and nesting: if(and(... && !or(... || ... || and(... , ... , ...)) && ...))  
where '...' are the existing comparisons that use == != >= <= > <  

https://github.com/Gussak/ArxLibertatis/tree/PR_DebugLineColumnInfo2  
Debug Line and Column Info  
Terminal log will show line and column where the problem happened.  

https://github.com/Gussak/ArxLibertatis/tree/PR_QOLcombineItemsKey  
QOL: new control (default key 'N') to combine items w/o having to double click

https://github.com/Gussak/ArxLibertatis/tree/PR_TakeAllItemsKey  
QOL: new Key to TakeAllItems from g_secondaryInventoryHud without having to aim the mouse on the tiny button there.

https://github.com/Gussak/ArxLibertatis/tree/PR_QOLUnstackItemsKey  
QOL: New unstak key to unstack one item from the stack in the current inventory.  

https://github.com/Gussak/ArxLibertatis/tree/PR_FormatString3  
Format expanded variables thru printf syntax  

https://github.com/Gussak/ArxLibertatis/tree/PR_LimitShadowBlobs  
src/graphics/effects/BlobShadow.cpp: limit blob shadows for high poly models  
High poly dropped items' models create a very dark ugly shadow.  
This patch limits the amount of shadows for them still using strided().  

https://github.com/Gussak/ArxLibertatis/tree/PR_NewVarFPS  
New variable ^fps to get the frame rate

https://github.com/Gussak/ArxLibertatis/tree/PR_Interpolate2  
Interpolate command  
Interpolate an entity near a target  

https://github.com/Gussak/ArxLibertatis/tree/PR_LifeOfOtherEnt  
new ^life_<entityID> ^lifemax_<entityID> ^lifemodmax_<entityID>  

https://github.com/Gussak/ArxLibertatis/tree/PR_RemainderOperation3  
Added Remainder arithmetic operation  

https://github.com/Gussak/ArxLibertatis/tree/PR_DegreesVariables2  
Added ^degrees... variables  
only degrees, also for pitch x and roll z now  

https://github.com/Gussak/ArxLibertatis/tree/PR_DistanceToLocation2  
^dist_ variable now can use an absolute location as target  
ex.: ^dist_{8000.25,7800.44,8500.32}  

https://github.com/Gussak/ArxLibertatis/tree/PR_LocationVariables3  
added ^locationx_ ^locationy_ ^locationz_ to get absolute position of any entity  

https://github.com/Gussak/ArxLibertatis/tree/PR_HoverFar  
^hover_<dist> returns any entity at most at specified distance.  

https://github.com/Gussak/ArxLibertatis/tree/PR_DropItems  
New command: dropitem Can drop one or all items of any entity inventory where it is or in front of the player.  

Obs.: other PR_.* branches may not be ready yet, may contain backup/untested commits, complicated code and loads of unecessary comments and commented dead code.  

PS.: These are tests and are not working yet or may just be useless:  
/PR_UsemeshOtherEnt  
/PR_WeaponCmdOtherEnt  
/PR_CmtAtOtherEnt_Behavior_Setmovemode_Settarget  

___

# __LICENSES__  

The licenses are inside each compressed package.  

___

# __DevelopmentEnvironment__  

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

# __Mod Merging (or mixing with overriding priorities) Suggestion__  

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

# __Issues/Todo__  
	
 TODO: material names like sM=@Origin can be used to configure special groups in the json file. probably sM=@HIT_10 with tiny transparen SPECIALTX_HIT_10.png, will help a lot on the script to prepare the section on .json file before converting to .ftl. This can also be used to prepare these sections when replacing door models and other models too I guess.
 TODO: put a vertext/face amount check on the script, it should not go too much beyond 2000 vertexes per ftl model ISSUE: if there are many high poly objects on the view sight, it will degrade the FPS. TODO:WIP: do more cleanup on the existing models' meshes while keeping visual quality.  
 TODO: windows automatic setup compatibility (generate the .bat files to prepare the relative links with mklink and prepare a top .bat that will call all the others)  
 TODO: Crafting/mixing/etc could optionally drop new (droppable/non-quest?) things on the ground. Increases challenge (like in that you need a place to craft things, even if it is on the ground) but also let the user appreciate new crafted models.  
 TODO: hitting a wall with bare hands should damage the player or the melee weapon.

updating forked branches:  
  github.com/Gussak/ArxLibertatis/compare/insanity...arx-insanity:ArxLibertatis:insanity
  
# __Done__  

 DONE at PR_LimitShadowBlobs: TODO: fix the dropped items' shadows, they are too big and too dark not matching replaced models' shadows.  
