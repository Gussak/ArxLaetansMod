///////////////////////////////////////////
// by Gussak (https://github.com/Gussak) //
///////////////////////////////////////////

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

//Set 劫estInt2 @TestFloat2 //it will always trunc do 1.9999 will become 1

//code IFs carefully with spaces: if ( 呆HologramInitialized == 1 ) { //as this if(呆HologramInitialized==1){ will result in true even if 呆HologramInitialized is not set...

//Do NOT unset vars used in timers! it will break them!!! ex.: timerTrapDestroy 1 劫mpTrapDestroyTime GoSub FUNCDestroySelfSafely  //do not UnSet 劫mpTrapDestroyTime

//apparently items can only stack if they have the exact same name?

//////////////////////////////// TODO LIST: /////////////////////////
//////////PRIORITY:HIGH (low difficulty also)
//TODO contextualizeDocModDesc: These Ancient Devices were found in collapsed ancient bunkers of a long lost and extremelly technologically advanced civilization. They are powered by an external energy source that, for some reason, is less effective or turns off when these devices are nearby strong foes and bosses. //TODO all or most of these ancient tech gets disabled near them
//////////PRIORITY:MEDIUM
//TODO box icon grey if unidentified. cyan when identified.
//TODO grenade icon and texture dark when inactive, red (current) when activated.
//////////PRIORITY:LOW
//TODO teleportArrow stack 10
//TODO grenade+hologram=teleportArrow (insta-kill any foe and teleport the player there)
//TODO teleportArrow+hologram=mindControl (undetectable, and frenzy foe against his friends)
//TODO some cleanup? there are some redundant "function" calls like to FUNCMakeNPCsHostile
//TODO sometimes the avatar will speak "they are dead, all dead" when activating the hologram to change the landscape, but... it could be considered contextualized about the ancient civilization that vanished ;)
//TODO `PLAY -ilp "~ΠkyBoxCurrentUVS~.wav"` requires ".wav" as it removes any extension before re-adding the .wav so somename.index1 would become "somename.wav" and not "somename.index1.wav" and was failing. I think the src cpp code should only remove extension if it is ".wav" or other sound format, and not everything after the last dot "."

ON INIT {
  Set ΠcriptDebugLog "~ΠcriptDebugLog~;OnInit"
  SetName "Ancient Device (unidentified)"
  SET_MATERIAL METAL
  SetGroup "DeviceTechBasic"
  SET_PRICE 50
  PlayerStackSize 50 
  
  Set 兌dentifyObjectKnowledgeRequirement 35
  SETEQUIP identify_value 兌dentifyObjectKnowledgeRequirement //seems to enable On Identify event but the value seems to be ignored to call that event?
  
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
  //Set ΠcriptDebugLog "~ΠcriptDebugLog~;OnIdentify"
  //Set ΠcriptDebugProblemTmp "identified=~兌dentified~;ObjKnow=~^PLAYER_SKILL_OBJECT_KNOWLEDGE~"
  //if ( 兌dentified > 0 ) ACCEPT //w/o this was flooding the log, why?
  //if ( 兌dentifyObjectKnowledgeRequirement == 0 ) ACCEPT //useless?
  if ( 兌dentified == 0 ) {
    if ( ^PLAYER_SKILL_OBJECT_KNOWLEDGE >= 兌dentifyObjectKnowledgeRequirement ) {
      Set 兌dentified 1
      //Set ΠcriptDebugLog "~ΠcriptDebugLog~"
      
      if (助seCount == 0) { //no uses will still be showing the doc so we know it is still to show the doc. this prevents changing if already showing a nice landscape
        Set ΠkyBoxCurrent "Hologram.skybox.index2000.DocIdentified"
        Set ΠkyBoxPrevious "~ΠkyBoxCurrent~"
        TWEAK SKIN "Hologram.skybox.index2000.DocUnidentified" "~ΠkyBoxCurrent~"
      }
      
      SET_PRICE 100
      
      Set ΓUNCnameUpdate_NameBase "Holograms of the over world"
      GoSub FUNCupdateUses
      GoSub FUNCnameUpdate
      
      Set ΠcriptDebugLog "~ΠcriptDebugLog~;OnIdentify"
      
      showlocals
    }
  }
  ACCEPT
}

ON INVENTORYUSE {
  Set ΠcriptDebugLog "~ΠcriptDebugLog~;OnInventoryUse"
  ++ 別nInventoryUseCount //total activations just for debug
  
  ///////////////// TRAP MODE SECTION ///////////////////
  if ( 劫rapInitStep > 0 ) {
    if ( 劫rapInitStep == 1 ) {
      if (^amount > 1) { //cannot activate a stack of items
        SPEAK -p [player_no] NOP
        ACCEPT
      }
      
      GoSub FUNCskillCheckAncientTech
      Set 你ctivateChance 佝UNCskillCheckAncientTech_chanceSuccess_OUTPUT
      if ( 利uality >= 4 ) {
        Set 你ctivateChance 100
      }
      RANDOM 你ctivateChance { //not granted to successfully activate it as it is a defective device
        Set 佝UNCtrapAttack_TrapTimeSec 5
        
        TWEAK ICON "HologramGrenadeActive[icon]"
        
        TWEAK SKIN "Hologram.tiny.index4000.grenade" "Hologram.tiny.index4000.grenadeActive"
        TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow.Clear" "Hologram.tiny.index4000.grenadeGlow"
        //Off at  900 1800 2700 3600 4500. Could be 850 too: 850 1700 2550 3400 4250. but if 800 would clash with ON at 4000
        timerTrapGlowBlinkOff -m 佝UNCtrapAttack_TrapTimeSec  900 TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow" "Hologram.tiny.index4000.grenadeGlow.Clear"
        //On  at 1000 2000 3000 4000 5000
        timerTrapGlowBlinkOn  -m 佝UNCtrapAttack_TrapTimeSec 1000 TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow.Clear" "Hologram.tiny.index4000.grenadeGlow"
        
        timerTrapVanish     1 佝UNCtrapAttack_TrapTimeSec TWEAK SKIN "Hologram.tiny.index4000.grenade"     "Hologram.tiny.index4000.grenade.Clear"
        timerTrapVanishGlow 1 佝UNCtrapAttack_TrapTimeSec TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow" "Hologram.tiny.index4000.grenadeGlow.Clear"
        
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
      Set 劫rapInitStep 2
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
  
  Set ΠcriptDebugLog "DebugLog:10;~^spelllevel~" //init script pseudo debug log
  //Set ΠcriptDebugLog "~ΠcriptDebugLog~;20"
  if (^inPlayerInventory == 1) {
    PLAY "POWER_DOWN"
    showlocals
    ACCEPT //can only be activated if deployed
  }
  
  if (助seBlockedMili > 0) {
    GoSub FUNCMalfunction
    Set ΠcriptDebugLog "~ΠcriptDebugLog~;Deny_A:Blocked=~助seBlockedMili~"
    
    ++ 助seCount 
    GoSub FUNCupdateUses //an attempt to use while blocked will damage it too, the player must wait the cooldown
    GoSub FUNCnameUpdate
    
    showlocals
    ACCEPT
  } else if (助seBlockedMili < 0) {
    // log to help fix inconsistency if it ever happens
    timerBlocked off
    Set ΠcriptDebugLog "~ΠcriptDebugLog~;Fix_A:Blocked=~助seBlockedMili~ IsNegative, fixing it to 0"
    //showlocals
    Set 助seBlockedMili 0
  }
  
  if (呆HologramInitialized == 1) {
    if ( ^#PLAYERDIST > 200 ) { //after scale up. 185 was almost precise but annoying to use. 190 is good but may be annoying if there is things on the ground.
      GoSub FUNCMalfunction
      Set ΠcriptDebugLog "~ΠcriptDebugLog~;Deny_C:PlayerDist=~^#PLAYERDIST~"
      showlocals
      ACCEPT
    }
  }
  
  //////////// INITIALIZE: Turn On ///////////
  if (呆HologramInitialized == 0) { //first use will just scale it up/initialize it
    PLAY "POWER"
    
    //Collision ON
    //Damager -eu 1
    PLAYERSTACKSIZE 1 //for the HOLOGRAM functionalities it is important to prevent resetting the use count when trying to mix(glitch) a stack, on reload game, it seems to keep the local vars to each object!
    SetGroup "DeviceTechHologram"
    
    TWEAK SKIN "Hologram.tiny.index4000.box" "Hologram.tiny.index4000.box.Clear"
    
    Set 助seMax ^rnd_115
    //GoSub FUNCcalcAncientTechSkill
    //Inc 助seMax @AncientTechSkill
    Set 助seRemain 助seMax
    Set 助seHologramDestructionStart 助seMax
    Mul 助seHologramDestructionStart 0.95
    
    SET_SHADOW OFF
    Set ΠcriptDebugLog "~ΠcriptDebugLog~;30"
    
    // grow effect (timers begin imediatelly or after this event exits?)
    // total time
    Set 助seBlockedMili 5000 //the time it will take to grow
    //timerBlocked -m 100 50 Dec 助seBlockedMili 50 //to wait while it scales up
    timerBlocked -m 0 50 Dec 助seBlockedMili 50 //will just decrement 助seBlockedMili until it reaches 0
    // interactivity blocked
    SET_INTERACTIVITY NONE
    timerInteractivity -m 1 助seBlockedMili SET_INTERACTIVITY YES
    // scale up effect (each timer must have it's own unique id)
    Set 刨cale 100 //default. target is 1000%
    timerGrowInc  -m 100 50 Inc 刨cale 9 //1000-100=900; 900/100=9 per step
    timerGrowInc2 -m 100 50 SetScale 刨cale
    
    Set 呆HologramInitialized 1
    
    TWEAK ICON "HologramInitialized[icon]"
    
    GoSub FUNCupdateUses
    GoSub FUNCnameUpdate
    
    //showvars
    showlocals //to not need to scroll up the log in terminal
    ACCEPT
  }
  
  //////////////// WORK on landscapes etc /////////////////////////
  ++ 助seCount
  
  if (助seCount == 1) { //init skyboxes
    Set 刨kyMode 2 //cubemap
    Set 刨kyBoxIndex 0 //initializes the landscapes
    Set ΠkyBoxCurrent "Hologram.skybox.index~刨kyBoxIndex~"
    TWEAK SKIN "Hologram.skybox.index2000.DocIdentified"   "~ΠkyBoxCurrent~" //no problem if unidentified
    TWEAK SKIN "Hologram.skybox.index2000.DocUnidentified" "~ΠkyBoxCurrent~"
    //Set ΠkyBoxCurrentUVS "Hologram.skybox.UVSphere.index3000.Clear" //sync this with what is in blender
    Set ΠkyBoxCurrentUVS "Hologram.skybox.UVSphere.index2000.DocBackground" //sync this with what is in  blender
    GoSub FUNCChangeSkyBox
  }
  
  // means the device is malfunctioning and shocks the player, was 25%
  Set 冶alfunction 0
  GoSub FUNCskillCheckAncientTech
  Set 低hkMalfunction 佝UNCskillCheckAncientTech_chanceFailure_OUTPUT
  Div 低hkMalfunction 2
  RANDOM 低hkMalfunction {
    GoSub FUNCshockPlayer
    //dodamage -lu player 3 //-u push, extra dmg with push. this grants some damage if lightning above fails
    INC 助seCount 10  //damage
    INC 助seCount ^rnd_10
    Set ΠcriptDebugLog "~ΠcriptDebugLog~;60.damagePlayer"
    Set 冶alfunction 1
    Inc 助seBlockedMili ^rnd_10000
  }
  
  //it called the attention of some hostile creature, not related to player skill. no need to use any hiding/shadow value as the hologram emits light and will call attention anyway. Only would make sense in some closed room, but rats may find their way there too.
  RANDOM 10 {
    PLAY "sfx_lightning_loop"
    //RANDOM 75 { 
      spawn npc "rat_base\\rat_base" SELF //player
      INC 助seCount 20 //damage
      INC 助seCount ^rnd_20
      Set ΠcriptDebugLog "~ΠcriptDebugLog~;70.spawn rat"
      Inc 助seBlockedMili ^rnd_15000
      Set 冶alfunction 1
    //} else { //TODOA add medium (usesdmg30-60) and hard (usesdmg50-80) creatures? is there a hostile dog (medium) or a weak small spider (hard)?  tweak/create a shrunk small and nerfed spider (hard)! tweak/create a bigger buffed rat (medium)!
      ////RANDOM 75 {
        //spawn npc "dog\\dog" player //these dogs are friendly...
        //Inc 助seBlockedMili 30000
        //Set 冶alfunction 1
        //INC 助seCount 5 //durability
        //Set ΠcriptDebugLog "~ΠcriptDebugLog~;70.spawn dog"
        ////spawn npc "bat\\bat" player //no, kills rats
      ////} else {
        ////spawn npc "goblin_base\\goblin_base" player //doesnt attack player
        ////spawn npc "goblin_test\\goblin_test" player //doesnt attack the player
        //Inc 助seBlockedMili 60000
        //Set 冶alfunction 1
      ////}
    //}
  }
  
  // warning to help the player wakeup 
  if (助seCount >= 助seHologramDestructionStart) { //this may happen a few times or just once, depending on the player bad luck ;)
    RANDOM 25 {
      PLAY "sfx_lightning_loop"
    }
    PLAY "TRAP"
    SETLIGHT 1 //TODO??
    Set 冶alfunction 1
    Set 助seBlockedMili 100 //to prevent any other delay and let the player quickly reach the destruction event
    TWEAK SKIN "Hologram.skybox.index1000.Status.Good" "Hologram.skybox.index1000.Status.Bad"
    GoSub FUNCshockPlayer
  }

  if (冶alfunction > 0) {
    GoSub FUNCMalfunction
    //DoDamage -u player 0 //-u push
  } else {
    /////////// HEALING EFFECTS
    GoSub FUNCskillCheckAncientTech
    RANDOM 佝UNCskillCheckAncientTech_chanceSuccess_OUTPUT { //was just 50
      //PLAY "potion_mana"
      Set @IncMana ^spelllevel
      Inc @IncMana @FUNCskillCheckAncientTech_addBonus_OUTPUT
      if ( 兌dentified > 0 ) Mul @IncMana 1.5
      SpecialFX MANA @IncMana
      //TODO play some sound that is not drinking or some visual effect like happens with healing
      SPEAK -p [player_yes] NOP //TODO good?
      Set ΠcriptDebugLog "~ΠcriptDebugLog~;MANA"
    }
    
    GoSub FUNCskillCheckAncientTech
    RANDOM 佝UNCskillCheckAncientTech_chanceSuccess_OUTPUT { //was just 50
      //SpecialFX HEAL ^spelllevel
      Set @IncHP ^spelllevel
      Inc @IncHP @FUNCskillCheckAncientTech_addBonus_OUTPUT
      if ( 兌dentified > 0 ) Mul @IncHP 1.5
      SPELLCAST -msf @IncHP HEAL PLAYER
      Set ΠcriptDebugLog "~ΠcriptDebugLog~;HEAL"
      //Set ΠcriptDebugLog "~ΠcriptDebugLog~;43"
    }
    
    ///////////////// SKYBOXES
    GoSub FUNCChangeSkyBox
  }
  
  Set ΠcriptDebugLog "~ΠcriptDebugLog~;100;player^spelllevel=~^spelllevel~"
  if (助seCount >= 助seMax) { /////////////////// DESTROY ///////////////////
    Set 伶estructionStarted 1
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
    //Set 助seBlockedMili 999999 //any huge value beyond destroy limit
    //             times delay
    //timerShrink1 -m 100   30 Dec 刨cale 10 //from 1000 to 0 in 3s with a shrink of 10% each step
    //timerShrink2 -m 100   30 SetScale 刨cale
    // total time to finish the animation is 5000ms
    //Set 刨IZED 10 //controls shrink varying speed from faster to slower: 5000/x=10/1; x=5000/10; 500ms
    //timerShrink0 -m 100  500 Dec 刨IZED 1 //this is the speed somehow
    //timerShrink1 -m 100   50 Dec 刨cale 刨IZED
    timerShrink1 -m 100   50 Dec 刨cale 10
    timerShrink2 -m 100   50 SetScale 刨cale
    //timerLevitateX -m  0 150 Inc 劫EMPORARY ^rnd_2
    //timerLevitateZ -m  0 200 Inc 劫EMPORARY2 3
    timerLevitate  -m 10 100 Move 0 -10 0 // Y negative is upwards //this doesnt seem to work well everytime //TODO use animation, but how?
    timerCrazySpin10p -m 0 75 Inc 刪otateY 1
    //timerCrazySpin10y -m 0 150 Inc 劫EMPORARY 2
    //timerCrazySpin10r -m 0 200 Inc 劫EMPORARY2 3
    //timerCrazySpin10  -m 0 10 Rotate 含mp 劫EMPORARY 劫EMPORARY2
    timerCrazySpin10  -m 0 10 Rotate 0 刪otateY 0 //the model doesnt spin from it's mass or geometric center but from it's origin that is on the bottom and using other than Y will just look bad..
    //timerCrazySpin20 -m 0   10 Rotate ^rnd_360 ^rnd_360 ^rnd_360
    //KEEP_COMMENT: when the object is rotating and moving, lightning seems to almost always miss making it unreliable. keeping these as visual effects mainly.
    //timerAttack10 -m  1 1000 SPELLCAST -smf ^spelllevel lightning_strike PLAYER //these dont do damage? even if using higher level like 3? it seems that as it is spinning, the aim misses the player? ends up just being a nice effect tho...
    //timerAttack10 -m  1 1000 GoSub FUNCaimPlayerCastLightning
    //timerAttack20 -m  1 2000 SPELLCAST -smf ^spelllevel lightning_strike PLAYER
    //timerAttack10 -m  1 2000 GoSub FUNCaimPlayerCastLightning
    //timerAttack30 -m  1 3000 SPELLCAST -smf ^spelllevel lightning_strike PLAYER
    //timerAttack10 -m  1 3000 GoSub FUNCaimPlayerCastLightning
    //RANDOM 25 { //to prevent player using as granted weapon against NPCs
      //timerAttack35 -m  1 3000 SPELLCAST -smf ^spelllevel EXPLOSION SELF
    //}
    //timerAttack40 -m  1 4000 SPELLCAST -smf ^spelllevel lightning_strike PLAYER
    //timerAttack10 -m  1 4000 GoSub FUNCaimPlayerCastLightning
    //TODO timerDemon45 -m  1 4500 show demon portal and tentacle and play its laugh, is also a reasoning for the fireball!
    //timerAttack50 -m  1 5000 SPELLCAST -smf ^spelllevel lightning_strike PLAYER
    //timerAttack10 -m  1 5000 GoSub FUNCaimPlayerCastLightning
    RANDOM 15 { //to prevent player using as granted weapon against NPCs
      //timerAttack55 -m  1 4950 SETTARGET PLAYER //for fireball
      //timerAttack56 -m  1 5000 SPAWN FIREBALL //the origin to fire from must be above floor
      Set 佝UNCtrapAttack_TrapMode 1 //projectile at player
      Set 佝UNCtrapAttack_TrapTimeSec 5
      GoSub FUNCtrapAttack
    }
    RANDOM 25 { //to prevent player using as granted weapon against NPCs
      //timerAttack57 -m  1 5000 SPELLCAST -smf ^spelllevel EXPLOSION SELF
      Set 佝UNCtrapAttack_TrapTimeSec 5
      timerTrapVanish 1 佝UNCtrapAttack_TrapTimeSec GoSub FUNChideHologramPartsPermanently
      GoSub FUNCtrapAttack
      //timerDestroy -m   1 5100 GoSub FUNCDestroySelfSafely
    }
    
    if (佝UNCtrapAttack_TrapCanKillMode_OUTPUT == 0) {
      timerGrantDestroySelf 1 伶efaultTrapTimoutSec GoSub FUNCDestroySelfSafely
    }
    
    GoSub FUNCupdateUses
    GoSub FUNCnameUpdate
    
    showvars
    showlocals //last to be easier to read on log
    ACCEPT
  }
  
  if (助seBlockedMili <= 0) {
    Inc 助seBlockedMili ^rnd_5000 //normal activation minimum random delay
  }
  
  if (助seCount < 助seHologramDestructionStart) { 
    //this must be after all changes to 助seBlockedMili !
    //trap start used the status bad override, so it can be ignored as wont change
    TWEAK SKIN "Hologram.skybox.index1000.Status.Good" "Hologram.skybox.index1000.Status.Warn"
    //// after the timeout will always be GOOD
    //Set ΠtatusSkinCurrent "Hologram.skybox.index1000.Status.Good"
    //Set ΠtatusSkinPrevious "~ΠtatusSkinCurrent~"
    //// reaching this point is always WARN: the player must wait the cooldown
    timerSkinGood -m 1 助seBlockedMili TWEAK SKIN "Hologram.skybox.index1000.Status.Warn" "Hologram.skybox.index1000.Status.Good"
  }
  
  timerBlocked -m 0 50 Dec 助seBlockedMili 50 //will just decrement 助seBlockedMili (should use -i too to only work when player is nearby?)
  
  GoSub FUNCupdateUses
  GoSub FUNCnameUpdate
  
  showlocals
  ACCEPT
}

On Main { //HeartBeat happens once per second apparently (but may be less often?)
  //Set ΠcriptDebugLog "~ΠcriptDebugLog~;OnMain"
  //starttimer timer2 //^#timer2
  //starttimer timer3 //^#timer3
  //starttimer timer4 //^#timer4
  //stoptimer timer1
  
  if (佝UNCtrapAttack_TrapCanKillMode_OUTPUT == 1) {
    //attractor SELF 1 1000
    GoSub FUNCMakeNPCsHostile //TODO this call wont work from a timer having to happen here? but GoSub FUNCinitDefaults works on init! For some reason, some GoSub work and other wont, just test each then.
  }
  
  if (呆HologramInitialized == 1) {
    if (伶estructionStarted == 1) {
      //attractor SELF 1 3000
      GoSub FUNCaimPlayerCastLightning
      GoSub FUNCMakeNPCsHostile // as NPC may be in-between
      Set ΠcriptDebugProblemTmp "MAIN:BeingDestroyed;" showlocals
      PLAY -s //stops sounds started with -i flag
    } else {
      //////////////// auto repairs the hologram device
      if (^#timer1 == 0) starttimer timer1
      if (^#timer1 > 60000) { //once per minute. if the player waits, it will self fix after a long time.
        if (助seCount != 0) {
          Set 助seRegen 助seMax
          Div 助seRegen 10 //minutes
          Dec 助seCount 助seRegen
          if (助seCount < 0) Set 助seCount 0
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
        if (刨kyMode == 2) { //cubemap
          if(判layingAmbientSoundForSkyMode != 刨kyMode) {
            PLAY -ilp "~ΠkyBoxCurrent~.wav"
            Set 判layingAmbientSoundForSkyMode 刨kyMode
          }
        } else { //uvsphere 1
          if(判layingAmbientSoundForSkyMode != 刨kyMode) {
            PLAY -ilp "~ΠkyBoxCurrentUVS~.wav"
            Set 判layingAmbientSoundForSkyMode 刨kyMode
          }
        }
        //if( ΑoWorldFade != 1 ){
          //worldfade out 1000 0.25 0.25 0.25
          //Set ΠcriptDebugLog "~ΠcriptDebugLog~;OnMain:FadeOut"
          //Set ΑoWorldFade 1
        //}
      } else {
        PLAY -s //stops sounds started with -i flag
        Set 判layingAmbientSoundForSkyMode 0 //reset 
        //if( ΑoWorldFade != 2 ){
          //worldfade in 1000
          //Set ΑoWorldFade 2
        //}
      }
    }
  }
  
  ACCEPT
}

ON COMBINE {
  Set ΠcriptDebugLog "~ΠcriptDebugLog~;OnCombine"
  UnSet ΠcriptDebugCombineFailReason
  showlocals //this is excellent here as any attempt will help showing the log!
  
  // check other (the one that you double click)
  if (^$param1 ISCLASS "Hologram") else ACCEPT //only combine with these
  if (^$param1 !isgroup "DeviceTechBasic") {
    SPEAK -p [player_no] NOP
    Set ΠcriptDebugCombineFailReason "Other:Not:Group:DeviceTechBasic"
    showlocals
    ACCEPT
  }
  
  //check self (the target of the combination request)
  //if (呆HologramInitialized == 0){
    //SPEAK -p [player_no] NOP
    //Set ΠcriptDebugCombineFailReason "Self:NotInitialized"
    //showlocals
    //ACCEPT
  //}
  if (^amount > 1) { //this must not be a stack of items
    SPEAK -p [player_no] NOP
    Set ΠcriptDebugCombineFailReason "Self:IsStack"
    showlocals
    ACCEPT
  }
  if (兌dentified == 0) {
    SPEAK -p [player_not_skilled_enough] NOP
    Set ΠcriptDebugCombineFailReason "Self:NotIdentified"
    showlocals
    ACCEPT
  }
  if (劫rapInitStep > 0) {
    SPEAK -p [player_no] NOP
    Set ΠcriptDebugCombineFailReason "Self:TODO:HoloTeleportArrow"
    showlocals
    ACCEPT
  }
  
  DESTROY ^$PARAM1
  
  PLAY -s //stops sounds started with -i flag
  
  GoSub FUNCskillCheckAncientTech
  Set 低reateChance 佝UNCskillCheckAncientTech_chanceSuccess_OUTPUT
  if ( 利uality >= 4 ) {
    if ( 兌temConditionSure == 5 ) {
      Set 低reateChance 100
    }
  }
  RANDOM 低reateChance {
    RANDOM 5 { // a minimal chance in case the player do not initialize it
      Set 利uality 15 
    }
    if ( 利uality >= 4 ) {
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
    
    Set 刨cale 100 //just in case it is combined with the big hologram on the floor
    SetScale 刨cale
    
    Set 劫rapInitStep 1
    PlayerStackSize 5
    SetGroup -r "DeviceTechBasic"
    SetGroup "Explosive"
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
  //Set ΠcriptDebugLog "~ΠcriptDebugLog~;OnHit:~^durability~/~^maxdurability~"
  //INC 助seCount 30
  //ACCEPT
//}
//on collide_npc { //nothing happens
  //Set ΠcriptDebugLog "~ΠcriptDebugLog~;collide_npc"
  //ACCEPT
//}
//on collision_error { //nothing happens
  //Set ΠcriptDebugLog "~ΠcriptDebugLog~;collision_error"
  //ACCEPT
//}

>>>FUNCaimPlayerCastLightning { //this doesnt work well when called from a timer...
  //Set ΠcriptDebugLog "~ΠcriptDebugLog~;FUNCaimPlayerCastLightning:"
  //ifVisible PLAYER { //use for fireball too? //this doesnt work for objects?
    Set 刪otateYBkp 刪otateY //bkp auto rotate angle speed
    Set 刪otateY 0 //this stops the rotation (but may not stop for enough time tho to let the lightning work properly)
    //forceangle <yaw*> //unnecessary?
    //^angleto_<entity> //unnecessary?
    //forceangle ^angleto_PLAYER //unnecessary?
    //SPELLCAST -smf ^spelllevel lightning_strike PLAYER //this is mainly like a visual effect as it seems to almost always miss the player..
    GoSub FUNCshockPlayer
    //Set ΠcriptDebugLog "~ΠcriptDebugLog~;OnMain:Lightning"
    //Set 刪otateYBkp 刪otateY //bkp auto rotate angle speed
    //Set ΠcriptDebugLog "~ΠcriptDebugLog~;刪otateY=~刪otateY~"
    //Set 刪otateY 0 //this stops the rotation
    ////forceangle <yaw*> //unnecessary?
    ////^angleto_<entity> //unnecessary?
    //forceangle ^angleto_PLAYER
    //Set ΠcriptDebugLog "~ΠcriptDebugLog~;^angleto_PLAYER=~^angleto_PLAYER~"
    //if ( ^#PLAYERDIST <= 500 ) { //this is only to let the player be able to flee as `ifVisible PLAYER` doesnt seem to work from objects (is always not visible right?)
      //DoDamage -lu player ^spelllevel //-u push, extra dmg with push //TODO when the object is rotating and moving, lightning seems to almost always miss making it unreliable even after trying to stop rotation above. So this is a workaround to the lightnings that miss the player, when they start working remove this.
    //}
    timerRestoreRotationSpeed -m 1 100 Set 刪otateY 刪otateYBkp // restore auto rotate speed after the shock has time to be cast
  //}
  //showlocals
  RETURN //to return to wherever it needs?
}

>>FUNCMalfunction {
  Set 刨fxRnd ^rnd_3
  if (刨fxRnd == 0) play "SFX_electric"
  if (刨fxRnd == 1) play "sfx_spark"
  if (刨fxRnd == 2) GoSub FUNCshockPlayer
  RETURN
}

>>FUNCChangeSkyBox { //these '{}' are not necessary but help on code editors
  RANDOM 50 { // skybox cubemap mode
    if (刨kyMode == 1) { //was UVSphere, so hide it
      Set ΠcriptDebugLog "~ΠcriptDebugLog~;From UVSphere to CubeMap"
      Set ΠkyBoxPreviousUVS "~ΠkyBoxCurrentUVS~"
      Set ΠkyBoxCurrentUVS "Hologram.skybox.UVSphere.index3000.Clear"
      TWEAK SKIN "~ΠkyBoxPreviousUVS~" "~ΠkyBoxCurrentUVS~"
    }
    Set ΠkyBoxPrevious "~ΠkyBoxCurrent~" //store current to know what needs to be replaced
    Set 刨kyBoxIndex ^rnd_2 //SED_TOKEN_TOTAL_SKYBOXES_CUBEMAP: to be easy to auto patch, sync with the skyboxes bash script. if rnd_3 will result in 0 1 2
    Set ΠkyBoxCurrent "Hologram.skybox.index~刨kyBoxIndex~" //update current
    if (ΠkyBoxCurrent == "~ΠkyBoxPrevious~") {
      Set ΠcriptDebugLog "~ΠcriptDebugLog~;SBI=~刨kyBoxIndex~"
      GoTo FUNCChangeSkyBox //this looks safe but needs at least 2 skyboxes
    }
    TWEAK SKIN "~ΠkyBoxPrevious~" "~ΠkyBoxCurrent~"
    Set 刨kyMode 2
  } else { //skybox UVSphere mode 1
    if (刨kyMode == 2) { //was CubeMap, so hide it
      Set ΠcriptDebugLog "~ΠcriptDebugLog~;From CubeMap to UVSphere"
      Set ΠkyBoxPrevious "~ΠkyBoxCurrent~"
      Set ΠkyBoxCurrent "Hologram.skybox.index3000.Clear"
      TWEAK SKIN "~ΠkyBoxPrevious~" "~ΠkyBoxCurrent~"
    }
    Set ΠkyBoxPreviousUVS "~ΠkyBoxCurrentUVS~" //store current to know what needs to be replaced
    Set 刨kyBoxIndex ^rnd_9 //SED_TOKEN_TOTAL_SKYBOXES_UVSPHERE: to be easy to auto patch, sync with the skyboxes bash script. if rnd_3 will result in 0 1 2
    Set ΠkyBoxCurrentUVS "Hologram.skybox.UVSphere.index~刨kyBoxIndex~" //update current
    if (ΠkyBoxCurrentUVS == "~ΠkyBoxPreviousUVS~") {
      Set ΠcriptDebugLog "~ΠcriptDebugLog~;SBI(UVS)=~刨kyBoxIndex~"
      GoTo FUNCChangeSkyBox //this looks safe but needs at least 2 skyboxes
    }
    TWEAK SKIN "~ΠkyBoxPreviousUVS~" "~ΠkyBoxCurrentUVS~"
    Set 刨kyMode 1
  }
  //showlocals
  RETURN
}

>>FUNCinitDefaults {
  if(告FUNCMakeNPCsHostile_rangeDefault == 0) {
    Set 告FUNCMakeNPCsHostile_rangeDefault 350 //the spell explosion(chaos) range
    Set 告FUNCMakeNPCsHostile_range 告FUNCMakeNPCsHostile_rangeDefault
  }
  
  TWEAK SKIN "Hologram.skybox.index2000.DocIdentified" "Hologram.skybox.index2000.DocUnidentified"
  TWEAK SKIN "Hologram.tiny.index4000.grenade"         "Hologram.tiny.index4000.grenade.Clear"
  TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow"     "Hologram.tiny.index4000.grenadeGlow.Clear"
  
  //Set 兌dentifyObjectKnowledgeRequirement 35
  Set 助seCount 0
  Set 伶efaultTrapTimoutSec 5
  
  Collision ON //nothing happens?
  Damager -eu 3 //doesnt damage NPCs?
  
  Set ΠcriptDebugLog "~ΠcriptDebugLog~;FUNCinitDefaults"
  showlocals
  
  RETURN
}

>>FUNCMakeNPCsHostile { //params: 告FUNCMakeNPCsHostile_range
  //FAIL: Set ^sender PLAYER ; SendEvent -nr Hit 告FUNCMakeNPCsHostile_range "0.01 summoned" //hits every NPC (-n is default) in 3000 range for 0.01 damage and tells it was the player (summoned sets ^sender to player)
  //FAIL: SendEvent -nr AGGRESSION 告FUNCMakeNPCsHostile_range "" //what params to use here??? // this just make them shake but wont become hostile
  //MakesNoSenseHere: SendEvent -nr STEAL 告FUNCMakeNPCsHostile_range "ON" //works!!!
  //TooMuchHere: SendEvent -nr ATTACK_PLAYER 告FUNCMakeNPCsHostile_range ""
  
  ///////////// GOOD! /////////////
  //SendEvent -nr PLAYER_ENEMY 告FUNCMakeNPCsHostile_range "" //(for goblin at least) this is good, if player is too near it attacks, otherwise only if player is visible
  SendEvent -nr CALL_HELP 告FUNCMakeNPCsHostile_range "" //(for goblin at least) this is good, if player is too near it attacks, otherwise only if player is visible. this also checks if npc is sleeping (therefore wont hear the trap sound)
  //TODO if they hear the trap being armed properly, they should flee instead
  
  //restore defaults for next call "w/o params"
  Set 告FUNCMakeNPCsHostile_range 告FUNCMakeNPCsHostile_rangeDefault 
  RETURN
}

>>FUNCshockPlayer {
  if (^inPlayerInventory == 1) { 
    //TODO is there some way to auto drop the item? if so, this would be unnecessary...
    PLAY "sfx_lightning_loop"
    dodamage -l player 1
  } else {
    ForceAngle ^angleto_PLAYER
    SPELLCAST -smf ^spelllevel LIGHTNING_STRIKE PLAYER //TODO this causes damage? or is just the visual effect?
    Random 25 {
      SPELLCAST -fmsd 250 ^spelllevel PARALYSE PLAYER
    }
    
    //Set 告FUNCMakeNPCsHostile_range 350  //reason: they know it is dangerous to them too.
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
    Set ΓUNCnameUpdate_NameBase "Broken Hologram Device" 
    GoSub FUNCupdateUses
    GoSub FUNCnameUpdate
    
    SetInteractivity NONE
    SpecialFX FIERY
    SPEAK -p [player_picklock_failed] NOP //TODO expectedly just a sound about failure and not about picklocking..
    //SPEAK -p [player_wrong] NOP //TODO expectedly just a sound about failure
    Set 劫mpBreakDestroyMilis 伶efaultTrapTimoutSec
    Mul 劫mpBreakDestroyMilis 1000
    timerTrapBreakDestroy -m 1 劫mpBreakDestroyMilis GoSub FUNCparalyseIfPlayerNearby //the trap tried to capture the player xD //TODOA not working?
    Inc 劫mpBreakDestroyMilis ^rnd_15000
    timerTrapBreakDestroy -m 1 劫mpBreakDestroyMilis GoSub FUNCDestroySelfSafely //to give time to let the player examine it a bit
  }
  showlocals
  RETURN
}

>>FUNCupdateUses {
  Set 助seRemain 助seMax
  Dec 助seRemain 助seCount
  //DO NOT CALL: GoSub FUNCnameUpdate
  if (助seCount >= 助seHologramDestructionStart) Set 助seBlockedMili 0 //quickly lets the player finish/destroy it
  RETURN
}

>>FUNCnameUpdate {
  //OUTPUT: ΓUNCnameUpdate_NameFinal_OUTPUT
  if ( 兌dentified == 0 ) ACCEPT //the player is still not sure about what is going on
  
  GoSub FUNCcalcAncientTechSkill
  
  Set ΓUNCnameUpdate_NameFinal_OUTPUT "~ΓUNCnameUpdate_NameBase~."
  
  if ( 呆HologramInitialized == 1 ) {
    // condition from 0.00 to 1.00
    //DO NOT CALL BECOMES ENDLESS RECURSIVE LOOP: GoSub FUNCupdateUses
    //Set ΠcriptDebugLog "~ΠcriptDebugLog~;FUNCnameUpdate"
    Set @ItemCondition 助seRemain
    //Set ΠcriptDebugLog "~ΠcriptDebugLog~;~@ItemCondition~=~助seRemain~"
    Div @ItemCondition 助seMax
    //Set ΠcriptDebugLog "~ΠcriptDebugLog~;/~助seMax~=~@ItemCondition~"
    
    //TODO why the below wont work? it is always bad or critical...
    //if      ( @ItemCondition >= 0.80 ) { Set ΖtemConditionDesc "excellent" }
    //else if ( @ItemCondition >= 0.60 ) { Set ΖtemConditionDesc "good"      }
    //else if ( @ItemCondition >= 0.40 ) { Set ΖtemConditionDesc "average"   }
    //else if ( @ItemCondition >= 0.20 ) { Set ΖtemConditionDesc "bad"       }
    //else {                               Set ΖtemConditionDesc "critical"  }
    Set @ItemConditionSureTmp @ItemCondition
    Mul @ItemConditionSureTmp 10 //0-10
    Div @ItemConditionSureTmp  2 //0-5
    Set 兌temConditionSure @ItemConditionSureTmp //trunc
    if ( 兌temConditionSure == 5 ) Set ΖtemConditionDesc "perfect"
    if ( 兌temConditionSure == 4 ) Set ΖtemConditionDesc "excellent"
    if ( 兌temConditionSure == 3 ) Set ΖtemConditionDesc "good"
    if ( 兌temConditionSure == 2 ) Set ΖtemConditionDesc "average"
    if ( 兌temConditionSure == 1 ) Set ΖtemConditionDesc "bad"
    if ( 兌temConditionSure == 0 ) Set ΖtemConditionDesc "critical"
    
    // perc
    Set @ItemConditionTmp @ItemCondition
    Mul @ItemConditionTmp 100
    Set ΠcriptDebugLog "~ΠcriptDebugLog~;*100=~@ItemCondition~"
    Set 兌temConditionPercent @ItemConditionTmp //trunc
    
    //TODO this always fails too, is always dreadful...
    //if(助seMax >  105) Set ΖtemQuality "pristine" else //105 (and not 100) means a more perceptible superiority
    //if(助seMax >=  80) Set ΖtemQuality "superior" else
    //if(助seMax >=  60) Set ΖtemQuality "decent"   else
    //if(助seMax >=  40) Set ΖtemQuality "mediocre" else
    //if(助seMax >=  20) Set ΖtemQuality "inferior" else
    //{                  Set ΖtemQuality "dreadful" }
    if (助seMax >= 95) {
      Set 利uality 5
    } else {
      Set 利uality 助seMax
      Div 利uality 10
      Div 利uality  2
    }
    if(利uality >= 5) Set ΖtemQuality "pristine+"
    if(利uality == 4) Set ΖtemQuality "superior+"
    if(利uality == 3) Set ΖtemQuality "decent"
    if(利uality == 2) Set ΖtemQuality "mediocre"
    if(利uality == 1) Set ΖtemQuality "inferior"
    if(利uality == 0) Set ΖtemQuality "dreadful"
    
    if(@AncientTechSkill >= 20) Set ΓUNCnameUpdate_NameFinal_OUTPUT "~ΓUNCnameUpdate_NameFinal_OUTPUT~ Quality:~ΖtemQuality~." //useful to chose wich one to keep
    if(@AncientTechSkill >= 35) Set ΓUNCnameUpdate_NameFinal_OUTPUT "~ΓUNCnameUpdate_NameFinal_OUTPUT~ Condition:~ΖtemConditionDesc~." //useful to hold your hand avoiding destroy it
    if(@AncientTechSkill >= 50) Set ΓUNCnameUpdate_NameFinal_OUTPUT "~ΓUNCnameUpdate_NameFinal_OUTPUT~ ~兌temConditionPercent~% ~助seCount~/~助seMax~ Remaining ~助seRemain~." //detailed condition for nerds ;)
  } else {
    Set ΓUNCnameUpdate_NameFinal_OUTPUT "~ΓUNCnameUpdate_NameFinal_OUTPUT~ (Not initialized)."
  }
  
  //SetName "~ΓUNCnameUpdate_NameBase~. Quality:~ΖtemQuality~, Condition:~ΖtemConditionDesc~(~兌temConditionPercent~%), Uses:Count=~助seCount,Remain=~助seRemain~,Max=~助seMax~"
  SetName "~ΓUNCnameUpdate_NameFinal_OUTPUT~"
  //Set @TestFloat 0.1
  //Set @TestFloat2 0.999999
  //Set 劫estInt2 @TestFloat2
  //Set @TestFloat3 0.3
  //Mul @TestFloat3 0.5 //0.15
  //Set @TestFloat4 0.8
  //Div @TestFloat4 2 //0.4
  //Set @TestFloat5 0.3
  //Mul @TestFloat5 100 //30
  //Set 劫estInt5 @TestFloat5
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
  //  佝UNCskillCheckAncientTech_chanceSuccess_OUTPUT
  //  佝UNCskillCheckAncientTech_chanceFailure_OUTPUT
  //  佝UNCskillCheckAncientTech_bonus_OUTPUT
  
  GoSub FUNCcalcAncientTechSkill
  
  Set 佝UNCskillCheckAncientTech_chanceSuccess_OUTPUT @AncientTechSkill
  if (佝UNCskillCheckAncientTech_chanceSuccess_OUTPUT <  5) Set 佝UNCskillCheckAncientTech_chanceSuccess_OUTPUT  5 //minimal success chance
  if (佝UNCskillCheckAncientTech_chanceSuccess_OUTPUT > 95) Set 佝UNCskillCheckAncientTech_chanceSuccess_OUTPUT 95 //minimal fail chance
  
  Set 佝UNCskillCheckAncientTech_chanceFailure_OUTPUT 100
  Dec 佝UNCskillCheckAncientTech_chanceFailure_OUTPUT 佝UNCskillCheckAncientTech_chanceSuccess_OUTPUT
  
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
  //INPUT: 佝UNCtrapAttack_TrapMode 0=explosion 1=projectile/targetPlayer
  //INPUT: 佝UNCtrapAttack_TrapTimeSec in seconds (not milis)
  SendEvent GLOW SELF "" //TODO this makes facetype glow unnecessary?
  
  SetGroup "DeviceTechExplosionActivated"
  SetGroup "Explosive"
  
  PLAY "TRAP"
  PLAY "POWER"
  
  Set 佝UNCtrapAttack_TrapCanKillMode_OUTPUT 1 //this calls FUNCMakeNPCsHostile at main() heartbeat
  
  //attractor SELF 1 1000 //makes it a bit difficult for the player to run away
  
  GoSub FUNCMakeNPCsHostile
  
  // random trap
  Set 佝UNCtrapAttack_TrapTimeSec 伶efaultTrapTimoutSec //must be seconds (not milis) to easify things below like timer count and text
  timerTrapTime     佝UNCtrapAttack_TrapTimeSec 1 Dec 佝UNCtrapAttack_TrapTimeSec 1
  timerTrapTimeName 佝UNCtrapAttack_TrapTimeSec 1 SetName "Holo-Grenade Activated (~佝UNCtrapAttack_TrapTimeSec~s)"
  //timerTrapAttack  -m 0  100 GoSub FUNCMakeNPCsHostile //doesnt work
  
  Set 劫rapEffectTime 0
  if (佝UNCtrapAttack_TrapMode == 0) { //explosion around self
    Set 劫mpTrapKind ^rnd_5
    if (劫mpTrapKind == 0) timerTrapAttack 1 佝UNCtrapAttack_TrapTimeSec SPELLCAST -smf ^spelllevel explosion  SELF
    if (劫mpTrapKind == 1) timerTrapAttack 1 佝UNCtrapAttack_TrapTimeSec SPELLCAST -smf ^spelllevel fire_field SELF
    if (劫mpTrapKind == 2) timerTrapAttack 1 佝UNCtrapAttack_TrapTimeSec SPELLCAST -smf ^spelllevel harm       SELF
    if (劫mpTrapKind == 3) timerTrapAttack 1 佝UNCtrapAttack_TrapTimeSec SPELLCAST -smf ^spelllevel ice_field  SELF
    if (劫mpTrapKind == 4) timerTrapAttack 1 佝UNCtrapAttack_TrapTimeSec SPELLCAST -smf ^spelllevel life_drain SELF
    //this cause no damage? //if (劫mpTrapKind == 5) timerTrapAttack  -m 1 5000 SPELLCAST -smf ^spelllevel mass_incinerate SELF
    Unset 劫mpTrapKind
    Set 劫rapEffectTime 2 //some effects have infinite time and then will last 2s (from 5000 to 7000) like explosion default time, as I being infinite would then last 0s as soon this entity is destroyed right?
  }
  if (佝UNCtrapAttack_TrapMode == 1) { //projectile at player
    timerTrapAttack 1 佝UNCtrapAttack_TrapTimeSec GoSub FUNCchkAndAttackProjectile
  }  
  
  timerTrapVanish       1 佝UNCtrapAttack_TrapTimeSec TWEAK SKIN "Hologram.tiny.index4000.grenade" "alpha"
  timerTrapVanishActive 1 佝UNCtrapAttack_TrapTimeSec TWEAK SKIN "Hologram.tiny.index4000.grenadeActive" "alpha"
  timerTrapVanishGlow   1 佝UNCtrapAttack_TrapTimeSec TWEAK SKIN "Hologram.tiny.index4000.grenadeGlow" "alpha"
  
  // trap effect time
  Set 劫mpTrapDestroyTime 佝UNCtrapAttack_TrapTimeSec
  Inc 劫mpTrapDestroyTime 劫rapEffectTime
  timerTrapDestroy 1 劫mpTrapDestroyTime GoSub FUNCDestroySelfSafely 
  
  showlocals
  // unset after log
  //Unset 劫mpTrapDestroyTime //DO NOT UNSET OR IT WILL BREAK THE TIMER!!!
  
  //restore defaults for next call "w/o params"
  Set 佝UNCtrapAttack_TrapMode 0
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
  TWEAK SKIN "ΠkyBoxCurrent" "alpha"
  TWEAK SKIN "ΠkyBoxCurrentUVS" "alpha"
  RETURN
}

>>FUNCchkAndAttackProjectile {
  if ( ^#PLAYERDIST > 告FUNCMakeNPCsHostile_rangeDefault ) ACCEPT //the objective is to protect NPCs that did not get alerted by the player aggressive action
  Set 劫mpTrapKind ^rnd_6
  if (劫mpTrapKind == 0) SPELLCAST -smf ^spelllevel FIREBALL              PLAYER
  if (劫mpTrapKind == 1) SPELLCAST -smf ^spelllevel FIRE_PROJECTILE       PLAYER
  if (劫mpTrapKind == 2) SPELLCAST -smf ^spelllevel ICE_PROJECTILE        PLAYER
  if (劫mpTrapKind == 3) SPELLCAST -smf ^spelllevel MAGIC_MISSILE         PLAYER
  if (劫mpTrapKind == 4) SPELLCAST -smf ^spelllevel MASS_LIGHTNING_STRIKE PLAYER
  if (劫mpTrapKind == 5) SPELLCAST -smf ^spelllevel POISON_PROJECTILE     PLAYER
  //if (劫rapKind == 0) SPELLCAST -smf ^spelllevel LIGHTNING_STRIKE PLAYER //too weak
  Unset 劫mpTrapKind
  RETURN
}

>>FUNCparalyseIfPlayerNearby { //TODOA is this working?
  if ( ^#PLAYERDIST < 500 ) {
    Set 劫mpParalyseMilis 3000
    Inc 劫mpParalyseMilis ^rnd_6000
    SPELLCAST -fmsd 劫mpParalyseMilis ^spelllevel PARALYSE PLAYER
  }
  RETURN
}

>>FUNCDestroySelfSafely {
  PLAY -s //stops sounds started with -i flag
  DESTROY SELF
  RETURN
}
