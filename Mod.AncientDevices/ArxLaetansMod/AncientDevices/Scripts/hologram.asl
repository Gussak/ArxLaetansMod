/*
///////////////////////////////////////////
// by Gussak (https://github.com/Gussak) //
///////////////////////////////////////////
__
//////////////// Developer DOC /////////////////
 Activating the hologram while looking max upwards will toggle showlocals.
 Activating the hologram while looking max downwards will run tests for new code once.
__
///////////////// User DOC //////////////
 AncientBox can only become SignalRepeater when activating the initial box device in the inventory. Also to revert.
 Combining any quality AncientBox with a low quality AncientDevice may break it. Combining any quality AncientBox with a high quality+ AncientDevice will always upgrade it. So, the second, or the target of the combination must be of quality+. Also, if you double click on a quality+ and combine it with a low quality, you may lose both! TODO: find a way to detect the quality of the PARAM1 item for combine.
 Bones and stones can be used to destroy AncientDevices if you want.
 Ancient Teleport will damage and paralize you randomly, less if you are highly skilled in AncientTechSkill.
 Signal strength is useful to position yourself to get better results when using it.
 Quality useful to chose wich one to keep or to combine to have better results when crafting.
 Condition is useful to hold your hand to avoid destroying the device.
 While unidentified, words will be in latin or messed up letters order, and numbers will be in hexadecimal.
__
///////////////// Global Timers dev track:
starttimer timer1 //^#timer1 used ON MAIN
starttimer timer2 //^#timer2 used ON IDENTIFY
starttimer timer3 //^#timer3
starttimer timer4 //^#timer4
__
////////////////////////////////////
 ON RELEASE: comment lines with //COMMENT_ON_RELEASE
__
//////////////////////////////////
 Obs.: If you just downloaded it from github, this file may need to have all 0xC2 chars (from before £ §) removed or it will not work. I cant find yet a way to force iso-8859-15 while editing it directly on github, it seems to always become utf-8 there.
__
/////////////// DEV HELP: term cmds //////////////
clear;LC_ALL=C egrep 'torch'   --include="*.asl" --include="*.ASL" -iRnIa  *
clear;LC_ALL=C egrep 'torch.*' --include="*.asl" --include="*.ASL" -iRIaho * |sort -u
clear;LC_ALL=C egrep 'angle' --include="*.h" --include="*.cpp" -iRnI *
__
//////////////// CPP EASY HELP /////////////////////
 #include <iostream>
 #define MYDBG(x) std::cout << "___MySimpleDbg___: " << x << "\n"
 MYDBG(anyVar<<","<<anything<<anythinElse);
__
/////////////// MOD DEV (.asl) TIPS: /////////////////
 a string var that is not set will be comparable only to empty "": if(£test == "") ok
 a string var that is not set will be expanded always to "void", so while "~£test~" expands to void, if(£test == "void") will FAIL!!!
__
 UnSet all vars beggining with _tmp to cleanup the showlocals log and to avoid var name clashes outside a function (despite them all are global to the script, better just prefix them all with the func name ...)
__
 ALWAYS use this: inventory add magic/hologram/hologram ; after any changes and ALWAYS work with a freshly instantiated item, othewise the log will show many things that are inconsistent.
__
 clear;LC_ALL=C egrep 'player_skill[^ ]*' --include="*.asl" --include="*.ASL" -iRIaho |tr -d '~\r\t"' |sort -u
// mage
^PLAYER_SKILL_CASTING
^PLAYER_SKILL_ETHERAL_LINK
^PLAYER_SKILL_OBJECT_KNOWLEDGE
// thief
^PLAYER_SKILL_MECANISM
^PLAYER_SKILL_STEALTH
^PLAYER_SKILL_INTUITION
// warrior
^PLAYER_SKILL_PROJECTILE
^PLAYER_SKILL_CLOSE_COMBAT
^PLAYER_SKILL_DEFENSE
__
^PLAYER_ATTRIBUTE_CONSTITUTION
^PLAYER_ATTRIBUTE_DEXTERITY
^PLAYER_ATTRIBUTE_MENTAL
^PLAYER_ATTRIBUTE_STRENGTH
__
 SETEQUIP STRENGTH 1
 SETEQUIP DEXTERITY 1
 SETEQUIP CONSTITUTION 1
 SETEQUIP INTELLIGENCE 1
__
 SETEQUIP STEALTH +8
 SETEQUIP MECANISM +8
 SETEQUIP INTUITION +8
 SETEQUIP ETHERAL_LINK +8
 SETEQUIP OBJECT_KNOWLEDGE +8
 SETEQUIP CASTING +8
 SETEQUIP CLOSE_COMBAT +8
 SETEQUIP PROJECTILE +8
 SETEQUIP DEFENSE +8
__
on inventories init, this configures the generic scroll into specific spell and level:
 INVENTORY ADD "magic\\scroll_generic\\scroll_generic"
 SENDEVENT -ir TRANSMUTE 1 "8 SPEED" //the 1 distance means apparently items inside the container being ON INIT or ON INITEND
 SENDEVENT -ir CUSTOM 1000 "SomeCustomString ~§SomeVar1~ ~§SomeVar2~ ~§SomeVar3~ ~§SomeVar4~ ~§SomeVar5~" // there is no limit for the number of parameters and types, so anything can be communicated between entities, nice! Just collect them with the correct type: ^$param<i> string, ^&param<i> number, ^#param<i> int
__
Set §TestInt2 @TestFloat2 //it will always trunc do 1.9999 will become 1
__
code IFs carefully with spaces: if ( §bHologramInitialized == 1 ) { //as this if(§bHologramInitialized==1){ will result in true even if §bHologramInitialized is not set...
__
Do NOT unset vars used in timers! it will break them!!! ex.: timerTrapDestroy 1 §TmpTrapDestroyTime GoTo TFUNCDestroySelfSafely  //do not UnSet §TmpTrapDestroyTime
__
apparently items can only stack if they have the exact same name and/or icon?
__
 when a timer calls a function, the function should end with ACCEPT and not RETURN, or the log may flood with errors from RETURN while having nothing in the call stack to return to!
  an easy trick to have both is have a TFUNC call the FUNC ex.:
  timerTFUNCdoSomething -m 1 333 GoTo -p TFUNCdoSomething £«mode=init ; //a Timer called Function will be prefixed with TFUNC
  >>TFUNCdoSomething () {
    GoSub -p FUNCdoSomething £»mode=£«mode ; // every automatic param must be forwarded, the var on the left of '=' will become £FUNCdoSomething«mode local var accessible from anywhere
    ACCEPT
  }
  >>FUNCdoSomething () { //now, this function can be called from anywhere with GoSub, and from timers with GoTo, w/o flooding the log with errors!
    if(£«mode == "init") Set £state "happy!"
    RETURN
  }
 Obs.: a CFUNC (child function) is not meant to be called directly. call it only by it's related func
 LC_ALL=C sed -i.bkp -r -e 's@^(>>)(FUNC[^ ]*)@>>T\2 { GoSub \2 ACCEPT } >>\2 @' Hologram.asl #creates the TFUNC...
 LC_ALL=C sed -i.bkp2 -r -e 's@(timer.*)([ \t]*GoSub)( *)(FUNC)@\1 GoTo\3T\4@' Hologram.asl #fixes timers to use TFUNC...
 LC_ALL=C egrep "timer.*GoSub" -ia #check if all timers use GoTo now
 export LC_ALL=C;egrep "GoTo" -wia Hologram.asl |egrep -via "timer|loop" #check if GoTo is being used by something else than a timer or a loop
 LC_ALL=C sed -i.bkp -r -e 's@(>>)([T]*FUNC[0-9a-zA-Z_]*)@>>\2 ()@gi' Hologram.asl # this will add " ()" at the end of every function, so it will be recognized as a symbol by geany and will show up as function on the symbols tab!
__
	//LOOPS: for/while, how to easily implement them:
	//Obs.: loop control/index vars are only required to be unique when nesting them.
	//Obs.: arrays always end with empty "" string when iterating thru them
	//Obs.: GoTo targets always have to be unique on the whole script
	//Obs.: the implementation can be further simplified, see the working code for LOOP_FLM_ChkNPC
	>>FUNCtst () { //FUNCtst is the context example, could be the name of an event like LOOP_MAIN_...
		>>LOOP_FUNCtst_ShortDescription_BEGIN
			// do something useful
			if(...) GoTo LOOP_FUNCtst_ShortDescription_BEGIN //continue
			if(...) GoTo LOOP_FUNCtst_ShortDescription_END //break
			GoTo LOOP_FUNCtst_ShortDescription_BEGIN //next iteration LAST THING ON THE LOOP!
		>>LOOP_FUNCtst_ShortDescription_END
		RETURN
	}
__
 //simplified count loop starting in 0 index
	Set §FUNCtst_index 0	>>LOOP_FUNCtst_lookForSmtng
		//do something
	++ §FUNCtst_index	if(§FUNCtst_index < 10) GoTo LOOP_FUNCLandMine_CheckIfAliveNPC
__
 //simplified array loop. Code the conditions to end the loop and easily surround them with 'not(or())'.
	Set §FUNCtst_index 0	>>LOOP_FUNCtst_iterArray1_a
		Set -a £FUNCtst_entry §FUNCtst_index "~£FUNCtst_array1~"
		// do something
	++ §FUNCtst_index	if(not(or(§FUNCtst_endLoopCondition > 0 || £FUNCtst_entry == ""))) GoTo LOOP_FUNCtst_iterArray1_a
__
__
////////////////////////////// TODO LIST: /////////////////////////
/// <><><> /////PRIORITY:HIGH (low difficulty also)
TODO contextualizeDocModDesc: These Ancient Devices were found in collapsed ancient bunkers of a long lost and extremelly technologically advanced civilization. They are powered by an external energy source that, for some reason, is less effective or turns off when these devices are nearby strong foes and bosses. //TODO all or most of these ancient tech gets disabled near them
/// <><> /////PRIORITY:MEDIUM
TODO box icon grey if unidentified. cyan when identified.
TODO grenade icon and texture dark when inactive, red (current) when activated.
TODO create a signal repeater item that can be placed in a high signal stregth place and repeats that signal str to 1000to3000 dist from it (depending on player ancientdev skill that will set it's initial quality). code at FUNCcalcSignalStrength
TODO x8 buttons CircularOptionChoser: place on ground, rotate it to 0 degrees, diff player yaw to it, on activate will highlight the chosen button.
TODO at 75 ancientskill, player can chose what targeted spell will be cast. at 100, what explosion will happen. using the CircularOptionChoser x8 buttons
/// <> /////PRIORITY:LOW
TODO all messy translations (not latin) could become latin in some alternative indirect cognitive way
TODO teleportArrow stack 10
TODO grenade+hologram=teleportArrow (insta-kill any foe and teleport the player there)
TODO teleportArrow+hologram=mindControl (undetectable, and frenzy foe against his friends)
TODO some cleanup? there are some redundant "function" calls like to FUNCMakeNPCsHostile
TODO sometimes the avatar will speak "they are dead, all dead" when activating the hologram to change the landscape, but... it could be considered contextualized about the ancient civilization that vanished ;)
TODO `PLAY -ilp "~£SkyBoxCurrentUVS~.wav"` requires ".wav" as it removes any extension before re-adding the .wav so somename.index1 would become "somename.wav" and not "somename.index1.wav" and was failing. I think the src cpp code should only remove extension if it is ".wav" or other sound format, and not everything after the last dot "."
*/

ON INIT () {
	SetName "Ancient Box (unidentified)"
	SET_MATERIAL METAL
	SetGroup "DeviceTechBasic"
	SET_PRICE 50
	PlayerStackSize 50
	
	Set §IdentifyObjectKnowledgeRequirement 35
	SETEQUIP identify_value §IdentifyObjectKnowledgeRequirement //seems to enable On Identify event but the value seems to be ignored to call that event?
	
	SET_STEAL 50
	SET_WEIGHT 0
	//Some things do not work here like initialising local vars and changing skin right?
	//timerSkinUnidentified  -m 1 50 TWEAK SKIN "Hologram.skybox.index2000.DocIdentified" "Hologram.skybox.index2000.DocUnidentified"
	//timerSkinGrenClear     -m 1 50 TWEAK SKIN "Hologram.tiny.index4000.grenade"         "Hologram.tiny.index4000.grenade.Clear"
	//timerSkinGrenGlowClear -m 1 50 TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow"     "Hologram.tiny.index4000.grenadeGlow.Clear"
	//timerInitDefaults -m 1 50 GoTo TFUNCinitDefaults //this is not granted..
	//GoSub FUNCinitDefaults
	
	ACCEPT
}

ON MovementDetected () {
	if(§DebugTestLOD == 1) ACCEPT
	//Set @posmex ^locationx_~^me~
	//Set @posmey ^locationy_~^me~
	//Set @posmez ^locationz_~^me~
	////Set £TestMovementdetected "~£TestMovementdetected~, SENDER:~^sender~, ME:~^me~, (~@posmex~,~@posmey~,~@posmez~), "
	//Set £TestMovementdetected "SENDER:~^sender~, ME:~^me~, (~@posmex~,~@posmey~,~@posmez~), "
	
	if (and(§AncientDeviceTriggerStep == 2 && £FUNCAncientDeviceActivationToggle«Mode == "DetectTargetNearby")) { // Active
		GoSub FUNCsignalStrenghCheck
		if(§FUNCsignalStrenghCheck«IsAcceptable == 0) {
			GoSub -p FUNCAncientDeviceActivationToggle £»force="OFF" ;
		}
		
		GoSub FUNCupdateIcon
	}
	
	ACCEPT
}

ON Clone () { //happens when unstacking. is more reliable than ON INIT because INIT also clone local vars values
	if(§DebugTestLOD == 1) ACCEPT
	Set £CloneInfo "SENDER:~^sender~, ME:~^me~"
	GoSub -p FUNCshowlocals £»filter="CloneInfo" §»force=1 ;
	if(§InitDefaultsDone == 0) GoSub FUNCinitDefaults
	ACCEPT
}

ON IDENTIFY () { //this is called (apparently every frame) when the player hovers the mouse over the item, but requires `SETEQUIP identify_value ...` to be set or this event wont be called.
	if(§DebugTestLOD == 1) ACCEPT
	if(§InitDefaultsDone == 0) GoSub FUNCinitDefaults
	
	GoSub FUNChoverInfo //TODO RM?
	if(£AncientDeviceMode == "ConfigOptions")	GoSub FUNCconfigOptionHover
	
	if (^amount > 1) ACCEPT //this must not be a stack of items
	//Set £ScriptDebugProblemTmp "identified=~§Identified~;ObjKnow=~^PLAYER_SKILL_OBJECT_KNOWLEDGE~"
	//if ( §Identified > 0 ) ACCEPT //w/o this was flooding the log, why?
	//if ( §IdentifyObjectKnowledgeRequirement == 0 ) ACCEPT //useless?
	if ( §Identified == 0 ) {
		if ( ^PLAYER_SKILL_OBJECT_KNOWLEDGE >= §IdentifyObjectKnowledgeRequirement ) {
			Set §Identified 1
			
			//if (§UseCount == 0) { //no uses will still be showing the doc so we know it is still to show the doc. this prevents changing if already showing a nice landscape
				//Set £SkyBoxCurrent "Hologram.skybox.index2000.DocIdentified"
				//Set £SkyBoxPrevious "~£SkyBoxCurrent~"
				//TWEAK SKIN "Hologram.skybox.index2000.DocUnidentified" "~£SkyBoxCurrent~"
			//}
			
			if(£AncientDeviceMode == "") Set £AncientDeviceMode "AncientBox" GoSub FUNCcfgAncientDevice
			
			Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;Identified_Now"
			
			GoSub -p FUNCshowlocals £»filter=".*(identified|stack).*" §»force=1 ;
		}
	} else {
		if (^#timer2 == 0) StartTimer timer2
		if (^#timer2 > 333) { //TOKEN_MOD_CFG
			GoSub FUNCupdateUses
			GoSub FUNCnameUpdate
			starttimer timer2
		}
	}
	ACCEPT
}

>>FUNCpatchNPCinventory() {
	//INPUT <£FUNCpatchNPCinventory«npc>
	
	if(£«npc == "") {
		GoSub -p FUNCCustomCmdsB4DbgBreakpoint £»DbgMsg="ERROR:invalid £«npc='~£«npc~'" ;
		RETURN
	}
	
	Set -r £«npc §«ChkNpcInvIsPatched §NPCvar_HoloLootPatchDone
	if(§«ChkNpcInvIsPatched == 0) { //each item has a weight
		//Set -ri £«npc §«HoloAdd "rune"
		Set §«HoloAddTotal 0
		
		Inventory GetItemCount -e £«npc §«HoloAdd "rune"
		Mul §«HoloAdd 36
		Add §«HoloAddTotal ^rnd_~§«HoloAdd~
		
		Inventory GetItemCount -e £«npc §«HoloAdd "ring"
		Mul §«HoloAdd 18
		Add §«HoloAddTotal ^rnd_~§«HoloAdd~
		
		Inventory GetItemCount -e £«npc §«HoloAdd "scroll"
		Mul §«HoloAdd 12
		Add §«HoloAddTotal ^rnd_~§«HoloAdd~
		
		Inventory GetItemCount -e £«npc §«HoloAdd "potion"
		Mul §«HoloAdd 6
		Add §«HoloAddTotal ^rnd_~§«HoloAdd~
		
		//todo other magic items could add 4
		
		Inventory GetItemCount -e £«npc §«HoloAdd "bottle"
		Mul §«HoloAdd 2
		Add §«HoloAddTotal ^rnd_~§«HoloAdd~
		
		Add §«HoloAddTotal ^rnd_1 //minimum chance
		
		if(§«HoloAddTotal > 0) {
			Inventory AddMulti -e £«npc "magic/hologram/hologram" §«HoloAddTotal
		}
		
		Set -w £«npc §NPCvar_HoloLootPatchDone 1
	}
	
	// clear b4 next call
	Set £«npc ""
	RETURN
}

//>>FUNCisnInvOrFloor ()
On Main () { //HeartBeat happens once per second apparently (but may be less often?)
	if(§DebugTestLOD == 1) ACCEPT
	if(§InitDefaultsDone == 0) GoSub FUNCinitDefaults
	
	Set £_aaaDebugScriptStackAndLog "On Main:"
	
	if (^amount > 1) ACCEPT //this must not be a stack of items
	Set £inInventory ^ininventory
	if (not(or(£inInventory == "none" || £inInventory == "player"))) ACCEPT //only works if in player inventory or on floor, so will not work on other containers, on corpses and on NPC inventories
	
	GoSub FUNChoverInfo
	
	Set £LootingInventory ^lootinventory
	if(£LootingInventory != "none") { //dynamically patch inventories
		GoSub -p FUNCpatchNPCinventory £»npc=£LootingInventory ;
	}
	
	if ( £AncientDeviceMode == "HologramMode" ) {
		if (§bHologramInitialized == 0) ACCEPT
		
		if (§DestructionStarted == 1) {
			//attractor SELF 1 3000
			GoSub FUNCaimPlayerCastLightning
			GoSub FUNCMakeNPCsHostile // as NPC may be in-between
			Set £ScriptDebugProblemTmp "MAIN:BeingDestroyed;" GoSub FUNCshowlocals
			PLAY -s //stops sounds started with -i flag
		} else {
			//////////////// auto repairs the hologram device
			if (^#timer1 == 0) starttimer timer1
			if (^#timer1 > 60000) { //once per minute. if the player waits, it will self fix after a long time.
				if (§UseCount != 0) {
					Set §UseRegen §UseMax
					Div §UseRegen 10 //minutes
					Dec §UseCount §UseRegen
					if (§UseCount < 0) Set §UseCount 0
					GoSub FUNCupdateUses
					GoSub FUNCnameUpdate
					GoSub FUNCshowlocals
				}
				starttimer timer1
			}
			
			/////////////// slow the player fleeing
			//if ( ^#PLAYERDIST < 250 ) { //this attract strengh is just annoying actually..
				//attractor SELF 3 250
			//} else {
				//attractor SELF OFF
			//}
			
			//////////////// improve landscape visualization
			////ISSUE: worldfade just paints the whole screen with that color w/o alpha :(, wont help to make outside darker
			if ( ^#PLAYERDIST <= 350 ) { //350 is good as the sound volume lowers :)
				if (§SkyMode == 2) { //cubemap
					if(§PlayingAmbientSoundForSkyMode != §SkyMode) {
						PLAY -ilp "~£SkyBoxCurrent~.wav"
						Set §PlayingAmbientSoundForSkyMode §SkyMode
					}
				} else { //uvsphere 1
					if(§PlayingAmbientSoundForSkyMode != §SkyMode) {
						PLAY -ilp "~£SkyBoxCurrentUVS~.wav"
						Set §PlayingAmbientSoundForSkyMode §SkyMode
					}
				}
				//if( £DoWorldFade != 1 ){
					//worldfade out 1000 0.25 0.25 0.25
					//Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;OnMain:FadeOut"
					//Set £DoWorldFade 1
				//}
			} else {
				PLAY -s //stops sounds started with -i flag
				Set §PlayingAmbientSoundForSkyMode 0 //reset 
				//if( £DoWorldFade != 2 ){
					//worldfade in 1000
					//Set £DoWorldFade 2
				//}
			}
		}
	} else { if ( £AncientDeviceMode == "SignalRepeater" ) {
		SENDEVENT -ir CUSTOM 3000 "CustomCmdSignalRepeater ~^me~ ~@SignalStrength~"
	} else { if ( £AncientDeviceMode == "RoleplayClassFocus" ) {
		Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;~£AncientDeviceMode~" //TODO chk ^dragged to hold cooking?
	} else { if ( £AncientDeviceMode == "Grenade" ) {
		Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;~£AncientDeviceMode~" //TODO chk ^dragged to hold cooking?
	} else { if ( £AncientDeviceMode == "LandMine" ) {
		Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;~£AncientDeviceMode~" //TODO
	} else { if ( £AncientDeviceMode == "Teleport" ) {
		Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;~£AncientDeviceMode~" //TODO
	} else { if ( £AncientDeviceMode == "MindControl" ) {
		Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;~£AncientDeviceMode~" //TODO
	} else { if ( £AncientDeviceMode == "SniperBullet" ) {
		Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;~£AncientDeviceMode~" //TODO
	} } } } } } } }
	
	// any item that is going to explode will benefit from this
	Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;Chk:TrapCanKillMode"
	if (§FUNCtrapAttack«TrapCanKillMode_OUTPUT == 1) {
		Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;TrapCanKillMode"
		//attractor SELF 1 1000
		GoSub FUNCMakeNPCsHostile //this is good as while the item is flying after being thrown, NPCs will wake up near it!
	}
	
	ACCEPT
}

ON CUSTOM () { //this is the receiving end of the transmission
	if(§DebugTestLOD == 1) ACCEPT
	if(§InitDefaultsDone == 0) GoSub FUNCinitDefaults
	
	if (^amount > 1) ACCEPT //this must not be a stack of items
	
	// ^$param<i> £string, ^&param<i> @number, ^#param<i> §int
	Set £CustomCommand ^$param1
	
	// RECEIVE SIGNAL FROM REPEATER
	if(£CustomCommand == "CustomCmdSignalRepeater") { 
		//this can be sent by many sources
		//being sent from ON MAIN, this should happen once per second
		Set £SignalRepeaterID          ^$param2
		Set @RepeaterSignalStrengthTmp ^#param3
		if (@RepeaterSignalStrengthTmp > @RepeaterSignalStrength){
			Set £RepeaterStrongestDeployedID £SignalRepeaterID
			Set @RepeaterSignalStrength @RepeaterSignalStrengthTmp
			// this will expectedly happen only after a new signal is received from ON MAIN sendevent that happens once per second //TODO right?
			timerClearRepeaterSignalID  -m 1 3000 Set £RepeaterStrongestDeployedID ""
			timerClearRepeaterSignalStr -m 1 3000 Set @RepeaterSignalStrength 0
		}
	}
	ACCEPT
}

ON COMBINE () {
	if(§DebugTestLOD == 1) ACCEPT
	if(§InitDefaultsDone == 0) GoSub FUNCinitDefaults
	
	Set £ClassMe ^class_~^me~ //SELF
	Set £OtherEntIdToCombineWithMe ^$PARAM1 // is the one that you double click
	Set £«OtherClass ^class_~£OtherEntIdToCombineWithMe~ //OTHER
	
	UnSet £«FailReason
	GoSub -p FUNCshowlocals §»force=1 ;
	
	if (^amount > 1) { //this must not be a stack of items
		SPEAK -p [player_no] NOP
		Set £ScriptDebugCombineFailReason "Self:IsStack"
		GoSub -p FUNCshowlocals §»force=1 ;
		ACCEPT
	}
	
	///////////////////// combine with other classes ///////////////////////
	
	if (or(
		£OtherEntIdToCombineWithMe ISCLASS "bone" || 
		£OtherEntIdToCombineWithMe ISCLASS "torch" || 
		£OtherEntIdToCombineWithMe ISCLASS "wall_block" || 
		£OtherEntIdToCombineWithMe ISCLASS "jail_stone"
	)) { //add anything that can smash it but these are enough. This is not a combine actually, is more like an action. this can break a stack!
		GoSub FUNCbreakDeviceDelayed
		ACCEPT
	}
	
	///////////////////// ancient devices only ///////////////////////
	
	// check other (£OtherEntIdToCombineWithMe is the one that you double click)
	//if (not(and(£OtherEntIdToCombineWithMe ISCLASS "Hologram"))) { //only combine with these
		//SPEAK -p [player_no] NOP
		//Set £«FailReason "Other:Not:Class:Hologram"
		//GoSub -p FUNCshowlocals §»force=1 ;
		//ACCEPT
	//}
	if(£ClassMe != £«OtherClass) {  //only combine if same kind
		SPEAK -p [player_no] NOP
		Set £«FailReason "Class:Differs"
		GoSub -p FUNCshowlocals §»force=1 ;
		ACCEPT
	}
	
	//Set £«FailReason "Test:£AncientDeviceMode=~£AncientDeviceMode~;"
	Set -r £OtherEntIdToCombineWithMe £OtherAncientDeviceMode £AncientDeviceMode //	Set -rw ^me £OtherEntIdToCombineWithMe £OtherAncientDeviceMode £AncientDeviceMode
	if(or(£OtherAncientDeviceMode == "" || £AncientDeviceMode == ""))	GoSub -p FUNCCustomCmdsB4DbgBreakpoint £»DbgMsg="ERROR:invalid ancient device modes to combine '~£OtherAncientDeviceMode~' '~£AncientDeviceMode~'" ;
	if(and(£OtherAncientDeviceMode == £AncientDeviceMode && £AncientDeviceMode != "AncientBox")) { //this is to increase quality, least for the cheapest
		if(§UseMax >= 80) { //quality 4+
			SPEAK -p [player_no] NOP
			Set £«FailReason "Quality:Already:MK2"
			GoSub -p FUNCshowlocals §»force=1 ;
		} else {
			Set -r £OtherEntIdToCombineWithMe §OtherUseMax §UseMax
			if(§OtherUseMax > §UseMax) {
				Set §UseMaxImprove §UseMax
				Set §UseMax §OtherUseMax	Set £DbgTmpUseMax "~£DbgTmpUseMax~;822;~§UseMax~"
			} else {
				Set §UseMaxImprove §OtherUseMax
			}
			Div §UseMaxImprove 5 //just +20% of lowest quality
			Add §UseMax §UseMaxImprove	Set £DbgTmpUseMax "~£DbgTmpUseMax~;827;~§UseMax~"
			
			GoSub FUNCupdateUses
			GoSub FUNCnameUpdate
			GoSub FUNCupdateIcon
			GoSub FUNCsignalStrenghUpdateRequirement
			
			DESTROY £OtherEntIdToCombineWithMe
		}
		ACCEPT
	}
	
	if(£OtherAncientDeviceMode != "AncientBox") { //this is for upgrading/morphing the item
		SPEAK -p [player_no] NOP
		Set £«FailReason "Other:Not:AncientBox"
		GoSub -p FUNCshowlocals §»force=1 ;
		ACCEPT
	}
	
	if (^me isgroup "Special") { //TODO the special objects could create other crafting trees tho
		SPEAK -p [player_no] NOP
		Set £«FailReason "Me:Is:Special"
		GoSub -p FUNCshowlocals §»force=1 ;
		ACCEPT
	}
	
	if (£OtherEntIdToCombineWithMe !isgroup "DeviceTechBasic") {
		SPEAK -p [player_no] NOP
		Set £«FailReason "Other:Not:Group:DeviceTechBasic:Aka_hologram"
		GoSub -p FUNCshowlocals §»force=1 ;
		ACCEPT
	}
	
	if(£AncientDeviceMode == "SniperBullet") { //SYNC_WITH_LAST_COMBINE sync with last/max combine option
		SPEAK -p [player_no] NOP
		Set £«FailReason "Self:Limit_reached:Combine_options"
		GoSub -p FUNCshowlocals §»force=1 ;
		ACCEPT
	}
	
	//check self (the target of the combination request)
	//if (§bHologramInitialized == 0){
		//SPEAK -p [player_no] NOP
		//Set £«FailReason "Self:NotInitialized"
		//GoSub FUNCshowlocals
		//ACCEPT
	//}
	if (^amount > 1) { //this must not be a stack of items
		SPEAK -p [player_no] NOP
		Set £«FailReason "Self:IsStack"
		GoSub -p FUNCshowlocals §»force=1 ;
		ACCEPT
	}
	if (§Identified == 0) {
		SPEAK -p [player_not_skilled_enough] NOP
		Set £«FailReason "Self:NotIdentified"
		GoSub -p FUNCshowlocals §»force=1 ;
		ACCEPT
	}
	//if (§AncientDeviceTriggerStep > 0) {
		//SPEAK -p [player_no] NOP
		//Set £«FailReason "Self:TODO:HoloTeleportArrow"
		//GoSub -p FUNCshowlocals §»force=1 ;
		//ACCEPT
	//}
	
	PLAY -s //stops sounds started with -i flag
	
	Set -r £OtherEntIdToCombineWithMe §FUNCmorphUpgrade_otherQuality §Quality
	GoSub FUNCmorphUpgrade
	
	DESTROY £OtherEntIdToCombineWithMe
	
	GoSub -p FUNCshowlocals §»force=1 ;
	ACCEPT
}

ON InventoryIn () { Set £_aaaDebugScriptStackAndLog "On_InventoryIn" //this happens when item is added to an inventory right?
	if(§DebugTestLOD == 1) ACCEPT
	//if (^amount > 1) ACCEPT //this must not be a stack of items
	PLAY -s //stops sounds started with -i flag
	ACCEPT
}

ON InventoryOut () { Set £_aaaDebugScriptStackAndLog "On_InventoryOut" //this happens when item is removed from an inventory right?
	if(§DebugTestLOD == 1) ACCEPT
	//if (^amount > 1) ACCEPT //this must not be a stack of items
	PLAY -s //stops sounds started with -i flag
	ACCEPT
}

//On Hit () { //nothing happens
	//Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;OnHit:~^durability~/~^maxdurability~"
	//INC §UseCount 30
	//ACCEPT
//}
//on collide_npc () { //nothing happens
	//Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;collide_npc"
	//ACCEPT
//}
//on collision_error () { //nothing happens
	//Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;collision_error"
	//ACCEPT
//}

>>TFUNCaimPlayerCastLightning () { GoSub FUNCaimPlayerCastLightning ACCEPT } >>FUNCaimPlayerCastLightning () { //TODO this doesnt work well when called from a timer, why?
	//ifVisible PLAYER { //use for fireball too? //this doesnt work for objects?
		Set §RotateYBkp §RotateY //bkp auto rotate angle speed
		Set §RotateY 0 //this stops the rotation (but may not stop for enough time tho to let the lightning work properly)
		//forceangle <yaw*> //unnecessary?
		//^angleto_<entity> //unnecessary?
		//forceangle ^angleto_PLAYER //unnecessary?
		GoSub FUNCshockPlayer
		timerRestoreRotationSpeed -m 1 100 Set §RotateY §RotateYBkp // restore auto rotate speed after the shock has time to be cast
	//}
	//GoSub FUNCshowlocals
	RETURN //to return to wherever it needs?
}

>>TFUNCMalfunction () { GoSub FUNCMalfunction ACCEPT } >>FUNCMalfunction () {
	Set §SfxRnd ^rnd_3
	if (§SfxRnd == 0) play "SFX_electric"
	if (§SfxRnd == 1) play "sfx_spark"
	if (§SfxRnd == 2) GoSub FUNCshockPlayer
	RETURN
}

>>TFUNCChangeSkyBox () { GoSub FUNCChangeSkyBox ACCEPT } >>FUNCChangeSkyBox () {
	RANDOM 50 { // skybox cubemap mode
		if (§SkyMode == 1) { //was UVSphere, so hide it
			Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;From UVSphere to CubeMap"
			Set £SkyBoxPreviousUVS "~£SkyBoxCurrentUVS~"
			Set £SkyBoxCurrentUVS "Hologram.skybox.UVSphere.index3000.Clear"
			TWEAK SKIN "~£SkyBoxPreviousUVS~" "~£SkyBoxCurrentUVS~"
		}
		Set £SkyBoxPrevious "~£SkyBoxCurrent~" //store current to know what needs to be replaced
		Set §SkyBoxIndex ^rnd_2 //SED_TOKEN_TOTAL_SKYBOXES_CUBEMAP: to be easy to auto patch, sync with the skyboxes bash script. if rnd_3 will result in 0 1 2
		Set £SkyBoxCurrent "Hologram.skybox.index~§SkyBoxIndex~" //update current
		if (£SkyBoxCurrent == "~£SkyBoxPrevious~") {
			Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;SBI=~§SkyBoxIndex~"
			GoTo FUNCChangeSkyBox //LOOP this looks safe but needs at least 2 skyboxes
		}
		TWEAK SKIN "~£SkyBoxPrevious~" "~£SkyBoxCurrent~"
		Set §SkyMode 2
	} else { //skybox UVSphere mode 1
		if (§SkyMode == 2) { //was CubeMap, so hide it
			Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;From CubeMap to UVSphere"
			Set £SkyBoxPrevious "~£SkyBoxCurrent~"
			Set £SkyBoxCurrent "Hologram.skybox.index3000.Clear"
			TWEAK SKIN "~£SkyBoxPrevious~" "~£SkyBoxCurrent~"
		}
		Set £SkyBoxPreviousUVS "~£SkyBoxCurrentUVS~" //store current to know what needs to be replaced
		Set §SkyBoxIndex ^rnd_9 //SED_TOKEN_TOTAL_SKYBOXES_UVSPHERE: to be easy to auto patch, sync with the skyboxes bash script. if rnd_3 will result in 0 1 2
		Set £SkyBoxCurrentUVS "Hologram.skybox.UVSphere.index~§SkyBoxIndex~" //update current
		if (£SkyBoxCurrentUVS == "~£SkyBoxPreviousUVS~") {
			Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;SBI(UVS)=~§SkyBoxIndex~"
			GoTo FUNCChangeSkyBox //LOOP this looks safe but needs at least 2 skyboxes
		}
		TWEAK SKIN "~£SkyBoxPreviousUVS~" "~£SkyBoxCurrentUVS~"
		Set §SkyMode 1
	}
	//GoSub FUNCshowlocals
	RETURN
}

>>FUNCconfigOptionHover () {
	// X degrees from 74.9 (downest) to 0 in the horizon. from 360 in the horizon to 301 (upperest)
	// Each face has 11 options.
	// Top and bottom faces can only provide access to half the options looking upwards, so we will use just 5 and the limit to the center one.
	// total accessibblle options in X: 11+5+5 = 21
	// available degrees in X: (360-301=59 + 74.9-0=74.9)=133.9=134
	// each opt degrees range: 134 / 21 = 6.3809523809
	Set @CfgOptHoverX ^degreesx_player 
	Set @CfgOptHoverY ^degreesy_player 
	// calc option up/down degrees range to index. this convert the degrees into 0-134 from bottom to top
	if(@CfgOptHoverX < 75) {
		Calc @CfgOptIndexTmp [ 74.9 - @CfgOptHoverX ]
	} else { if(@CfgOptHoverX > 300) {
		Calc @CfgOptIndexTmp [ 74.9 + 59 - [ @CfgOptHoverX - 301 ] ]
	} }
	Div @CfgOptIndexTmp 6.3809523809
	Set §CfgOptIndexTruncTmp @CfgOptIndexTmp
	Add §CfgOptIndexTruncTmp 1 //to fix from 0.0 to 1.0 that is the lowest option
	// §CfgOptIndexTruncTmp 1-5 (5) bottom, 6-16 (11) horizon, 17-21 (5) top
	Set §CfgOptIndex -1
	
	// this below translates to CfgOptions
	// quadrants in Y rotation
	Set §CfgOptIndexTruncTmp2 21
	Sub §CfgOptIndexTruncTmp2 §CfgOptIndexTruncTmp
	if(and(@CfgOptHoverY > 0 && @CfgOptHoverY < 90)) { //Cfg Opts 6-
		if(§CfgOptIndexTruncTmp <= 5) { //bottom
		} else {
		if(and(§CfgOptIndexTruncTmp >= 6 && §CfgOptIndexTruncTmp <= 16)) { //horizon
			Set §CfgOptIndex 6
			Add §CfgOptIndex §CfgOptIndexTruncTmp
		} else {
		if(§CfgOptIndexTruncTmp >= 17) { //top
		} } }
	} else {
	if(and(@CfgOptHoverY > 90 && @CfgOptHoverY < 180)) {
	} else {
	if(and(@CfgOptHoverY > 180 && @CfgOptHoverY < 270)) {
	} else {
	if(and(@CfgOptHoverY > 270 && @CfgOptHoverY < 360)) {
	}	} } }
	GoSub -p FUNCconfigOptionHighlight §»index=§CfgOptIndex ;
	RETURN
}
>>FUNCconfigOptionHighlight () {
	//INPUT: <§FUNCconfigOptionHighlight_index>
	if(§FUNCconfigOptionHighlight_index < 0) GoSub FUNCCustomCmdsB4DbgBreakpoint
	
	Set £FUNCconfigOptions«mode "show"
	
	if(§FUNCconfigOptionHighlight_indexPrevious > -1) {
		//Set £FUNCconfigOptions«mode "hide"
		Set §FUNCconfigOptions«index §FUNCconfigOptionHighlight_indexPrevious
		GoSub CFUNCconfigOptionUpdate
	}
	
	Set §FUNCconfigOptions«index §FUNCconfigOptionHighlight_index
	GoSub CFUNCconfigOptionUpdate
	
	Set §FUNCconfigOptionHighlight_indexPrevious §FUNCconfigOptionHighlight_index
	
	Set §FUNCconfigOptionHighlight_index -1 //set to invalid, so next call requires it being set
	RETURN
}
>>FUNCconfigOptions () {
	//INPUT: [£«mode] values: "hide" "show"
	if(£«mode == "hide") {
		TWEAK SKIN "Hologram.ConfigOptions"	"Hologram.ConfigOptions.Clear"
		Set §«index 1 >>LOOP_FCO_ClearAll
			GoSub CFUNCconfigOptionHide
		++ §«index if(§«index <= §ConfigOptions_maxIndex) GoTo LOOP_FCO_ClearAll
	} else {
	if(£«mode == "show") {
		TWEAK SKIN "Hologram.ConfigOptions.Clear" "Hologram.ConfigOptions"
		
		//TOKEN_AUTOPATCH_UpdateCfgOpt_BEGIN
		GoSub -p CFUNCconfigOptionUpdate @»check=&G_HologCfgOpt_ClassFocus ;
		GoSub -p CFUNCconfigOptionUpdate @»check=&G_HologCfgOpt_DebugTests ;
		GoSub -p CFUNCconfigOptionUpdate @»check=&G_HologCfgOpt_ShowLocals ;
		//TOKEN_AUTOPATCH_UpdateCfgOpt_END
	} }
	
	Set £«mode "hide" //default for next call
	RETURN
}
>>CFUNCconfigOptionUpdate () {
	//INPUT: <@«check>
	if(@«check < 0) GoSub FUNCCustomCmdsB4DbgBreakpoint
	
	Set §FUNCconfigOptions«index @«check
	// trunc will get the index. if identical, means disabled: ex.: disabled: 33.0 == 33, enabled: 33.1 != 33
	if(@«check == §FUNCconfigOptions«index) { //.0 means disabled
		GoSub CFUNCconfigOptionDisable
	} else { //.1 means enabled
		GoSub CFUNCconfigOptionEnable
	}
	
	if(§FUNCconfigOptions«index == &G_HologCfgOpt_ShowLocals) {
		if(&G_HologCfgOpt_ShowLocals > §FUNCconfigOptions«index) {
			Set &G_Debug_ShowLocals 1 // &G_HologCfgOpt_ShowLocals == 21.1
		} else {
			Set &G_Debug_ShowLocals 0 // &G_HologCfgOpt_ShowLocals == 21.0
		}
	}
	
	Set @«check -1 //set invalid to be required on next call
	RETURN
}
>>CFUNCconfigOptionToggle () {
	//INPUT: <@CFUNCconfigOptionToggle_check>
	if(@CFUNCconfigOptionToggle_check < 0) GoSub FUNCCustomCmdsB4DbgBreakpoint
	//OUTPUT: @CFUNCconfigOptionToggle_set_OUTPUT
	Set §CFUNCconfigOptionToggle_trunc @CFUNCconfigOptionToggle_check
	Sub @CFUNCconfigOptionToggle_check §CFUNCconfigOptionToggle_trunc //if enabled will result in 0.1
	Set @CFUNCconfigOptionToggle_set_OUTPUT §CFUNCconfigOptionToggle_trunc //disable (the below if fails so..)
	if(@CFUNCconfigOptionToggle_check == 0.0)	Add @CFUNCconfigOptionToggle_set_OUTPUT 0.1 //enable
	Set @CFUNCconfigOptionToggle_check -1 //set invalid to req on next call
	RETURN
}
>>CFUNCconfigOptionEnable () {
	TWEAK SKIN "Hologram.ConfigOptions.index~%05d,§FUNCconfigOptions«index~.Clear" "Hologram.ConfigOptions.index~%05d,§FUNCconfigOptions«index~.Enabled" 
	RETURN
}
>>CFUNCconfigOptionDisable () {
	TWEAK SKIN "Hologram.ConfigOptions.index~%05d,§FUNCconfigOptions«index~.Enabled" "Hologram.ConfigOptions.index~%05d,§FUNCconfigOptions«index~.Clear"
	RETURN
}
>>CFUNCconfigOptionHide () {
	TWEAK SKIN "Hologram.ConfigOptions.index~%05d,§FUNCconfigOptions«index~.Enabled" "Hologram.ConfigOptions.index~%05d,§FUNCconfigOptions«index~.Clear"
	if(§FUNCconfigOptions«index == §FUNCconfigOptions_HighlightIndex) {
		TWEAK SKIN "Hologram.ConfigOptions.Highlight" "Hologram.ConfigOptions.index~%05d,§FUNCconfigOptions«index~.Clear"
		TWEAK SKIN "Hologram.ConfigOptions.EnabledAndHighlight" "Hologram.ConfigOptions.index~%05d,§FUNCconfigOptions«index~.Clear"
	}
	RETURN
}
/*
>>CFUNCconfigOptions_Update () {
	//INPUT: <§FUNCconfigOptions«index>
	//INPUT: <£FUNCconfigOptions«mode>
	if(£FUNCconfigOptions«mode == "hide") { //mainly used to hide this skybox layer 
		TWEAK SKIN "Hologram.ConfigOptions.index~%05d,§FUNCconfigOptions«index~.Enabled" "Hologram.ConfigOptions.index~%05d,§FUNCconfigOptions«index~.Clear"
		if(§FUNCconfigOptions_HighlightIndex == §FUNCconfigOptions«index) {
			TWEAK SKIN "Hologram.ConfigOptions.Highlight" "Hologram.ConfigOptions.index~%05d,§FUNCconfigOptions«index~.Clear"
			TWEAK SKIN "Hologram.ConfigOptions.EnabledAndHighlight" "Hologram.ConfigOptions.index~%05d,§FUNCconfigOptions«index~.Clear"
		}
	} else {
	if(£FUNCconfigOptions«mode == "show") {
		if(§FUNCconfigOptions_HighlightIndex == §FUNCconfigOptions«index) {
			TWEAK SKIN "Hologram.ConfigOptions.index~%05d,§FUNCconfigOptions«index~.Clear" "Hologram.ConfigOptions.EnabledAndHighlight" 
			TWEAK SKIN "Hologram.ConfigOptions.index~%05d,§FUNCconfigOptions«index~.Enabled" "Hologram.ConfigOptions.EnabledAndHighlight" 
		} else {
			TWEAK SKIN "Hologram.ConfigOptions.index~%05d,§FUNCconfigOptions«index~.Clear" "Hologram.ConfigOptions.index~%05d,§FUNCconfigOptions«index~.Enabled" 
			if(§FUNCconfigOptions_HighlightIndex == §FUNCconfigOptions«indexprevious todoa) {
			}
		}
	} }
	RETURN
}
*/

>>TFUNCinitDefaults () { GoSub FUNCinitDefaults ACCEPT } >>FUNCinitDefaults () { //DO NOT CALL FROM "ON INIT" or every item on the stack will have the same random values!!! :(
	if(§InitDefaultsDone > 0) RETURN
	if (^amount > 1) RETURN //this must not be a stack of items to prevent identical random values!
	
	Set &G_DebugMode 1 //COMMENT_ON_RELEASE
	
	if(£AncientDeviceMode == "") Set £AncientDeviceMode "AncientBox" GoSub FUNCcfgAncientDevice
	
	GoSub -p FUNCconfigOptions £»mode="hide" ;
	TWEAK SKIN "Hologram.skybox.index2000.DocIdentified"	"Hologram.skybox.index2000.DocUnidentified"
	TWEAK SKIN "Hologram.tiny.index4000.grenade"					"Hologram.tiny.index4000.grenade.Clear"
	TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow"			"Hologram.tiny.index4000.grenadeGlow.Clear" //TODO RM in favor of Halo ?
	
	if(§iFUNCMakeNPCsHostile_rangeDefault == 0) {
		Set §iFUNCMakeNPCsHostile_rangeDefault 350 //the spell explosion(chaos) range //SED_TOKEN_MOD_CFG
		Set §iFUNCMakeNPCsHostile_range §iFUNCMakeNPCsHostile_rangeDefault
	}
	
	Set §ConfigOptions_maxIndex 66 //SED_TOKEN_MOD_CFG
	// .0 means initially disabled (.1 would mean enabled initially)
	//TOKEN_AUTOPATCH_CfgOptDefaults_BEGIN
	if(&G_HologCfgOpt_ClassFocus == 0) Set &G_HologCfgOpt_ClassFocus 17.0
	if(&G_HologCfgOpt_ShowLocals == 0) Set &G_HologCfgOpt_ShowLocals 21.0
	if(&G_HologCfgOpt_DebugTests == 0) Set &G_HologCfgOpt_DebugTests 22.0
	//TOKEN_AUTOPATCH_CfgOptDefaults_BEGIN
	
	Set §MaxUseMax 115
	//if(&G_HologRnd < §MaxUseMax) {
		//Set &G_HologRnd ^rnd_99999
	//} else {
		//Set &G_HologRnd ^rnd_~&G_HologRnd~
	//}
	//Set §UseMax &G_HologRnd
	////Set §UseMax ^arxseconds //^arxtime //raw time
	//Set £DbgTmpUseMax "~£DbgTmpUseMax~;~§UseMax~"
	//Mod §UseMax §MaxUseMax
	//Set £DbgTmpUseMax "~£DbgTmpUseMax~;~§UseMax~"
	//if(§UseMax < 5) Set §UseMax 5
	////Add §UseMax 5 //minimum
	//Set £DbgTmpUseMax "~£DbgTmpUseMax~;~§UseMax~;...;~^arxtime~;~^arxtime~"
	////Set §UseMax 5	Set £DbgTmpUseMax "~£DbgTmpUseMax~;1159;~§UseMax~"
	////Add §UseMax ^random_110	Set £DbgTmpUseMax "~£DbgTmpUseMax~;1160;~§UseMax~"
	////Set £DbgTmpUseMax "~£DbgTmpUseMax~;1160;~^rnd_110~;~^rnd_110~;~^rnd_110~;~^rnd_110~;~^rnd_110~" //random is predictive and is giving the same exact values everytime I reload the game ... :/
	////Set £DbgTmpUseMax2 "~£DbgTmpUseMax2~;1162;~^random_110~;~^random_110~;~^random_110~;~^random_110~;~^random_110~" //random is predictive and is giving the same exact values everytime I reload the game ... :/
	//Set £DbgTmpUseMax2 "~£DbgTmpUseMax2~;~^me~;~^random_110~;~^random_110~;~^random_110~;~^random_110~;~^random_110~" //random is predictive and is giving the same exact values everytime I reload the game ... :/
	//if(#G_HologRnd < §MaxUseMax) Set #G_HologRnd 99999
	//Sub #G_HologRnd ^rnd_~§MaxUseMax~
	//Set §UseMax #G_HologRnd
	//Mod §UseMax §MaxUseMax
	Set §UseMax ^rnd_~§MaxUseMax~
	if(§UseMax < 5) Set §UseMax 5
	
	Set §SeekTargetDistance 5001
	Set §TeleDistEndTele 200 //if player is above the item on the floor, it will be 177 dist. The dist of the item on the floor to a goblin is 67 btw. Must be above these.
	
	//////////////////// signal
	if(#G_HologCfg_InitGlobalsDone == 0) {
		Set $G_Holog_SignalMode "NoSignal" //initially None with 0 delay below, will instantly become working mode the first time player sees it
		Set #G_Holog_SignalModeChangeTime 0
	}
	
	GoSub FUNCsignalStrenghUpdateRequirement
	
	Set §SignalDistBase 1000 //SED_TOKEN_MOD_CFG
	
	Set §SignalDistHalf §SignalDistBase
	Div §SignalDistHalf 2
	
	//Set §SignalDistMin §SignalDistBase
	//Mul §SignalDistMin 0.25
	Calc §SignalDistMin [ §SignalDistBase * 0.25 ]
	
	//Set §IdentifyObjectKnowledgeRequirement 35
	Set §UseCount 0
	//Set §DefaultTrapTimoutSec 5 //SED_TOKEN_MOD_CFG
	Set §DefaultTrapTimeoutMillis 5000 //SED_TOKEN_MOD_CFG
	
	Collision ON //nothing happens when thrown?
	Damager -eu 3 //doesnt damage NPCs when thrown?
	
	++ §InitDefaultsDone
	++ #G_HologCfg_InitGlobalsDone
	Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;FUNCinitDefaults:~^me~"
	GoSub -p FUNCshowlocals §»force=1 ;
	
	RETURN
}

>>TFUNCMakeNPCsHostile () { GoSub FUNCMakeNPCsHostile ACCEPT } >>FUNCMakeNPCsHostile ()  {
	//INPUT: [§iFUNCMakeNPCsHostile_range]
	
	//FAIL: Set ^sender PLAYER ; SendEvent -nr Hit §iFUNCMakeNPCsHostile_range "0.01 summoned" //hits every NPC (-n is default) in 3000 range for 0.01 damage and tells it was the player (summoned sets ^sender to player)
	//FAIL: SendEvent -nr AGGRESSION §iFUNCMakeNPCsHostile_range "" //what params to use here??? // this just make them shake but wont become hostile
	//MakesNoSenseHere: SendEvent -nr STEAL §iFUNCMakeNPCsHostile_range "ON" //works!!!
	//TooMuchHere: SendEvent -nr ATTACK_PLAYER §iFUNCMakeNPCsHostile_range ""
	
	///////////// GOOD! /////////////
	//SendEvent -nr PLAYER_ENEMY §iFUNCMakeNPCsHostile_range "" //(for goblin at least) this is good, if player is too near it attacks, otherwise only if player is visible
	SendEvent -nr CALL_HELP §iFUNCMakeNPCsHostile_range "" //(for goblin at least) this is good, if player is too near it attacks, otherwise only if player is visible. this also checks if npc is sleeping (therefore wont hear the trap sound)
	//TODO if they hear the trap being armed properly, they should flee instead
	
	//restore defaults for next call "w/o params"
	Set §iFUNCMakeNPCsHostile_range §iFUNCMakeNPCsHostile_rangeDefault 
	RETURN
}

>>TFUNCshockPlayer () { GoSub FUNCshockPlayer ACCEPT } >>FUNCshockPlayer () {
	if (^inPlayerInventory == 1) { 
		DropItem -e player "~^me~"
		//PLAY "sfx_lightning_loop"
		//dodamage -l player 1
	}
	//else {
		ForceAngle ^degreesyto_PLAYER
		SPELLCAST -smf @SignalStrLvl LIGHTNING_STRIKE PLAYER //TODO this causes damage? or is just the visual effect?
		Random 25 {
			GoSub FUNCparalysePlayer
		}
		
		//Set §iFUNCMakeNPCsHostile_range 350  //reason: they know it is dangerous to them too.
		GoSub FUNCMakeNPCsHostile
	//}
	
	RETURN
}

>>TFUNCbreakDeviceDelayed () { GoSub FUNCbreakDeviceDelayed ACCEPT } >>FUNCbreakDeviceDelayed () {
	//INPUT: [§FUNCbreakDeviceDelayed_ParalyzePlayer]
	//INPUT: [§FUNCbreakDeviceDelayed_ParalyzePlayerExtraMilis]
	
	SetGroup "DeviceTechBroken"
	//GoSub FUNCshockPlayer
	
	if(§Identified == 1) {
		Set £FUNCnameUpdate«NameBase "Broken Hologram Device" 
	} else {
		Set £FUNCnameUpdate«NameBase "Fracti Grolhoam Fabrica" //latin messy latin
	}
	GoSub FUNCupdateUses
	GoSub FUNCnameUpdate
	
	TWEAK ICON "HologramBroken[icon]"
	
	SetInteractivity NONE
	SpecialFX FIERY
	SPEAK -p [player_picklock_failed] NOP //TODO expectedly just a sound about failure and not about picklocking..
	//SPEAK -p [player_wrong] NOP //TODO expectedly just a sound about failure
	//Set §TmpBreakDestroyMilis §DefaultTrapTimeoutMillis
	////Mul §TmpBreakDestroyMilis 5000
	//Inc §TmpBreakDestroyMilis ^rnd_10000
	Calc §TmpBreakDestroyMilis [ §DefaultTrapTimeoutMillis + ^rnd_10000 ]
	timerTFUNCDestroySelfSafely -m 1 §TmpBreakDestroyMilis GoTo TFUNCDestroySelfSafely //to give time to let the player examine it a bit
	if(§FUNCbreakDeviceDelayed_ParalyzePlayer == 1) {
		//Set @FUNCparalysePlayer_Millis 100
		//Dec @FUNCparalysePlayer_Millis @AncientTechSkill
		//if(@FUNCparalysePlayer_Millis > 0) {
			//Div @FUNCparalysePlayer_Millis 100 //percent now
			//Mul @FUNCparalysePlayer_Millis §TmpBreakDestroyMilis //a percent of the destroy time
			//Inc @FUNCparalysePlayer_Millis §FUNCbreakDeviceDelayed_ParalyzePlayerExtraMilis
			//Set @FUNCparalysePlayer_Millis 1000
			//Inc @FUNCparalysePlayer_Millis ^rnd_2000
			//GoSub FUNCparalysePlayer
		//}
		Set @FUNCparalysePlayer_Millis §TmpBreakDestroyMilis
		Inc @FUNCparalysePlayer_Millis §FUNCbreakDeviceDelayed_ParalyzePlayerExtraMilis
		GoSub FUNCparalysePlayer
		
		timerTrapBreakDestroyParalyze -m 1 §TmpBreakDestroyMilis GoTo TFUNCparalyseIfPlayerNearby //the trap tried to capture the player
	}
	
	//timerTrapBreakDestroyAutoDrop -m 1 1500 DropItem -e player "~^me~"
	timerTFUNCshockPlayer1 -m 1 1500 GoTo TFUNCshockPlayer //this drops it
	timerTFUNCshockPlayer2 -m 0 3000 GoTo TFUNCshockPlayer //this also warns the player
	
	GoSub FUNCshowlocals
	//reset to default b4 next call
	Set §FUNCbreakDeviceDelayed_ParalizePlayer 0
	Set §FUNCbreakDeviceDelayed_ParalyzePlayerExtraMilis 0
	RETURN
}

>>TFUNCupdateUses () { GoSub FUNCupdateUses ACCEPT } >>FUNCupdateUses () {
	Set §UseRemain §UseMax
	Dec §UseRemain §UseCount
	//DO NOT CALL: GoSub FUNCnameUpdate
	if (§UseCount >= §UseHologramDestructionStart) Set §UseBlockedMili 0 //quickly lets the player finish/destroy it
	RETURN
}

>>TFUNCnameUpdate () { GoSub FUNCnameUpdate ACCEPT } >>FUNCnameUpdate () {
	// if not identified, words will be in latin or messed up letters order
	//OUTPUT: £FUNCnameUpdate«NameFinal_OUTPUT
	//if(§Identified == 0) ACCEPT //the player is still not sure about what is going on
	
	Set £«NameFinal_OUTPUT "~£«NameBase~."
	
	//if ( §bHologramInitialized == 1 ) {
		GoSub FUNCcalcAncientTechSkill
		
		GoSub FUNCcalcSignalStrength
		
		// condition from 0.00 to 1.00
		//DO NOT CALL BECOMES ENDLESS RECURSIVE LOOP: GoSub FUNCupdateUses
		Set @ItemCondition §UseRemain
		Div @ItemCondition §UseMax
		Calc @ItemConditionSureTmp [ @ItemCondition * 10 / 2 ]
		Set §ItemConditionSure @ItemConditionSureTmp //trunc
		if(§Identified == 1) {
			//Set -a £ItemConditionDesc §ItemConditionSure "Perfect Excellent Good Average Bad Critical"
			Set -v £ItemConditionDesc §ItemConditionSure "Critical" "Bad" "Average" "Good" "Excellent" "Perfect" ;
		} else {
			//                                            latin       latin   messy     latin   messy       messy
			Set -v £ItemConditionDesc §ItemConditionSure "discrimine" "malae" "gearave" "bonae" "ntexlecel" "etcerpf" ;
		}
		
		Set §SignalStrSure §SignalStrengthTrunc
		Div §SignalStrSure 33
		Inc §SignalStrSure 1
		if(§SignalStrengthTrunc == 0) Set §SignalStrSure 0
		if(§SignalStrengthTrunc >= 95) Set §SignalStrSure 4
		if(§Identified == 1) {
			Set -v £SignalStrInfo §SignalStrSure "None" "Bad" "Good" "Strong" "Excellent" ;
		} else {
			//                                    latin    latin   latin   latin    messy
			Set -v £SignalStrInfo §SignalStrSure "Nullum" "Malae" "Bonae" "Fortis" "Ntexlecel" ;
		}
		
		// perc
		//Set @ItemConditionTmp @ItemCondition
		//Mul @ItemConditionTmp 100
		Calc @ItemConditionTmp [ @ItemCondition * 100 ]
		Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;*100=~@ItemCondition~"
		Set §ItemConditionPercent @ItemConditionTmp //trunc
		
		//TODO this always fails too, is always dreadful...
		//if(§UseMax >  105) Set £ItemQuality "pristine" else //105 (and not 100) means a more perceptible superiority
		//if(§UseMax >=  80) Set £ItemQuality "superior" else
		//if(§UseMax >=  60) Set £ItemQuality "decent"   else
		//if(§UseMax >=  40) Set £ItemQuality "mediocre" else
		//if(§UseMax >=  20) Set £ItemQuality "inferior" else
		//{                  Set £ItemQuality "dreadful" }
		if (§UseMax >= 95) {
			Set §Quality 5
		} else {
			Set §Quality §UseMax
			Div §Quality 10
			Div §Quality  2
		}
		
		if(§Identified == 1) {
			//if(§Quality >= 5) Set £ItemQuality "pristine+"
			//if(§Quality == 4) Set £ItemQuality "superior+" //80+
			//if(§Quality == 3) Set £ItemQuality "decent"
			//if(§Quality == 2) Set £ItemQuality "mediocre"
			//if(§Quality == 1) Set £ItemQuality "inferior"
			//if(§Quality == 0) Set £ItemQuality "dreadful"
			Set -v £ItemQuality §Quality "dreadful" "inferior" "mediocre" "decent" "superior+" "pristine+" ;
		} else {
			//if(§Quality >= 5) Set £ItemQuality "nistepri+"
			//if(§Quality == 4) Set £ItemQuality "orpesuri+"
			//if(§Quality == 3) Set £ItemQuality "tdenec"
			//if(§Quality == 2) Set £ItemQuality "edimecro"
			//if(§Quality == 1) Set £ItemQuality "nrifeior"
			//if(§Quality == 0) Set £ItemQuality "horribilis" //latin
			//                           latin        messy...
			Set -v £ItemQuality §Quality "horribilis" "nrifeior" "edimecro" "tdenec" "orpesuri+" "nistepri+" ;
		}
		
		if ( §Quality >= 4 ) {
			if(§Identified == 1) {
				Set £«NameFinal_OUTPUT "~£«NameFinal_OUTPUT~ MK2+" 
			} else {
				Set £«NameFinal_OUTPUT "~£«NameFinal_OUTPUT~ Gradus Duo+" 
			}
		}
		GoSub FUNCupdateIcon
		
		if(§AncientDeviceTriggerStep == 1){
			Set £«NameFinal_OUTPUT "~£«NameFinal_OUTPUT~ (off)."
		}
		if(§AncientDeviceTriggerStep == 2){
			if(§FUNCsignalStrenghCheck«IsAcceptable == 1) {
				Set £«NameFinal_OUTPUT "~£«NameFinal_OUTPUT~ (.+!ON!+.)"
			} else {
				Set £«NameFinal_OUTPUT "~£«NameFinal_OUTPUT~ (StandBy)"
			}
		}
		
		if(and(£FUNCseekTargetLoop«HoverEnt != "" && £FUNCseekTargetLoop«HoverEnt != "void")) {
			Set £«NameFinal_OUTPUT "~£«NameFinal_OUTPUT~ (Aim:~£FUNCseekTargetLoop«HoverEnt~,~§FUNCseekTargetLoop«HoverLife~hp)."
		}
		
		//if(@AncientTechSkill >= 50) { //detailed info for nerds ;) 
			if(§Identified == 1) {
				Set £SignalStrInfo "~£SignalStrInfo~(req ~%.1f,@FUNCsignalStrenghCheck«Required~%, here is ~§SignalStrengthTrunc~%, ~$G_Holog_SignalMode~ for ~§SignalModeChangeDelay~s)" //it is none or working for N seconds
			} else {
				Set £SignalStrInfo "~£SignalStrInfo~(req 0x~%X,@FUNCsignalStrenghCheck«Required~, here is 0x~%X,§SignalStrengthTrunc~% for 0x~%X,§SignalModeChangeDelay~s)" //it is none or working for N seconds //not messy, but could be
			}
			//Set §hours   ^gamehours
			//Mod §hours 24
			Calc §hours [ ^gamehours % 24 ]
			//Set §minutes ^gameminutes
			//Mod §minutes 60
			Calc §minutes [ ^gameminutes % 60 ]
			//Set §seconds ^gameseconds
			//Mod §seconds 60
			Calc §seconds [ ^gameseconds % 60 ]
			// as day/night is based in quest stages and (I believe) they do not update the global time g_gameTime value, these would be incoherent to show as GameTime GT:^arxdays ^arxtime_hours ^arxtime_minutes ^arxtime_seconds. So will show only real time.
			if(§Identified == 1) {
				Set £ItemConditionDesc "~£ItemConditionDesc~(~§ItemConditionPercent~% ~§UseCount~/~§UseMax~ Remaining ~§UseRemain~) RT:~^gamedays~day(s) ~%02d,§hours~:~%02d,§minutes~:~%02d,§seconds~(~^arxtime~)" 
			} else {
				Set £ItemConditionDesc "~£ItemConditionDesc~(0x~%X,§ItemConditionPercent~% 0x~%X,§UseCount~/0x~%X,§UseMax~ Reliquum 0x~%X,§UseRemain~) RT:0x~%X,^gamedays~day(s) 0x~%02X,§hours~:0x~%02X,§minutes~:0x~%02X,§seconds~" //latin
			}
			//Set £ItemConditionDesc "~£ItemConditionDesc~(~§ItemConditionPercent~% ~§UseCount~/~§UseMax~ Remaining ~§UseRemain~) RT:~^gamedays~day(s) ~%02d,^gamehours~:~%02d,^gameminutes~:~%02d,^gameseconds~" 
			Set £ItemQuality "~£ItemQuality~(~§UseMax~)"
		//}
		if(§Identified == 1) {
			// latin is almost identical...
			if(@AncientTechSkill >= 20) Set £«NameFinal_OUTPUT "~£«NameFinal_OUTPUT~ Signal:~£SignalStrInfo~." 
			if(@AncientTechSkill >= 30) Set £«NameFinal_OUTPUT "~£«NameFinal_OUTPUT~ Quality:~£ItemQuality~."
			if(@AncientTechSkill >= 40) Set £«NameFinal_OUTPUT "~£«NameFinal_OUTPUT~ Condition:~£ItemConditionDesc~."
		} else {
			if(@AncientTechSkill >= 20) Set £«NameFinal_OUTPUT "~£«NameFinal_OUTPUT~ Nagsil:~£SignalStrInfo~." //messy
			if(@AncientTechSkill >= 30) Set £«NameFinal_OUTPUT "~£«NameFinal_OUTPUT~ Itaquyl:~£ItemQuality~." //messy
			if(@AncientTechSkill >= 40) Set £«NameFinal_OUTPUT "~£«NameFinal_OUTPUT~ Ditononic:~£ItemConditionDesc~." //messy
		}
		
		//EASY DEBUG STUFF
		if(&G_DebugMode == 1) {
			//Set £«NameFinal_OUTPUT "~£«NameFinal_OUTPUT~ DBG:~^degreesx_player~,~^degreesy_player~,~^degreesz_player~."
		}
		
		//if(@AncientTechSkill >= 50) Set £«NameFinal_OUTPUT "~£«NameFinal_OUTPUT~ Signal:~§SignalStrengthTrunc~, ~§ItemConditionPercent~% ~§UseCount~/~§UseMax~ Remaining ~§UseRemain~." //detailed condition for nerds ;) 
	//} else {
		//Set £«NameFinal_OUTPUT "~£«NameFinal_OUTPUT~ (Not initialized)."
	//}
	
	//SetName "~£«NameBase~. Quality:~£ItemQuality~, Condition:~£ItemConditionDesc~(~§ItemConditionPercent~%), Uses:Count=~§UseCount,Remain=~§UseRemain~,Max=~§UseMax~"
	SetName "~£«NameFinal_OUTPUT~"
	GoSub FUNCshowlocals
}

>>FUNCupdateIcon () {
	Set £IconPrevious £Icon
	
	if(£IconBasename == "") GoSub FUNCCustomCmdsB4DbgBreakpoint
	Set £Icon "~£IconBasename~"
	
	if(§Quality >= 4) Set £Icon "~£Icon~MK2"
	
	// new models and icons
	if(or(
			£AncientDeviceMode == "Grenade" //||
	)) {
		if(§AncientDeviceTriggerStep == 1){
			Set £Icon "~£Icon~.OFF"
		}
		if(§AncientDeviceTriggerStep == 2){
			if(§FUNCsignalStrenghCheck«IsAcceptable == 1) {
				Set £Icon "~£Icon~.ON"
			} else {
				Set £Icon "~£Icon~.StandBy"
			}
		}
	}
	
	Set £Icon "~£Icon~[icon]"
	
	if(£IconPrevious != £Icon)	TWEAK ICON "~£Icon~"
	
	RETURN
}

>>TFUNCcalcAncientTechSkill () { GoSub FUNCcalcAncientTechSkill ACCEPT } >>FUNCcalcAncientTechSkill () {
	Set @AncientTechSkill ^PLAYER_SKILL_MECANISM
	Add @AncientTechSkill ^PLAYER_SKILL_OBJECT_KNOWLEDGE
	Add @AncientTechSkill ^PLAYER_SKILL_INTUITION
	Div @AncientTechSkill 3 //the total skills used for it
	
	Set @AncientTechSkillDebuffPercMultiplyer 100
	Sub @AncientTechSkillDebuffPercMultiplyer @AncientTechSkill
	if(@AncientTechSkillDebuffPercMultiplyer <  5) Set @AncientTechSkillDebuffPercMultiplyer 5
	if(@AncientTechSkillDebuffPercMultiplyer > 95) Set @AncientTechSkillDebuffPercMultiplyer 95
	Div @AncientTechSkillDebuffPercMultiplyer 100 //perc 0.0 to 1.0
	RETURN
}

>>TFUNCskillCheckAncientTech () { GoSub FUNCskillCheckAncientTech ACCEPT } >>FUNCskillCheckAncientTech () { //checks the technical skill like in a percent base. 
	//INPUTS:
	//OUTPUTS:
	//  §FUNCskillCheckAncientTech«chanceSuccess_OUTPUT
	//  §FUNCskillCheckAncientTech«chanceFailure_OUTPUT
	//  @FUNCskillCheckAncientTech«bonus_OUTPUT
	
	GoSub FUNCcalcAncientTechSkill
	
	Set §«chanceSuccess_OUTPUT @AncientTechSkill
	if (§«chanceSuccess_OUTPUT <  5) Set §«chanceSuccess_OUTPUT  5 //minimal success chance
	if (§«chanceSuccess_OUTPUT > 95) Set §«chanceSuccess_OUTPUT 95 //minimal fail chance
	
	Set §«chanceFailure_OUTPUT 100
	Dec §«chanceFailure_OUTPUT §«chanceSuccess_OUTPUT
	
	Set @«addBonus_OUTPUT @AncientTechSkill
	Set @TmpRandomBonus 10
	Inc @TmpRandomBonus ^rnd_10
	Div @«addBonus_OUTPUT @TmpRandomBonus
	
	// unset after log if any
	GoSub FUNCshowlocals
	Unset @TmpRandomBonus
	
	RETURN
}

>>TFUNCtrapAttack () { GoSub FUNCtrapAttack ACCEPT } >>FUNCtrapAttack () {
	//INPUT: [§FUNCtrapAttack«TimeoutMillis]
	//INPUT: [§FUNCtrapAttack«TrapMode]: 0=explosion(default) 1=projectile/targetPlayer
	//OUTPUT: §FUNCtrapAttack«TrapCanKillMode_OUTPUT
	
	SendEvent GLOW SELF "" //TODO this also makes it glow or just calls the ON GLOW event that needs to be implemented here?
	
	SetGroup "DeviceTechExplosionActivated"
	SetGroup "Explosive"
	
	PLAY "TRAP"
	PLAY "POWER"
	
	Set §«TrapCanKillMode_OUTPUT 1 //this calls FUNCMakeNPCsHostile at main() heartbeat
	
	//attractor SELF 1 1000 //makes it a bit difficult for the player to run away
	
	GoSub FUNCMakeNPCsHostile
	
	GoSub FUNCcalcSignalStrength
	
	// random trap
	if(§«TimeoutMillis == 0)	Set §«TimeoutMillis §DefaultTrapTimeoutMillis
	Set §«TrapTimeSec §«TimeoutMillis
	Div §«TrapTimeSec 1000 //must be seconds (not milis) to easify things below like timer count and text
	if(§«TrapTimeSec > 0) {
		timerTrapTime     §«TrapTimeSec 1 Dec §«TrapTimeSec 1
		timerTrapTimeName §«TrapTimeSec 1 SetName "Holo-Grenade Activated (~§«TrapTimeSec~s)"
	}
	//timerTrapAttack  -m 0  100 GoTo TFUNCMakeNPCsHostile //doesnt work
	
	Set §TrapEffectTimeMillis 0
	if (§«TrapMode == 0) { //explosion around self
		//Set §TmpTrapKind ^rnd_5
		//if (§TmpTrapKind == 0) timerTrapAttack -m 1 §«TimeoutMillis SPELLCAST -smf @SignalStrLvl explosion  SELF
		//if (§TmpTrapKind == 1) timerTrapAttack -m 1 §«TimeoutMillis SPELLCAST -smf @SignalStrLvl fire_field SELF
		//if (§TmpTrapKind == 2) timerTrapAttack -m 1 §«TimeoutMillis SPELLCAST -smf @SignalStrLvl harm       SELF
		//if (§TmpTrapKind == 3) timerTrapAttack -m 1 §«TimeoutMillis SPELLCAST -smf @SignalStrLvl ice_field  SELF
		//if (§TmpTrapKind == 4) timerTrapAttack -m 1 §«TimeoutMillis SPELLCAST -smf @SignalStrLvl life_drain SELF
		timerTrapAttack -m 1 §«TimeoutMillis GoTo TFUNCchkAndAttackExplosion
		//this cause no damage? //if (§TmpTrapKind == 5) timerTrapAttack  -m 1 5000 SPELLCAST -smf @SignalStrLvl mass_incinerate SELF
		//Unset §TmpTrapKind
		Set §TrapEffectTimeMillis 2000 //some effects have infinite time and then will last 2s (from 5000 to 7000) like explosion default time, as I being infinite would then last 0s as soon this entity is destroyed right?
	} else {
	if (§«TrapMode == 1) { //projectile at player
		timerTrapAttack -m 1 §«TimeoutMillis GoTo TFUNCchkAndAttackProjectile
	} }
	
	timerTrapVanish       -m 1 §«TimeoutMillis TWEAK SKIN "Hologram.tiny.index4000.grenade"       "alpha"
	timerTrapVanishActive -m 1 §«TimeoutMillis TWEAK SKIN "Hologram.tiny.index4000.grenadeActive" "alpha"
	timerTrapVanishGlow   -m 1 §«TimeoutMillis TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow"   "alpha" //TODO rm in favor of Halo?
	
	// trap effect time
	Set §TmpTrapDestroyTime §«TimeoutMillis
	Inc §TmpTrapDestroyTime §TrapEffectTimeMillis
	timerTFUNCDestroySelfSafely -m 1 §TmpTrapDestroyTime GoTo TFUNCDestroySelfSafely 
	
	//Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;§«TimeoutMillis=~§«TimeoutMillis~"
	GoSub -p FUNCshowlocals §»force=1 ;
	// unset after log
	//Unset §TmpTrapDestroyTime //DO NOT UNSET OR IT WILL BREAK THE TIMER!!!
	
	//restore defaults for next call "w/o params"
	Set §«TrapMode 0
	//Set §«TrapTimeSec §DefaultTrapTimoutSec
	Set §«TimeoutMillis §DefaultTrapTimeoutMillis
	RETURN
}

>>TFUNCchkAndAttackExplosion () { GoSub FUNCchkAndAttackExplosion ACCEPT } >>FUNCchkAndAttackExplosion () {
	GoSub FUNCsignalStrenghCheck	if(§FUNCsignalStrenghCheck«IsAcceptable == 1) {
		Set §TmpTrapKind ^rnd_5
		if (§TmpTrapKind == 0) SPELLCAST -smf @SignalStrLvl explosion  SELF
		if (§TmpTrapKind == 1) SPELLCAST -smf @SignalStrLvl fire_field SELF
		if (§TmpTrapKind == 2) SPELLCAST -smf @SignalStrLvl harm       SELF
		if (§TmpTrapKind == 3) SPELLCAST -smf @SignalStrLvl ice_field  SELF
		if (§TmpTrapKind == 4) SPELLCAST -smf @SignalStrLvl life_drain SELF
	} else {
		GoSub FUNCbreakDeviceDelayed
	}
	RETURN
}

>>TFUNCchkAndAttackProjectile () { GoSub FUNCchkAndAttackProjectile ACCEPT } >>FUNCchkAndAttackProjectile () {
	//if ( ^#PLAYERDIST > §iFUNCMakeNPCsHostile_rangeDefault ) ACCEPT //the objective is to protect NPCs that did not get alerted by the player aggressive action
	GoSub FUNCsignalStrenghCheck	if(§FUNCsignalStrenghCheck«IsAcceptable == 1) {
		Set §TmpTrapKind ^rnd_6
		if (§TmpTrapKind == 0) SPELLCAST -smf @SignalStrLvl FIREBALL              PLAYER
		if (§TmpTrapKind == 1) SPELLCAST -smf @SignalStrLvl FIRE_PROJECTILE       PLAYER
		if (§TmpTrapKind == 2) SPELLCAST -smf @SignalStrLvl ICE_PROJECTILE        PLAYER
		if (§TmpTrapKind == 3) SPELLCAST -smf @SignalStrLvl MAGIC_MISSILE         PLAYER
		if (§TmpTrapKind == 4) SPELLCAST -smf @SignalStrLvl MASS_LIGHTNING_STRIKE PLAYER
		if (§TmpTrapKind == 5) SPELLCAST -smf @SignalStrLvl POISON_PROJECTILE     PLAYER
		//TODO semi-paralize, every 1-3s shocks NPC and slowly pull it back to grenade or mine location thru interpolate and paralize it there for 0-1s
		//if (§TrapKind == 0) SPELLCAST -smf @SignalStrLvl LIGHTNING_STRIKE PLAYER //too weak
		//Unset §TmpTrapKind
	} else {
		GoSub FUNCbreakDeviceDelayed
	}
	RETURN
}

>>TFUNChideHologramPartsPermanently () { GoSub FUNChideHologramPartsPermanently ACCEPT } >>FUNChideHologramPartsPermanently () {
	// clean unnecessary skins from this item only:
	//TODO? just replace by a HoloGrenade.ftl, will also help lower this script size and Hologram.ftl overlapping things in blender (not a big deal tho..)
	TWEAK SKIN "Hologram.ousidenoise" "alpha"
	TWEAK SKIN "Hologram.projcone" "alpha"
	TWEAK SKIN "Hologram.projectors" "alpha"
	TWEAK SKIN "Hologram.skybox.index1000.Status.Good" "alpha"
	TWEAK SKIN "Hologram.skybox.index1000.Status.Warn" "alpha"
	TWEAK SKIN "Hologram.skybox.index1000.Status.Bad" "alpha"
	TWEAK SKIN "Hologram.skybox.index2000.DocIdentified" "alpha"
	TWEAK SKIN "Hologram.skybox.index2000.DocUnidentified" "alpha"
	TWEAK SKIN "Hologram.skybox.UVSphere.index2000.DocBackground" "alpha"
	TWEAK SKIN "£SkyBoxCurrent" "alpha"
	TWEAK SKIN "£SkyBoxCurrentUVS" "alpha"
	RETURN
}

>>TFUNCparalyseIfPlayerNearby () { GoSub FUNCparalyseIfPlayerNearby ACCEPT } >>FUNCparalyseIfPlayerNearby () {
	if ( ^#PlayerDist < 500 ) {
		Set @FUNCparalysePlayer_Millis 1000
		Inc @FUNCparalysePlayer_Millis ^rnd_2000
		GoSub FUNCparalysePlayer
	}
	RETURN
}
>>TFUNCparalysePlayer () { GoSub FUNCparalysePlayer ACCEPT } >>FUNCparalysePlayer () {
	//INPUT: [@FUNCparalysePlayer_Millis]
	
	//Set @FUNCparalysePlayer_Resist 100	Dec @FUNCparalysePlayer_Resist @AncientTechSkill //calc resist percent
	//Mul @FUNCparalysePlayer_Millis @FUNCparalysePlayer_Resist //lower the delay by the percent
	GoSub FUNCcalcAncientTechSkill
	Mul @FUNCparalysePlayer_Millis @AncientTechSkillDebuffPercMultiplyer
	if(@FUNCparalysePlayer_Millis > 50) { // needs a minimum to make sense
		if(@FUNCparalysePlayer_Millis > 250) Set @FUNCparalysePlayer_Millis 250 //TODO find some alternative, being paralyzed so often for so long is too annoying, so limiting paralyze to 250ms for now...
		Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;FUNCparalysePlayer_Millis=~@FUNCparalysePlayer_Millis~"
		SPELLCAST -fmsd @FUNCparalysePlayer_Millis @SignalStrLvl PARALYSE PLAYER
	}
	// reset input to default
	Set @FUNCparalysePlayer_Millis 250
	RETURN
}

>>TFUNCDestroySelfSafely () { GoSub FUNCDestroySelfSafely ACCEPT } >>FUNCDestroySelfSafely () {
	PLAY -s //stops sounds started with -i flag
	DESTROY SELF
	RETURN
}

>>TFUNCcalcSignalStrength () { GoSub FUNCcalcSignalStrength ACCEPT } >>FUNCcalcSignalStrength () { //this is meant to be independent from magic skills so instead of ^spelllevel to cast spells, use @SignalStrLvl
	//Set @testCallStack 1 2 //TODORM
	
	// reset to recalc
	Set @RepeaterSignalStrength 0.0 //0.0 to 100.0
	Set @SignalStrength 0.0         //0.0 to 100.0
	Set §SignalStrengthTrunc 0      //  0 to 100
	Set @SignalStrLvl 0.0           //0.0 to 10.0
	
	// no signal for some short realtime. This means the global ancient energy transmitter is failing or getting interference.
	Set §DEBUGgameseconds ^gameseconds
	Set §SignalModeChangeDelay #G_Holog_SignalModeChangeTime
	Dec §SignalModeChangeDelay ^gameseconds
	if($G_Holog_SignalMode == "Working"){
		if(^gameseconds > #G_Holog_SignalModeChangeTime){
			Set $G_Holog_SignalMode "NoSignal" //configures the no signal delay below
			Set #G_Holog_SignalModeChangeTime  ^gameseconds
			Inc #G_Holog_SignalModeChangeTime  ^rnd_300 //up to
			RETURN
		}
	} else { if($G_Holog_SignalMode == "NoSignal"){
		if(^gameseconds > #G_Holog_SignalModeChangeTime){
			Set $G_Holog_SignalMode "Working" //configures the working signal delay below
			Set #G_Holog_SignalModeChangeTime  ^gameseconds
			Inc #G_Holog_SignalModeChangeTime  900 //from
			Inc #G_Holog_SignalModeChangeTime  ^rnd_900 //up to
			RETURN
		}
		RETURN
	} }
	
	if(£RepeaterStrongestDeployedID != "") { //TODO implement signal repeaters
		////if(and(§SignalRepeater == 1 && ^dist_player <= 3000)) { // 1: there is a signal repeater at player inventory (good as forces player to want to not move) 
		////if(and(§SignalRepeater == 1 && ^dist_player <= 3000)) { // 1: there is a signal repeater at player inventory (good as forces player to want to not move) 
		//if(^dist_player <= 3000) { // there is a signal repeater at player inventory (good as forces player to want to not move) 
			//// at some locations there is no signal at all.
			//Set §NoSignalRegion ^locationx_player
			//Inc §NoSignalRegion ^locationz_player
			//Mod §NoSignalRegion §SignalDistBase
			//if(§NoSignalRegion >= §SignalDistMin) {
				//Set @RepeaterSignalStrength ^locationx_player
				//Inc @RepeaterSignalStrength ^locationy_player
				//Inc @RepeaterSignalStrength ^locationz_player
			//}
		//} else { if(§SignalRepeater == 2) { // 2: there is a deployed repeater nearby
		//} else {
			////TODO £SignalRepeaterID
			//Set @RepeaterSignalDist ^dist_~£RepeaterStrongestDeployedID~ //nearest (but could be all within 3000 range and receive the strongest signal)
		//} }
		Set @RepeaterSignalDist ^dist_~£RepeaterStrongestDeployedID~ //nearest (but could be all within 3000 range and receive the strongest signal)
	} else {
		Set @AncientGlobalTransmitterSignalDist ^dist_[0,0,0] //could be anywhere, if  I create a bunker map with it, then it will have a proper location 
	}
	
	// no signal regions are like squared columns
	//Set §NoSignalRegion ^locationx_~^me~
	//Inc §NoSignalRegion ^locationz_~^me~
	//Mod §NoSignalRegion §SignalDistBase
	Calc §NoSignalRegion [ [ ^locationx_~^me~ + ^locationz_~^me~ ] % §SignalDistBase ]
	// signal strength based on deterministic but difficultly previsible cubic regions
	if(§NoSignalRegion >= §SignalDistMin) {
		//Set @SignalStrength ^locationx_~^me~
		//Inc @SignalStrength ^locationy_~^me~
		Calc @SignalStrength [ ^locationx_~^me~ + ^locationy_~^me~ + ^locationz_~^me~ ]
		if (^inPlayerInventory == 1) Inc @SignalStrength 90 //if at player inventory, items are 90 dist from ground (based on tests above). Could just use ^locationy_player tho instead of ^locationy_~^me~. This is important because when placing the item on the floor it will then have almost the same value.
		//Inc @SignalStrength ^locationz_~^me~
		
		if(§SignalRepeater == 0) {
			// less cubic/less previsible (this alone would be like spheric regions btw)
			Add @SignalStrength @AncientGlobalTransmitterSignalDist
		}
		//TODOA ternary ifElse: Calc @SignalStrength [ ^locationx_~^me~ + ^locationy_~^me~ + [ ^inPlayerInventory == 1 ? 90 : 0 ] + ^locationz_~^me~ + [ §SignalRepeater == 0 ? @AncientGlobalTransmitterSignalDist : 0 ] ]
	}
	
	// stronger signal wins
	if(@RepeaterSignalStrength > @SignalStrength) Set @SignalStrength @RepeaterSignalStrength
	
	if(§SignalRepeater == 0) {
		// see comments about cubic and spheric regions above
		// means from 0 to §SignalDistHalf then from §SignalDistHalf to 0 as the player moves around. Ex.: if max dist is 1000, it will be from 0 to 500 and from 500 to 0, then from 0 to 500 again...
		Mod @SignalStrength §SignalDistBase //remainder
		if (@SignalStrength > §SignalDistHalf) {
			//Dec @SignalStrength §SignalDistHalf
			//Mul @SignalStrength -1
			//Inc @SignalStrength §SignalDistHalf
			Calc @SignalStrength [ [ @SignalStrength - §SignalDistHalf ] * -1 + §SignalDistHalf ]
		}
	} else {
		Set @RepeaterSignalHere @SignalStrength //100% reference
		// percent from max distance
		//Set @RepeaterSignalDistPerc @RepeaterSignalDist 
		//Div @RepeaterSignalDistPerc 3000 //perc from 0.0to1.0
		Calc @RepeaterSignalDistPerc [ @RepeaterSignalDist / 3000 ] //perc from 0.0to1.0
		// if near, the value will be small so the final signal strength will be high
		//Set @SignalStrength 1.0
		//Dec @SignalStrength @RepeaterSignalDistPerc
		//// from 0.0 to 100.0
		//Mul @SignalStrength 100
		Calc @SignalStrength [ [ 1.0 - @RepeaterSignalDistPerc ] * 100 ] // from 0.0 to 100.0
	}
	
	// percent and signal level
	//Div @SignalStrength §SignalDistHalf //converts to a percent from 0.0 to 1.0
	//Mul @SignalStrength 100 //0.0 to 100.0
	Calc @SignalStrength [ 
		@SignalStrength / §SignalDistHalf //converts to a percent from 0.0 to 1.0
		* 100 ] //0.0 to 100.0
	Set §SignalStrengthTrunc @SignalStrength //trunc 0 to 100
	// to use instead of ^spelllevel
	//Set @SignalStrLvl @SignalStrength
	//Div @SignalStrLvl 10 //0-10 like spell cast level would be
	Calc @SignalStrLvl [ @SignalStrength / 10 ] //0-10 like spell cast level would be
	
	RETURN
}

//////////////////////////// TESTS /////////////////////////////
>>TFUNChoverInfo () { GoSub FUNChoverInfo ACCEPT } >>FUNChoverInfo () {
	GoSub FUNCshowlocals
	Set £HoverEnt ^hover_~§SeekTargetDistance~
	if(£HoverEnt != "none") {
		Set £HoverClass ^class_~^hover_5001~
		Set §HoverLifeTmp ^life_~^hover_5001~
		Set @HoverLifeTmp2 ^life_~£HoverEnt~
		Set @testDegreesXh   ^degreesx_~^hover_5001~
		Set @testDegreesYh   ^degreesy_~^hover_5001~
		Set @testDegreesZh   ^degreesz_~^hover_5001~ //some potions are inclined a bit
		Set @testDegreesYtoh ^degreesyto_~^hover_5001~
    //just crashes... if(§HoverLifeTmp > 0) USEMESH -e £HoverEnt "movable\\npc_gore\\npc_gore" //todoRM 
    //nothing happens if(§HoverLifeTmp > 0) SPAWN ITEM "movable\\npc_gore\\npc_gore" "~£HoverEnt~" //todoRM
		GoSub FUNCshowlocals
	}
	RETURN
}

>>TFUNCseekTargetLoop () { GoSub FUNCseekTargetLoop ACCEPT } >>FUNCseekTargetLoop () {
	//INPUT: <£«mode>
	//INPUT: [£«callFuncWhenTargetFound]
	//OUTPUT: £«TargetFoundEnt_OUTPUT
	if(and(£«mode != "stop" && not("FUNC" IsIn £«callFuncWhenTargetFound));) GoSub -p FUNCCustomCmdsB4DbgBreakpoint £»DbgMsg="ERROR: invalid call to £«callFuncWhenTargetFound=~£«callFuncWhenTargetFound~ (btw £«mode=~£«mode~)" ;
	
	if(£«mode == "init") {
		Set £«TargetFoundEnt_OUTPUT ""
		Set £«mode "seek"
		timerTFUNCseekTargetLoop -m 0 333 GoTo TFUNCseekTargetLoop
		GoSub -p FUNCshowlocals §»force=1 ;
	} else {
	if(£«mode == "seek") {
		Set £«HoverEnt ^hover_~§SeekTargetDistance~
		Set §«HoverLife ^life_~£«HoverEnt~
		if(and(£«HoverEnt != "none" && §«HoverLife > 0)) {
			Set £«mode "stop"
			Set £«TargetFoundEnt_OUTPUT £«HoverEnt
			if(£«callFuncWhenTargetFound != "") {
				GoSub -p £«callFuncWhenTargetFound £»target=£«HoverEnt ;
			}
		}
		GoSub -p FUNCshowlocals §»force=1 ;
	} else {
	if(£«mode == "stop") {
		//reset b4 next call
		Set £«mode ""
		Set £«callFuncWhenTargetFound ""
		timerTFUNCseekTargetLoop off
	} else {
		GoSub -p FUNCCustomCmdsB4DbgBreakpoint £»DbgMsg="ERROR: invalid £mode='~£«mode~'" ;
	} } }
	RETURN
}
>>TCFUNCFlyMeToTarget () { GoSub CFUNCFlyMeToTarget ACCEPT } >>CFUNCFlyMeToTarget () {  //TODO re-use this for mindcontrol and teleport
	//INPUT: <£«callFuncWhenTargetReached>
	//INPUT: [@«flySpeed] this is used only when initializing
	if(not("FUNC" IsIn £«callFuncWhenTargetReached)) GoSub -p FUNCCustomCmdsB4DbgBreakpoint £»DbgMsg="ERROR: invalid call set ~£«callFuncWhenTargetReached~" ;
	if(@«flySpeed <= 0.0) GoSub -p FUNCCustomCmdsB4DbgBreakpoint £»DbgMsg="ERROR: invalid flySpeed ~@«flySpeed~" ;
	
	if(^life_~£FUNCseekTargetLoop«HoverEnt~ > 0) {
		if(^dist_~£FUNCseekTargetLoop«HoverEnt~ > §TeleDistEndTele) {
			//the idea is to be unsafe positioning over npc location as it will be destroyed
			if(@TeleMeStepDist == 0) { //initialize
				if(^inInventory == "player") {
					DropItem -e player "~^me~" //or wont be able to calc the distance from it to the player 
					Calc §MeY [ ^dist_player / 2 * -1 ]
					Move 0 §MeY 0 //to not fly from the floor position, to look better
				}
				SetInteractivity None
				
				Set @FUNCcalcInterpolateTeleStepDist1s_Init ^dist_~£FUNCseekTargetLoop«HoverEnt~
				GoSub FUNCcalcInterpolateTeleStepDist1s()
				Set @TeleMeStepDist @FUNCcalcInterpolateTeleStepDist1s_OUTPUT
				
				if(and(@«flySpeed > 0.0 && @«flySpeed != 1.0)) {
					Mul @TeleMeStepDist @«flySpeed // < 1.0 takes longer to travel. > 1.0 travel faster
				}
				
				GoSub FUNCcalcFrameMilis	Set §«TeleTimerFlyMilis §FUNCcalcFrameMilis«FrameMilis_OUTPUT //must be a new var to let the func one modifications not interfere with this timer below
				timerTCFUNCFlyMeToTarget -m 0 §«TeleTimerFlyMilis GoTo TCFUNCFlyMeToTarget
			}
			interpolate -s "~^me~" "~£FUNCseekTargetLoop«HoverEnt~" @TeleMeStepDist //0.95 //0.9 the more the smoother anim it gets, must be < 1.0 tho or it wont move!
		} else { // last step
			interpolate "~^me~" "~£FUNCseekTargetLoop«HoverEnt~" 0.0 //one last step to be precise
			GoSub -p FUNCshowlocals §»force=1 ;
			GoSub -p £«callFuncWhenTargetReached £»target=£FUNCseekTargetLoop«HoverEnt ;
			Set £«do "off"
		}
	} else {
		Set £«do "off"
	}
	
	if(£«do == "off") {
		GoSub -p FUNCshowlocals §»force=1 ;
		timerTCFUNCFlyMeToTarget off
		//reset b4 next call
		Set @«flySpeed 1.0
		Set £«do "on"
	}
	
	RETURN
}
>>TFUNCDetectAndReachTarget () { GoSub FUNCDetectAndReachTarget ACCEPT } >>FUNCDetectAndReachTarget () {
	// this is a control function that delegates to many other functions, but them all call back to here if needed
	//INPUT: <£«mode>
	//INPUT: <£«callFuncWhenTargetReached>
	//INPUT: [£«target]
	if(£«mode == "") GoSub -p FUNCCustomCmdsB4DbgBreakpoint £»DbgMsg="ERROR: invalid £«mode=~£«mode~" ;
	if(not("FUNC" IsIn £«callFuncWhenTargetReached)) GoSub -p FUNCCustomCmdsB4DbgBreakpoint £»DbgMsg="ERROR: invalid £«callFuncWhenTargetReached=~£«callFuncWhenTargetReached~" ;
	
	if(£«mode == "InitDetectTarget"){
		Set £«mode "TargetAcquired"
		GoSub -p FUNCseekTargetLoop £»mode="init" £»callFuncWhenTargetFound=FUNCDetectAndReachTarget ;
		GoSub -p FUNCshowlocals §»force=1 ;
	} else { if(£«mode == "TargetAcquired") {
		Set £«mode "DoWhenTargetReached"
		GoSub -p CFUNCFlyMeToTarget £»target=£«target £»callFuncWhenTargetReached=FUNCDetectAndReachTarget ;
		GoSub -p FUNCshowlocals §»force=1 ;
	} else { if(£«mode == "DoWhenTargetReached") {
		Set £«mode "stop" //will just auto stop see below 
		GoSub -p £«callFuncWhenTargetReached £»target=£«target ;
		GoSub -p FUNCshowlocals §»force=1 ;
		GoSub FUNCbreakDeviceDelayed
	} } }
	
	if(£«mode == "stop") {
		timerTFUNCDetectAndReachTarget off //safety
		GoSub -p FUNCseekTargetLoop £»mode="stop" ;
		
		//reset b4 next call
		Set £«mode ""
		Set £«callFuncWhenTargetReached ""
		Set £«target ""
	}
	
	RETURN
}
/*
>>TFUNCDetectAndReachTarget () { GoSub FUNCDetectAndReachTarget ACCEPT } >>FUNCDetectAndReachTarget () {
	//INPUT: <£FUNCDetectAndReachTarget_mode>
	//INPUT: <£FUNCDetectAndReachTarget_callFuncWhenTargetReached>
	//INPUT: [£FUNCDetectAndReachTarget_target]
	if(£FUNCDetectAndReachTarget_mode == "") GoSub FUNCCustomCmdsB4DbgBreakpoint
	
	if(£FUNCDetectAndReachTarget_mode == "detect"){
		if(not("FUNC" IsIn £FUNCDetectAndReachTarget_callFuncWhenTargetReached)) GoSub FUNCCustomCmdsB4DbgBreakpoint
		
		//if(£FUNCseekTargetLoop«TargetFoundEnt_OUTPUT == "") {
		if(£FUNCDetectAndReachTarget_target == "") {
			Set £CFUNCFlyMeToTarget«callFuncWhenTargetReached "FUNCDetectAndReachTarget" // CFUNCFlyMeToTarget is called by FUNCseekTargetLoop
			//Set £CFUNCFlyMeToTarget«callFuncWhenTargetReached "CFUNCSniperBulletAtTarget" // CFUNCFlyMeToTarget will set CFUNCSniperBulletAtTarget's target param
			//Set £FUNCseekTargetLoop«callFuncWhenTargetFound "CFUNCFlyMeToTarget"
			// this will keep tring to find a target.
			GoSub -p FUNCseekTargetLoop "£»mode=init" "£callFuncWhenTargetFound=CFUNCFlyMeToTarget" ;
		} else { // here is reached when called by CFUNCFlyMeToTarget
			//GoSub -p FUNCkillNPC "£»target=£FUNCseekTargetLoop«TargetFoundEnt_OUTPUT" ;
			GoSub -p £FUNCDetectAndReachTarget_callFuncWhenTargetReached £»target=£FUNCDetectAndReachTarget_target ;
			GoSub FUNCbreakDeviceDelayed
			Set £FUNCDetectAndReachTarget_mode "stop" //will just auto stop see below 
		}
	}
	//if(£FUNCDetectAndReachTarget_mode == "detect") {
		//if(not("FUNC" IsIn £FUNCDetectAndReachTarget_callFuncWhenTargetReached)) GoSub FUNCCustomCmdsB4DbgBreakpoint
		//Set £CFUNCFlyMeToTarget«callFuncWhenTargetReached "FUNCDetectAndReachTarget"
		//GoSub -p FUNCseekTargetLoop "£»mode=init" "£callFuncWhenTargetFound=CFUNCFlyMeToTarget" ;
	//}
	
	if(£FUNCDetectAndReachTarget_mode == "stop") {
		GoSub -p FUNCseekTargetLoop "£»mode=stop" ;
		
		//reset b4 next call
		Set £FUNCDetectAndReachTarget_mode ""
		Set £FUNCDetectAndReachTarget_callFuncWhenTargetReached ""
		Set £FUNCDetectAndReachTarget_target ""
	}
	
	RETURN
}
*/
>>CFUNCSniperBulletAtTarget () {
	// INPUT <£CFUNCSniperBulletAtTarget_target> will be set at FUNCDetectAndReachTarget
	if(£CFUNCSniperBulletAtTarget_target == "") GoSub FUNCCustomCmdsB4DbgBreakpoint
	GoSub -p FUNCkillNPC £»target=£CFUNCSniperBulletAtTarget_target ;
	//reset b4 next call
	Set £CFUNCSniperBulletAtTarget_target ""
	RETURN
}

>>TFUNCLandMine () { GoSub FUNCLandMine ACCEPT } >>FUNCLandMine () {
	//TODO new command attractor to NPCs range 150? strong so they forcedly step on it if too nearby
	GoSub FUNCsignalStrenghCheck if(§FUNCsignalStrenghCheck«IsAcceptable == 0) ACCEPT
	
	Set @«TriggerRange 50
	Add @«TriggerRange @AncientTechSkill
	Set £«OnTopEntList ^$ObjOnTop_~@«TriggerRange~
	if(£«OnTopEntList != "none") {
		Set §«OnTopLife 0
		
		Set §«LoopIndex 0	>>LOOP_FUNCLandMine_ChkNPC
			Set -a £«OnTopEntId §«LoopIndex "~£«OnTopEntList~"
			if(£«OnTopEntId != "") {
				Set §«OnTopLife ^life_~£«OnTopEntId~
				if(§«OnTopLife > 0) {
					if(§Quality >= 4) { // high quality wont trigger with innofensive rats
						Set £«OnTopEntClass ^class_~£«OnTopEntId~
						if(£«OnTopEntClass == "rat_base") { //should be any npc that is never a threat
							Set §«OnTopLife 0
							Set £«OnTopEntId ""
						}
					}
				}
			}
		++ §«LoopIndex	if(not(or(§«OnTopLife > 0 || £«OnTopEntId == ""))) GoTo LOOP_FUNCLandMine_ChkNPC //end loop if found one alive or on end of array
		
		if(§«OnTopLife > 0) {
			//Set §Scale 100
			timerShrink1 -m 0 100 Dec §Scale 1
			timerShrink2 -m 0 100 SetScale §Scale
			
			Set §FUNCtrapAttack«TimeoutMillis 2000
			GoSub FUNCcalcAncientTechSkill
			Mul §FUNCtrapAttack«TimeoutMillis @AncientTechSkillDebuffPercMultiplyer
			GoSub FUNCtrapAttack
			
			timerTFUNCLandMine off
			
			GoSub -p FUNCshowlocals §»force=1 ;
		}
	}
	RETURN
}
>>CFUNCTeleportPlayerToTarget () {
	//INPUT: <£CFUNCTeleportPlayerToTarget«target>
	Set §«TargetLife ^life_~£«target~
	if(§«TargetLife > 0) {
		//if(^inInventory == "player") {
			//DropItem -e player "~^me~" //or wont be able to calc the distance from it to the player 
			//Calc §MeY [ ^dist_player / 2 * -1 ]
			//Move 0 §MeY 0 //to not fly from the floor position, to look better
		//}
		//SetInteractivity None
		
		GoSub FUNCcalcFrameMilis	Set §«TeleTimerFlyMilis §FUNCcalcFrameMilis«FrameMilis_OUTPUT //must be a new var to let the func one modifications not interfere with this timer below
		timerTFUNCteleportToAndKillNPC_flyPlayerToMe -m 0 §«TeleTimerFlyMilis GoTo TFUNCteleportToAndKillNPC_flyPlayerToMe
		//TODO explode npc in gore dismembering, may be can use cpp ARX_NPC_TryToCutSomething() to explode the body
	}
	GoSub -p FUNCshowlocals §»force=1 ;
	RETURN
}
/* TODO REMOVE deprecated
>>TFUNCteleportToAndKillNPC () { GoSub FUNCteleportToAndKillNPC ACCEPT } >>FUNCteleportToAndKillNPC () {
	//TODO may be can use cpp ARX_NPC_TryToCutSomething() to explode the body
	//TODO try also modify GetFirstInterAtPos(..., float & fMaxPos)  fMaxPos=10000, but needs to disable player interactivity to not work as telekinesis or any other kind of activation...
	Set £«HoverEnt ^hover_~§SeekTargetDistance~
	Set §«HoverLife ^life_~£«HoverEnt~
	if(and(£«HoverEnt != "none" && §«HoverLife > 0)) {
		//timerTeleportSelf    -m 0 50 teleport "~£«HoverEnt~"
		DropItem -e player "~^me~" //or wont be able to calc the distance from it to the player 
		//(Set §MeY ^dist_player)	(Div §MeY 2)	(Mul §MeY -1)	(Move 0 §MeY 0) //to not fly from the floor position, to look better
		Calc §MeY [ ^dist_player / 2 * -1 ]
		Move 0 §MeY 0 //to not fly from the floor position, to look better
		
		SetInteractivity None
		
		GoSub FUNCcalcFrameMilis	Set §«TeleTimerFlyMilis §FUNCcalcFrameMilis«FrameMilis_OUTPUT //must be a new var to let the func one modifications not interfere with this timer below
		timerTFUNCteleportToAndKillNPC_flyMeToNPC -m 0 §«TeleTimerFlyMilis GoTo TFUNCteleportToAndKillNPC_flyMeToNPC
		//timerTeleportKillNPC -m 0 50 SENDEVENT -nr CRUSH_BOX 50 "" //SENDEVENT -finr CRUSH_BOX 50 ""
		//timerTeleportPlayer    -m 1 100 teleport -p "~£«HoverEnt~"
		//timerTFUNCteleportToAndKillNPC_flyPlayerToMe -m 0 50 GoTo TFUNCteleportToAndKillNPC_flyPlayerToMe
		//TODO explode npc in gore dismembering
    //timerTeleportDropNPCItems     -m 1 2000 DropItem -e "~£«HoverEnt~" all
    ////nothing happens: timerTeleportKillNPC -m 1 300 SPAWN ITEM "movable\\npc_gore\\npc_gore" "~£«HoverEnt~"
    //timerTeleportDamageAndKillNPC -m 1 2100 DoDamage -fmlcgewsao "~£«HoverEnt~" 99999
    //timerTeleportDestroyNPC       -m 1 2200 Destroy "~£«HoverEnt~" //must be last thing or the ent reference will fail for the other commands 
		//timerBreakDevice              -m 1 2300 GoTo TFUNCbreakDeviceDelayed //only after everything else have completed! this takes a long time to finish breaking it
		
		timerTFUNCteleportToAndKillNPC off
		GoSub FUNCshowlocals
	}
	RETURN
}
*/
>>TFUNCteleportToAndKillNPC_flyMeToNPC () { GoSub FUNCteleportToAndKillNPC_flyMeToNPC ACCEPT } >>FUNCteleportToAndKillNPC_flyMeToNPC () {
	if(^life_~£CFUNCTeleportPlayerToTarget«target~ > 0) {
		//the idea is to be unsafe positioning over npc location as it will be destroyed
		if(@TeleMeStepDist == 0) {
			Set @FUNCcalcInterpolateTeleStepDist1s_Init ^dist_~£CFUNCTeleportPlayerToTarget«target~
			GoSub FUNCcalcInterpolateTeleStepDist1s()
			//Set @TeleMeStepDist @FUNCcalcInterpolateTeleStepDist1s_OUTPUT
			//Mul @TeleMeStepDist 0.33 //this will make it take 3 times longer to travel, is more challenging
			Calc @TeleMeStepDist [ @FUNCcalcInterpolateTeleStepDist1s_OUTPUT * 0.33 ] //this will make it take 3 times longer to travel, is more challenging
		}
		interpolate -s "~^me~" "~£CFUNCTeleportPlayerToTarget«target~" @TeleMeStepDist //0.95 //0.9 the more the smoother anim it gets, must be < 1.0 tho or it wont move!
	} else {
		interpolate "~^me~" "~£CFUNCTeleportPlayerToTarget«target~" 0.0 //one last step to be precise
		timerTFUNCteleportToAndKillNPC_flyMeToNPC off
	}
	
	if(and(^dist_~£CFUNCTeleportPlayerToTarget«target~ < §TeleDistEndTele && §TelePlayerNow == 0)) {
		Set §TelePlayerNow 1 //to start player flying only once
		GoSub FUNCcalcFrameMilis()	Set §«TeleTimerFlyMilis §FUNCcalcFrameMilis«FrameMilis_OUTPUT //must be a new var to let the func one modifications not interfere with this timer below
		timerTFUNCteleportToAndKillNPC_flyPlayerToMe -m 0 §«TeleTimerFlyMilis GoTo TFUNCteleportToAndKillNPC_flyPlayerToMe()
	}
	
	GoSub FUNCshowlocals()
	RETURN
}
>>TFUNCteleportToAndKillNPC_flyPlayerToMe () { GoSub FUNCteleportToAndKillNPC_flyPlayerToMe() ACCEPT } >>FUNCteleportToAndKillNPC_flyPlayerToMe () {
	if(@«TelePlayerStepDist == 0) {
		//this will take 20 frames and is not based in time, TODO make it fly based in time, must use the FPS to calc it. or make it fly in a fixed speed/distance
		Set @FUNCcalcInterpolateTeleStepDist1s_Init ^dist_player
		GoSub FUNCcalcInterpolateTeleStepDist1s()
		Calc @«TelePlayerStepDist [ @FUNCcalcInterpolateTeleStepDist1s_OUTPUT * 3 ]  //this will make the player teleport feels more like a teleport while still having some cool flying
	}
	
	if(@«TelePlayerStepDist > 0) {
		Set @TeleHoloToPlayerDist ^dist_player
		if(@TeleHoloToPlayerDist > §TeleDistEndTele) {
			//the idea is to be unsafe positioning over/colliding with npc (that will be destroyed) location //is like fly speed
			interpolate -s player "~^me~" @«TelePlayerStepDist
		} else {
			Set §FUNCbreakDeviceDelayed_ParalyzePlayerExtraMilis 0
			Set @TeleDmgPlayer ^life_~£CFUNCTeleportPlayerToTarget«target~
			if(@TeleDmgPlayer >= ^life_player) {
				Calc §FUNCbreakDeviceDelayed_ParalyzePlayerExtraMilis [ @TeleDmgPlayer - ^life_player ]
				if(§FUNCbreakDeviceDelayed_ParalyzePlayerExtraMilis == 0) ++ §FUNCbreakDeviceDelayed_ParalyzePlayerExtraMilis
				Calc §FUNCbreakDeviceDelayed_ParalyzePlayerExtraMilis [ 
					§FUNCbreakDeviceDelayed_ParalyzePlayerExtraMilis * 1000 // to milis
					/ 10 ] // 10% of extra life only
				Set @TeleDmgPlayer [ ^life_player - 0.5 ] //barely alive
			}
			DoDamage -l player @TeleDmgPlayer
			
			GoSub -p FUNCkillNPC §»destroyCorpse=1 £»target=£CFUNCTeleportPlayerToTarget«target ;
			
			//timerTeleDestroyNPC -m 1 50 Destroy "~£CFUNCTeleportPlayerToTarget«target~" //must be last thing or the ent reference will fail for the other commands 
			
			//Weapon -e player ON //doesnt work on player?
			GoSub -p FUNCbreakDeviceDelayed §»ParalyzePlayer=1 ; //only after everything else have completed! this takes a long time to finish breaking it
			
			Collision -e player disable
			timerTFUNCteleportToAndKillNPC_flyPlayerToMe_LastInterpolate -m 1 200 interpolate player "~^me~" 0.0 //one last step to be precise
			timerTFUNCteleportToAndKillNPC_flyPlayerToMe_CollisionEnable -m 1 200 Collision -e player enable
			timerTFUNCteleportToAndKillNPC_flyPlayerToMe off
		}
	}
	
	GoSub FUNCshowlocals
	
	RETURN
}
>>FUNCkillNPC () {
	//INPUT: <£FUNCkillNPC«target>
	//INPUT: [§FUNCkillNPC«destroyCorpse]
	
	if(£«target == "") {
		GoSub -p FUNCCustomCmdsB4DbgBreakpoint £»DbgMsg="ERROR: target was not set" ;
	}
	if(^life_~£«target~ <= 0) {
		GoSub -p FUNCCustomCmdsB4DbgBreakpoint £»DbgMsg="WARN: target='~£«target~' but life is <= 0" ; //npc can be dead already tho what is not a problem... TODOA ^type_<entity> will return NPC or ITEM:Equippable ITEM:Consumable ITEM:MISC
	}
	if(or(£«target == "void" || £«target == "")) {
		GoSub -p FUNCCustomCmdsB4DbgBreakpoint £»filter=".*" £»DbgMsg="ERROR: target='~£«target~'" ;
	}
	
	if(§«destroyCorpse == 1) {
		//TODO destroy the corpse and spawn gore
		Spawn Item "movable\\npc_gore\\npc_gore" "~£«target~"
		Set £«gore ^last_spawned
		(Move -e £«gore 0 25 0)	(Rotate -ae £«gore 0 0 5) //TODO fix the model instead? this is to fix gore that is too high and inclined a bit
		GoSub -p FUNCpatchNPCinventory £»npc=£«target ;
		Inventory GetItemCountList -e £«target £KilledNPCinvList2D all //this is mainly to show on the log
		DropItem -e £«target all
	}
	
	DoDamage -fmlcgewsao £«target 99999 //this is essential. Just destroying the NPC wont kill it and it will (?) remain in game invisible fighting other NPCs
	if(§«destroyCorpse == 1) timerFUNCkillNPC -m 1 50 Destroy £FUNCkillNPC«target //on next frame to avoid other quest/data sync problems probably
	
	GoSub -p FUNCshowlocals §»force=1 ; //keep here
	
	//reset before next call if it has no params
	Set §«destroyCorpse 0 
	Set £«target ""
	RETURN
}
>>TFUNCcalcFrameMilis () { GoSub FUNCcalcFrameMilis ACCEPT } >>FUNCcalcFrameMilis () {
	//OUTPUT: §FUNCcalcFrameMilis«FrameMilis_OUTPUT how long does one frame take in millis
	Set @FPS ^fps
	Set §«FrameMilis_OUTPUT 1000 //1s
	Div §«FrameMilis_OUTPUT @FPS
	if(§«FrameMilis_OUTPUT < 1) Set §«FrameMilis_OUTPUT 1
	RETURN
}
>>TFUNCcalcInterpolateTeleStepDist1s () { GoSub FUNCcalcInterpolateTeleStepDist1s ACCEPT } >>FUNCcalcInterpolateTeleStepDist1s () {
	// calculates the distance that must be displaced per frame to complete the total distance in 1 second
	//INPUT:  <@FUNCcalcInterpolateTeleStepDist1s_Init>
	if(@FUNCcalcInterpolateTeleStepDist1s_Init <= 0) GoSub FUNCCustomCmdsB4DbgBreakpoint
	//OUTPUT: @FUNCcalcInterpolateTeleStepDist1s_OUTPUT
	
	//GoSub FUNCcalcFrameMilis()	Set §TeleSteps §FUNCcalcFrameMilis«FrameMilis_OUTPUT //will take 1s to fly to any distance
	GoSub FUNCcalcFrameMilis()	Set @TFUNCcalcInterpolateTeleStepDist1s_tmpTeleSteps @FPS //will take 1s to fly to any distance
	Set @FUNCcalcInterpolateTeleStepDist1s_OUTPUT @FUNCcalcInterpolateTeleStepDist1s_Init
	Div @FUNCcalcInterpolateTeleStepDist1s_OUTPUT @TFUNCcalcInterpolateTeleStepDist1s_tmpTeleSteps
	if(@FUNCcalcInterpolateTeleStepDist1s_OUTPUT <= 1.0) {
		Set @FUNCcalcInterpolateTeleStepDist1s_OUTPUT 1.01 //2.0 //could be 1.01, anything bigger than 1.0, but if the variable receiving this value is integer, it is better to be 2 instead.
	}
	// cleanup
	//UnSet @TFUNCcalcInterpolateTeleStepDist1s_tmpTeleSteps
	Set @FUNCcalcInterpolateTeleStepDist1s_Init -1 //init invalid to req b4 next call
	RETURN
}
>>TFUNCMindControl () { GoSub FUNCMindControl ACCEPT } >>FUNCMindControl () {
  // this works like a frenzied NPC
  
  //TODO goblin_base.asl: settarget -a ~othergoblinnearby~; BEHAVIOR -f MOVE_TO;  WEAPON ON; SETMOVEMODE RUN; Aim the first goblin, aim the second, the 1st attacks the 2nd and vice versa. then: sendevent call_help to the 2nd, that will make them look for the player, then keep aiming on them, they will then attack the 1st!
	Set £FUNCMindControl_HoverEntTmp ^hover_~§SeekTargetDistance~
	Set §FUNCMindControl_HoverLife ^life_~£FUNCMindControl_HoverEntTmp~
	if(and(£FUNCMindControl_HoverEntTmp != "none" && §FUNCMindControl_HoverLife > 0)) {
    if(£FUNCMindControl_HoverEntMain == "") {
      Set £FUNCMindControl_HoverEntMain "~£FUNCMindControl_HoverEntTmp~"
      timerTeleportSelf -m 0 50 teleport "~£FUNCMindControl_HoverEntMain~"
      timerBreakDevice -m 1 60000 GoTo TFUNCbreakDeviceDelayed
      RETURN
    } else {
      if(£FUNCMindControl_HoverEntMain == "~£FUNCMindControl_HoverEntTmp~"){
        RETURN
      }
    }
    
    ++ §FUNCMindControl_HoverExtraCount
    
    //if(§FUNCMindControl_HoverExtraCount == 1) {
    if(or(£FUNCMindControl_HoverEntAttackedByMain == "" || ^life_~£FUNCMindControl_HoverEntAttackedByMain~ == 0)) {
      Set £FUNCMindControl_HoverEntAttackedByMain "~£FUNCMindControl_HoverEntTmp~"
      SetTarget   -e £FUNCMindControl_HoverEntMain -a "~£FUNCMindControl_HoverEntAttackedByMain~"
      Behavior    -e £FUNCMindControl_HoverEntMain -f MOVE_TO
      Weapon      -e £FUNCMindControl_HoverEntMain ON
      SetMoveMode -e £FUNCMindControl_HoverEntMain RUN
    }
    
    //SendEvent -nr CALL_HELP 1500 "" //they will seek for the player, now player can aim them too
    
    SetTarget   -e £FUNCMindControl_HoverEntTmp -a "~£FUNCMindControl_HoverEntMain~"
    Behavior    -e £FUNCMindControl_HoverEntTmp -f MOVE_TO
    Weapon      -e £FUNCMindControl_HoverEntTmp ON
    SetMoveMode -e £FUNCMindControl_HoverEntTmp RUN
    
    if(^life_~£FUNCMindControl_HoverEntAttackedByMain~ == 0) {
      GoSub FUNCbreakDeviceDelayed
      timerMindControlDetectHoverNPC off
    }
    //++ §FUNCMindControl_HoverExtraCount
    //if(§FUNCMindControl_HoverExtraCount >= 3) {
      //timerMindControlDetectHoverNPC off
    //}

		//Set £FUNCMindControl_SpawnFoe "bat\\bat" //TODO bats are getting stuck in the walls... they also get stuck in the air? they dont fly at all???
		//Set £FUNCMindControl_SpawnFoe "rat_base\\rat_base" //rats wont attack goblins...
		//TODO track all spawnings with ^last_spawned, kill them after the NPC dies, destroy the corpses and their loot
		
		//Set §FUNCMindControl_FrenzyDelay 60000
		
		//spawn npc "~£FUNCMindControl_SpawnFoe~" "~£FUNCMindControl_HoverEntTmp~"
		//Set £FUNCMindControl_SpawnFoeLastID ^last_spawned
		//timerVanishLastSpawn -m 1 §FUNCMindControl_FrenzyDelay Destroy "~£FUNCMindControl_SpawnFoeLastID~"
		
		//timerKillMCSpawn -m 1 59900 DoDamage -fmlcgewsao "~£FUNCMindControl_SpawnFoeLastID~" 99999
		//timerTFUNCMindControlKillSpawn -m 0 333 GoTo TFUNCMindControlKillSpawn
		
		//timerBreakDevice -m 1 §FUNCMindControl_FrenzyDelay GoTo TFUNCbreakDeviceDelayed //only after everything else have completed! this takes a long time to finish breaking it
		//timerMindControlDetectHoverNPC off
		
		GoSub FUNCshowlocals
	}
	RETURN
}
>>TFUNCMindControlKillSpawn () { GoSub FUNCMindControlKillSpawn ACCEPT } >>FUNCMindControlKillSpawn ()  {
	//teleport "~£FUNCMindControl_HoverEntTmp~" //should be enough to force bat attack the npc as it dont fly..
	interpolate "~£FUNCMindControl_SpawnFoeLastID~" "~£FUNCMindControl_HoverEntTmp~" 0.1
	if(^life_~£FUNCMindControl_HoverEntTmp~ <= 0){
		//DoDamage -fmlcgewsao "~£FUNCMindControl_SpawnFoeLastID~" 99999 //uneccessary?
		Destroy "~£FUNCMindControl_SpawnFoeLastID~"
		
		//Destroy "~£FUNCMindControl_HoverEntTmp~" //TODO will lose any items on it right? how to drop its items on floor? or could just change NPC mesh to "movable\\npc_gore\\npc_gore" and keep inventory stuff there! //destoying the npc is unsafe anyway, may destroy something that is game breaking...
		//just crashes... USEMESH -e £FUNCMindControl_HoverEntTmp "movable\\npc_gore\\npc_gore"
		//nothing happens SPAWN ITEM "movable\\npc_gore\\npc_gore" "~£FUNCMindControl_HoverEntTmp~"
		timerTFUNCMindControlKillSpawn off
	}
	RETURN
}
//>>FUNCMindControlSpawnFoeTrick () { Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;FUNCMindControl" 
	//Set £FUNCMindControl_HoverEnt "~^hover_5001~"
	//Set §HoverLife ^life_~£FUNCMindControl_HoverEnt~
	//if(and(£FUNCMindControl_HoverEnt != "none" && §HoverLife > 0)) {
		//Set £FUNCMindControl_SpawnFoe "bat\\bat" //TODO bats are getting stuck in the walls... they also get stuck in the air? they dont fly at all???
		////Set £FUNCMindControl_SpawnFoe "rat_base\\rat_base" //rats wont attack goblins...
		////TODO track all spawnings with ^last_spawned, kill them after the NPC dies, destroy the corpses and their loot
		//timerTeleportSelf -m 0 50 teleport ~£FUNCMindControl_HoverEnt~
		//timerMindControlSpawnBat -m 1 1000 spawn npc "~£FUNCMindControl_SpawnFoe~" "~£FUNCMindControl_HoverEnt~"
		//if(@AncientTechSkill >   20) timerMindControlSpawnBat2 -m 1 2000 spawn npc "~£FUNCMindControl_SpawnFoe~" "~£FUNCMindControl_HoverEnt~"
		//if(@AncientTechSkill >   40) timerMindControlSpawnBat3 -m 1 3000 spawn npc "~£FUNCMindControl_SpawnFoe~" "~£FUNCMindControl_HoverEnt~"
		//if(@AncientTechSkill >   60) timerMindControlSpawnBat4 -m 1 4000 spawn npc "~£FUNCMindControl_SpawnFoe~" "~£FUNCMindControl_HoverEnt~"
		//if(@AncientTechSkill >   80) timerMindControlSpawnBat5 -m 1 5000 spawn npc "~£FUNCMindControl_SpawnFoe~" "~£FUNCMindControl_HoverEnt~"
		//if(@AncientTechSkill >= 100) {
			//timerMindControlSpawnBat6 -m 1 6000 spawn npc "~£FUNCMindControl_SpawnFoe~" "~£FUNCMindControl_HoverEnt~"
			//timerMindControlSpawnBat7 -m 1 7000 spawn npc "~£FUNCMindControl_SpawnFoe~" "~£FUNCMindControl_HoverEnt~"
		//}
		//timerBreakDevice -m 1 1500 GoTo TFUNCbreakDeviceDelayed //only after everything else have completed! this takes a long time to finish breaking it
		//timerMindControlDetectHoverNPC off
		//GoSub FUNCshowlocals
	//}
	//RETURN
//}

>>TFUNCmorphUpgrade () { GoSub FUNCmorphUpgrade ACCEPT } >>FUNCmorphUpgrade ()  {
	//INPUT: <§FUNCmorphUpgrade_otherQuality>

	/////////////////////////////////////////////////////////////////////////////////
	////////////// MORPH thru simple activation while in inventory //////////////////
	// each this can become a combine tree. AncientBox is the first of the main devices. SignalRepeater could be the first of another tree!
	if (£AncientDeviceMode == "_BecomeSignalRepeater_") {
		Set £AncientDeviceMode "SignalRepeater"
		// this must be easy to become again a hologram, so do minimal changes!
		TWEAK SKIN "Hologram.tiny.index4000.box" "Hologram.tiny.index4000.boxSignalRepeater"
		if(§Identified == 1) {
			Set £FUNCnameUpdate«NameBase "Hologram Signal Repeater" 
		} else {
			Set £FUNCnameUpdate«NameBase "Grolhoam Nagils Atrepere" //all messy
		}
		Set £IconBasename "HoloSignalRepeater"
		SetGroup "Special"
		//Set §AncientDeviceTriggerStep 1
		//PlayerStackSize 1
		RETURN
	} else { 
	if ( £AncientDeviceMode == "SignalRepeater" ) {
		Set £AncientDeviceMode "RoleplayClassFocus" GoSub FUNCcfgAncientDevice
		SetGroup "Special"
		//TWEAK SKIN "Hologram.tiny.index4000.boxSignalRepeater" "Hologram.tiny.index4000.boxConfigOptions"
		RETURN //because this is not a normal tool
	} else { 
	if ( £AncientDeviceMode == "RoleplayClassFocus" ) {
		Set £AncientDeviceMode "ConfigOptions" GoSub FUNCcfgAncientDevice
		GoSub -p FUNCconfigOptions £»mode="show" ;
		SetGroup "Special"
		//TWEAK SKIN "Hologram.tiny.index4000.boxSignalRepeater" "Hologram.tiny.index4000.boxConfigOptions"
		RETURN //because this is not a normal tool
	} else { ////////////////////////// last, reinits/resets the Special non-combining cycle ///////////////////////
	if ( £AncientDeviceMode == "ConfigOptions" ) {
		Set £AncientDeviceMode "AncientBox" GoSub FUNCcfgAncientDevice
		GoSub -p FUNCconfigOptions £»mode="hide" ;
		SetGroup -r "Special" // back to basic device
		//TWEAK SKIN "Hologram.tiny.index4000.boxSignalRepeater" "Hologram.tiny.index4000.box"
		RETURN //because this is not a normal tool
	} else {
		NOP
	} } } }
	
	
	////////////////////////////////////////////////////////////////////////////////////
	/////////////////// MORPH only by combining below here! ////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////
	if(§FUNCmorphUpgrade_otherQuality < 0) GoSub FUNCCustomCmdsB4DbgBreakpoint
	
	Set §AncientDeviceTriggerStep 0
	GoSub FUNCskillCheckAncientTech	Set §CreateChance §FUNCskillCheckAncientTech«chanceSuccess_OUTPUT
	if (and(or(§Quality >= 4 || §FUNCmorphUpgrade_otherQuality >= 4) && §ItemConditionSure == 5)) Set §CreateChance 100
	RANDOM §CreateChance {
		if (or(£AncientDeviceMode == "HologramMode" || £AncientDeviceMode == "AncientBox")) { Set £AncientDeviceMode "Grenade"
			Set §PristineChance @FUNCskillCheckAncientTech«chanceSuccess_OUTPUT
			Div §PristineChance 10
			If (§PristineChance < 5) Set §PristineChance 5
			RANDOM §PristineChance { // grants a minimal chance based on skill in case the player do not initialize it
				Set §Quality 5 
			}
			
			if(§Identified == 1) {
				Set £FUNCnameUpdate«NameBase "Hologram Grenade" 
			} else {
				Set £FUNCnameUpdate«NameBase "Grolhoam Degnare" //messy
			}
			//Set £IconBasename "HologramGrenade"
			Set £IconBasename "AncientDevice.Grenade"
			
			//PLAY "TRAP"
			TWEAK SKIN "Hologram.tiny.index4000.box"               "Hologram.tiny.index4000.box.Clear"
			TWEAK SKIN "Hologram.tiny.index4000.grenade.Clear"     "Hologram.tiny.index4000.grenade"
			//TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow.Clear" "Hologram.tiny.index4000.grenadeGlow"
			
			GoSub FUNChideHologramPartsPermanently
			
			Set §Scale 100 SetScale §Scale //just in case it is combined with the big hologram on the floor
			
			Set §AncientDeviceTriggerStep 1
			PlayerStackSize 12
			SetGroup -r "DeviceTechBasic"
			SetGroup "Explosive"
		} else {
		if ( £AncientDeviceMode == "Grenade" ) { Set £AncientDeviceMode "LandMine"
			TWEAK SKIN "Hologram.tiny.index4000.box.Clear" "Hologram.tiny.index4000.boxLandMine"
			TWEAK SKIN "Hologram.tiny.index4000.grenade"   "Hologram.tiny.index4000.grenade.Clear"
			//TODO TWEAK SKIN "Hologram.tiny.index4000.LandMine.Clear"   "Hologram.tiny.index4000.LandMine"
			//Set §Scale 10 SetScale §Scale //TODO create a huge landmine (from box there, height 100%, width and length 5000%, blend alpha 0.1 there just to be able to work) on blender hologram overlapping, it will be scaled down here! Or should be a new model, a thin plate on the ground disguised as rock floor texture may be graph/obj3d/textures/l2_gobel_[stone]_floor01.jpg. Could try a new command like `setplayertweak mesh <newmesh>` but for items!
			if(§Identified == 1) {
				Set £FUNCnameUpdate«NameBase "Hologram Landmine" 
			} else {
				Set £FUNCnameUpdate«NameBase "Grolhoam Terra Perdere" //messy latin latin
			}
			Set £IconBasename "HoloLandMine"
			Set §AncientDeviceTriggerStep 1
			PLAYERSTACKSIZE 9
		} else {
		if ( £AncientDeviceMode == "LandMine" ) { Set £AncientDeviceMode "Teleport"
			TWEAK SKIN "Hologram.tiny.index4000.boxLandMine" "Hologram.tiny.index4000.boxTeleport" 
			Set §Scale 100 SetScale §Scale
			if(§Identified == 1) {
				Set £FUNCnameUpdate«NameBase "Hologram Teleport" 
			} else {
				Set £FUNCnameUpdate«NameBase "Grolhoam Itinerantur" //messy latin
			}
			Set £IconBasename "HoloTeleport"
			Set §AncientDeviceTriggerStep 1
			PLAYERSTACKSIZE 6
		} else {
		if ( £AncientDeviceMode == "Teleport" ) { Set £AncientDeviceMode "MindControl"
			// why bats? they are foes of everyone else and the final result is equivalent. //TODO But, may be, make them disappear as soon they die to prevent looting their corpses as easy bonus loot.
			// why not mind control the targeted foe directly? too complicated. //TODO create new copy foes asl that behave as a player summon? create a player summon and change it's model after killing the targeted foe? implement something in c++ that make it easier to let mind control work as initially intended?
			TWEAK SKIN "Hologram.tiny.index4000.boxTeleport" "Hologram.tiny.index4000.boxMindControl" 
			Set §Scale 100 SetScale §Scale
			if(§Identified == 1) {
				Set £FUNCnameUpdate«NameBase "Hologram Mind Control" 
			} else {
				Set £FUNCnameUpdate«NameBase "Grolhoam Mens Moderantum" //messy latin latin
			}
			Set £IconBasename "HoloMindControl"
			Set §AncientDeviceTriggerStep 1
			PLAYERSTACKSIZE 3
		} else {
		if ( £AncientDeviceMode == "MindControl" ) { Set £AncientDeviceMode "SniperBullet"
			TWEAK SKIN "Hologram.tiny.index4000.boxMindControl" "Hologram.tiny.index4000.boxSniperBullet" 
			Set §Scale 100 SetScale §Scale
			if(§Identified == 1) {
				Set £FUNCnameUpdate«NameBase "Hologram Sniper Bullet" 
			} else {
				Set £FUNCnameUpdate«NameBase "Grolhoam Procul Occidere" //messy latin latin
			}
			Set £IconBasename "AncientSniperBullet"
			Set §AncientDeviceTriggerStep 1
			PLAYERSTACKSIZE 3
		} } } } }
		
		if(§AncientDeviceTriggerStep == 1) {
			GoSub FUNCupdateUses
			GoSub FUNCnameUpdate
			GoSub FUNCupdateIcon
			GoSub FUNCsignalStrenghUpdateRequirement

			if( £AncientDeviceMode != "HologramMode" ) SET_SHADOW ON //because hologram emits light
		}
	} else {
		//SPEAK -p [player_picklock_failed] NOP //TODO expectedly just a sound about failure and not about picklocking..
		////SPEAK -p [player_wrong] NOP //TODO expectedly just a sound about failure
		GoSub FUNCbreakDeviceDelayed
		GoSub FUNCshowlocals
	}
	
	Set §FUNCmorphUpgrade_otherQuality -1 //init invalid to req b4 next call
	RETURN
}
>>FUNCcfgSkin () {
	//INPUT: <£«simple>
	if(not("Hologram" IsIn £«simple)) GoSub FUNCCustomCmdsB4DbgBreakpoint
	TWEAK SKIN "Hologram.tiny.index4000.box.Clear"         "~£«simple~"
	TWEAK SKIN "Hologram.tiny.index4000.boxSignalRepeater" "~£«simple~"
	TWEAK SKIN "Hologram.tiny.index4000.boxLandMine"       "~£«simple~"
	TWEAK SKIN "Hologram.tiny.index4000.boxTeleport"       "~£«simple~"
	TWEAK SKIN "Hologram.tiny.index4000.boxMindControl"    "~£«simple~"
	RETURN
}
>>TFUNCcfgAncientDevice () { GoSub FUNCcfgAncientDevice ACCEPT } >>FUNCcfgAncientDevice () {
	//INPUT: <£AncientDeviceMode>
	if(£AncientDeviceMode == "") GoSub FUNCCustomCmdsB4DbgBreakpoint
	
	if(£AncientDeviceMode == "AncientBox") {
		GoSub -p FUNCcfgSkin £»simple="Hologram.tiny.index4000.box" ;
		SET_PRICE 50
		PlayerStackSize 50
		Set £IconBasename "AncientBox"
		if(§Identified == 1) {
			Set £FUNCnameUpdate«NameBase "Ancient Box (OFF)" 
		} else {
			Set £FUNCnameUpdate«NameBase "Antiqua Capsa (Debilitatum)" //latin
		}
	} else {
	if(£AncientDeviceMode == "RoleplayClassFocus") {
		SET_MATERIAL METAL
		SET_GROUP JEWELRY
		SET_PRICE 50
		SET_STEAL 50
		SETEQUIP identify_value 1
		SETOBJECTTYPE RING
		SET_WEIGHT 0
		HALO -olcs 0.59 0.46 1 30
		SET_SHADOW OFF
		PlayerStackSize 1
		
		GoSub -p FUNCcfgSkin £»simple="Hologram.tiny.index4000.boxRoleplayClassFocus" ;
		
		Set £IconBasename "AncientRoleplayClassFocus"
		if(§Identified == 1) {
			Set £FUNCnameUpdate«NameBase "Ancient Box Class Focus" 
		} else {
			Set £FUNCnameUpdate«NameBase "Antiqua Capsa Slacs Sucfo" //latin/messy
		}
	} else {
	if(£AncientDeviceMode == "ConfigOptions") {
		GoSub -p FUNCcfgSkin £»simple="Hologram.tiny.index4000.boxConfigOptions" ;
		SET_PRICE 13
		PlayerStackSize 1
		Set £IconBasename "AncientConfigOptions"
		Set £FUNCnameUpdate«NameBase "Ancient Device Config Options" //keep always readable!
	} } }
	
	GoSub FUNCupdateUses
	GoSub FUNCnameUpdate
	
	RETURN
}
>>TFUNCcfgHologram () { GoSub FUNCcfgHologram ACCEPT } >>FUNCcfgHologram ()  {
	Set £AncientDeviceMode "HologramMode"
	
	if (§UseCount == 0) { //no uses will still be showing the doc so we know it is still to show the doc. this prevents changing if already showing a nice landscape
		Set £SkyBoxCurrent "Hologram.skybox.index2000.DocIdentified"
		Set £SkyBoxPrevious "~£SkyBoxCurrent~"
		TWEAK SKIN "Hologram.skybox.index2000.DocUnidentified" "~£SkyBoxCurrent~"
	}
	
	TWEAK SKIN "Hologram.tiny.index4000.box"               "Hologram.tiny.index4000.box.Clear"
	TWEAK SKIN "Hologram.tiny.index4000.boxSignalRepeater" "Hologram.tiny.index4000.box.Clear"
	TWEAK SKIN "Hologram.tiny.index4000.boxLandMine"       "Hologram.tiny.index4000.box.Clear"
	TWEAK SKIN "Hologram.tiny.index4000.boxTeleport"       "Hologram.tiny.index4000.box.Clear"
	TWEAK SKIN "Hologram.tiny.index4000.boxMindControl"    "Hologram.tiny.index4000.box.Clear"
	
	SET_PRICE 100
	
	if(§Identified == 1) {
		Set £FUNCnameUpdate«NameBase "Holograms of the over world" 
	} else {
		Set £FUNCnameUpdate«NameBase "Grolhoam Super Mundi" //messy latin latin
	}
	GoSub FUNCupdateUses
	GoSub FUNCnameUpdate
	
	PlayerStackSize 50
	
	TWEAK ICON "HologramInitialized[icon]"
	
	RETURN
}
>>FUNCsignalStrenghCheck () {
	//OUTPUT: §FUNCsignalStrenghCheck«IsAcceptable
	//OUTPUT: @FUNCsignalStrenghCheck«Required
	Set §«IsAcceptable 0
	
	Set @«Required @SignalStrengthReqBase
	if(§Quality >= 4) {
		Mul @«Required 1.666
		if(@«Required > 95) Set @«Required 95
	}
	
	if(@SignalStrength >= @«Required) Set §«IsAcceptable 1
	RETURN
}
>>TFUNCblinkGlow () { GoSub FUNCblinkGlow ACCEPT } >>FUNCblinkGlow () {
	//PARAMS: §«times
	GoSub FUNCsignalStrenghCheck
	if(and(§«times >= 0 && §FUNCsignalStrenghCheck«IsAcceptable == 1)){
		//TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow.Clear" "Hologram.tiny.index4000.grenadeGlow"
		//Off at  900 1800 2700 3600 4500. Could be 850 too: 850 1700 2550 3400 4250. but if 800 would clash with ON at 4000
		//timerTrapGlowBlinkOff -m §«times  901 TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow" "Hologram.tiny.index4000.grenadeGlow.Clear" //901 will last 100 times til it matches multiple of 1000 below
		timerTrapGlowBlinkOff -m §«times  901 Halo -f //901 will last 100 times til it matches multiple of 1000 below
		//On  at 1000 2000 3000 4000 5000
		//timerTrapGlowBlinkOn  -m §«times 1000 TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow.Clear" "Hologram.tiny.index4000.grenadeGlow"
		timerTrapGlowBlinkOn  -m §«times 1000 Halo -ocs 0.5 1.0 0.5 30
	} else {
		timerTrapGlowBlinkOff off
		timerTrapGlowBlinkOn  off
		//TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow" "Hologram.tiny.index4000.grenadeGlow.Clear"
		Halo -f
	}
	RETURN
}
//>>FUNCconfigOptionChk () {
	////INPUT: <@FUNCconfigOptionChk_chk>
	//Set §FUNCconfigOptionChk_chkTrunc @FUNCconfigOptionChk_chk
	//RETURN
//}
>>FUNCsignalStrenghUpdateRequirement () {
	Set @SignalStrengthReqBase 0
	// dont use too high values cuz of Mul below
	if(£AncientDeviceMode == "AncientBox"    ) Set @SignalStrengthReqBase  1
	if(£AncientDeviceMode == "SignalRepeater") Set @SignalStrengthReqBase  1
	if(£AncientDeviceMode == "RoleplayClassFocus") Set @SignalStrengthReqBase 100 //just to equip it
	if(£AncientDeviceMode == "ConfigOptions" ) Set @SignalStrengthReqBase  0 //keep 0!
	if(£AncientDeviceMode == "HologramMode"  ) Set @SignalStrengthReqBase  5 //can randomly be dangerous
	if(£AncientDeviceMode == "Grenade"       ) Set @SignalStrengthReqBase 30 //can instakill
	if(£AncientDeviceMode == "LandMine"      ) Set @SignalStrengthReqBase 75 //can instakill, easy to use
	if(£AncientDeviceMode == "MindControl"   ) Set @SignalStrengthReqBase 20 //
	if(£AncientDeviceMode == "Teleport"      ) Set @SignalStrengthReqBase 40 //instakills and travels
	if(£AncientDeviceMode == "SniperBullet"  ) Set @SignalStrengthReqBase 50 //instakills, safe to use
	GoTo FUNCsignalStrenghCheck
	RETURN
}

>>FUNCAncientDeviceActivationToggle () {
	//INPUT: <£FUNCAncientDeviceActivationToggle«force>
	//INPUT: <£FUNCAncientDeviceActivationToggle«Mode>
	//INPUT: [£FUNCAncientDeviceActivationToggle«callFuncWhenTargetReached]
	//INPUT: [£FUNCAncientDeviceActivationToggle«callFuncDetectNearbyTarget]
	
	if ( £«force == "ON" ) Set §AncientDeviceTriggerStep 1
	if ( £«force == "OFF" ) Set §AncientDeviceTriggerStep 2
	
	if ( §AncientDeviceTriggerStep == 1 ) { // stopped or stand-by. Will activate.
		if(£«Mode == "FlyToTarget") {
			if(not("FUNC" IsIn £«callFuncWhenTargetReached)) GoSub -p FUNCCustomCmdsB4DbgBreakpoint £»DbgMsg="ERROR: invalid £«callFuncWhenTargetReached=~£«callFuncWhenTargetReached~" ;
			GoSub -p FUNCDetectAndReachTarget £»mode="InitDetectTarget" £»callFuncWhenTargetReached=£«callFuncWhenTargetReached ;
		} else { if(£«Mode == "DetectTargetNearby") {
			if(not("FUNC" IsIn £«callFuncDetectNearbyTarget)) GoSub -p FUNCCustomCmdsB4DbgBreakpoint £»DbgMsg="ERROR: invalid £«callFuncDetectNearbyTarget=~£«callFuncDetectNearbyTarget~" ;
			timerFUNCAncientDeviceActivationToggle_DetectTargetNearby -m 0 50 GoTo -w £«callFuncDetectNearbyTarget
		} else {
			GoSub -p FUNCCustomCmdsB4DbgBreakpoint £»DbgMsg="ERROR: invalid mode £«Mode=~£«Mode~" ;
		} }
		GoSub -p FUNCblinkGlow §»times=0 ;
		Set §AncientDeviceTriggerStep 2
	} else { if ( §AncientDeviceTriggerStep == 2 ) { // Active. Will Stop.
		if(£«Mode == "FlyToTarget") {
			GoSub -p FUNCDetectAndReachTarget £»mode="stop" ;
		} else { if(£«Mode == "DetectTargetNearby") {
			timerFUNCAncientDeviceActivationToggle_DetectTargetNearby off
		} }
		GoSub -p FUNCblinkGlow §»times=-1 ;
		Set §AncientDeviceTriggerStep 1
		
		// cleanup b4 next call
		Set £«Mode ""
		Set £«callFuncWhenTargetReached ""
		Set £«callFuncDetectNearbyTarget ""
	} }
	
	GoSub -p FUNCshowlocals £»filter=FUNCAncientDeviceActivationToggle §»force=1 ;
	
	RETURN
}

>>FUNCtestModPatch () { 
	/**
	 * keep this example here as patching only works on original/vanilla files
	 * create the file hologram.tmpToCreatePatch.asl and modify there to: Set £TestModPatch "patched1b"
	 * $ sed -r -e 's@(TestModPatch ")original(")@\1patched1b\2@' hologram.asl >hologram.tmpToCreatePatch.asl
	 * $ diff -u hologram.asl hologram.tmpToCreatePatch.asl >hologram.asl.patch
	 */
	Set £TestModPatch "original" //change to "patched" at the diff's patch file !
	++ §testsPerformed
	Set £TestsCompleted "~£TestsCompleted~, ~^debugcalledfrom_0~"
	RETURN
}

>>FUNCtestChangeMesh () { 
	if(^inInventory != "none") RETURN //must be on floor
	//SetScale 150 //already fixed tho from 20 to 30 width in blender
	timerChangeMesh -m 1 750 USEMESH "ancientdevices/ancientdevice.grenade.ftl" // the extension will be removed and re-added!!!
	timerChangeSkinToActive -m 0 1000 TWEAK SKIN "AncientDevice.Grenade.StatusOFF" "AncientDevice.Grenade.StatusON" //after usemesh!!!
	timerChangeSkinToInactive -m 0 1251 TWEAK SKIN "AncientDevice.Grenade.StatusON" "AncientDevice.Grenade.StatusOFF" //after usemesh!!!
	
//	Set £FUNCtestLOD«lod "high" //TODOABCDE £«lod is not working at FUNCtestLOD when a timer calls TFUNCtestLOD like: timerTFUNCtestLOD -m 1 2000 GoTo -p TFUNCtestLOD £»lod="high" ;
//	timerTFUNCtestLOD -m 1 2000 GoTo TFUNCtestLOD
	
	RETURN
}
//>>TFUNCtestLOD () { GoSub -p FUNCtestLOD £»lod=£TFUNCtestLOD«lod ; GoSub -p FUNCshowlocals £»filter="testLOD" §»force=1 ; ACCEPT } >>FUNCtestLOD () {
>>TFUNCtestLOD () { GoSub FUNCtestLOD ACCEPT } >>FUNCtestLOD () {
	//INPUT: £FUNCtestLOD«lod
	if(£«lod == "") {
		GoSub -p FUNCCustomCmdsB4DbgBreakpoint £»DbgMsg="ERROR: invalid empty £«lod=~£«lod~" ;
		Set £«lod "high"
	}
	experiment LOD £«lod
	if(£«lod == "perfect")	{ Set £«lod "high" } else {
	if(£«lod == "high")			{ Set £«lod "medium" } else {
	if(£«lod == "medium")		{ Set £«lod "low" } else {
	if(£«lod == "low")			{ Set £«lod "bad" } else {
	if(£«lod == "bad")			{ Set £«lod "flat" } else {
	if(£«lod == "flat")			{ Set £«lod "perfect" } else {
		NOP
	} } } } } }
	//timerTFUNCtestLOD -m 1 1000 GoTo -p TFUNCtestLOD £»lod=£«lod ;
	timerTFUNCtestLOD -m 1 1000 GoTo TFUNCtestLOD
	GoSub -p FUNCshowlocals £»filter="testLOD" §»force=1 ;
	
	Set §DebugTestLOD 1
	RETURN
}

>>TFUNCtestEnv () { GoSub FUNCtestEnv ACCEPT } >>FUNCtestEnv () {
	Env -l
	RETURN
}

//KEEP HERE TEST: Set £TestFixScriptEncoding "matters(£§«»¥¶¤) maybe(`¹²³×äåéëþüúíóöáßðfghïø½©®bñµç¿~¡ÄÅÉËÞÜÚÍÓÖÁÐFGHÏ¼Ø°Æ¼¢®BÑµÇ)" // all can be easily input with AltGr dead keys

>>FUNCClassFocusCalc () {
	if(£AncientDeviceMode != "RoleplayClassFocus")	GoSub -p FUNCCustomCmdsB4DbgBreakpoint £»DbgMsg="ERROR: invalid call of class focus calc: '~£AncientDeviceMode~'" ;
	
	////////////////////////////////////////////////////////////
	///////////// based on docs/RoleplayClassFocusBuffSkills.txt
	
	Set @«mageCasting      ^PLAYER_SKILL_CASTING
	Set @«mageEtherealLink ^PLAYER_SKILL_ETHERAL_LINK
	Set @«mageObjKnowledge ^PLAYER_SKILL_OBJECT_KNOWLEDGE
	
	Set @«thiefMechanism ^PLAYER_SKILL_MECANISM
	Set @«thiefStealth   ^PLAYER_SKILL_STEALTH
	Set @«thiefIntuition ^PLAYER_SKILL_INTUITION
	
	Set @«warriorProjectile ^PLAYER_SKILL_PROJECTILE
	Set @«warriorCombat     ^PLAYER_SKILL_CLOSE_COMBAT
	//Set @«warriorDefensePrevious @«warriorDefense //DEBUGRM
	Set @«warriorDefense    ^PLAYER_SKILL_DEFENSE
	//Set @«warriorDefenseToo ^PLAYER_SKILL_DEFENSE //DEBUGRM

	Set @«TotalClasses 3
	Calc @«fNormalizer [ @«TotalClasses - 1 ]
	Set @«fDifficulty 1.0 // TODO user cfg or base this in some global game cfg about difficulty: 0.0 hardest=vanilla; ... ; 1.0 default calculated bonus; > 1.0 easier than default, means more bonus
	
	// sum for each class
	Calc @«M [ @«mageCasting       + @«mageEtherealLink + @«mageObjKnowledge ]
	Calc @«T [ @«thiefMechanism    + @«thiefStealth     + @«thiefIntuition   ]
	//Set @«Wprevious @«W //DEBUGRM
	Calc @«W [ @«warriorProjectile + @«warriorCombat    + @«warriorDefense   ]
	
	// bonus for each class
	Calc @«BMW [ @«M - @«W ] if(@«BMW < 0) Set @«BMW 0
	Calc @«BMT [ @«M - @«T ] if(@«BMT < 0) Set @«BMT 0
	Calc @«BM  [ @«BMW + @«BMT ]
	
	Calc @«BTM [ @«T - @«M ] if(@«BTM < 0) Set @«BTM 0
	Calc @«BTW [ @«T - @«W ] if(@«BTW < 0) Set @«BTW 0
	Calc @«BT  [ @«BTM + @«BTW ]
	
	Calc @«BWM [ @«W - @«M ] if(@«BWM < 0) Set @«BWM 0
	Calc @«BWT [ @«W - @«T ] if(@«BWT < 0) Set @«BWT 0
	//Set @«BWprevious @«BW //DEBUGRM
	Calc @«BW  [ @«BWM + @«BWT ]
	
	Div @«BM @«fNormalizer
	Div @«BT @«fNormalizer
	Div @«BW @«fNormalizer
	
	// bonus multiplier
	Calc @«PM [ @«BM * @«fDifficulty / @«M ]
	Calc @«PT [ @«BT * @«fDifficulty / @«T ]
	Calc @«PW [ @«BW * @«fDifficulty / @«W ]
	
	// final bonus result
	// mage
	Calc @«FCasting         [ @«mageCasting * @«PM ]
	Calc @«FEtherealLink    [ @«mageEtherealLink * @«PM ]
	Calc @«FObjectKnowledge [ @«mageObjKnowledge * @«PM ]
	// thief
	Calc @«FIntuition [ @«thiefIntuition * @«PT ]
	Calc @«FStealth [ @«thiefStealth * @«PT ]
	Calc @«FMechanism [ @«thiefMechanism * @«PT ]
	// warrior
	Calc @«FProjectile [ @«warriorProjectile * @«PW ]
	Calc @«FCombat     [ @«warriorCombat * @«PW ]
	Calc @«FDefense    [ @«warriorDefense * @«PW ]
	
	// apply
	SETEQUIP CASTING          +~@«FCasting~
	SETEQUIP ETHERAL_LINK     +~@«FEtherealLink~
	SETEQUIP OBJECT_KNOWLEDGE +~@«FObjectKnowledge~
	
	SETEQUIP STEALTH   +~@«FStealth~
	SETEQUIP MECANISM  +~@«FMechanism~
	SETEQUIP INTUITION +~@«FIntuition~
	
	SETEQUIP CLOSE_COMBAT +~@«FCombat~
	SETEQUIP PROJECTILE   +~@«FProjectile~
	SETEQUIP DEFENSE      +~@«FDefense~
	
	GoSub -p FUNCshowlocals §»force=1 ;
	
	RETURN
}

ON EQUIPIN () {
	if(£AncientDeviceMode == "RoleplayClassFocus") {
		PLAY "EQUIP_RING"
		
		//GoSub FUNCsignalStrenghCheck
		//if(§FUNCsignalStrenghCheck«IsAcceptable == 1) {
			GoSub FUNCClassFocusCalc
			//HERO_SAY -d "Class Focus ON"
		//} else {
			//HERO_SAY -d "Class Focus FAIL (re-equip at a high signal strength location)"
		//}
	} else {
		HERO_SAY -d "Equip failed"
		GoSub -p FUNCshowlocals §»force=1 ;
	}
	
	ACCEPT
}

ON EQUIPOUT () {
	if(£AncientDeviceMode == "RoleplayClassFocus") {
		//TODO explain why "magic/ring_oliver/ring_oliver.asl" doesnt need to undo the bonus like is required below...
		SETEQUIP CASTING          -~@«FCasting~
		SETEQUIP ETHERAL_LINK     -~@«FEtherealLink~
		SETEQUIP OBJECT_KNOWLEDGE -~@«FObjectKnowledge~
		
		SETEQUIP STEALTH   -~@«FStealth~
		SETEQUIP MECANISM  -~@«FMechanism~
		SETEQUIP INTUITION -~@«FIntuition~
		
		SETEQUIP CLOSE_COMBAT -~@«FCombat~
		SETEQUIP PROJECTILE   -~@«FProjectile~
		SETEQUIP DEFENSE      -~@«FDefense~
		
		HERO_SAY -d "Class Focus OFF"
		ACCEPT
	}
}

ON INVENTORYUSE () {
	if(§DebugTestLOD == 1) ACCEPT
	if(§InitDefaultsDone == 0) GoSub FUNCinitDefaults
	
	if (^amount > 1) {
		SPEAK -p [player_no] NOP
		ACCEPT //this must not be a stack of items
	}

	++ §OnInventoryUseCount //total activations just for debug
	
	if(^inPlayerInventory == 1) {
		// this is another morph cycle, just activate to go, no combining:
		if(and(£AncientDeviceMode == "AncientBox" && §bHologramInitialized == 0)) { //signal repeater can only be created inside the inventory
			Set £AncientDeviceMode "_BecomeSignalRepeater_"
			GoSub FUNCmorphUpgrade
			ACCEPT
		} else {
		if(£AncientDeviceMode == "SignalRepeater") {
			GoSub FUNCmorphUpgrade
			ACCEPT
		} else {
		if(£AncientDeviceMode == "RoleplayClassFocus") {
			GoSub FUNCmorphUpgrade
			ACCEPT
		} else {
		if(£AncientDeviceMode == "ConfigOptions") { //last only revert to hologram inside the inventory
			GoSub FUNCmorphUpgrade
			ACCEPT
		} } } }
	}
	
	if ( £AncientDeviceMode == "Grenade" ) { // is unstable and cant be turned off. no toggle
		if(and(@testPlayerDegreesX > 74 && @testPlayerDegreesX < 75)) {
			GoSub FUNCtestChangeMesh
			ACCEPT
		}
		
		if ( §AncientDeviceTriggerStep == 1 ) {
			if (^amount > 1) { //cannot activate a stack of items
				SPEAK -p [player_no] NOP
				ACCEPT
			}
			
			GoSub FUNCskillCheckAncientTech
			Set §ActivateChance §FUNCskillCheckAncientTech«chanceSuccess_OUTPUT
			if ( §Quality >= 4 ) {
				Set §ActivateChance 100
			}
			RANDOM §ActivateChance { //not granted to successfully activate it as it is a defective device
				Set §FUNCtrapAttack«TimeoutMillis §DefaultTrapTimeoutMillis
				
				//TWEAK ICON "HologramGrenadeActive[icon]"
				TWEAK ICON "AncientDevice.Grenade.Active[icon]"
				TWEAK SKIN "Hologram.tiny.index4000.grenade" "Hologram.tiny.index4000.grenadeActive"
				/* todob
				//USEMESH "magic\hologram\AncientDevice.Grenade"
				USEMESH "ancientdevices/ancientdevice.grenade"
				TWEAK SKIN "AncientDevice.Grenade" "AncientDevice.Grenade.Active" //after usemesh!!!
				*/
				
				Calc §«calcTimes [ §FUNCtrapAttack«TimeoutMillis / 1000 ]
				GoSub -p FUNCblinkGlow §»times=§«calcTimes ;
				
				//timerTrapVanish     -m 1 §FUNCtrapAttack«TimeoutMillis TWEAK SKIN "Hologram.tiny.index4000.grenade"     "Hologram.tiny.index4000.grenade.Clear"
				//timerTrapVanishGlow -m 1 §FUNCtrapAttack«TimeoutMillis TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow" "Hologram.tiny.index4000.grenadeGlow.Clear"
				
				GoSub FUNCtrapAttack
			} else {
				//SetName "Broken Hologram Device"
				////PLAY "POWER_DOWN"
				////PLAY "sfx_lightning_loop"
				//GoSub FUNCshockPlayer
				////GoSub FUNCMalfunction
				////SpecialFX TORCH //it vanished..
				//SpecialFX FIERY
				//SetGroup "DeviceTechBroken"
				GoSub FUNCbreakDeviceDelayed
			}
			//timerTrapDestroy -m 1 5100 GoTo TFUNCDestroySelfSafely
			//timerTrapDestroy -m 1 7000 GoTo TFUNCDestroySelfSafely //some effects have infinite time and then will last 2s (from 5000 to 7000)
			Set §AncientDeviceTriggerStep 2
		} else { // after trap being activated will only shock the player and who is in-between too
			GoSub FUNCshockPlayer
			if (^inPlayerInventory == 1) { //but if in inventory, will dissassemble the grenade recovering 2 holograms used to create it
				INVENTORY ADDMULTI "magic\hologram\hologram" 2 //TODO this isnt working?
				GoSub FUNCDestroySelfSafely
			}
		}
		ACCEPT
	} else {
	if ( £AncientDeviceMode == "LandMine" ) {
		//if ( §AncientDeviceTriggerStep == 1 ) {
			//Set §AncientDeviceTriggerStep 2 //activate
			////Set §Scale 500 SetScale §Scale //TODO should be a new model, a thin plate on the ground disguised as rock floor texture may be graph/obj3d/textures/l2_gobel_[stone]_floor01.jpg. Could try a new command like `setplayertweak mesh <newmesh>` but for items!
			//Set §Scale 33 SetScale §Scale //TODOA create a huge landmine (from box there, height 100%, width and length 5000%, blend alpha 0.1 there just to be able to work) on blender hologram overlapping, it will be scaled down here! Or should be a new model, a thin plate on the ground disguised as rock floor texture may be graph/obj3d/textures/l2_gobel_[stone]_floor01.jpg. Could try a new command like `setplayertweak mesh <newmesh>` but for items!
			//timerTFUNCLandMine -m 0 50 GoTo TFUNCLandMine
			//GoSub -p FUNCblinkGlow §»times=0 ;
		//} else { if ( §AncientDeviceTriggerStep == 2 ) {
			//timerTFUNCLandMine off 
			////Set §Scale 100 SetScale §Scale
			//Set §AncientDeviceTriggerStep 1  //stop
			//GoSub -p FUNCblinkGlow §»times=-1 ;
		//} }
		Set §Scale 33 SetScale §Scale //TODOA create a huge landmine (from box there, height 100%, width and length 5000%, blend alpha 0.1 there just to be able to work) on blender hologram overlapping, it will be scaled down here! Or should be a new model, a thin plate on the ground disguised as rock floor texture may be graph/obj3d/textures/l2_gobel_[stone]_floor01.jpg. Could try a new command like `setplayertweak mesh <newmesh>` but for items!
		GoSub -p FUNCAncientDeviceActivationToggle £»Mode="DetectTargetNearby" £»callFuncDetectNearbyTarget=TFUNCLandMine ;
		ACCEPT
	} else {
	if ( £AncientDeviceMode == "Teleport" ) {
		//if ( §AncientDeviceTriggerStep == 1 ) {
			//Set §AncientDeviceTriggerStep 2 // activate
			//timerTFUNCteleportToAndKillNPC -m 0 333 GoTo TFUNCteleportToAndKillNPC
			//GoSub -p FUNCblinkGlow §»times=0 ;
		//} else { if ( §AncientDeviceTriggerStep == 2 ) {
			//timerTFUNCteleportToAndKillNPC off
			//Set §AncientDeviceTriggerStep 1  //stop
			//GoSub -p FUNCblinkGlow §»times=-1 ;
		//} }
		Set @CFUNCFlyMeToTarget«flySpeed 0.5 //takes 2s
		GoSub -p FUNCAncientDeviceActivationToggle £»Mode="FlyToTarget" £»callFuncWhenTargetReached=CFUNCTeleportPlayerToTarget ;
		ACCEPT
	} else {
	if ( £AncientDeviceMode == "MindControl" ) {
		if ( §AncientDeviceTriggerStep == 1 ) {
			Set §AncientDeviceTriggerStep 2
			timerMindControlDetectHoverNPC -m 0 333 GoTo TFUNCMindControl
			GoSub -p FUNCblinkGlow §»times=0 ;
		} else { if ( §AncientDeviceTriggerStep == 2 ) {
			timerMindControlDetectHoverNPC off
			Set §AncientDeviceTriggerStep 1  //stop
			GoSub -p FUNCblinkGlow §»times=-1 ;
		} }
		//TODOA GoSub -p FUNCAncientDeviceActivationToggle £»Mode=FlyToTarget £»callFuncWhenTargetReached=CFUNCMindControlAtTarget ;
		GoSub FUNCnameUpdate
		ACCEPT
	} else {
	if ( £AncientDeviceMode == "SniperBullet" ) {
		Set @CFUNCFlyMeToTarget«flySpeed 3.0 //takes 0.33s
		GoSub -p FUNCAncientDeviceActivationToggle £»Mode="FlyToTarget" £»callFuncWhenTargetReached=CFUNCSniperBulletAtTarget ;
		ACCEPT
	} else {
	if ( £AncientDeviceMode == "RoleplayClassFocus" ) {
		EQUIP PLAYER
		ACCEPT
	} } } } } }
	GoSub FUNCnameUpdate
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////  !!! HOLOGRAM ONLY BELOW HERE !!!  /////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	
	if(and(£AncientDeviceMode == "AncientBox" && ^inInventory == "none")) { //on floor
		GoSub FUNCcfgHologram
		ACCEPT
	}
	
	if(£AncientDeviceMode != "HologramMode") {
		Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;Unrecognized:£AncientDeviceMode='~£AncientDeviceMode~'"
		SPEAK -p [player_no] NOP
		GoSub -p FUNCshowlocals §»force=1 £»filter=".*(AncientDevice|ActivateChance|quality|blinkGlow|trapAttack|UseCount|UseBlockedMili).*" ;
		ACCEPT
	}
	
	//////////////// DENY ACTIVATION SECTION ///////////////////////
	
	Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;DebugLog:10"
	//Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;20"
	//if (^inPlayerInventory == 1) {
		//if(and(£AncientDeviceMode == "HologramMode" && §bHologramInitialized == 0)) {
			//Set £AncientDeviceMode "_BecomeSignalRepeater_"
			//GoSub FUNCmorphUpgrade
		//} else {
		//if(£AncientDeviceMode == "SignalRepeater") {
			//GoSub FUNCmorphUpgrade //revert to hologram
		//} else {
			//PLAY "POWER_DOWN"
			//GoSub FUNCshowlocals
		//}	}
		//ACCEPT //can only be activated if deployed
	//}
	
	if (§UseBlockedMili > 0) {
		GoSub FUNCMalfunction
		Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;Deny_A:Blocked=~§UseBlockedMili~"
		
		++ §UseCount 
		GoSub FUNCupdateUses //an attempt to use while blocked will damage it too, the player must wait the cooldown
		GoSub FUNCnameUpdate
		
		GoSub FUNCshowlocals
		ACCEPT
	} else { if (§UseBlockedMili < 0) {
		// log to help fix inconsistency if it ever happens
		timerBlocked off
		Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;Fix_A:Blocked=~§UseBlockedMili~ IsNegative, fixing it to 0"
		//GoSub FUNCshowlocals
		Set §UseBlockedMili 0
	} }
	
	if (§bHologramInitialized == 1) {
		if ( ^#PLAYERDIST > 200 ) { //after scale up. 185 was almost precise but annoying to use. 190 is good but may be annoying if there is things on the ground.
			GoSub FUNCMalfunction
			Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;Deny_C:PlayerDist=~^#PLAYERDIST~"
			GoSub FUNCshowlocals
			ACCEPT
		}
	}
	
	//////////// INITIALIZE: Turn On ///////////
	if (§bHologramInitialized == 0) { //first use will just scale it up/initialize it
		PLAY "POWER"
		
		//Collision ON
		//Damager -eu 1
		PLAYERSTACKSIZE 1 //for the HOLOGRAM functionalities it is important to prevent resetting the use count when trying to mix(glitch) a stack, on reload game, it seems to keep the local vars to each object!
		SetGroup "DeviceTechHologram"
		
		TWEAK SKIN "Hologram.tiny.index4000.box" "Hologram.tiny.index4000.box.Clear"
		
		////Set §UseMax 5
		////Inc §UseMax ^rnd_110
		////GoSub FUNCcalcAncientTechSkill
		////Inc §UseMax @AncientTechSkill
		////Set §UseRemain §UseMax
		//Set §UseHologramDestructionStart §UseMax
		//Mul §UseHologramDestructionStart 0.95
		Calc §UseHologramDestructionStart [ §UseMax * 0.95 ]
		
		SET_SHADOW OFF
		Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;30"
		
		// grow effect (timers begin imediatelly or after this event exits?)
		// total time
		Set §UseBlockedMili 2000 //the time it will take to grow
		//timerBlocked -m 100 50 Dec §UseBlockedMili 50 //to wait while it scales up
		timerBlocked -m 0 50 Dec §UseBlockedMili 50 //will just decrement §UseBlockedMili
		// interactivity blocked
		SET_INTERACTIVITY NONE
		timerInteractivity -m 1 §UseBlockedMili SET_INTERACTIVITY YES
		// scale up effect (each timer must have it's own unique id)
		Set §Scale 100 //default. target is 1000%
		timerGrowInc  -m 100 20 Inc §Scale 9 //1000-100=900; 900/100=9 per step
		timerGrowInc2 -m 100 20 SetScale §Scale
		
		Set §bHologramInitialized 1
		
		TWEAK ICON "HologramInitialized[icon]"
		
		GoSub FUNCupdateUses
		GoSub FUNCnameUpdate
		
		//showvars
		GoSub FUNCshowlocals //to not need to scroll up the log in terminal
		ACCEPT
	}
	
	//////////////// WORK on landscapes etc /////////////////////////
	++ §UseCount
	
	if (§UseCount == 1) { //init skyboxes
		Set §SkyMode 2 //cubemap
		Set §SkyBoxIndex 0 //initializes the landscapes
		Set £SkyBoxCurrent "Hologram.skybox.index~§SkyBoxIndex~"
		TWEAK SKIN "Hologram.skybox.index2000.DocIdentified"   "~£SkyBoxCurrent~" //no problem if unidentified
		TWEAK SKIN "Hologram.skybox.index2000.DocUnidentified" "~£SkyBoxCurrent~"
		//Set £SkyBoxCurrentUVS "Hologram.skybox.UVSphere.index3000.Clear" //sync this with what is in blender
		Set £SkyBoxCurrentUVS "Hologram.skybox.UVSphere.index2000.DocBackground" //sync this with what is in  blender
		GoSub FUNCChangeSkyBox
	}
	
	// means the device is malfunctioning and shocks the player, was 25%
	Set §Malfunction 0
	GoSub FUNCskillCheckAncientTech
	Set §ChkMalfunction §FUNCskillCheckAncientTech«chanceFailure_OUTPUT
	Div §ChkMalfunction 2
	RANDOM §ChkMalfunction {
		GoSub FUNCshockPlayer
		//dodamage -lu player 3 //-u push, extra dmg with push. this grants some damage if lightning above fails
		INC §UseCount 10  //damage
		INC §UseCount ^rnd_10
		Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;60.damagePlayer"
		Set §Malfunction 1
		Inc §UseBlockedMili ^rnd_10000
	}
	
	//it called the attention of some hostile creature, not related to player skill. no need to use any hiding/shadow value as the hologram emits light and will call attention anyway. Only would make sense in some closed room, but rats may find their way there too.
	RANDOM 10 {
		PLAY "sfx_lightning_loop"
		RANDOM 75 { 
			spawn npc "rat_base\\rat_base" SELF //player
			INC §UseCount 20 //damage
			INC §UseCount ^rnd_20
			Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;70.spawn rat"
			Inc §UseBlockedMili ^rnd_15000
			Set §Malfunction 1
		} else {
			//spawn npc "wrat_base\\wrat_base" player //too strong on low levels
			//TODOA add medium (usesdmg30-60) and hard (usesdmg50-80) creatures? is there a hostile dog (medium) or a weak small spider (hard)?  tweak/create a shrunk small and nerfed spider (hard)! tweak/create a bigger buffed rat (medium)! try the demon and the blue creature
			////RANDOM 75 {
				//spawn npc "dog\\dog" player //these dogs are friendly...
				//Inc §UseBlockedMili 30000
				//Set §Malfunction 1
				//INC §UseCount 5 //durability
				//Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;70.spawn dog"
				////spawn npc "bat\\bat" player //no, kills rats
			////} else {
				////spawn npc "goblin_base\\goblin_base" player //doesnt attack player
				////spawn npc "goblin_test\\goblin_test" player //doesnt attack the player
				//Inc §UseBlockedMili 60000
				//Set §Malfunction 1
			////}
		//}
		}
	}
	
	// warning to help the player wakeup 
	if (§UseCount >= §UseHologramDestructionStart) { //this may happen a few times or just once, depending on the player bad luck ;)
		RANDOM 25 {
			PLAY "sfx_lightning_loop"
		}
		PLAY "TRAP"
		SETLIGHT 1 //TODO??
		Set §Malfunction 1
		Set §UseBlockedMili 100 //to prevent any other delay and let the player quickly reach the destruction event
		TWEAK SKIN "Hologram.skybox.index1000.Status.Good" "Hologram.skybox.index1000.Status.Bad"
		GoSub FUNCshockPlayer
	}

	if (§Malfunction > 0) {
		GoSub FUNCMalfunction
		//DoDamage -u player 0 //-u push
	} else {
		/////////// HEALING EFFECTS
		GoSub FUNCskillCheckAncientTech
		RANDOM §FUNCskillCheckAncientTech«chanceSuccess_OUTPUT { //was just 50
			//PLAY "potion_mana"
			//Set @IncMana @SignalStrLvl
			//Inc @IncMana @FUNCskillCheckAncientTech«addBonus_OUTPUT
			Calc @IncMana [ @SignalStrLvl + @FUNCskillCheckAncientTech«addBonus_OUTPUT ]
			if ( §Identified > 0 ) Mul @IncMana 1.5
			SpecialFX MANA @IncMana
			//TODO play some sound that is not drinking or some visual effect like happens with healing
			SPEAK -p [player_yes] NOP //TODO good?
			Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;MANA"
		}
		
		GoSub FUNCskillCheckAncientTech
		RANDOM §FUNCskillCheckAncientTech«chanceSuccess_OUTPUT { //was just 50
			//SpecialFX HEAL @SignalStrLvl
			//Set @IncHP @SignalStrLvl
			//Inc @IncHP @FUNCskillCheckAncientTech«addBonus_OUTPUT
			Calc @IncHP [ @SignalStrLvl + @FUNCskillCheckAncientTech«addBonus_OUTPUT ]
			if ( §Identified > 0 ) Mul @IncHP 1.5
			SPELLCAST -msf @IncHP HEAL PLAYER
			Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;HEAL"
			//Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;43"
		}
		
		///////////////// SKYBOXES
		GoSub FUNCChangeSkyBox
	}
	
	Set £_aaaDebugScriptStackAndLog "~£_aaaDebugScriptStackAndLog~;100;"
	if (§UseCount >= §UseMax) { /////////////////// DESTROY ///////////////////
		Set §DestructionStarted 1
		PLAY "TRAP"
		PLAY "POWER"
		SET_INTERACTIVITY NONE
		attractor SELF 1 3000 //intentionally hinders player fleeing a bit
		//nothing happens: SetTrap 20 //technical is the skill used to detect trap above that value
		//SPELLCAST -smf 1 Paralyze PLAYER //nothing happens
		//DoDamage -lu player 1 //-u push
		//SPELLCAST -smf 1 Trap PLAYER //nothing happens
		GoSub FUNCMakeNPCsHostile
		
		///////////// ANIMATION ////////////////
		//Set §UseBlockedMili 999999 //any huge value beyond destroy limit
		//             times delay
		//timerShrink1 -m 100   30 Dec §Scale 10 //from 1000 to 0 in 3s with a shrink of 10% each step
		//timerShrink2 -m 100   30 SetScale §Scale
		// total time to finish the animation is 5000ms
		//Set §SIZED 10 //controls shrink varying speed from faster to slower: 5000/x=10/1; x=5000/10; 500ms
		//timerShrink0 -m 100  500 Dec §SIZED 1 //this is the speed somehow
		//timerShrink1 -m 100   50 Dec §Scale §SIZED
		timerShrink1 -m 100   50 Dec §Scale 10
		timerShrink2 -m 100   50 SetScale §Scale
		//timerLevitateX -m  0 150 Inc §TEMPORARY ^rnd_2
		//timerLevitateZ -m  0 200 Inc §TEMPORARY2 3
		timerLevitate  -m 10 100 Move 0 -10 0 // Y negative is upwards //this doesnt seem to work well everytime //TODO use animation, but how?
		timerCrazySpin10p -m 0 75 Inc §RotateY 1
		//timerCrazySpin10y -m 0 150 Inc §TEMPORARY 2
		//timerCrazySpin10r -m 0 200 Inc §TEMPORARY2 3
		//timerCrazySpin10  -m 0 10 Rotate §tmp §TEMPORARY §TEMPORARY2
		timerCrazySpin10  -m 0 10 Rotate 0 §RotateY 0 //the model doesnt spin from it's mass or geometric center but from it's origin that is on the bottom and using other than Y will just look bad..
		//timerCrazySpin20 -m 0   10 Rotate ^rnd_360 ^rnd_360 ^rnd_360
		RANDOM 15 { //to prevent player using as granted weapon against NPCs
			//timerAttack55 -m  1 4950 SETTARGET PLAYER //for fireball
			//timerAttack56 -m  1 5000 SPAWN FIREBALL //the origin to fire from must be above floor
			//Set §FUNCtrapAttack«TrapMode 1 //projectile at player
			//Set §FUNCtrapAttack«TimeoutMillis §DefaultTrapTimeoutMillis
			GoSub -p FUNCtrapAttack §»TrapMode=1 §»TimeoutMillis=§DefaultTrapTimeoutMillis ;
		} else {
		RANDOM 25 { //to prevent player using as granted weapon against NPCs
			//Set §FUNCtrapAttack«TimeoutMillis §DefaultTrapTimeoutMillis
			//timerTrapVanish -m 1 §FUNCtrapAttack«TimeoutMillis GoTo TFUNChideHologramPartsPermanently
			GoSub -p FUNCtrapAttack §»TimeoutMillis=§DefaultTrapTimeoutMillis ;
			//timerDestroy -m   1 5100 GoTo TFUNCDestroySelfSafely
		} }
		
		if (§FUNCtrapAttack«TrapCanKillMode_OUTPUT == 0) {
			timerTFUNCDestroySelfSafely -m 1 §DefaultTrapTimeoutMillis GoTo TFUNCDestroySelfSafely
		}
		
		GoSub FUNCupdateUses
		GoSub FUNCnameUpdate
		
		//showvars
		GoSub FUNCshowlocals //last to be easier to read on log
		ACCEPT
	}
	
	if (§UseBlockedMili <= 0) {
		Inc §UseBlockedMili ^rnd_5000 //normal activation minimum random delay
	}
	
	if (§UseCount < §UseHologramDestructionStart) { 
		//this must be after all changes to §UseBlockedMili !
		//trap start used the status bad override, so it can be ignored as wont change
		TWEAK SKIN "Hologram.skybox.index1000.Status.Good" "Hologram.skybox.index1000.Status.Warn"
		//// after the timeout will always be GOOD
		//Set £StatusSkinCurrent "Hologram.skybox.index1000.Status.Good"
		//Set £StatusSkinPrevious "~£StatusSkinCurrent~"
		//// reaching this point is always WARN: the player must wait the cooldown
		timerSkinGood -m 1 §UseBlockedMili TWEAK SKIN "Hologram.skybox.index1000.Status.Warn" "Hologram.skybox.index1000.Status.Good"
	}
	
	timerBlocked -m 0 50 Dec §UseBlockedMili 50 //will just decrement §UseBlockedMili (should use -i too to only work when player is nearby?)
	
	GoSub FUNCupdateUses
	GoSub FUNCnameUpdate
	
	GoSub FUNCshowlocals
	ACCEPT
}






/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
>>CFUNCA_KeepAtTheEnd () { // !!! important to quickly check if the script openning and closing of braces match!!!!!!!!!!!!!!!!!!!!!!!
	RETURN
}
