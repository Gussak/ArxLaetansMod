///////////////////////////////////////////
// by Gussak (https://github.com/Gussak) //
///////////////////////////////////////////

////////////////////////////////////
// Obs.: If you just downloaded it from github, this file may need to have all 'Ã' 0xC2 chars removed or it will not work. I cant find yet a way to force iso-8859-15 while editing it directly on github, it seems to always become utf-8 there.

///////////////// DEV HELP: //////////////
// easy grep ex.: clear;LC_ALL=C egrep 'torch'   --include="*.asl" --include="*.ASL" -iRnIa  *
// easy grep ex.: clear;LC_ALL=C egrep 'torch.*' --include="*.asl" --include="*.ASL" -iRIaho * |sort -u

///////////////// TIPS: /////////////////
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

//apparently items can only stack if they have the exact same name?

//////////////////////////////// TODO LIST: /////////////////////////
//////////PRIORITY:HIGH (low difficulty also)
//TODO contextualizeDocModDesc: These Ancient Devices were found in collapsed ancient bunkers of a long lost and extremelly technologically advanced civilization. They are powered by an external energy source that, for some reason, is less effective or turns off when these devices are nearby strong foes and bosses. //TODO all or most of these ancient tech gets disabled near them
//////////PRIORITY:MEDIUM
//TODO box icon grey if unidentified. cyan when identified.
//TODO grenade icon and texture dark when inactive, red (current) when activated.
//TODO create a signal repeater item that can be placed in a high signal stregth place and repeats that signal str to 1000to3000 dist from it (depending on player ancientdev skill that will set it's initial quality). code at FUNCcalcSignalStrength
//////////PRIORITY:LOW
//TODO teleportArrow stack 10
//TODO grenade+hologram=teleportArrow (insta-kill any foe and teleport the player there)
//TODO teleportArrow+hologram=mindControl (undetectable, and frenzy foe against his friends)
//TODO some cleanup? there are some redundant "function" calls like to FUNCMakeNPCsHostile
//TODO sometimes the avatar will speak "they are dead, all dead" when activating the hologram to change the landscape, but... it could be considered contextualized about the ancient civilization that vanished ;)
//TODO `PLAY -ilp "~£SkyBoxCurrentUVS~.wav"` requires ".wav" as it removes any extension before re-adding the .wav so somename.index1 would become "somename.wav" and not "somename.index1.wav" and was failing. I think the src cpp code should only remove extension if it is ".wav" or other sound format, and not everything after the last dot "."

ON INIT {
  Set £ScriptDebugLog "~£ScriptDebugLog~;OnInit"
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

ON IDENTIFY { //this is called (apparently every frame) when the player hovers the mouse over the item, but requires `SETEQUIP identify_value ...` to be set or this event wont be called.
  //Set £ScriptDebugLog "~£ScriptDebugLog~;OnIdentify"
  //Set £ScriptDebugProblemTmp "identified=~§Identified~;ObjKnow=~^PLAYER_SKILL_OBJECT_KNOWLEDGE~"
  //if ( §Identified > 0 ) ACCEPT //w/o this was flooding the log, why?
  //if ( §IdentifyObjectKnowledgeRequirement == 0 ) ACCEPT //useless?
  if ( §Identified == 0 ) {
    if ( ^PLAYER_SKILL_OBJECT_KNOWLEDGE >= §IdentifyObjectKnowledgeRequirement ) {
      Set §Identified 1
      //Set £ScriptDebugLog "~£ScriptDebugLog~"
      
      if (§UseCount == 0) { //no uses will still be showing the doc so we know it is still to show the doc. this prevents changing if already showing a nice landscape
        Set £SkyBoxCurrent "Hologram.skybox.index2000.DocIdentified"
        Set £SkyBoxPrevious "~£SkyBoxCurrent~"
        TWEAK SKIN "Hologram.skybox.index2000.DocUnidentified" "~£SkyBoxCurrent~"
      }
      
      SET_PRICE 100
      
      Set £FUNCnameUpdate_NameBase "Holograms of the over world"
      GoSub FUNCupdateUses
      GoSub FUNCnameUpdate
      
      Set £ScriptDebugLog "~£ScriptDebugLog~;OnIdentify"
      
      showlocals
    }
  } else {
    Set £ScriptDebugLog ""
    if (^#timer2 == 0) starttimer timer2
    if (^#timer2 > 333) { //TOKEN_MOD_CFG
      GoSub FUNCupdateUses
      GoSub FUNCnameUpdate
      starttimer timer2
    }
  }
  ACCEPT
}

ON INVENTORYUSE {
  GoSub FUNCtests
  Set £ScriptDebugLog "~£ScriptDebugLog~;OnInventoryUse"
  ++ §OnInventoryUseCount //total activations just for debug
  
  ///////////////// TRAP MODE SECTION ///////////////////
  if ( §TrapInitStep > 0 ) {
    if ( §TrapInitStep == 1 ) {
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
        TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow.Clear" "Hologram.tiny.index4000.grenadeGlow"
        //Off at  900 1800 2700 3600 4500. Could be 850 too: 850 1700 2550 3400 4250. but if 800 would clash with ON at 4000
        timerTrapGlowBlinkOff -m §FUNCtrapAttack_TrapTimeSec  900 TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow" "Hologram.tiny.index4000.grenadeGlow.Clear"
        //On  at 1000 2000 3000 4000 5000
        timerTrapGlowBlinkOn  -m §FUNCtrapAttack_TrapTimeSec 1000 TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow.Clear" "Hologram.tiny.index4000.grenadeGlow"
        
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
        GoSub FUNCbreakDevice
      }
      //timerTrapDestroy -m 1 5100 GoSub FUNCDestroySelfSafely
      //timerTrapDestroy -m 1 7000 GoSub FUNCDestroySelfSafely //some effects have infinite time and then will last 2s (from 5000 to 7000)
      Set §TrapInitStep 2
    } else { // after trap being activated will only shock the player and who is in-between too
      GoSub FUNCshockPlayer
      if (^inPlayerInventory == 1) { //but if in inventory, will dissassemble the grenade recovering 2 holograms used to create it
        INVENTORY ADDMULTI "magic\hologram\hologram" 2 //TODOA this isnt working?
        GoSub FUNCDestroySelfSafely
      }
    }
    ACCEPT
  }
  
  //////////////// DENY ACTIVATION SECTION ///////////////////////
  
  Set £ScriptDebugLog "DebugLog:10;" //init script pseudo debug log
  //Set £ScriptDebugLog "~£ScriptDebugLog~;20"
  if (^inPlayerInventory == 1) {
    PLAY "POWER_DOWN"
    showlocals
    ACCEPT //can only be activated if deployed
  }
  
  if (§UseBlockedMili > 0) {
    GoSub FUNCMalfunction
    Set £ScriptDebugLog "~£ScriptDebugLog~;Deny_A:Blocked=~§UseBlockedMili~"
    
    ++ §UseCount 
    GoSub FUNCupdateUses //an attempt to use while blocked will damage it too, the player must wait the cooldown
    GoSub FUNCnameUpdate
    
    showlocals
    ACCEPT
  } else if (§UseBlockedMili < 0) {
    // log to help fix inconsistency if it ever happens
    timerBlocked off
    Set £ScriptDebugLog "~£ScriptDebugLog~;Fix_A:Blocked=~§UseBlockedMili~ IsNegative, fixing it to 0"
    //showlocals
    Set §UseBlockedMili 0
  }
  
  if (§bHologramInitialized == 1) {
    if ( ^#PLAYERDIST > 200 ) { //after scale up. 185 was almost precise but annoying to use. 190 is good but may be annoying if there is things on the ground.
      GoSub FUNCMalfunction
      Set £ScriptDebugLog "~£ScriptDebugLog~;Deny_C:PlayerDist=~^#PLAYERDIST~"
      showlocals
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
    
    Set §UseMax ^rnd_115
    //GoSub FUNCcalcAncientTechSkill
    //Inc §UseMax @AncientTechSkill
    Set §UseRemain §UseMax
    Set §UseHologramDestructionStart §UseMax
    Mul §UseHologramDestructionStart 0.95
    
    SET_SHADOW OFF
    Set £ScriptDebugLog "~£ScriptDebugLog~;30"
    
    // grow effect (timers begin imediatelly or after this event exits?)
    // total time
    Set §UseBlockedMili 5000 //the time it will take to grow
    //timerBlocked -m 100 50 Dec §UseBlockedMili 50 //to wait while it scales up
    timerBlocked -m 0 50 Dec §UseBlockedMili 50 //will just decrement §UseBlockedMili until it reaches 0
    // interactivity blocked
    SET_INTERACTIVITY NONE
    timerInteractivity -m 1 §UseBlockedMili SET_INTERACTIVITY YES
    // scale up effect (each timer must have it's own unique id)
    Set §Scale 100 //default. target is 1000%
    timerGrowInc  -m 100 50 Inc §Scale 9 //1000-100=900; 900/100=9 per step
    timerGrowInc2 -m 100 50 SetScale §Scale
    
    Set §bHologramInitialized 1
    
    TWEAK ICON "HologramInitialized[icon]"
    
    GoSub FUNCupdateUses
    GoSub FUNCnameUpdate
    
    //showvars
    showlocals //to not need to scroll up the log in terminal
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
    showlocals //last to be easier to read on log
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
  
  showlocals
  ACCEPT
}

On Main { //HeartBeat happens once per second apparently (but may be less often?)
  //Set £ScriptDebugLog "~£ScriptDebugLog~;OnMain"
  //starttimer timer1 //^#timer1 used ON MAIN
  //starttimer timer2 //^#timer2 used ON IDENTIFY
  //starttimer timer3 //^#timer3
  //starttimer timer4 //^#timer4
  //stoptimer timer1
  
  if ( £AncientDeviceMode == "Hologram" ) {
    if (§bHologramInitialized == 0) ACCEPT
    
    if (§DestructionStarted == 1) {
      //attractor SELF 1 3000
      GoSub FUNCaimPlayerCastLightning
      GoSub FUNCMakeNPCsHostile // as NPC may be in-between
      Set £ScriptDebugProblemTmp "MAIN:BeingDestroyed;" showlocals
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
          showlocals
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
  } else if ( £AncientDeviceMode == "SignalRepeater" ) {
    SENDEVENT -ir CUSTOM 3000 "CustomCmdSignalRepeater ~^me~ ~@SignalStrength~"
  } else if ( £AncientDeviceMode == "Grenade" ) {
  } else if ( £AncientDeviceMode == "LandMine" ) {
  } else if ( £AncientDeviceMode == "TeleportKill" ) {
  } else if ( £AncientDeviceMode == "MindControlBats" ) {
  }
  
  // any item that is going to explode will benefit from this
  if (§FUNCtrapAttack_TrapCanKillMode_OUTPUT == 1) {
    //attractor SELF 1 1000
    GoSub FUNCMakeNPCsHostile //this is good as while the item is flying after being thrown, NPCs will wake up near it!
  }
  
  ACCEPT
}

ON CUSTOM { //this is the receiving end of the transmission
  // ^$param<i> £string, ^&param<i> @number, ^#param<i> §int
  Set £CustomCommand ^$param1
  
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

ON COMBINE {
  Set £ScriptDebugLog "~£ScriptDebugLog~;OnCombine"
  UnSet £ScriptDebugCombineFailReason
  showlocals //this is excellent here as any attempt will help showing the log!
  
  // check other (the one that you double click)
  if (^$param1 ISCLASS "Hologram") else ACCEPT //only combine with these
  if (^$param1 !isgroup "DeviceTechBasic") {
    SPEAK -p [player_no] NOP
    Set £ScriptDebugCombineFailReason "Other:Not:Group:DeviceTechBasic"
    showlocals
    ACCEPT
  }
  
  //check self (the target of the combination request)
  //if (§bHologramInitialized == 0){
    //SPEAK -p [player_no] NOP
    //Set £ScriptDebugCombineFailReason "Self:NotInitialized"
    //showlocals
    //ACCEPT
  //}
  if (^amount > 1) { //this must not be a stack of items
    SPEAK -p [player_no] NOP
    Set £ScriptDebugCombineFailReason "Self:IsStack"
    showlocals
    ACCEPT
  }
  if (§Identified == 0) {
    SPEAK -p [player_not_skilled_enough] NOP
    Set £ScriptDebugCombineFailReason "Self:NotIdentified"
    showlocals
    ACCEPT
  }
  if (§TrapInitStep > 0) {
    SPEAK -p [player_no] NOP
    Set £ScriptDebugCombineFailReason "Self:TODO:HoloTeleportArrow"
    showlocals
    ACCEPT
  }
  
  DESTROY ^$PARAM1
  
  PLAY -s //stops sounds started with -i flag
  
  GoSub FUNCskillCheckAncientTech
  Set §CreateChance §FUNCskillCheckAncientTech_chanceSuccess_OUTPUT
  if (And(§Quality >= 4 && §ItemConditionSure == 5) {
    Set §CreateChance 100
  }
  RANDOM §CreateChance {
    if ( £AncientDeviceMode == "Hologram" ) { Set £AncientDeviceMode "Grenade"
      Set §PristineChance @FUNCskillCheckAncientTech_chanceSuccess_OUTPUT
      Div §PristineChance 10
      If (§PristineChance < 5) Set §PristineChance 5
      RANDOM §PristineChance { // grants a minimal chance based on skill in case the player do not initialize it
        Set §Quality 5 
      }
      
      if ( §Quality >= 4 ) {
        SetName "HoloGrenade+"
        TWEAK ICON "HologramGrenadeMK2[icon]"
      } else {
        SetName "HoloGrenade"
        TWEAK ICON "HologramGrenade[icon]"
      }
      
      //PLAY "TRAP"
      TWEAK SKIN "Hologram.tiny.index4000.box"               "Hologram.tiny.index4000.box.Clear"
      TWEAK SKIN "Hologram.tiny.index4000.grenade.Clear"     "Hologram.tiny.index4000.grenade"
      //TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow.Clear" "Hologram.tiny.index4000.grenadeGlow"
      
      GoSub FUNChideHologramPartsPermanently
      
      Set §Scale 100 //just in case it is combined with the big hologram on the floor
      SetScale §Scale
      
      Set §TrapInitStep 1
      PlayerStackSize 5
      SetGroup -r "DeviceTechBasic"
      SetGroup "Explosive"
    } else  if ( £AncientDeviceMode == "Grenade" ) { Set £AncientDeviceMode "LandMine"
      //TODO
    } else  if ( £AncientDeviceMode == "LandMine" ) { Set £AncientDeviceMode "TeleportKill"
      //TODO
    } else  if ( £AncientDeviceMode == "TeleportKill" ) { Set £AncientDeviceMode "MindControlBats"
      // why bats? they are foes of everyone else and the final result is equivalent. //TODO But, may be, make them disappear as soon they die to prevent looting their corpses as easy bonus loot.
      // why not mind control the targeted foe directly? too complicated. //TODO create new copy foes asl that behave as a player summon? create a player summon and change it's model after killing the targeted foe? implement something in c++ that make it easier to let mind control work as initially intended?
      //TODO
    }
  } else {
    //SPEAK -p [player_picklock_failed] NOP //TODO expectedly just a sound about failure and not about picklocking..
    ////SPEAK -p [player_wrong] NOP //TODO expectedly just a sound about failure
    GoSub FUNCbreakDevice
    showlocals
  }
  
  ACCEPT
}

ON InventoryIn {
  PLAY -s //stops sounds started with -i flag
  ACCEPT
}

ON InventoryOut {
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

>>>FUNCaimPlayerCastLightning { //this doesnt work well when called from a timer...
  //Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCaimPlayerCastLightning:"
  //ifVisible PLAYER { //use for fireball too? //this doesnt work for objects?
    Set §RotateYBkp §RotateY //bkp auto rotate angle speed
    Set §RotateY 0 //this stops the rotation (but may not stop for enough time tho to let the lightning work properly)
    //forceangle <yaw*> //unnecessary?
    //^angleto_<entity> //unnecessary?
    //forceangle ^angleto_PLAYER //unnecessary?
    GoSub FUNCshockPlayer
    timerRestoreRotationSpeed -m 1 100 Set §RotateY §RotateYBkp // restore auto rotate speed after the shock has time to be cast
  //}
  //showlocals
  RETURN //to return to wherever it needs?
}

>>FUNCMalfunction {
  Set §SfxRnd ^rnd_3
  if (§SfxRnd == 0) play "SFX_electric"
  if (§SfxRnd == 1) play "sfx_spark"
  if (§SfxRnd == 2) GoSub FUNCshockPlayer
  RETURN
}

>>FUNCChangeSkyBox { //these '{}' are not necessary but help on code editors
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
      GoTo FUNCChangeSkyBox //this looks safe but needs at least 2 skyboxes
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
      GoTo FUNCChangeSkyBox //this looks safe but needs at least 2 skyboxes
    }
    TWEAK SKIN "~£SkyBoxPreviousUVS~" "~£SkyBoxCurrentUVS~"
    Set §SkyMode 1
  }
  //showlocals
  RETURN
}

>>FUNCinitDefaults {
  Set £AncientDeviceMode "Hologram"
  
  TWEAK SKIN "Hologram.skybox.index2000.DocIdentified" "Hologram.skybox.index2000.DocUnidentified"
  TWEAK SKIN "Hologram.tiny.index4000.grenade"         "Hologram.tiny.index4000.grenade.Clear"
  TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow"     "Hologram.tiny.index4000.grenadeGlow.Clear"
  
  if(§iFUNCMakeNPCsHostile_rangeDefault == 0) {
    Set §iFUNCMakeNPCsHostile_rangeDefault 350 //the spell explosion(chaos) range //SED_TOKEN_MOD_CFG
    Set §iFUNCMakeNPCsHostile_range §iFUNCMakeNPCsHostile_rangeDefault
  }
  
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
  showlocals
  
  RETURN
}

>>FUNCMakeNPCsHostile { //params: §iFUNCMakeNPCsHostile_range
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

>>FUNCshockPlayer {
  if (^inPlayerInventory == 1) { 
    //TODO is there some way to auto drop the item? if so, this would be unnecessary...
    PLAY "sfx_lightning_loop"
    dodamage -l player 1
  } else {
    ForceAngle ^angleto_PLAYER
    SPELLCAST -smf @SignalStrLvl LIGHTNING_STRIKE PLAYER //TODO this causes damage? or is just the visual effect?
    Random 25 {
      SPELLCAST -fmsd 250 @SignalStrLvl PARALYSE PLAYER
    }
    
    //Set §iFUNCMakeNPCsHostile_range 350  //reason: they know it is dangerous to them too.
    GoSub FUNCMakeNPCsHostile
  }
  
  RETURN
}

>>FUNCbreakDevice {
  SetGroup "DeviceTechBroken"
  GoSub FUNCshockPlayer
  if (^inPlayerInventory == 1) {
    //TODOA find a way to just auto drop the item to work the more challenging code below
    DoDamage -lu PLAYER 3
    GoSub FUNCDestroySelfSafely
  } else {
    Set £FUNCnameUpdate_NameBase "Broken Hologram Device" 
    GoSub FUNCupdateUses
    GoSub FUNCnameUpdate
    
    SetInteractivity NONE
    SpecialFX FIERY
    SPEAK -p [player_picklock_failed] NOP //TODO expectedly just a sound about failure and not about picklocking..
    //SPEAK -p [player_wrong] NOP //TODO expectedly just a sound about failure
    Set §TmpBreakDestroyMilis §DefaultTrapTimoutSec
    Mul §TmpBreakDestroyMilis 1000
    timerTrapBreakDestroy -m 1 §TmpBreakDestroyMilis GoSub FUNCparalyseIfPlayerNearby //the trap tried to capture the player xD //TODOA not working?
    Inc §TmpBreakDestroyMilis ^rnd_15000
    timerTrapBreakDestroy -m 1 §TmpBreakDestroyMilis GoSub FUNCDestroySelfSafely //to give time to let the player examine it a bit
  }
  showlocals
  RETURN
}

>>FUNCupdateUses {
  Set §UseRemain §UseMax
  Dec §UseRemain §UseCount
  //DO NOT CALL: GoSub FUNCnameUpdate
  if (§UseCount >= §UseHologramDestructionStart) Set §UseBlockedMili 0 //quickly lets the player finish/destroy it
  RETURN
}

>>FUNCnameUpdate {
  //OUTPUT: £FUNCnameUpdate_NameFinal_OUTPUT
  if ( §Identified == 0 ) ACCEPT //the player is still not sure about what is going on
  
  Set £FUNCnameUpdate_NameFinal_OUTPUT "~£FUNCnameUpdate_NameBase~."
  
  if ( §bHologramInitialized == 1 ) {
    GoSub FUNCcalcAncientTechSkill
    
    GoSub FUNCcalcSignalStrength
    
    // condition from 0.00 to 1.00
    //DO NOT CALL BECOMES ENDLESS RECURSIVE LOOP: GoSub FUNCupdateUses
    //Set £ScriptDebugLog "~£ScriptDebugLog~;FUNCnameUpdate"
    Set @ItemCondition §UseRemain
    //Set £ScriptDebugLog "~£ScriptDebugLog~;~@ItemCondition~=~§UseRemain~"
    Div @ItemCondition §UseMax
    //Set £ScriptDebugLog "~£ScriptDebugLog~;/~§UseMax~=~@ItemCondition~"
    //TODO why the below wont work? it is always bad or critical...
    //if      ( @ItemCondition >= 0.80 ) { Set £ItemConditionDesc "excellent" }
    //else if ( @ItemCondition >= 0.60 ) { Set £ItemConditionDesc "good"      }
    //else if ( @ItemCondition >= 0.40 ) { Set £ItemConditionDesc "average"   }
    //else if ( @ItemCondition >= 0.20 ) { Set £ItemConditionDesc "bad"       }
    //else {                               Set £ItemConditionDesc "critical"  }
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
    
    if(@AncientTechSkill >= 50) { //detailed info for nerds ;) 
      Set £SignalStrInfo "~£SignalStrInfo~(~§SignalStrengthTrunc~% for ~§SignalModeChangeDelay~s)" //it is none or working for N seconds
      Set §hours   ^gamehours
      Mod §hours 24
      Set §minutes ^gameminutes
      Mod §minutes 60
      Set §seconds ^gameseconds
      Mod §seconds 60
      // as day/night is based in quest stages and (I believe) they do not update the global time g_gameTime value, these would be incoherent to show as GameTime GT:^arxdays ^arxtime_hours ^arxtime_minutes ^arxtime_seconds. So will show only real time.
      Set £ItemConditionDesc "~£ItemConditionDesc~(~§ItemConditionPercent~% ~§UseCount~/~§UseMax~ Remaining ~§UseRemain~) RT:~^gamedays~day(s) ~%02d,^gamehours~:~%02d,^gameminutes~:~%02d,^gameseconds~" 
      //Set £ItemConditionDesc "~£ItemConditionDesc~(~§ItemConditionPercent~% ~§UseCount~/~§UseMax~ Remaining ~§UseRemain~) RT:~^gamedays~day(s) ~%02d,^gamehours~:~%02d,^gameminutes~:~%02d,^gameseconds~" 
      Set £ItemQuality "~£ItemQuality~(~§UseMax~)"
    }
    if(@AncientTechSkill >= 20) Set £FUNCnameUpdate_NameFinal_OUTPUT "~£FUNCnameUpdate_NameFinal_OUTPUT~ Signal:~£SignalStrInfo~." //useful to position yourself
    if(@AncientTechSkill >= 30) Set £FUNCnameUpdate_NameFinal_OUTPUT "~£FUNCnameUpdate_NameFinal_OUTPUT~ Quality:~£ItemQuality~." //useful to chose wich one to keep
    if(@AncientTechSkill >= 40) Set £FUNCnameUpdate_NameFinal_OUTPUT "~£FUNCnameUpdate_NameFinal_OUTPUT~ Condition:~£ItemConditionDesc~." //useful to hold your hand avoiding destroy it
    //if(@AncientTechSkill >= 50) Set £FUNCnameUpdate_NameFinal_OUTPUT "~£FUNCnameUpdate_NameFinal_OUTPUT~ Signal:~§SignalStrengthTrunc~, ~§ItemConditionPercent~% ~§UseCount~/~§UseMax~ Remaining ~§UseRemain~." //detailed condition for nerds ;) 
  } else {
    Set £FUNCnameUpdate_NameFinal_OUTPUT "~£FUNCnameUpdate_NameFinal_OUTPUT~ (Not initialized)."
  }
  
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
  showlocals
}

>>FUNCcalcAncientTechSkill {
  Set @AncientTechSkill ^PLAYER_SKILL_MECANISM
  Inc @AncientTechSkill ^PLAYER_SKILL_OBJECT_KNOWLEDGE
  Inc @AncientTechSkill ^PLAYER_SKILL_INTUITION
  Div @AncientTechSkill 3 //the total skills used for it
  RETURN
}

>>FUNCskillCheckAncientTech { //checks the technical skill like in a percent base. 
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
  showlocals
  Unset @TmpRandomBonus
  
  RETURN
}

>>FUNCtrapAttack {
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
  
  timerTrapVanish       1 §FUNCtrapAttack_TrapTimeSec TWEAK SKIN "Hologram.tiny.index4000.grenade" "alpha"
  timerTrapVanishActive 1 §FUNCtrapAttack_TrapTimeSec TWEAK SKIN "Hologram.tiny.index4000.grenadeActive" "alpha"
  timerTrapVanishGlow   1 §FUNCtrapAttack_TrapTimeSec TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow" "alpha"
  
  // trap effect time
  Set §TmpTrapDestroyTime §FUNCtrapAttack_TrapTimeSec
  Inc §TmpTrapDestroyTime §TrapEffectTime
  timerTrapDestroy 1 §TmpTrapDestroyTime GoSub FUNCDestroySelfSafely 
  
  showlocals
  // unset after log
  //Unset §TmpTrapDestroyTime //DO NOT UNSET OR IT WILL BREAK THE TIMER!!!
  
  //restore defaults for next call "w/o params"
  Set §FUNCtrapAttack_TrapMode 0
  RETURN
}

>>FUNCchkAndAttackProjectile {
  if ( ^#PLAYERDIST > §iFUNCMakeNPCsHostile_rangeDefault ) ACCEPT //the objective is to protect NPCs that did not get alerted by the player aggressive action
  Set §TmpTrapKind ^rnd_6
  if (§TmpTrapKind == 0) SPELLCAST -smf @SignalStrLvl FIREBALL              PLAYER
  if (§TmpTrapKind == 1) SPELLCAST -smf @SignalStrLvl FIRE_PROJECTILE       PLAYER
  if (§TmpTrapKind == 2) SPELLCAST -smf @SignalStrLvl ICE_PROJECTILE        PLAYER
  if (§TmpTrapKind == 3) SPELLCAST -smf @SignalStrLvl MAGIC_MISSILE         PLAYER
  if (§TmpTrapKind == 4) SPELLCAST -smf @SignalStrLvl MASS_LIGHTNING_STRIKE PLAYER
  if (§TmpTrapKind == 5) SPELLCAST -smf @SignalStrLvl POISON_PROJECTILE     PLAYER
  //if (§TrapKind == 0) SPELLCAST -smf @SignalStrLvl LIGHTNING_STRIKE PLAYER //too weak
  Unset §TmpTrapKind
  RETURN
}

>>FUNChideHologramPartsPermanently {
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

>>FUNCparalyseIfPlayerNearby { //TODOA is this working?
  if ( ^#PLAYERDIST < 500 ) {
    Set §TmpParalyseMilis 3000
    Inc §TmpParalyseMilis ^rnd_6000
    SPELLCAST -fmsd §TmpParalyseMilis @SignalStrLvl PARALYSE PLAYER
  }
  RETURN
}

>>FUNCDestroySelfSafely {
  PLAY -s //stops sounds started with -i flag
  DESTROY SELF
  RETURN
}

>>FUNCcalcSignalStrength { //this is meant to be independent from magic skills so instead of ^spelllevel to cast spells, use @SignalStrLvl
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
  } else if(£SignalMode == "None"){
    if(^gameseconds > #SignalModeChangeTime){
      Set £SignalMode "Working" //configures the working signal delay below
      Set #SignalModeChangeTime  ^gameseconds
      Inc #SignalModeChangeTime  900 //from
      Inc #SignalModeChangeTime  ^rnd_900 //up to
      RETURN
    }
    RETURN
  }
  
  if(§SignalRepeater > 0) { //TODO implement signal repeaters
    if(and(§SignalRepeater == 1 && ^dist_player <= 3000)) // 1: there is a signal repeater at player inventory (good as forces player to want to not move) 
      // at some locations there is no signal at all.
      Set §NoSignalRegion ^locationx_player
      Inc §NoSignalRegion ^locationz_player
      Mod §NoSignalRegion §SignalDistBase
      if(§NoSignalRegion >= §SignalDistMin) {
        Set @RepeaterSignalStrength ^locationx_player
        Inc @RepeaterSignalStrength ^locationy_player
        Inc @RepeaterSignalStrength ^locationz_player
      }
    } else if(§SignalRepeater == 2) { // 2: there is a deployed repeater nearby
      todoa £SignalRepeaterID
      Set @RepeaterSignalDist ^dist_"~£RepeaterStrongestDeployedID~" //nearest (but could be all within 3000 range and receive the strongest signal)
    }
  } else {
    Set @AncientGlobalTransmitterSignalDist ^dist_"0,0,0"
  }
  
  // signal strength based on deterministic but difficultly previsible cubic regions
  Set §NoSignalRegion ^locationx_player
  Inc §NoSignalRegion ^locationz_player
  Mod §NoSignalRegion §SignalDistBase
  if(§NoSignalRegion >= §SignalDistMin) {
    Set @SignalStrength ^locationx_self 
    Inc @SignalStrength ^locationy_self
    if (^inPlayerInventory == 1) Inc @SignalStrength 90 //if at player inventory, items are 90 dist from ground (based on tests above). Could just use ^locationy_player tho.
    Inc @SignalStrength ^locationz_self
    
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
>>FUNCtestPrintfFormats {
  Set @testFloat 78.12345
  Set §testInt 513
  Set £testString "foo"
  //some simple printf formats
  Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;float:~%020.6f,@testFloat~"
  Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;hexa:0x~%08X,§testInt~"
  Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;decimalAlignRight:~%8d,§testInt~"
  Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;string='~%10s,£testString~'"
  RETURN
}
>>FUNCtestLogicOperators {
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
  
  RETURN
}
>>FUNCtests {
  // other tmp tests
  //fail teleport -pi //tele the player to its starting spawn point
  //Set @TstDistToSomeFixedPoint ^RealDist_PRESSUREPAD_GOB_0022 //this gives a wrong(?) huge value..
  //Set @TstDistToSomeFixedPoint ^Dist_PRESSUREPAD_GOB_0022 //this doesnt seem to work, the value wont change..
  //Set §TstDistToSomeFixedPoint @TstDistToSomeFixedPoint
  
  Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;FUNCtests" //printf format
  GoSub FUNCtestPrintfFormats
  GoSub FUNCtestLogicOperators
  
  showlocals
  RETURN
}
