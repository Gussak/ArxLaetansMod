///////////////////////////////////////////
// by Gussak (https://github.com/Gussak) //
///////////////////////////////////////////

//////////////////////////////////////
// ON RELEASE: comment lines with //COMMENT_ON_RELEASE

////////////////////////////////////
// Obs.: If you just downloaded it from github, this file may need to have all 0xC2 chars (from before £ §) removed or it will not work. I cant find yet a way to force iso-8859-15 while editing it directly on github, it seems to always become utf-8 there.

///////////////// DEV HELP: term cmds //////////////
//clear;LC_ALL=C egrep 'torch'   --include="*.asl" --include="*.ASL" -iRnIa  *
//clear;LC_ALL=C egrep 'torch.*' --include="*.asl" --include="*.ASL" -iRIaho * |sort -u
//clear;LC_ALL=C egrep 'angle' --include="*.h" --include="*.cpp" -iRnI *

////////////////// CPP EASY HELP /////////////////////
// #include <iostream>
// #define MYDBG(x) std::cout << "___MySimpleDbg___: " << x << "\n"
// MYDBG(anyVar<<","<<anything<<anythinElse);

///////////////// TIPS: /////////////////
// ALWAYS use this: inventory add magic/hologram/hologram ; after any changes and ALWAYS work with a freshly instantiated item, othewise the log will show many things that are inconsistent.

// clear;LC_ALL=C egrep 'player_skill[^ ]*' --include="*.asl" --include="*.ASL" -iRIaho |tr -d '~\r\t"' |sort -u
//^PLAYER_SKILL_CASTING
//^PLAYER_SKILL_CLOSE_COMBAT
//^PLAYER_SKILL_DEFENSE
//^PLAYER_SKILL_INTUITION
//^PLAYER_SKILL_MECANISM
//^PLAYER_SKILL_OBJECT_KNOWLEDGE
//^PLAYER_SKILL_PROJECTILE
//^PLAYER_SKILL_STEALTH
// 
//^PLAYER_ATTRIBUTE_CONSTITUTION
//^PLAYER_ATTRIBUTE_DEXTERITY
//^PLAYER_ATTRIBUTE_MENTAL
//^PLAYER_ATTRIBUTE_STRENGTH

//on inventories init, this configures the generic scroll into specific spell and level:
// INVENTORY ADD "magic\\scroll_generic\\scroll_generic"
// SENDEVENT -ir TRANSMUTE 1 "8 SPEED" //the 1 distance means apparently items inside the container being ON INIT or ON INITEND
// SENDEVENT -ir CUSTOM 1000 "SomeCustomString ~§SomeVar1~ ~§SomeVar2~ ~§SomeVar3~ ~§SomeVar4~ ~§SomeVar5~" // there is no limit for the number of parameters and types, so anything can be communicated between entities, nice! Just collect them with the correct type: ^$param<i> string, ^&param<i> number, ^#param<i> int

//Set §TestInt2 @TestFloat2 //it will always trunc do 1.9999 will become 1

//code IFs carefully with spaces: if ( §bHologramInitialized == 1 ) { //as this if(§bHologramInitialized==1){ will result in true even if §bHologramInitialized is not set...

//Do NOT unset vars used in timers! it will break them!!! ex.: timerTrapDestroy 1 §TmpTrapDestroyTime GoSub FUNCDestroySelfSafely  //do not UnSet §TmpTrapDestroyTime

//apparently items can only stack if they have the exact same name and/or icon?

// when a timer calls a function, it should end with ACCEPT and not RETURN, or the log may flood with errors!
//  a easy trick to have both is have a TFUNC call the FUNC ex.:
//  GoTo TFUNCdoSomething //Timer Called Function = TFUNC
//  >>TFUNCdoSomething {
//    GoSub FUNCdoSomething
//    ACCEPT
//  }
//  >>FUNCdoSomething { //now, this function can be called from anywhere with GoSub w/o flooding the log with errors!
//    RETURN
//  }

//////////////////////////////// TODO LIST: /////////////////////////
///// <><><> /////PRIORITY:HIGH (low difficulty also)
//TODO contextualizeDocModDesc: These Ancient Devices were found in collapsed ancient bunkers of a long lost and extremelly technologically advanced civilization. They are powered by an external energy source that, for some reason, is less effective or turns off when these devices are nearby strong foes and bosses. //TODO all or most of these ancient tech gets disabled near them
///// <><> /////PRIORITY:MEDIUM
//TODO box icon grey if unidentified. cyan when identified.
//TODO grenade icon and texture dark when inactive, red (current) when activated.
//TODO create a signal repeater item that can be placed in a high signal stregth place and repeats that signal str to 1000to3000 dist from it (depending on player ancientdev skill that will set it's initial quality). code at FUNCcalcSignalStrength
//TODO x8 buttons CircularOptionChoser: place on ground, rotate it to 0 degrees, diff player yaw to it, on activate will highlight the chosen button.
//TODO at 75 ancientskill, player can chose what targeted spell will be cast. at 100, what explosion will happen. using the CircularOptionChoser x8 buttons
///// <> /////PRIORITY:LOW
//TODO teleportArrow stack 10
//TODO grenade+hologram=teleportArrow (insta-kill any foe and teleport the player there)
//TODO teleportArrow+hologram=mindControl (undetectable, and frenzy foe against his friends)
//TODO some cleanup? there are some redundant "function" calls like to FUNCMakeNPCsHostile
//TODO sometimes the avatar will speak "they are dead, all dead" when activating the hologram to change the landscape, but... it could be considered contextualized about the ancient civilization that vanished ;)
//TODO `PLAY -ilp "~£SkyBoxCurrentUVS~.wav"` requires ".wav" as it removes any extension before re-adding the .wav so somename.index1 would become "somename.wav" and not "somename.index1.wav" and was failing. I think the src cpp code should only remove extension if it is ".wav" or other sound format, and not everything after the last dot "."

ON INIT { Set £ScriptDebugLog "On_Init"
	SetName "Ancient Device (unidentified)"
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
	timerInitDefaults -m 1 50 GoSub FUNCinitDefaults
	
	ACCEPT
}

ON IDENTIFY { Set £ScriptDebugLog "On_Identify" //this is called (apparently every frame) when the player hovers the mouse over the item, but requires `SETEQUIP identify_value ...` to be set or this event wont be called.
	if (^amount > 1) ACCEPT //this must not be a stack of items

	//Set £ScriptDebugProblemTmp "identified=~§Identified~;ObjKnow=~^PLAYER_SKILL_OBJECT_KNOWLEDGE~"
	//if ( §Identified > 0 ) ACCEPT //w/o this was flooding the log, why?
	//if ( §IdentifyObjectKnowledgeRequirement == 0 ) ACCEPT //useless?
	if ( §Identified == 0 ) {
		if ( ^PLAYER_SKILL_OBJECT_KNOWLEDGE >= §IdentifyObjectKnowledgeRequirement ) {
			Set §Identified 1
			
			if (§UseCount == 0) { //no uses will still be showing the doc so we know it is still to show the doc. this prevents changing if already showing a nice landscape
				Set £SkyBoxCurrent "Hologram.skybox.index2000.DocIdentified"
				Set £SkyBoxPrevious "~£SkyBoxCurrent~"
				TWEAK SKIN "Hologram.skybox.index2000.DocUnidentified" "~£SkyBoxCurrent~"
			}
			
			GoSub FUNCcfgHologram
			
			Set £ScriptDebugLog "~£ScriptDebugLog~;Identified_Now"
			
			GoSub FUNCshowlocals
		}
	} else {
		if (^#timer2 == 0) starttimer timer2
		if (^#timer2 > 333) { //TOKEN_MOD_CFG
			GoSub FUNCupdateUses
			GoSub FUNCnameUpdate
			starttimer timer2
		}
	}
	ACCEPT
}

ON INVENTORYUSE { Set £ScriptDebugLog "On_InventoryUse"
	if (^amount > 1) ACCEPT //this must not be a stack of items

	++ §OnInventoryUseCount //total activations just for debug
	GoSub FUNCtests //COMMENT_ON_RELEASE
	
	if(^inPlayerInventory == 1) {
		if(and(£AncientDeviceMode == "Hologram" && §bHologramInitialized == 0)) { //signal repeater can only be created inside the inventory
			Set £AncientDeviceMode "_BecomeSignalRepeater_"
			GoSub FUNCmorphUpgrade
			ACCEPT
		} else {
		if(£AncientDeviceMode == "SignalRepeater") { //signal repeater can only revert to hologram inside the inventory
			GoSub FUNCmorphUpgrade
			ACCEPT
		} }
	}
	
	if ( £AncientDeviceMode == "Grenade" ) { // is unstable and cant be turned off
		if ( §AncientDeviceTriggerStep == 1 ) {
			if (^amount > 1) { //cannot activate a stack of items
				SPEAK -p [player_no] NOP
				ACCEPT
			}
			
			GoSub FUNCskillCheckAncientTech
			Set §ActivateChance §FUNCskillCheckAncientTech_chanceSuccess_OUTPUT
			if ( §Quality >= 4 ) {
				Set §ActivateChance 100
			}
			RANDOM §ActivateChance { //not granted to successfully activate it as it is a defective device
				Set §FUNCtrapAttack_TrapTimeSec 5
				
				TWEAK ICON "HologramGrenadeActive[icon]"
				
				TWEAK SKIN "Hologram.tiny.index4000.grenade" "Hologram.tiny.index4000.grenadeActive"
				Set §FUNCblinkGlow_times §FUNCtrapAttack_TrapTimeSec GoSub FUNCblinkGlow
				
				timerTrapVanish     1 §FUNCtrapAttack_TrapTimeSec TWEAK SKIN "Hologram.tiny.index4000.grenade"     "Hologram.tiny.index4000.grenade.Clear"
				timerTrapVanishGlow 1 §FUNCtrapAttack_TrapTimeSec TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow" "Hologram.tiny.index4000.grenadeGlow.Clear"
				
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
			//timerTrapDestroy -m 1 5100 GoSub FUNCDestroySelfSafely
			//timerTrapDestroy -m 1 7000 GoSub FUNCDestroySelfSafely //some effects have infinite time and then will last 2s (from 5000 to 7000)
			Set §AncientDeviceTriggerStep 2
		} else { // after trap being activated will only shock the player and who is in-between too
			GoSub FUNCshockPlayer
			if (^inPlayerInventory == 1) { //but if in inventory, will dissassemble the grenade recovering 2 holograms used to create it
				INVENTORY ADDMULTI "magic\hologram\hologram" 2 //TODOA this isnt working?
				GoSub FUNCDestroySelfSafely
			}
		}
		ACCEPT
	} else {
	if ( £AncientDeviceMode == "LandMine" ) {
		if ( §AncientDeviceTriggerStep == 1 ) {
			Set §AncientDeviceTriggerStep 2 //activate
			//Set §Scale 500 SetScale §Scale //TODOA should be a new model, a thin plate on the ground disguised as rock floor texture may be graph/obj3d/textures/l2_gobel_[stone]_floor01.jpg. Could try a new command like `setplayertweak mesh <newmesh>` but for items!
			//Set §Scale 10 SetScale §Scale //TODOA create a huge landmine (from box there, height 100%, width and length 5000%, blend alpha 0.1 there just to be able to work) on blender hologram overlapping, it will be scaled down here! Or should be a new model, a thin plate on the ground disguised as rock floor texture may be graph/obj3d/textures/l2_gobel_[stone]_floor01.jpg. Could try a new command like `setplayertweak mesh <newmesh>` but for items!
			timerLandMineDetectNearbyNPC -m 0 100 GoSub FUNCLandMine
			Set §FUNCblinkGlow_times 0 GoSub FUNCblinkGlow
		} else { if ( §AncientDeviceTriggerStep == 2 ) {
			timerLandMineDetectNearbyNPC off 
			//Set §Scale 100 SetScale §Scale
			Set §AncientDeviceTriggerStep 1  //stop
			Set §FUNCblinkGlow_times -1 GoSub FUNCblinkGlow
		} }
		GoSub FUNCnameUpdate
		ACCEPT
	} else {
	if ( £AncientDeviceMode == "Teleport" ) {
		if ( §AncientDeviceTriggerStep == 1 ) {
			Set §AncientDeviceTriggerStep 2 // activate
			timerTFUNCteleportToAndKillNPC -m 0 333 GoTo TFUNCteleportToAndKillNPC
			Set §FUNCblinkGlow_times 0 GoSub FUNCblinkGlow
		} else { if ( §AncientDeviceTriggerStep == 2 ) {
			timerTFUNCteleportToAndKillNPC off
			Set §AncientDeviceTriggerStep 1  //stop
			Set §FUNCblinkGlow_times -1 GoSub FUNCblinkGlow
		} }
		GoSub FUNCnameUpdate
		ACCEPT
	} else {
	if ( £AncientDeviceMode == "MindControl" ) {
		if ( §AncientDeviceTriggerStep == 1 ) {
			Set §AncientDeviceTriggerStep 2 //seek ^hover_5000
			timerMindControlDetectHoverNPC -m 0 333 GoSub FUNCMindControl
			Set §FUNCblinkGlow_times 0 GoSub FUNCblinkGlow
		} else { if ( §AncientDeviceTriggerStep == 2 ) {
			timerMindControlDetectHoverNPC off
			Set §AncientDeviceTriggerStep 1  //stop
			Set §FUNCblinkGlow_times -1 GoSub FUNCblinkGlow
		} }
		GoSub FUNCnameUpdate
		ACCEPT
	} } } }
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////  !!! HOLOGRAM ONLY BELOW HERE !!!  /////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	if(£AncientDeviceMode != "Hologram") {
		Set £ScriptDebugLog "~£ScriptDebugLog~;Unrecognized:£AncientDeviceMode='~£AncientDeviceMode~'"
		SPEAK -p [player_no] NOP
		GoSub FUNCshowlocals
		ACCEPT
	}
	
	//////////////// DENY ACTIVATION SECTION ///////////////////////
	
	Set £ScriptDebugLog "~£ScriptDebugLog~;DebugLog:10"
	//Set £ScriptDebugLog "~£ScriptDebugLog~;20"
	if (^inPlayerInventory == 1) {
		if(and(£AncientDeviceMode == "Hologram" && §bHologramInitialized == 0)) {
			Set £AncientDeviceMode "_BecomeSignalRepeater_"
			GoSub FUNCmorphUpgrade
		} else {
		if(£AncientDeviceMode == "SignalRepeater") {
			GoSub FUNCmorphUpgrade //revert to hologram
		} else {
			PLAY "POWER_DOWN"
			GoSub FUNCshowlocals
		}	}
		ACCEPT //can only be activated if deployed
	}
	
	if (§UseBlockedMili > 0) {
		GoSub FUNCMalfunction
		Set £ScriptDebugLog "~£ScriptDebugLog~;Deny_A:Blocked=~§UseBlockedMili~"
		
		++ §UseCount 
		GoSub FUNCupdateUses //an attempt to use while blocked will damage it too, the player must wait the cooldown
		GoSub FUNCnameUpdate
		
		GoSub FUNCshowlocals
		ACCEPT
	} else { if (§UseBlockedMili < 0) {
		// log to help fix inconsistency if it ever happens
		timerBlocked off
		Set £ScriptDebugLog "~£ScriptDebugLog~;Fix_A:Blocked=~§UseBlockedMili~ IsNegative, fixing it to 0"
		//GoSub FUNCshowlocals
		Set §UseBlockedMili 0
	} }
	
	if (§bHologramInitialized == 1) {
		if ( ^#PLAYERDIST > 200 ) { //after scale up. 185 was almost precise but annoying to use. 190 is good but may be annoying if there is things on the ground.
			GoSub FUNCMalfunction
			Set £ScriptDebugLog "~£ScriptDebugLog~;Deny_C:PlayerDist=~^#PLAYERDIST~"
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
		
		//Set §UseMax 5
		//Inc §UseMax ^rnd_110
		//GoSub FUNCcalcAncientTechSkill
		//Inc §UseMax @AncientTechSkill
		//Set §UseRemain §UseMax
		Set §UseHologramDestructionStart §UseMax
		Mul §UseHologramDestructionStart 0.95
		
		SET_SHADOW OFF
		Set £ScriptDebugLog "~£ScriptDebugLog~;30"
		
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
	Set §ChkMalfunction §FUNCskillCheckAncientTech_chanceFailure_OUTPUT
	Div §ChkMalfunction 2
	RANDOM §ChkMalfunction {
		GoSub FUNCshockPlayer
		//dodamage -lu player 3 //-u push, extra dmg with push. this grants some damage if lightning above fails
		INC §UseCount 10  //damage
		INC §UseCount ^rnd_10
		Set £ScriptDebugLog "~£ScriptDebugLog~;60.damagePlayer"
		Set §Malfunction 1
		Inc §UseBlockedMili ^rnd_10000
	}
	
	//it called the attention of some hostile creature, not related to player skill. no need to use any hiding/shadow value as the hologram emits light and will call attention anyway. Only would make sense in some closed room, but rats may find their way there too.
	RANDOM 10 {
		PLAY "sfx_lightning_loop"
		//RANDOM 75 { 
			spawn npc "rat_base\\rat_base" SELF //player
			INC §UseCount 20 //damage
			INC §UseCount ^rnd_20
			Set £ScriptDebugLog "~£ScriptDebugLog~;70.spawn rat"
			Inc §UseBlockedMili ^rnd_15000
			Set §Malfunction 1
		//} else { //TODOA add medium (usesdmg30-60) and hard (usesdmg50-80) creatures? is there a hostile dog (medium) or a weak small spider (hard)?  tweak/create a shrunk small and nerfed spider (hard)! tweak/create a bigger buffed rat (medium)!
			////RANDOM 75 {
				//spawn npc "dog\\dog" player //these dogs are friendly...
				//Inc §UseBlockedMili 30000
				//Set §Malfunction 1
				//INC §UseCount 5 //durability
				//Set £ScriptDebugLog "~£ScriptDebugLog~;70.spawn dog"
				////spawn npc "bat\\bat" player //no, kills rats
			////} else {
				////spawn npc "goblin_base\\goblin_base" player //doesnt attack player
				////spawn npc "goblin_test\\goblin_test" player //doesnt attack the player
				//Inc §UseBlockedMili 60000
				//Set §Malfunction 1
			////}
		//}
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
		RANDOM §FUNCskillCheckAncientTech_chanceSuccess_OUTPUT { //was just 50
			//PLAY "potion_mana"
			Set @IncMana @SignalStrLvl
			Inc @IncMana @FUNCskillCheckAncientTech_addBonus_OUTPUT
			if ( §Identified > 0 ) Mul @IncMana 1.5
			SpecialFX MANA @IncMana
			//TODO play some sound that is not drinking or some visual effect like happens with healing
			SPEAK -p [player_yes] NOP //TODO good?
			Set £ScriptDebugLog "~£ScriptDebugLog~;MANA"
		}
		
		GoSub FUNCskillCheckAncientTech
		RANDOM §FUNCskillCheckAncientTech_chanceSuccess_OUTPUT { //was just 50
			//SpecialFX HEAL @SignalStrLvl
			Set @IncHP @SignalStrLvl
			Inc @IncHP @FUNCskillCheckAncientTech_addBonus_OUTPUT
			if ( §Identified > 0 ) Mul @IncHP 1.5
			SPELLCAST -msf @IncHP HEAL PLAYER
			Set £ScriptDebugLog "~£ScriptDebugLog~;HEAL"
			//Set £ScriptDebugLog "~£ScriptDebugLog~;43"
		}
		
		///////////////// SKYBOXES
		GoSub FUNCChangeSkyBox
	}
	
	Set £ScriptDebugLog "~£ScriptDebugLog~;100;"
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
			Set §FUNCtrapAttack_TrapMode 1 //projectile at player
			Set §FUNCtrapAttack_TrapTimeSec 5
			GoSub FUNCtrapAttack
		}
		RANDOM 25 { //to prevent player using as granted weapon against NPCs
			Set §FUNCtrapAttack_TrapTimeSec 5
			timerTrapVanish 1 §FUNCtrapAttack_TrapTimeSec GoSub FUNChideHologramPartsPermanently
			GoSub FUNCtrapAttack
			//timerDestroy -m   1 5100 GoSub FUNCDestroySelfSafely
		}
		
		if (§FUNCtrapAttack_TrapCanKillMode_OUTPUT == 0) {
			timerGrantDestroySelf 1 §DefaultTrapTimoutSec GoSub FUNCDestroySelfSafely
		}
		
		GoSub FUNCupdateUses
		GoSub FUNCnameUpdate
		
		showvars
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

On Main { Set £ScriptDebugLog "On_Main" //HeartBeat happens once per second apparently (but may be less often?)
	if (^amount > 1) ACCEPT //this must not be a stack of items
	
	//starttimer timer1 //^#timer1 used ON MAIN
	//starttimer timer2 //^#timer2 used ON IDENTIFY
	//starttimer timer3 //^#timer3
	//starttimer timer4 //^#timer4
	//stoptimer timer1
	
	GoSub FUNChoverInfo
	
	if ( £AncientDeviceMode == "Hologram" ) {
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
					//Set £ScriptDebugLog "~£ScriptDebugLog~;OnMain:FadeOut"
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
	} else { if ( £AncientDeviceMode == "Grenade" ) {
		Set £ScriptDebugLog "~£ScriptDebugLog~;~£AncientDeviceMode~" //TODO chk ^dragged to hold cooking?
	} else { if ( £AncientDeviceMode == "LandMine" ) {
		Set £ScriptDebugLog "~£ScriptDebugLog~;~£AncientDeviceMode~" //TODO
	} else { if ( £AncientDeviceMode == "Teleport" ) {
		Set £ScriptDebugLog "~£ScriptDebugLog~;~£AncientDeviceMode~" //TODO
	} else { if ( £AncientDeviceMode == "MindControl" ) {
		Set £ScriptDebugLog "~£ScriptDebugLog~;~£AncientDeviceMode~" //TODO
	} } } } } }
	
	// any item that is going to explode will benefit from this
	Set £ScriptDebugLog "~£ScriptDebugLog~;Chk:TrapCanKillMode"
	if (§FUNCtrapAttack_TrapCanKillMode_OUTPUT == 1) {
		Set £ScriptDebugLog "~£ScriptDebugLog~;TrapCanKillMode"
		//attractor SELF 1 1000
		GoSub FUNCMakeNPCsHostile //this is good as while the item is flying after being thrown, NPCs will wake up near it!
	}
	
	ACCEPT
}

ON CUSTOM { Set £ScriptDebugLog "On_Custom" //this is the receiving end of the transmission
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

ON COMBINE { Set £ScriptDebugLog "On_Combine:~^$PARAM1~"
	UnSet £ScriptDebugCombineFailReason
	GoSub FUNCshowlocals //this is excellent here as any attempt will help showing the log!
	
	// check other (^$PARAM1 is the one that you double click)
	if (^$PARAM1 ISCLASS "Hologram") else ACCEPT //only combine with these
	if (^$PARAM1 !isgroup "DeviceTechBasic") {
		SPEAK -p [player_no] NOP
		Set £ScriptDebugCombineFailReason "Other:Not:Group:DeviceTechBasic:Aka_hologram"
		GoSub FUNCshowlocals
		ACCEPT
	}
	
	if(£AncientDeviceMode == "MindControl") { //sync with last/max combine option
		SPEAK -p [player_no] NOP
		Set £ScriptDebugCombineFailReason "Self:Limit_reached:Combine_options"
		GoSub FUNCshowlocals
		ACCEPT
	}
	
	//check self (the target of the combination request)
	//if (§bHologramInitialized == 0){
		//SPEAK -p [player_no] NOP
		//Set £ScriptDebugCombineFailReason "Self:NotInitialized"
		//GoSub FUNCshowlocals
		//ACCEPT
	//}
	if (^amount > 1) { //this must not be a stack of items
		SPEAK -p [player_no] NOP
		Set £ScriptDebugCombineFailReason "Self:IsStack"
		GoSub FUNCshowlocals
		ACCEPT
	}
	if (§Identified == 0) {
		SPEAK -p [player_not_skilled_enough] NOP
		Set £ScriptDebugCombineFailReason "Self:NotIdentified"
		GoSub FUNCshowlocals
		ACCEPT
	}
	//if (§AncientDeviceTriggerStep > 0) {
		//SPEAK -p [player_no] NOP
		//Set £ScriptDebugCombineFailReason "Self:TODO:HoloTeleportArrow"
		//GoSub FUNCshowlocals
		//ACCEPT
	//}
	
	DESTROY ^$PARAM1
	
	PLAY -s //stops sounds started with -i flag
	
	GoSub FUNCmorphUpgrade
	
	ACCEPT
}

ON InventoryIn { Set £ScriptDebugLog "On_InventoryIn"
	//if (^amount > 1) ACCEPT //this must not be a stack of items
	PLAY -s //stops sounds started with -i flag
	ACCEPT
}

ON InventoryOut { Set £ScriptDebugLog "On_InventoryOut"
	//if (^amount > 1) ACCEPT //this must not be a stack of items
	PLAY -s //stops sounds started with -i flag
	ACCEPT
}

//On Hit { //nothing happens
	//Set £ScriptDebugLog "~£ScriptDebugLog~;OnHit:~^durability~/~^maxdurability~"
	//INC §UseCount 30
	//ACCEPT
//}
//on collide_npc { //nothing happens
	//Set £ScriptDebugLog "~£ScriptDebugLog~;collide_npc"
	//ACCEPT
//}
//on collision_error { //nothing happens
	//Set £ScriptDebugLog "~£ScriptDebugLog~;collision_error"
	//ACCEPT
//}

>>>FUNCaimPlayerCastLightning { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCaimPlayerCastLightning" //this doesnt work well when called from a timer...
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

>>FUNCMalfunction { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCMalfunction"
	Set §SfxRnd ^rnd_3
	if (§SfxRnd == 0) play "SFX_electric"
	if (§SfxRnd == 1) play "sfx_spark"
	if (§SfxRnd == 2) GoSub FUNCshockPlayer
	RETURN
}

>>FUNCChangeSkyBox { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCChangeSkyBox" //these '{}' are not necessary but help on code editors
	RANDOM 50 { // skybox cubemap mode
		if (§SkyMode == 1) { //was UVSphere, so hide it
			Set £ScriptDebugLog "~£ScriptDebugLog~;From UVSphere to CubeMap"
			Set £SkyBoxPreviousUVS "~£SkyBoxCurrentUVS~"
			Set £SkyBoxCurrentUVS "Hologram.skybox.UVSphere.index3000.Clear"
			TWEAK SKIN "~£SkyBoxPreviousUVS~" "~£SkyBoxCurrentUVS~"
		}
		Set £SkyBoxPrevious "~£SkyBoxCurrent~" //store current to know what needs to be replaced
		Set §SkyBoxIndex ^rnd_2 //SED_TOKEN_TOTAL_SKYBOXES_CUBEMAP: to be easy to auto patch, sync with the skyboxes bash script. if rnd_3 will result in 0 1 2
		Set £SkyBoxCurrent "Hologram.skybox.index~§SkyBoxIndex~" //update current
		if (£SkyBoxCurrent == "~£SkyBoxPrevious~") {
			Set £ScriptDebugLog "~£ScriptDebugLog~;SBI=~§SkyBoxIndex~"
			GoTo FUNCChangeSkyBox //LOOP this looks safe but needs at least 2 skyboxes
		}
		TWEAK SKIN "~£SkyBoxPrevious~" "~£SkyBoxCurrent~"
		Set §SkyMode 2
	} else { //skybox UVSphere mode 1
		if (§SkyMode == 2) { //was CubeMap, so hide it
			Set £ScriptDebugLog "~£ScriptDebugLog~;From CubeMap to UVSphere"
			Set £SkyBoxPrevious "~£SkyBoxCurrent~"
			Set £SkyBoxCurrent "Hologram.skybox.index3000.Clear"
			TWEAK SKIN "~£SkyBoxPrevious~" "~£SkyBoxCurrent~"
		}
		Set £SkyBoxPreviousUVS "~£SkyBoxCurrentUVS~" //store current to know what needs to be replaced
		Set §SkyBoxIndex ^rnd_9 //SED_TOKEN_TOTAL_SKYBOXES_UVSPHERE: to be easy to auto patch, sync with the skyboxes bash script. if rnd_3 will result in 0 1 2
		Set £SkyBoxCurrentUVS "Hologram.skybox.UVSphere.index~§SkyBoxIndex~" //update current
		if (£SkyBoxCurrentUVS == "~£SkyBoxPreviousUVS~") {
			Set £ScriptDebugLog "~£ScriptDebugLog~;SBI(UVS)=~§SkyBoxIndex~"
			GoTo FUNCChangeSkyBox //LOOP this looks safe but needs at least 2 skyboxes
		}
		TWEAK SKIN "~£SkyBoxPreviousUVS~" "~£SkyBoxCurrentUVS~"
		Set §SkyMode 1
	}
	//GoSub FUNCshowlocals
	RETURN
}

>>FUNCinitDefaults { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCinitDefaults"
	Set £AncientDeviceMode "Hologram"
	
	TWEAK SKIN "Hologram.skybox.index2000.DocIdentified" "Hologram.skybox.index2000.DocUnidentified"
	TWEAK SKIN "Hologram.tiny.index4000.grenade"         "Hologram.tiny.index4000.grenade.Clear"
	TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow"     "Hologram.tiny.index4000.grenadeGlow.Clear"
	
	if(§iFUNCMakeNPCsHostile_rangeDefault == 0) {
		Set §iFUNCMakeNPCsHostile_rangeDefault 350 //the spell explosion(chaos) range //SED_TOKEN_MOD_CFG
		Set §iFUNCMakeNPCsHostile_range §iFUNCMakeNPCsHostile_rangeDefault
	}
	
	Set §UseMax 5
	Inc §UseMax ^rnd_110
	
	Set £SignalMode "Working"
	Set #SignalModeChangeTime 0
	
	Set §SignalDistBase 1000 //SED_TOKEN_MOD_CFG
	
	Set §SignalDistHalf §SignalDistBase
	Div §SignalDistHalf 2
	
	Set §SignalDistMin §SignalDistBase
	Mul §SignalDistMin 0.25
	
	//Set §IdentifyObjectKnowledgeRequirement 35
	Set §UseCount 0
	Set §DefaultTrapTimoutSec 5 //SED_TOKEN_MOD_CFG
	
	Collision ON //nothing happens when thrown?
	Damager -eu 3 //doesnt damage NPCs when thrown?
	
	Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCinitDefaults"
	GoSub FUNCshowlocals
	
	RETURN
}

>>FUNCMakeNPCsHostile { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCMakeNPCsHostile" //params: §iFUNCMakeNPCsHostile_range
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

>>FUNCshockPlayer { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCshockPlayer"
	if (^inPlayerInventory == 1) { 
		//TODO is there some way to auto drop the item? if so, this would be unnecessary...
		PLAY "sfx_lightning_loop"
		dodamage -l player 1
	} else {
		ForceAngle ^degreesyto_PLAYER
		SPELLCAST -smf @SignalStrLvl LIGHTNING_STRIKE PLAYER //TODO this causes damage? or is just the visual effect?
		Random 25 {
			SPELLCAST -fmsd 250 @SignalStrLvl PARALYSE PLAYER
		}
		
		//Set §iFUNCMakeNPCsHostile_range 350  //reason: they know it is dangerous to them too.
		GoSub FUNCMakeNPCsHostile
	}
	
	RETURN
}

>>FUNCbreakDeviceDelayed { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCbreakDeviceDelayed"
	SetGroup "DeviceTechBroken"
	GoSub FUNCshockPlayer
	//if (^inPlayerInventory == 1) {
		////TODOA find a way to just auto drop the item to work the more challenging code below
		//DoDamage -lu PLAYER 3
		//GoSub FUNCDestroySelfSafely
	//} else {
		Set £FUNCnameUpdate_NameBase "Broken Hologram Device" 
		GoSub FUNCupdateUses
		GoSub FUNCnameUpdate
		
		TWEAK ICON "HologramBroken[icon]"
		
		SetInteractivity NONE
		SpecialFX FIERY
		SPEAK -p [player_picklock_failed] NOP //TODO expectedly just a sound about failure and not about picklocking..
		//SPEAK -p [player_wrong] NOP //TODO expectedly just a sound about failure
		Set §TmpBreakDestroyMilis §DefaultTrapTimoutSec
		Mul §TmpBreakDestroyMilis 1000
		timerTrapBreakDestroy -m 1 §TmpBreakDestroyMilis GoSub FUNCparalyseIfPlayerNearby //the trap tried to capture the player xD //TODOA not working?
		Inc §TmpBreakDestroyMilis ^rnd_15000
		timerTrapBreakDestroy -m 1 §TmpBreakDestroyMilis GoSub FUNCDestroySelfSafely //to give time to let the player examine it a bit
	//}
	GoSub FUNCshowlocals
	RETURN
}

>>FUNCupdateUses { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCupdateUses"
	Set §UseRemain §UseMax
	Dec §UseRemain §UseCount
	//DO NOT CALL: GoSub FUNCnameUpdate
	if (§UseCount >= §UseHologramDestructionStart) Set §UseBlockedMili 0 //quickly lets the player finish/destroy it
	RETURN
}

>>FUNCnameUpdate { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCnameUpdate"
	//OUTPUT: £FUNCnameUpdate_NameFinal_OUTPUT
	if ( §Identified == 0 ) ACCEPT //the player is still not sure about what is going on
	
	Set £FUNCnameUpdate_NameFinal_OUTPUT "~£FUNCnameUpdate_NameBase~."
	
	//if ( §bHologramInitialized == 1 ) {
		GoSub FUNCcalcAncientTechSkill
		
		GoSub FUNCcalcSignalStrength
		
		// condition from 0.00 to 1.00
		//DO NOT CALL BECOMES ENDLESS RECURSIVE LOOP: GoSub FUNCupdateUses
		//Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCnameUpdate"
		Set @ItemCondition §UseRemain
		//Set £ScriptDebugLog "~£ScriptDebugLog~;~@ItemCondition~=~§UseRemain~"
		Div @ItemCondition §UseMax
		//Set £ScriptDebugLog "~£ScriptDebugLog~;/~§UseMax~=~@ItemCondition~"
		//TODO try again these 'else { if' below
		//if      ( @ItemCondition >= 0.80 ) { Set £ItemConditionDesc "excellent" }
		//else { if ( @ItemCondition >= 0.60 ) { Set £ItemConditionDesc "good"      }
		//else { if ( @ItemCondition >= 0.40 ) { Set £ItemConditionDesc "average"   }
		//else { if ( @ItemCondition >= 0.20 ) { Set £ItemConditionDesc "bad"       }
		//else {                               Set £ItemConditionDesc "critical"    } } } }
		Set @ItemConditionSureTmp @ItemCondition
		Mul @ItemConditionSureTmp 10 //0-10
		Div @ItemConditionSureTmp  2 //0-5
		Set §ItemConditionSure @ItemConditionSureTmp //trunc
		if ( §ItemConditionSure == 5 ) Set £ItemConditionDesc "perfect"
		if ( §ItemConditionSure == 4 ) Set £ItemConditionDesc "excellent"
		if ( §ItemConditionSure == 3 ) Set £ItemConditionDesc "good"
		if ( §ItemConditionSure == 2 ) Set £ItemConditionDesc "average"
		if ( §ItemConditionSure == 1 ) Set £ItemConditionDesc "bad"
		if ( §ItemConditionSure == 0 ) Set £ItemConditionDesc "critical"
		
		Set §SignalStrSure §SignalStrengthTrunc
		Div §SignalStrSure 33
		Inc §SignalStrSure 1
		if(§SignalStrengthTrunc == 0) Set §SignalStrSure 0
		if(§SignalStrengthTrunc >= 95) Set §SignalStrSure 4
		if(§SignalStrSure == 0) Set £SignalStrInfo "none"
		if(§SignalStrSure == 1) Set £SignalStrInfo "bad"
		if(§SignalStrSure == 2) Set £SignalStrInfo "good"
		if(§SignalStrSure == 3) Set £SignalStrInfo "strong"
		if(§SignalStrSure == 4) Set £SignalStrInfo "excellent"
		
		// perc
		Set @ItemConditionTmp @ItemCondition
		Mul @ItemConditionTmp 100
		Set £ScriptDebugLog "~£ScriptDebugLog~;*100=~@ItemCondition~"
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
		if(§Quality >= 5) Set £ItemQuality "pristine+"
		if(§Quality == 4) Set £ItemQuality "superior+"
		if(§Quality == 3) Set £ItemQuality "decent"
		if(§Quality == 2) Set £ItemQuality "mediocre"
		if(§Quality == 1) Set £ItemQuality "inferior"
		if(§Quality == 0) Set £ItemQuality "dreadful"
		
		if(§AncientDeviceTriggerStep == 2){
			Set £FUNCnameUpdate_NameFinal_OUTPUT "~£FUNCnameUpdate_NameFinal_OUTPUT~ (ACTIVE)."
		}
		
		if(@AncientTechSkill >= 50) { //detailed info for nerds ;) 
			Set £SignalStrInfo "~£SignalStrInfo~(~§SignalStrengthTrunc~% for ~§SignalModeChangeDelay~s)" //it is none or working for N seconds
			Set §hours   ^gamehours
			Mod §hours 24
			Set §minutes ^gameminutes
			Mod §minutes 60
			Set §seconds ^gameseconds
			Mod §seconds 60
			// as day/night is based in quest stages and (I believe) they do not update the global time g_gameTime value, these would be incoherent to show as GameTime GT:^arxdays ^arxtime_hours ^arxtime_minutes ^arxtime_seconds. So will show only real time.
			Set £ItemConditionDesc "~£ItemConditionDesc~(~§ItemConditionPercent~% ~§UseCount~/~§UseMax~ Remaining ~§UseRemain~) RT:~^gamedays~day(s) ~%02d,§hours~:~%02d,§minutes~:~%02d,§seconds~" 
			//Set £ItemConditionDesc "~£ItemConditionDesc~(~§ItemConditionPercent~% ~§UseCount~/~§UseMax~ Remaining ~§UseRemain~) RT:~^gamedays~day(s) ~%02d,^gamehours~:~%02d,^gameminutes~:~%02d,^gameseconds~" 
			Set £ItemQuality "~£ItemQuality~(~§UseMax~)"
		}
		if(@AncientTechSkill >= 20) Set £FUNCnameUpdate_NameFinal_OUTPUT "~£FUNCnameUpdate_NameFinal_OUTPUT~ Signal:~£SignalStrInfo~." //useful to position yourself
		if(@AncientTechSkill >= 30) Set £FUNCnameUpdate_NameFinal_OUTPUT "~£FUNCnameUpdate_NameFinal_OUTPUT~ Quality:~£ItemQuality~." //useful to chose wich one to keep
		if(@AncientTechSkill >= 40) Set £FUNCnameUpdate_NameFinal_OUTPUT "~£FUNCnameUpdate_NameFinal_OUTPUT~ Condition:~£ItemConditionDesc~." //useful to hold your hand avoiding destroy it
		//if(@AncientTechSkill >= 50) Set £FUNCnameUpdate_NameFinal_OUTPUT "~£FUNCnameUpdate_NameFinal_OUTPUT~ Signal:~§SignalStrengthTrunc~, ~§ItemConditionPercent~% ~§UseCount~/~§UseMax~ Remaining ~§UseRemain~." //detailed condition for nerds ;) 
	//} else {
		//Set £FUNCnameUpdate_NameFinal_OUTPUT "~£FUNCnameUpdate_NameFinal_OUTPUT~ (Not initialized)."
	//}
	
	//SetName "~£FUNCnameUpdate_NameBase~. Quality:~£ItemQuality~, Condition:~£ItemConditionDesc~(~§ItemConditionPercent~%), Uses:Count=~§UseCount,Remain=~§UseRemain~,Max=~§UseMax~"
	SetName "~£FUNCnameUpdate_NameFinal_OUTPUT~"
	//Set @TestFloat 0.1
	//Set @TestFloat2 0.999999
	//Set §TestInt2 @TestFloat2
	//Set @TestFloat3 0.3
	//Mul @TestFloat3 0.5 //0.15
	//Set @TestFloat4 0.8
	//Div @TestFloat4 2 //0.4
	//Set @TestFloat5 0.3
	//Mul @TestFloat5 100 //30
	//Set §TestInt5 @TestFloat5
	GoSub FUNCshowlocals
}

>>FUNCcalcAncientTechSkill { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCcalcAncientTechSkill"
	Set @AncientTechSkill ^PLAYER_SKILL_MECANISM
	Inc @AncientTechSkill ^PLAYER_SKILL_OBJECT_KNOWLEDGE
	Inc @AncientTechSkill ^PLAYER_SKILL_INTUITION
	Div @AncientTechSkill 3 //the total skills used for it
	RETURN
}

>>FUNCskillCheckAncientTech { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCskillCheckAncientTech" //checks the technical skill like in a percent base. 
	//INPUTS:
	//OUTPUTS:
	//  §FUNCskillCheckAncientTech_chanceSuccess_OUTPUT
	//  §FUNCskillCheckAncientTech_chanceFailure_OUTPUT
	//  §FUNCskillCheckAncientTech_bonus_OUTPUT
	
	GoSub FUNCcalcAncientTechSkill
	
	Set §FUNCskillCheckAncientTech_chanceSuccess_OUTPUT @AncientTechSkill
	if (§FUNCskillCheckAncientTech_chanceSuccess_OUTPUT <  5) Set §FUNCskillCheckAncientTech_chanceSuccess_OUTPUT  5 //minimal success chance
	if (§FUNCskillCheckAncientTech_chanceSuccess_OUTPUT > 95) Set §FUNCskillCheckAncientTech_chanceSuccess_OUTPUT 95 //minimal fail chance
	
	Set §FUNCskillCheckAncientTech_chanceFailure_OUTPUT 100
	Dec §FUNCskillCheckAncientTech_chanceFailure_OUTPUT §FUNCskillCheckAncientTech_chanceSuccess_OUTPUT
	
	Set @FUNCskillCheckAncientTech_addBonus_OUTPUT @AncientTechSkill
	Set @TmpRandomBonus 10
	Inc @TmpRandomBonus ^rnd_10
	Div @FUNCskillCheckAncientTech_addBonus_OUTPUT @TmpRandomBonus
	
	// unset after log if any
	GoSub FUNCshowlocals
	Unset @TmpRandomBonus
	
	RETURN
}

>>FUNCtrapAttack { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCtrapAttack" 
	//INPUT: §FUNCtrapAttack_TrapMode 0=explosion 1=projectile/targetPlayer
	//INPUT: §FUNCtrapAttack_TrapTimeSec in seconds (not milis)
	SendEvent GLOW SELF "" //TODO this also makes it glow or just calls the ON GLOW event that needs to be implemented here?
	
	SetGroup "DeviceTechExplosionActivated"
	SetGroup "Explosive"
	
	PLAY "TRAP"
	PLAY "POWER"
	
	Set §FUNCtrapAttack_TrapCanKillMode_OUTPUT 1 //this calls FUNCMakeNPCsHostile at main() heartbeat
	
	//attractor SELF 1 1000 //makes it a bit difficult for the player to run away
	
	GoSub FUNCMakeNPCsHostile
	
	GoSub FUNCcalcSignalStrength
	
	// random trap
	Set §FUNCtrapAttack_TrapTimeSec §DefaultTrapTimoutSec //must be seconds (not milis) to easify things below like timer count and text
	timerTrapTime     §FUNCtrapAttack_TrapTimeSec 1 Dec §FUNCtrapAttack_TrapTimeSec 1
	timerTrapTimeName §FUNCtrapAttack_TrapTimeSec 1 SetName "Holo-Grenade Activated (~§FUNCtrapAttack_TrapTimeSec~s)"
	//timerTrapAttack  -m 0  100 GoSub FUNCMakeNPCsHostile //doesnt work
	
	Set §TrapEffectTime 0
	if (§FUNCtrapAttack_TrapMode == 0) { //explosion around self
		Set §TmpTrapKind ^rnd_5
		if (§TmpTrapKind == 0) timerTrapAttack 1 §FUNCtrapAttack_TrapTimeSec SPELLCAST -smf @SignalStrLvl explosion  SELF
		if (§TmpTrapKind == 1) timerTrapAttack 1 §FUNCtrapAttack_TrapTimeSec SPELLCAST -smf @SignalStrLvl fire_field SELF
		if (§TmpTrapKind == 2) timerTrapAttack 1 §FUNCtrapAttack_TrapTimeSec SPELLCAST -smf @SignalStrLvl harm       SELF
		if (§TmpTrapKind == 3) timerTrapAttack 1 §FUNCtrapAttack_TrapTimeSec SPELLCAST -smf @SignalStrLvl ice_field  SELF
		if (§TmpTrapKind == 4) timerTrapAttack 1 §FUNCtrapAttack_TrapTimeSec SPELLCAST -smf @SignalStrLvl life_drain SELF
		//this cause no damage? //if (§TmpTrapKind == 5) timerTrapAttack  -m 1 5000 SPELLCAST -smf @SignalStrLvl mass_incinerate SELF
		Unset §TmpTrapKind
		Set §TrapEffectTime 2 //some effects have infinite time and then will last 2s (from 5000 to 7000) like explosion default time, as I being infinite would then last 0s as soon this entity is destroyed right?
	}
	if (§FUNCtrapAttack_TrapMode == 1) { //projectile at player
		timerTrapAttack 1 §FUNCtrapAttack_TrapTimeSec GoSub FUNCchkAndAttackProjectile
	}  
	
	timerTrapVanish       1 §FUNCtrapAttack_TrapTimeSec TWEAK SKIN "Hologram.tiny.index4000.grenade"       "alpha"
	timerTrapVanishActive 1 §FUNCtrapAttack_TrapTimeSec TWEAK SKIN "Hologram.tiny.index4000.grenadeActive" "alpha"
	timerTrapVanishGlow   1 §FUNCtrapAttack_TrapTimeSec TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow"   "alpha"
	
	// trap effect time
	Set §TmpTrapDestroyTime §FUNCtrapAttack_TrapTimeSec
	Inc §TmpTrapDestroyTime §TrapEffectTime
	timerTrapDestroy 1 §TmpTrapDestroyTime GoSub FUNCDestroySelfSafely 
	
	GoSub FUNCshowlocals
	// unset after log
	//Unset §TmpTrapDestroyTime //DO NOT UNSET OR IT WILL BREAK THE TIMER!!!
	
	//restore defaults for next call "w/o params"
	Set §FUNCtrapAttack_TrapMode 0
	RETURN
}

>>FUNCchkAndAttackProjectile { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCchkAndAttackProjectile" 
	if ( ^#PLAYERDIST > §iFUNCMakeNPCsHostile_rangeDefault ) ACCEPT //the objective is to protect NPCs that did not get alerted by the player aggressive action
	Set §TmpTrapKind ^rnd_6
	if (§TmpTrapKind == 0) SPELLCAST -smf @SignalStrLvl FIREBALL              PLAYER
	if (§TmpTrapKind == 1) SPELLCAST -smf @SignalStrLvl FIRE_PROJECTILE       PLAYER
	if (§TmpTrapKind == 2) SPELLCAST -smf @SignalStrLvl ICE_PROJECTILE        PLAYER
	if (§TmpTrapKind == 3) SPELLCAST -smf @SignalStrLvl MAGIC_MISSILE         PLAYER
	if (§TmpTrapKind == 4) SPELLCAST -smf @SignalStrLvl MASS_LIGHTNING_STRIKE PLAYER
	if (§TmpTrapKind == 5) SPELLCAST -smf @SignalStrLvl POISON_PROJECTILE     PLAYER
	//TODO semi-paralize, every 1-3s shocks NPC and slowly pull it back to grenade or mine location thru interpolate and paralize it there for 0-1s
	//if (§TrapKind == 0) SPELLCAST -smf @SignalStrLvl LIGHTNING_STRIKE PLAYER //too weak
	Unset §TmpTrapKind
	RETURN
}

>>FUNChideHologramPartsPermanently { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNChideHologramPartsPermanently" 
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

>>FUNCparalyseIfPlayerNearby { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCparalyseIfPlayerNearby"  //TODOA is this working?
	if ( ^#PLAYERDIST < 500 ) {
		Set §TmpParalyseMilis 3000
		Inc §TmpParalyseMilis ^rnd_6000
		SPELLCAST -fmsd §TmpParalyseMilis @SignalStrLvl PARALYSE PLAYER
	}
	RETURN
}

>>FUNCDestroySelfSafely { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCDestroySelfSafely" 
	PLAY -s //stops sounds started with -i flag
	DESTROY SELF
	RETURN
}

>>FUNCcalcSignalStrength { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCcalcSignalStrength"  //this is meant to be independent from magic skills so instead of ^spelllevel to cast spells, use @SignalStrLvl
	// reset to recalc
	Set @RepeaterSignalStrength 0 //0.0 to 100.0
	Set @SignalStrength 0         //0.0 to 100.0
	Set §SignalStrengthTrunc 0   //  0 to 100
	Set @SignalStrLvl 0           //0.0 to 10.0
	
	// no signal for some short realtime. This means the global ancient energy transmitter is failing or getting interference.
	Set §DEBUGgameseconds ^gameseconds
	Set §SignalModeChangeDelay #SignalModeChangeTime
	Dec §SignalModeChangeDelay ^gameseconds
	if(£SignalMode == "Working"){
		if(^gameseconds > #SignalModeChangeTime){
			Set £SignalMode "None" //configures the no signal delay below
			Set #SignalModeChangeTime  ^gameseconds
			Inc #SignalModeChangeTime  ^rnd_300 //up to
			RETURN
		}
	} else { if(£SignalMode == "None"){
		if(^gameseconds > #SignalModeChangeTime){
			Set £SignalMode "Working" //configures the working signal delay below
			Set #SignalModeChangeTime  ^gameseconds
			Inc #SignalModeChangeTime  900 //from
			Inc #SignalModeChangeTime  ^rnd_900 //up to
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
			////todoa £SignalRepeaterID
			//Set @RepeaterSignalDist ^dist_~£RepeaterStrongestDeployedID~ //nearest (but could be all within 3000 range and receive the strongest signal)
		//} }
		Set @RepeaterSignalDist ^dist_~£RepeaterStrongestDeployedID~ //nearest (but could be all within 3000 range and receive the strongest signal)
	} else {
		Set @AncientGlobalTransmitterSignalDist ^dist_{0,0,0} //could be anywhere, if  I create a bunker map with it, then it will have a proper location 
	}
	
	// signal strength based on deterministic but difficultly previsible cubic regions
	Set §NoSignalRegion ^locationx_player
	Inc §NoSignalRegion ^locationz_player
	Mod §NoSignalRegion §SignalDistBase
	if(§NoSignalRegion >= §SignalDistMin) {
		Set @SignalStrength ^locationx_~^me~
		Inc @SignalStrength ^locationy_~^me~
		if (^inPlayerInventory == 1) Inc @SignalStrength 90 //if at player inventory, items are 90 dist from ground (based on tests above). Could just use ^locationy_player tho.
		Inc @SignalStrength ^locationz_~^me~
		
		if(§SignalRepeater == 0) {
			// less cubic/less previsible (this alone would be like spheric regions btw)
			Inc @SignalStrength @AncientGlobalTransmitterSignalDist
		}
	}
	
	// stronger signal wins
	if(@RepeaterSignalStrength > @SignalStrength) Set @SignalStrength @RepeaterSignalStrength
	
	if(§SignalRepeater == 0) {
		// see comments about cubic and spheric regions above
		// means from 0 to §SignalDistHalf then from §SignalDistHalf to 0 as the player moves around. Ex.: if max dist is 1000, it will be from 0 to 500 and from 500 to 0, then from 0 to 500 again...
		Mod @SignalStrength §SignalDistBase //remainder
		if (@SignalStrength > §SignalDistHalf) {
			Dec @SignalStrength §SignalDistHalf
			Mul @SignalStrength -1
			Inc @SignalStrength §SignalDistHalf
		}
	} else {
		Set @RepeaterSignalHere @SignalStrength //100% reference
		// percent from max distance
		Set @RepeaterSignalDistPerc @RepeaterSignalDist 
		Div @RepeaterSignalDistPerc 3000 //perc from 0.0to1.0
		// if near, the value will be small so the final signal strength will be high
		Set @SignalStrength 1.0
		Dec @SignalStrength @RepeaterSignalDistPerc
		// from 0.0 to 100.0
		Mul @SignalStrength 100
	}
	
	// percent and signal level
	Div @SignalStrength §SignalDistHalf //converts to a percent from 0.0 to 1.0
	Mul @SignalStrength 100 //0.0 to 100.0
	Set §SignalStrengthTrunc @SignalStrength //trunc 0 to 100
	// to use instead of ^spelllevel
	Set @SignalStrLvl @SignalStrength
	Div @SignalStrLvl 10 //0-10 like spell cast level would be
	
	RETURN
}

//////////////////////////// TESTS /////////////////////////////
>>FUNChoverInfo { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNChoverInfo" 
	Set £ScriptDebugLog "~£ScriptDebugLog~;HOVER='~^hover_5000~'"
	GoSub FUNCshowlocals
	Set £HoverEnt "~^hover_5000~"
	if(£HoverEnt != "none") {
		Set £HoverClass ^class_~^hover_5000~
		Set §HoverLifeTmp ^life_~^hover_5000~
		Set @HoverLifeTmp2 ^life_~£HoverEnt~
		Set @testDegreesXh   ^degreesx_~^hover_5000~
		Set @testDegreesYh   ^degreesy_~^hover_5000~
		Set @testDegreesZh   ^degreesz_~^hover_5000~ //some potions are inclined a bit
		Set @testDegreesYtoh ^degreesyto_~^hover_5000~
    //just crashes... if(§HoverLifeTmp > 0) USEMESH -e "~£HoverEnt~" "movable\\npc_gore\\npc_gore" //todoRM 
    //nothing happens if(§HoverLifeTmp > 0) SPAWN ITEM "movable\\npc_gore\\npc_gore" "~£HoverEnt~" //todoRM
		GoSub FUNCshowlocals
	}
	RETURN
}

>>FUNCtestPrintfFormats { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCtestPrintfFormats" 
	Set @testFloat 78.12345
	Set §testInt 513
	Set £testString "foo"
	//some simple printf formats
	Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;float:~%020.6f,@testFloat~"
	Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;hexa:0x~%08X,§testInt~"
	Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;decimalAlignRight:~%8d,§testInt~"
	Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;string='~%10s,£testString~'"
	++ §testsPerformed
	RETURN
}
>>FUNCtestLogicOperators { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCtestLogicOperators" 
	Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;FUNCtests"
	Set @testFloat 1.5
	Set §testInt 7
	Set £testString "foo"
	
	// OK means can appear on the £ScriptDebug________________Tests. WRONG means it should not have appeared.
	
	if(and(@testFloat == 1.5 && §testInt == 7 && £testString == "foo")){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;A1:OK"
	}
	if(and(@testFloat == 1.5 && §testInt == 7 && £testString == "foo1")){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;A2:WRONG"
	}
	if(and(@testFloat == 1.5 && §testInt == 8 && £testString == "foo")){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;A3:WRONG"
	}
	if(and(@testFloat == 1.6 && §testInt == 7 && £testString == "foo")){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;A4:WRONG"
	}
	// test without block delimiters { }
	if(and(@testFloat == 1.5 && §testInt == 7 && £testString == "foo"))
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;A11:OK"
	if(and(@testFloat == 1.5 && §testInt == 7 && £testString == "foo1"))
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;A12:WRONG"
	if(and(@testFloat == 1.5 && §testInt == 8 && £testString == "foo"))
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;A13:WRONG"
	if(and(@testFloat == 1.6 && §testInt == 7 && £testString == "foo"))
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;A14:WRONG"
	
	// not(!)
	if(!and(@testFloat == 1.5 && §testInt == 7 && £testString == "foo"))
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;b11:wrong"
	if(!and(@testFloat == 1.5 && §testInt == 7 && £testString == "foo1"))
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;b12:ok"
	if(!and(@testFloat == 1.5 && §testInt == 8 && £testString == "foo"))
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;b13:ok"
	if(!and(@testFloat == 1.6 && §testInt == 7 && £testString == "foo"))
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;b14:ok"
	
	// or !or
	if(or(@testFloat == 1.5 , §testInt == 7 , £testString == "foo")){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;c1:OK"
	}
	if(!or(@testFloat == 1.5 || §testInt != 7 || £testString == "foo1")){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;c2:WRONG"
	}
	if(!or(@testFloat != 1.5 || §testInt != 8 || £testString == "foo")){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;c3:WRONG"
	}
	if(or(@testFloat == 1.6 || §testInt != 7 || £testString == "foo")){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;c4:ok"
	}
	
	// nesting and multiline
	if(or(      @testFloat == 1.6 ||       §testInt != 7    ||       and(        £testString == "foo"         &&         §testInt != 7       ) ||      !or(@testFloat != 1.5 || §testInt == 8 || £testString == "foo") ||      !and(@testFloat == 1.5 , §testInt == 8 , £testString == "foo")     )  ){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;d1:ok"
	}
	if(or(      @testFloat == 1.6 ||       §testInt != 7    ||       and(        £testString == "foo"         &&         §testInt != 7       ) ||      !or(@testFloat != 1.5 || §testInt == 8 || £testString == "foo") ||      !and(@testFloat == 1.5 , §testInt != 8 , £testString == "foo")     )  ){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;d2:wrong"
	}
	
	//Set @test1 1.0
	//Set @test2 11.0
	//Set £name "foo"
	//if(and(@test1 == 1.0 && or(£name != "dummy" || @test2 > 10.0)){
		//Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;FUNCtests:A"
	//}
	//if(and(@test1 == 2.0 && or(£name != "dummy" || @test2 > 10.0)){ //TODO this is failing
		//Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;FUNCtests:B"
	//}
	//if(and(@test1 == 1.0 && or(£name == "dummy" || @test2 > 10.0)){
		//Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;FUNCtests:C"
	//}
	//if(or(@test1 == 2.0 || £name == "dummy" || @test2 <= 10.0)) Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;FUNCtests:D"
	//if(or(@test1 == 2.0 || £name == "dummy" || @test2 >= 10.0)) Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;FUNCtests:E"
	
	++ §testsPerformed
	RETURN
}
>>FUNCdistAbsPos { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCdistAbsPos" 
	// distance to absolute locations
	Set §testDistAbsolute ^dist_{0,0,0}
	Set @testDistAbsolute2 ^dist_{1000.123,2000.56,3000}
	Set §testAbsX 5000
	Set @testAbsY 500.45
	Set @testAbsZ 500.45
	Set @testDistAbsolute3  ^dist_{~§testAbsX~,~@testAbsY~,~§testAbsZ~}
	Set §testDistAbsolute4  ^dist_{~^locationx_player~,~^locationy_player~,~^locationz_player~}
	Set @testDistAbsolute4b ^dist_{~^locationx_player~,~^locationy_player~,~^locationz_player~}
	//Set @testDistAbsolute4b ^dist_"{~^locationx_player~,~^locationy_player~,~^locationz_player~}" //rm tests the warn msg with line and column about unexpected "
	++ §testsPerformed
	RETURN
}
>>FUNCtestElseIf { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCtestElseIf" 
	++ §test
	if ( §test == 1 ) {
		Set £work "~£work~;~§test~:ok1"
	} else { if ( §test == 2 ) {
		Set £work "~£work~;~§test~:ok2"
	} else { if ( §test == 3 ) {
		Set £work "~£work~;~§test~:ok3"
	} else { 
		Set £work "~£work~;~§test~:okElse"
	}  }  }
	GoSub FUNCshowlocals
	RETURN
}
>>FUNCtests { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCtests" 
	// other tmp tests
	
	Set @testDegreesXp ^degreesx_player
	Set @testDegreesYp ^degreesy_player
	Set @testDegreesZp ^degreesz_player //usually always 0 to player I think
	Set @testDegreesYtoPlayer ^degreesyto_player
	Set @testDegreesYtoPlayer2 ^degreesto_player
	
	Set @testDegreesXme ^degreesx_~^me~
	Set @testDegreesYme ^degreesy_~^me~
	Set @testDegreesZme ^degreesz_~^me~ //some potions are inclined a bit

	Set @testDegreesYme2 ^degrees
	Set @testDegreesYme3 ^degrees_~^me~
	Set @testDegreesYp2  ^degrees_player
	
	if(^degreesx_player == 301) { //maximum Degrees player can look up is that
		//TODO put this on CircularOptionChoser
		++ §FUNCshowlocals_enabled
		if(§FUNCshowlocals_enabled > 1) Set §FUNCshowlocals_enabled 0
		GoSub FUNCshowlocals
	}
	
	if(^degreesx_player == 74.9) { //minimum Degrees player can look down is that
		//TODO put this on CircularOptionChoser
		
		//fail teleport -pi //tele the player to its starting spawn point
		//Set @TstDistToSomeFixedPoint ^RealDist_PRESSUREPAD_GOB_0022 //this gives a wrong(?) huge value..
		//Set @TstDistToSomeFixedPoint ^Dist_PRESSUREPAD_GOB_0022 //this doesnt seem to work, the value wont change..
		//Set §TstDistToSomeFixedPoint @TstDistToSomeFixedPoint
		
		Set £ScriptDebug________________Tests "FUNCtests"
		GoSub FUNCdistAbsPos
		GoSub FUNCtestPrintfFormats
		GoSub FUNCtestLogicOperators
		GoSub FUNCtestElseIf
	}
	 
	GoSub FUNCshowlocals
	RETURN
}

>>FUNCLandMine { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCLandMine" 
	//TODO new command attractor to NPCs range 150?
	Set £FUNCLandMine_OnTopEnt "~^$objontop~"
	Set §OnTopLife ^life_~£FUNCLandMine_OnTopEnt~
	if(and(£FUNCLandMine_OnTopEnt != "none" && §OnTopLife > 0)) {
		//Set §Scale 100
		timerShrink1 -m 0 100 Dec §Scale 1
		timerShrink2 -m 0 100 SetScale §Scale
		
		GoSub FUNCtrapAttack
		
		timerLandMineDetectNearbyNPC off
		
		GoSub FUNCshowlocals
	}
	RETURN
}
>>TFUNCteleportToAndKillNPC {
	GoSub FUNCteleportToAndKillNPC
	ACCEPT
}
>>FUNCteleportToAndKillNPC { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCteleportToAndKillNPC" 
	//TODO may be can use cpp ARX_NPC_TryToCutSomething() to explode the body
	//TODO try also modify GetFirstInterAtPos(..., float & fMaxPos)  fMaxPos=10000, but needs to disable player interactivity to not work as telekinesis or any other kind of activation...
	Set £FUNCteleportToAndKillNPC_HoverEnt "~^hover_5000~"
	Set §FUNCteleportToAndKillNPC_HoverLife ^life_~£FUNCteleportToAndKillNPC_HoverEnt~
	if(and(£FUNCteleportToAndKillNPC_HoverEnt != "none" && §FUNCteleportToAndKillNPC_HoverLife > 0)) {
		//timerTeleportSelf    -m 0 50 teleport "~£FUNCteleportToAndKillNPC_HoverEnt~"
		Set §TeleDistEndTele 100
		//DropItem player "~^me~"
		timerTFUNCteleportToAndKillNPC_flyMe -m 0 50 GoTo TFUNCteleportToAndKillNPC_flyMe
		//timerTeleportKillNPC -m 0 50 SENDEVENT -nr CRUSH_BOX 50 "" //SENDEVENT -finr CRUSH_BOX 50 ""
		//timerTeleportPlayer    -m 1 100 teleport -p "~£FUNCteleportToAndKillNPC_HoverEnt~"
		//timerTFUNCteleportToAndKillNPC_flyPlayer -m 0 50 GoTo TFUNCteleportToAndKillNPC_flyPlayer
		//TODO explode npc in gore dismembering
    //timerTeleportDropNPCItems     -m 1 2000 DropItem "~£FUNCteleportToAndKillNPC_HoverEnt~" all
    ////nothing happens: timerTeleportKillNPC -m 1 300 SPAWN ITEM "movable\\npc_gore\\npc_gore" "~£FUNCteleportToAndKillNPC_HoverEnt~"
    //timerTeleportDamageAndKillNPC -m 1 2100 DoDamage -fmlcgewsao "~£FUNCteleportToAndKillNPC_HoverEnt~" 99999
    //timerTeleportDestroyNPC       -m 1 2200 Destroy "~£FUNCteleportToAndKillNPC_HoverEnt~" //must be last thing or the ent reference will fail for the other commands 
		//timerBreakDevice              -m 1 2300 GoSub FUNCbreakDeviceDelayed //only after everything else have completed! this takes a long time to finish breaking it
		timerTFUNCteleportToAndKillNPC off
		GoSub FUNCshowlocals
	}
	RETURN
}
>>TFUNCteleportToAndKillNPC_flyMe {
	GoSub FUNCteleportToAndKillNPC_flyMe
	ACCEPT
}
>>FUNCteleportToAndKillNPC_flyMe {
	if(^life_~£FUNCteleportToAndKillNPC_HoverEnt~ > 0) {
		//the idea is to be unsafe positioning over npc location as it will be destroyed
		interpolate "~^me~" "~£FUNCteleportToAndKillNPC_HoverEnt~" 0.5 //0.9 the less the smoother anim it gets :), dont put too low tho..
	} else {
		timerTFUNCteleportToAndKillNPC_flyMe off
	}
	
	if(and(^dist_~£FUNCteleportToAndKillNPC_HoverEnt~ < §TeleDistEndTele && §TelePlayerNow == 0)) {
		Set §TelePlayerNow 1 //to start player flying only once
		GoSub FUNCcalcFrameMilis Set §TeleTimerFlyMilis §FUNCcalcFrameMilis_FrameMilis //must be a new var to let the func one modifications not interfere with this timer below
		timerTFUNCteleportToAndKillNPC_flyPlayer -m 0 §TeleTimerFlyMilis GoTo TFUNCteleportToAndKillNPC_flyPlayer
	}
	
	GoSub FUNCshowlocals
	RETURN
}
>>FUNCcalcFrameMilis {
	Set @FPS ^fps
	Set §FUNCcalcFrameMilis_FrameMilis 1000
	Div §FUNCcalcFrameMilis_FrameMilis @FPS
	if(§FUNCcalcFrameMilis_FrameMilis < 1) Set §FUNCcalcFrameMilis_FrameMilis 1
	RETURN
}
>>TFUNCteleportToAndKillNPC_flyPlayer {
	GoSub FUNCteleportToAndKillNPC_flyPlayer
	ACCEPT
}
>>FUNCteleportToAndKillNPC_flyPlayer {
	//if(§TeleSteps == 0) {
	if(@TelePlayerDistInit == 0) {
		//Set §TelePlayerToX ^locationx_~£FUNCteleportToAndKillNPC_HoverEnt~
		//Set §TelePlayerToY ^locationy_~£FUNCteleportToAndKillNPC_HoverEnt~
		//Set §TelePlayerToZ ^locationz_~£FUNCteleportToAndKillNPC_HoverEnt~
		//todo? if §TelePlayerToX > 90000000000 fail
		Set @TelePlayerDistInit ^dist_~£FUNCteleportToAndKillNPC_HoverEnt~
		//this will take 20 frames and is not based in time, TODO make it fly based in time, must use the FPS to calc it. or make it fly in a fixed speed/distance
		GoSub FUNCcalcFrameMilis Set §TeleSteps §FUNCcalcFrameMilis_FrameMilis //will take 1s to fly to any distance
		Set @TelePlayerStepDist @TelePlayerDistInit
		Div @TelePlayerStepDist §TeleSteps
		//Set @TelePlayerStepDist 50 //fixed fly speed per frame, it is bad as is not time based.. TODOA use FPS to calc it per second
	}
	
	//if(§TeleSteps > 0) {
	//if(and(@TelePlayerDistInit > 0 && ^dist_player > §TeleDistEndTele)) {
	if(@TelePlayerDistInit > 0) {
		Set @TeleHoloToPlayerDist ^dist_player
		if(@TeleHoloToPlayerDist > §TeleDistEndTele) {
			//the idea is to be unsafe positioning over/colliding with npc (that will be destroyed) location
			//is like fly speed
			//TODO not working, wont move: interpolate player "~§TelePlayerToX~,~§TelePlayerToY~,~§TelePlayerToZ~" @TelePlayerStepDist
			//Set @TelePlayerPlaceDist @TelePlayerDistInit
			//Dec @TelePlayerPlaceDist @TelePlayerStepDist
			//interpolate player "~§TelePlayerToX~,~§TelePlayerToY~,~§TelePlayerToZ~" @TelePlayerPlaceDist
			//interpolate player "~£FUNCteleportToAndKillNPC_HoverEnt~" @TelePlayerStepDist
			interpolate player "~^me~" @TelePlayerStepDist
			//-- §TeleSteps
		} else {
			DropItem "~£FUNCteleportToAndKillNPC_HoverEnt~" all
			//DoDamage -fmlcgewsao "~£FUNCteleportToAndKillNPC_HoverEnt~" 99999
			Destroy "~£FUNCteleportToAndKillNPC_HoverEnt~" //must be last thing or the ent reference will fail for the other commands 
			GoSub FUNCbreakDeviceDelayed //only after everything else have completed! this takes a long time to finish breaking it
			timerTFUNCteleportToAndKillNPC_flyPlayer off
		}
	}
	
	//if(§TeleSteps == 0) {
		//timerTFUNCteleportToAndKillNPC_flyPlayer off
	//}
	GoSub FUNCshowlocals
	
	RETURN
}
>>FUNCMindControl { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCMindControl" 
  // this works like a frenzied NPC
  
  //TODO goblin_base.asl: settarget -a ~othergoblinnearby~; BEHAVIOR -f MOVE_TO;  WEAPON ON; SETMOVEMODE RUN; Aim the first goblin, aim the second, the 1st attacks the 2nd and vice versa. then: sendevent call_help to the 2nd, that will make them look for the player, then keep aiming on them, they will then attack the 1st!
	Set £FUNCMindControl_HoverEntTmp "~^hover_5000~"
	Set §FUNCMindControl_HoverLife ^life_~£FUNCMindControl_HoverEntTmp~
	if(and(£FUNCMindControl_HoverEntTmp != "none" && §FUNCMindControl_HoverLife > 0)) {
    if(£FUNCMindControl_HoverEntMain == "") {
      Set £FUNCMindControl_HoverEntMain "~£FUNCMindControl_HoverEntTmp~"
      timerTeleportSelf -m 0 50 teleport "~£FUNCMindControl_HoverEntMain~"
      timerBreakDevice -m 1 60000 GoSub FUNCbreakDeviceDelayed
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
      SetTarget   -e ~£FUNCMindControl_HoverEntMain~ -a "~£FUNCMindControl_HoverEntAttackedByMain~"
      Behavior    -e ~£FUNCMindControl_HoverEntMain~ -f MOVE_TO
      Weapon      -e ~£FUNCMindControl_HoverEntMain~ ON
      SetMoveMode -e ~£FUNCMindControl_HoverEntMain~ RUN
    }
    
    //SendEvent -nr CALL_HELP 1500 "" //they will seek for the player, now player can aim them too
    
    SetTarget   -e ~£FUNCMindControl_HoverEntTmp~ -a "~£FUNCMindControl_HoverEntMain~"
    Behavior    -e ~£FUNCMindControl_HoverEntTmp~ -f MOVE_TO
    Weapon      -e ~£FUNCMindControl_HoverEntTmp~ ON
    SetMoveMode -e ~£FUNCMindControl_HoverEntTmp~ RUN
    
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
		//timerFUNCMindControlKillSpawn -m 0 333 GoSub FUNCMindControlKillSpawn
		
		//timerBreakDevice -m 1 §FUNCMindControl_FrenzyDelay GoSub FUNCbreakDeviceDelayed //only after everything else have completed! this takes a long time to finish breaking it
		//timerMindControlDetectHoverNPC off
		
		GoSub FUNCshowlocals
	}
	RETURN
}
>>FUNCMindControlKillSpawn {
	//teleport "~£FUNCMindControl_HoverEntTmp~" //should be enough to force bat attack the npc as it dont fly..
	interpolate "~£FUNCMindControl_SpawnFoeLastID~" "~£FUNCMindControl_HoverEntTmp~" 0.1
	if(^life_~£FUNCMindControl_HoverEntTmp~ <= 0){
		//DoDamage -fmlcgewsao "~£FUNCMindControl_SpawnFoeLastID~" 99999 //uneccessary?
		Destroy "~£FUNCMindControl_SpawnFoeLastID~"
		
		//Destroy "~£FUNCMindControl_HoverEntTmp~" //TODOABC will lose any items on it right? how to drop its items on floor? or could just change NPC mesh to "movable\\npc_gore\\npc_gore" and keep inventory stuff there! //destoying the npc is unsafe anyway, may destroy something that is game breaking...
		//just crashes... USEMESH -e "~£FUNCMindControl_HoverEntTmp~" "movable\\npc_gore\\npc_gore"
		//nothing happens SPAWN ITEM "movable\\npc_gore\\npc_gore" "~£FUNCMindControl_HoverEntTmp~"
		timerFUNCMindControlKillSpawn off
	}
	RETURN
}
//>>FUNCMindControlBkp2 { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCMindControl" 
	//Set £FUNCMindControl_HoverEnt "~^hover_5000~"
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
		//timerBreakDevice -m 1 1500 GoSub FUNCbreakDeviceDelayed //only after everything else have completed! this takes a long time to finish breaking it
		//timerMindControlDetectHoverNPC off
		//GoSub FUNCshowlocals
	//}
	//RETURN
//}

>>FUNCmorphUpgrade { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCmorphUpgrade" 
	Set §AncientDeviceTriggerStep 0
	GoSub FUNCskillCheckAncientTech
	Set §CreateChance §FUNCskillCheckAncientTech_chanceSuccess_OUTPUT
	if (and(§Quality >= 4 && §ItemConditionSure == 5)) Set §CreateChance 100
	RANDOM §CreateChance {
		if (£AncientDeviceMode == "_BecomeSignalRepeater_") { Set £AncientDeviceMode "SignalRepeater"
			// this must be easy to become again a hologram, so do minimal changes!
			TWEAK SKIN "Hologram.tiny.index4000.box" "Hologram.tiny.index4000.boxSignalRepeater"
			Set £FUNCnameUpdate_NameBase "Holo Signal Repeater"
			Set £Icon "HoloSignalRepeater"
			//Set §AncientDeviceTriggerStep 1
			//PlayerStackSize 1
		} else { 
		if ( £AncientDeviceMode == "SignalRepeater" ) { Set £AncientDeviceMode "Hologram"
			TWEAK SKIN "Hologram.tiny.index4000.boxSignalRepeater" "Hologram.tiny.index4000.box"
			GoSub FUNCcfgHologram
			RETURN //ONLY HERE!!! is just reverting to hologram!
		} else {
		if (£AncientDeviceMode == "Hologram") { Set £AncientDeviceMode "Grenade"
			Set §PristineChance @FUNCskillCheckAncientTech_chanceSuccess_OUTPUT
			Div §PristineChance 10
			If (§PristineChance < 5) Set §PristineChance 5
			RANDOM §PristineChance { // grants a minimal chance based on skill in case the player do not initialize it
				Set §Quality 5 
			}
			
			Set £FUNCnameUpdate_NameBase "Holo Grenade"
			Set £Icon "HologramGrenade"
			
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
			Set §Scale 10 SetScale §Scale //TODOA create a huge landmine (from box there, height 100%, width and length 5000%, blend alpha 0.1 there just to be able to work) on blender hologram overlapping, it will be scaled down here! Or should be a new model, a thin plate on the ground disguised as rock floor texture may be graph/obj3d/textures/l2_gobel_[stone]_floor01.jpg. Could try a new command like `setplayertweak mesh <newmesh>` but for items!
			Set £FUNCnameUpdate_NameBase "Holo Landmine"
			Set £Icon "HoloLandMine"
			Set §AncientDeviceTriggerStep 1
			PLAYERSTACKSIZE 9
		} else {
		if ( £AncientDeviceMode == "LandMine" ) { Set £AncientDeviceMode "Teleport"
			TWEAK SKIN "Hologram.tiny.index4000.boxLandMine" "Hologram.tiny.index4000.boxTeleport" 
			Set §Scale 100 SetScale §Scale
			Set £FUNCnameUpdate_NameBase "Holo Teleport"
			Set £Icon "HoloTeleport"
			Set §AncientDeviceTriggerStep 1
			PLAYERSTACKSIZE 6
		} else {
		if ( £AncientDeviceMode == "Teleport" ) { Set £AncientDeviceMode "MindControl"
			// why bats? they are foes of everyone else and the final result is equivalent. //TODO But, may be, make them disappear as soon they die to prevent looting their corpses as easy bonus loot.
			// why not mind control the targeted foe directly? too complicated. //TODO create new copy foes asl that behave as a player summon? create a player summon and change it's model after killing the targeted foe? implement something in c++ that make it easier to let mind control work as initially intended?
			TWEAK SKIN "Hologram.tiny.index4000.boxTeleport" "Hologram.tiny.index4000.boxMindControl" 
			Set §Scale 100 SetScale §Scale
			Set £FUNCnameUpdate_NameBase "Holo Mind Control"
			Set £Icon "HoloMindControl"
			Set §AncientDeviceTriggerStep 1
			PLAYERSTACKSIZE 3
		} } } } } }
		
		if(§AncientDeviceTriggerStep == 1) {
			if ( §Quality >= 4 ) {
				Set £FUNCnameUpdate_NameBase "~£FUNCnameUpdate_NameBase~ MK2+"
				Set £Icon "~£Icon~MK2"
			}
			
			GoSub FUNCupdateUses
			GoSub FUNCnameUpdate

			Set £Icon "~£Icon~[icon]"
			TWEAK ICON "~£Icon~"
			
			if( £AncientDeviceMode != "Hologram" ) SET_SHADOW ON
		}
	} else {
		//SPEAK -p [player_picklock_failed] NOP //TODO expectedly just a sound about failure and not about picklocking..
		////SPEAK -p [player_wrong] NOP //TODO expectedly just a sound about failure
		GoSub FUNCbreakDeviceDelayed
		GoSub FUNCshowlocals
	}
	
	RETURN
}
>>FUNCcfgHologram { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCcfgHologram" 
	TWEAK SKIN "Hologram.tiny.index4000.box.Clear"         "Hologram.tiny.index4000.box"
	TWEAK SKIN "Hologram.tiny.index4000.boxSignalRepeater" "Hologram.tiny.index4000.box"
	TWEAK SKIN "Hologram.tiny.index4000.boxLandMine"       "Hologram.tiny.index4000.box"
	TWEAK SKIN "Hologram.tiny.index4000.boxTeleport"       "Hologram.tiny.index4000.box"
	TWEAK SKIN "Hologram.tiny.index4000.boxMindControl"    "Hologram.tiny.index4000.box"
	
	SET_PRICE 100
	
	Set £FUNCnameUpdate_NameBase "Holograms of the over world"
	GoSub FUNCupdateUses
	GoSub FUNCnameUpdate
	
	PlayerStackSize 50 
	
	TWEAK ICON "Hologram[icon]"
	
	RETURN
}
>>FUNCblinkGlow { Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCblinkGlow" 
	//PARAMS: §FUNCblinkGlow_times
	if(§FUNCblinkGlow_times >= 0){
		TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow.Clear" "Hologram.tiny.index4000.grenadeGlow"
		//Off at  900 1800 2700 3600 4500. Could be 850 too: 850 1700 2550 3400 4250. but if 800 would clash with ON at 4000
		timerTrapGlowBlinkOff -m §FUNCblinkGlow_times  901 TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow" "Hologram.tiny.index4000.grenadeGlow.Clear" //901 will last 100 times til it matches multiple of 1000 below
		//On  at 1000 2000 3000 4000 5000
		timerTrapGlowBlinkOn  -m §FUNCblinkGlow_times 1000 TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow.Clear" "Hologram.tiny.index4000.grenadeGlow"
	} else {
		timerTrapGlowBlinkOff off
		timerTrapGlowBlinkOn  off
		TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow" "Hologram.tiny.index4000.grenadeGlow.Clear"
	}
	RETURN
}

>>FUNCshowlocals { //no £ScriptDebugLog. this func is to easy disable showlocals.
	if(§FUNCshowlocals_enabled >= 1){
		showlocals
	}
	RETURN
}
