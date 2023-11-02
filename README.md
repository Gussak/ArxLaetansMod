# Arx Laetans Mod

"Sic aedificabitur ut eo frui possis dum in Arx mundum respiras!"  

New lore: all bottles are made of magic glass that adapts it's shape to it's contents type (powder/water(unchanged), magical, hazardous, restoration), so all empty bottles will look the same.  

___

__INSTALLING:__  

Extract each compressed package you want (and the respective setup package from https://github.com/Gussak/ArxLaetansModSetup) at the game folder.  
The setup package is important to create compatibility with Arx Fatalis/Libertatis and to keep the models work independent. As they are CC-BY they can be re-used and adapted to work elsewhere too if you want.  

TODO:OBS.: windows .bat files to create windows file links are WIP and still needs testing. createWindowsLinks.bat is not ready yet.

___

__LICENSES__  

The licenses are inside each compressed package.  

__DevelopmentEnvironment__  

These models were prepared using these linux scripts (that may run on windows cygwin but were only tested on linux ubuntu 22.04, so I suggest using a VirtualMachine with minimal linux on it):  

This file have many dependencies and config requirements.  
It will try to prepare the development environment and guide you to complete that.  
If you have any problems, open an issue detailing it.  
If some dependency doesnt work well, check one of my forks, this script should work with them.  
`tools/interim/convertOBJtoFTL.sh`  
If everything is working correcly, running it to update changes from blender, may be as simple as this and may take about 25s, ex.:  
`./convertOBJtoFTL.sh --noprompt WineBottle bottle_wine`

These 2 files need to be placed at the same folder where blender addon is installed or extracted:  
```
 plugins/blender/arx_addon/unpackFtl.simpleCmdLine.py
 plugins/blender/arx_addon/unpackFtl.simpleCmdLine.sh
```

The setup package has relative symlinks that can be easily created in `nemo` or `nautilus` using an action calling `sec.Symlink.MakeRelative.NautilusScript.sh`.

On `git gui`, using these tools to easify splitting changes into many branches to create pull requests:  
`https://github.com/AquariusPower/CppDebugMessages/tree/master/.devsPrefs/AquariusPower/git%20tools`  

__Mod Merging (or mixing with overwriting priorities) Suggestion__  

Suggestion: Instead of overwriting exiting files with mods' ones, I use mergerfs thru `secOverrideMultiLayerMountPoint.sh ArxLibertatis`, but you can just run something like (btw, all folders and files must be readonly only least the write layer) ex.:  
```
"mergerfs" "-o" "defaults,allow_other,use_ino,category.action=ff,category.create=ff,category.search=ff" \
  "ArxLibertatis.0.WriteLayer\
:./ArxLibertatis.layer9000.GFX-ArxLaetansMod\
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
:./ArxLibertatis.layer1100.Gameplay-Arx_Fatalis_Lockipick_Mod (lockpicks durability)"
  "ArxLibertatis"
```
Obs.: this is not a recommended layer sort order, this is just an example as I have not fully tested if all are working as intended.  

__Issues/Todo__  

ISSUE: if there are many high poly objects on the view sight, it will degrade the FPS. TODO:WIP: do more cleanup on the existing models' meshes while keeping visual quality.  

TODO: fix the dropped items' shadows, they are too big and too dark not matching replaced models' shadows.  
TODO: windows automatic setup compatibility (generate the .bat files to prepare the relative links with mklink and prepare a top .bat that will call all the others)  
TODO: Crafting/mixing/etc could optionally drop new (droppable/non-quest?) things on the ground. Increases challenge (like in that you need a place to craft things, even if it is on the ground) but also let the user appreciate new crafted models.  
