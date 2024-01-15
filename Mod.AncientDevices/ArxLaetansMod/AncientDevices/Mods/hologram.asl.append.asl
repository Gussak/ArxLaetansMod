/*
///////////////////////////////////////////
// by Gussak (https://github.com/Gussak) //
///////////////////////////////////////////
__
//////////////// TESTS /////////////////
 This file contains tests to all new functionalities.
 TODO: short simplified usage examples with all possible options
*/

>>TFUNCtestArithmetics () { GoSub FUNCtestArithmetics ACCEPT } >>FUNCtestArithmetics () {
	Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;FUNCtestArithmetics"
	Set @testAriFloat 2
	Set §testAriInt 2
	NthRoot @testAriFloat §testAriInt //1.41...
	Add §testAriInt 1
	Set @testAriFloat3 2 //
	NthRoot @testAriFloat3 §testAriInt //
	Set @testAriFloat4 -2
	NthRoot @testAriFloat4 2 //-1.41...
	Sub §testAriInt 1
	Set @testAriFloat2 2
	Pow @testAriFloat2 3 //8
	++ §testsPerformed
	Set £TestsCompleted "~£TestsCompleted~, ~^debugcalledfrom_0~"
	RETURN
}
>>FUNCtestCalcNesting () {
	Set @testCalcVar 3.71
	Calc @testCalcNesting10 [ -7.126 ]
	Calc @testCalcNesting20 [ -7.126 - 6 ]
	Calc @testCalcNesting30 [ -7.126 + 6 ]
	Calc @testCalcNesting40 [ 8.5 / 2 ]
	Calc @testCalcNesting50 [ 8.5 * 2 ]
	Calc @testCalcNesting60 [ 10 ^ 2 ]
	Calc @testCalcNesting70 [ 2 ^ 0.5 ]
	Calc @testCalcNesting75 [ 2 ^ [ 1 / 2 ] ]
	Calc @testCalcNesting80 [ -7.126 + [ [ @testCalcVar ^ [ 1 / 3 ] ] * 32 ] % [ 2 ^ 2 ] ] //should be 2,412320834, check in gnome-calculator: int(-7,126+((3,71^(1/3))*32)) mod (2^2) ; but wont give float result there as remainder requires integer in calculators, so put this there: -7,126+((3,71^(1/3))*32) ; here std::fmod() is used!
	Calc @testCalcNesting90 [ 
		-7.126 //test multiline and comment
		+ [ 
				[ 
					@testCalcVar ^ [ 1 / 3 ] ] 
					* // testing..
					32 
				] % [ 2 ^ 2 ] 
		]
	++ §testsPerformed
	Set £TestsCompleted "~£TestsCompleted~, ~^debugcalledfrom_0~"
	RETURN
}
>>TFUNCtestPrintfFormats () { GoSub FUNCtestPrintfFormats ACCEPT } >>FUNCtestPrintfFormats () {
	Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;FUNCtestPrintfFormats"
	Set @testFloat 78.12345
	Set §testInt 513
	Set £testString "foo"
	//some simple printf formats
	Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;float:~%020.6f,@testFloat~"
	Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;hexa:0x~%08X,§testInt~"
	Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;decimalAlignRight:~%8d,§testInt~"
	Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;string='~%10s,£testString~'"
	++ §testsPerformed
	Set £TestsCompleted "~£TestsCompleted~, ~^debugcalledfrom_0~"
	RETURN
}
>>TFUNCtestLogicOperators () { GoSub FUNCtestLogicOperators ACCEPT } >>FUNCtestLogicOperators () {
	Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;FUNCtestLogicOperators"
	
	Set @testFloat 1.5 //dont change!
	Set §testInt 7 //dont change!
	Set £testString "foo" //dont change!
	
	// OK means can appear on the £ScriptDebug________________Tests. WRONG means it should not have appeared.
	if(and(@testFloat == 1.5 && §testInt == 7 && £testString == "foo")){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;A1=ok"
	} else GoSub FUNCCustomCmdsB4DbgBreakpoint
	if(and(@testFloat == 1.5 && §testInt == 7 && £testString == "foo1")){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;A2=WRONG"
		GoSub FUNCCustomCmdsB4DbgBreakpoint
	}
	if(and(@testFloat == 1.5 && §testInt != 7 && £testString == "foo")){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;A3=WRONG"
		GoSub FUNCCustomCmdsB4DbgBreakpoint
	}
	if(and(@testFloat != 1.5 && §testInt == 7 && £testString == "foo")){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;A4=WRONG"
		GoSub FUNCCustomCmdsB4DbgBreakpoint
	}
	// test without block delimiters { }
	if(and(@testFloat == 1.5 && §testInt == 7 && £testString == "foo"))
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;A11=ok"
	else GoSub FUNCCustomCmdsB4DbgBreakpoint
	if(and(@testFloat == 1.5 && §testInt == 7 && £testString == "foo1"))
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;A12=WRONG"
	if(and(@testFloat == 1.5 && §testInt != 7 && £testString == "foo"))
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;A13=WRONG"
	if(and(@testFloat != 1.5 && §testInt == 7 && £testString == "foo"))
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;A14=WRONG"
	
	// not(!)
	if(not(and(@testFloat == 1.5 && §testInt == 7 && £testString == "foo"))) {
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;b11=WRONG"
		GoSub FUNCCustomCmdsB4DbgBreakpoint
	}
	if(not(and(@testFloat == 1.5 && §testInt == 7 && £testString != "foo"))) {
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;b12=ok"
	} else GoSub FUNCCustomCmdsB4DbgBreakpoint
	if(not(and(@testFloat == 1.5 && §testInt != 7 && £testString == "foo"))) {
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;b13=ok"
	} else GoSub FUNCCustomCmdsB4DbgBreakpoint
	if(not(and(@testFloat != 1.5 && §testInt == 7 && £testString == "foo"))) {
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;b14=ok"
	} else GoSub FUNCCustomCmdsB4DbgBreakpoint
	
	// or nor
	if(or(@testFloat == 1.5 , §testInt == 7 , £testString == "foo")){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;c1=ok"
	} else GoSub FUNCCustomCmdsB4DbgBreakpoint
	if(not(or(@testFloat == 1.5 || §testInt != 7 || £testString == "foo1"))){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;c2=WRONG"
		GoSub FUNCCustomCmdsB4DbgBreakpoint
	}
	if(not(or(@testFloat != 1.5 || §testInt == 7 || £testString == "foo"))){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;c3=WRONG"
		GoSub FUNCCustomCmdsB4DbgBreakpoint
	}
	if(not(or(@testFloat != 1.5 || §testInt != 7 || £testString == "foo"))){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;c3b=WRONG"
		GoSub FUNCCustomCmdsB4DbgBreakpoint
	}
	if(or(@testFloat != 1.5 || §testInt != 7 || £testString == "foo")){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;c4=ok"
	} else GoSub FUNCCustomCmdsB4DbgBreakpoint
	
	if(and(@testFloat == 1.5 && §testInt == 7 && £testString == "foo")){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;e1=ok"
	} else GoSub FUNCCustomCmdsB4DbgBreakpoint
	if(not(and(@testFloat != 1.5 && §testInt == 7 && £testString == "foo"))){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;e1b=ok"
	} else GoSub FUNCCustomCmdsB4DbgBreakpoint
	if(or(@testFloat != 1.5 || §testInt != 7 || £testString == "foo")){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;e2=ok"
	} else GoSub FUNCCustomCmdsB4DbgBreakpoint
	if(not(or(@testFloat != 1.5 || §testInt != 7 || £testString != "foo"))){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;e2b=ok"
	} else GoSub FUNCCustomCmdsB4DbgBreakpoint
	if(and(@testFloat != 1.5 && §testInt == 7 && £testString == "foo")){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;e3=wrong"
		GoSub FUNCCustomCmdsB4DbgBreakpoint
	}
	if(not(and(@testFloat == 1.5 && §testInt == 7 && £testString == "foo"))){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;e3b=wrong"
		GoSub FUNCCustomCmdsB4DbgBreakpoint
	}
	if(or(@testFloat != 1.5 || §testInt != 7 || £testString != "foo")){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;e4=wrong"
		GoSub FUNCCustomCmdsB4DbgBreakpoint
	}
	if(not(or(@testFloat == 1.5 || §testInt != 7 || £testString != "foo"))){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;e4b=wrong"
		GoSub FUNCCustomCmdsB4DbgBreakpoint
	}
	
	// nesting and multiline conditions
	if(or( @testFloat != 1.5 || §testInt != 7 || and(£testString == "foo" && §testInt == 7); )){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;d1a=ok"
	} else GoSub FUNCCustomCmdsB4DbgBreakpoint
	
	if( or( @testFloat != 1.5 || §testInt != 7 || and(£testString == "foo" && §testInt != 7); || not(or(@testFloat != 1.5 || §testInt != 7 || £testString != "foo");) ) ){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;d1b=ok"
	} else GoSub FUNCCustomCmdsB4DbgBreakpoint
	
	if(or(
		@testFloat != 1.5 || 
		§testInt   != 7   || 
		and(£testString == "foo" && §testInt != 7); ||
		not(or(@testFloat != 1.5 || §testInt != 7 || £testString != "foo");)
	)){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;d1b2=ok"
	} else GoSub FUNCCustomCmdsB4DbgBreakpoint
	
	if(not(or(
		@testFloat != 1.5 || 
		§testInt != 7     || 
		and(£testString == "foo" && §testInt != 7); ||
		not(or(@testFloat != 1.5 || §testInt != 7 || £testString != "foo");)
	))){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;d1b3=WRONG"
		GoSub FUNCCustomCmdsB4DbgBreakpoint
	}
	
	//todo review below, not working yet
	if(or(
		@testFloat != 1.5 ||
		§testInt   != 7   ||
		and(£testString == "foo" && §testInt != 7); ||
		not(or(@testFloat != 1.5 || §testInt != 7 || £testString == "foo");) ||
		not(and(@testFloat == 1.5 , §testInt != 7 , £testString == "foo");)
	)){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;d2=ok"
	} else GoSub FUNCCustomCmdsB4DbgBreakpoint

	if(or(
		@testFloat != 1.5 ||
		§testInt   != 7   ||         //
		and(£testString == "foa" && §testInt == 7); || //"foa" is wrong, used like that to help debug only here
		not(or (@testFloat != 1.5 || §testInt == 7 || £testString == "fob");) || //"fob" is wrong, used like that to help debug only here
		not(and(@testFloat == 1.5  , §testInt == 7  , £testString == "foc");) //this ends up as true //"foc" is wrong, used like that to help debug only here
	)){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;d2b=ok"
	} else GoSub FUNCCustomCmdsB4DbgBreakpoint
	
	if(or(
		@testFloat != 1.5 ||
		§testInt   != 7   ||
		and( //nice comment
			£testString == "foo" &&
			§testInt != 7       
		); ||      
		not(or( //nicier comment
			@testFloat != 1.5 || §testInt != 7 || £testString == "foo"
		);) ||
		not(and(
			@testFloat == 1.5 , 
			§testInt != 7 , 
			£testString == "foo" );)
	)){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;d2c=ok"
	} else GoSub FUNCCustomCmdsB4DbgBreakpoint
	
	//Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;Multiline_LogicOper_begin"
	if(
		or(
				@testFloat != 1.5 ||
				§testInt   != 7   ||
				and(
						£testString == "foo"
						&&
						§testInt != 7
				); ||
				not(or(  @testFloat != 1.5 || §testInt != 7 || £testString == "foo" );) ||
				not(and( @testFloat == 1.5  , §testInt != 7  , £testString == "foo" );)
		)
	){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;d3b=ok"
	} else GoSub FUNCCustomCmdsB4DbgBreakpoint
	
	if(or(      @testFloat != 1.5 ||       §testInt != 7    ||       and(        £testString == "foo"         &&         §testInt != 7       ); ||      not(or(@testFloat != 1.5 || §testInt != 7 || £testString == "foo");) ||      not(and(@testFloat == 1.5 , §testInt == 7 , £testString == "foo");) )){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;d3c2=WRONG"
		GoSub FUNCCustomCmdsB4DbgBreakpoint
	}
	if(
		or(
				@testFloat != 1.5 ||
				§testInt   != 7   ||
				and(
						£testString == "foa"
						&&
						§testInt == 7
				); ||
				not(or(  @testFloat != 1.5 || §testInt == 7 || £testString == "fob" );) ||
				not(and( @testFloat == 1.5  , §testInt == 7  , £testString == "foo" );)
		);
	){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;d3c3=WRONG"
		GoSub FUNCCustomCmdsB4DbgBreakpoint
	}
	
	//Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;Multiline_LogicOper_3"
	if(
		or(
				@testFloat != 1.5 ||
				§testInt   != 7   ||
				and(
						£testString == "foo"
						&&
						§testInt != 7
				); ||
				not(or( @testFloat != 1.5 || §testInt != 7 || £testString == "foo");) ||
				not(and(@testFloat == 1.5  , §testInt == 7  , £testString == "foo");)
		)
	){
		Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;d4=WRONG"
		GoSub FUNCCustomCmdsB4DbgBreakpoint
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
	Set £TestsCompleted "~£TestsCompleted~, ~^debugcalledfrom_0~"
	RETURN
}
>>TFUNCtestDistAbsPos () { GoSub FUNCtestDistAbsPos ACCEPT } >>FUNCtestDistAbsPos () {
	Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;FUNCdistAbsPos"
	// distance to absolute locations
	Set §testDistAbsolute ^dist_[0,0,0]
	Set @testDistAbsolute2 ^dist_[1000.123,2000.56,3000]
	Set §testAbsX 5000
	Set @testAbsY 500.45
	Set @testAbsZ 500.45
	Set @testDistAbsolute3  ^dist_[~§testAbsX~,~@testAbsY~,~§testAbsZ~]
	Set §testDistAbsolute4  ^dist_[~^locationx_player~,~^locationy_player~,~^locationz_player~]
	Set @testDistAbsolute4b ^dist_[~^locationx_player~,~^locationy_player~,~^locationz_player~]
	//Set @testDistAbsolute4b ^dist_"{~^locationx_player~,~^locationy_player~,~^locationz_player~}" //rm tests the warn msg with line and column about unexpected "
	++ §testsPerformed
	Set £TestsCompleted "~£TestsCompleted~, ~^debugcalledfrom_0~"
	RETURN
}
>>TFUNCtestElseIf () { GoSub FUNCtestElseIf ACCEPT } >>FUNCtestElseIf () {
	Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;FUNCtestElseIf"
	++ §test
	if ( §test == 1 ) {
		Set £work "~£work~;~§test~:ok1"
	} else {
	if ( §test == 2 ) {
		Set £work "~£work~;~§test~:ok2"
	} else {
	if ( §test == 3 ) {
		Set £work "~£work~;~§test~:ok3"
	} else { 
		Set £work "~£work~;~§test~:okElse"
	}  }  }
	++ §testsPerformed
	Set £TestsCompleted "~£TestsCompleted~, ~^debugcalledfrom_0~"
	GoSub FUNCshowlocals
	RETURN
}
>>TFUNCtestDegrees () { GoSub FUNCtestDegrees ACCEPT } >>FUNCtestDegrees () {
	Set £ScriptDebug________________Tests "~£ScriptDebug________________Tests~;FUNCtestDegrees"
	
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
	
	++ §testsPerformed
	Set £TestsCompleted "~£TestsCompleted~, ~^debugcalledfrom_0~"
	RETURN
}
>>FUNCtestCallStack1 () {
	GoSub FUNCtestCallStack2
	RETURN
}
>>FUNCtestCallStack2 () {
	GoSub FUNCtestCallStack3
	RETURN
}
>>FUNCtestCallStack3 () {
	GoSub FUNCtestCallStack4
	RETURN
}
>>FUNCtestCallStack4 () {
	Set £TestsCompleted "~£TestsCompleted~, ~^debugcalledfrom_0~"
	++ §testsPerformed
	//showvars //showlocals
	GoSub -p FUNCshowlocals §force=1 ;
	//Set £DebugMessage "~£DebugMessage~ test break point in deep call stack.\n yes works to stop the engine by creating a system popup!"	GoSub FUNCCustomCmdsB4DbgBreakpoint // keep commented
	RETURN
}
>>FUNCtestAsk () {
	Set £TestAsk "123 abc"
	ask "test or not?" £TestAsk
	++ §testsPerformed
	Set £TestsCompleted "~£TestsCompleted~, ~^debugcalledfrom_0~"
	RETURN
}
>>FUNCtestModOverride () {
	//create this cfg file and paste test.mod.override.holog there: 
	//  ArxLibertatis/mods/modloadorder.cfg
	//create this mod file, place this function test.mod.override.holog there and change the "original" text to something else:
	//  ArxLibertatis/mods/test.mod.override.holog/graph/obj3d/interactive/items/magic/hologram/hologram.asl.override.asl
	Set £TestModOverride "original" //change this on the overrider !
	++ §testsPerformed
	Set £TestsCompleted "~£TestsCompleted~, ~^debugcalledfrom_0~"
	RETURN
}
>>FUNCtestModPatch () {
	Set £TestModPatch "original" //change to "patched" at the diff's patch file !
	++ §testsPerformed
	Set £TestsCompleted "~£TestsCompleted~, ~^debugcalledfrom_0~"
	RETURN
}
>>FUNCtestSwapMultilineComment () {
/* this test WRONG lines with less than 2 chars available to be fixed: put an empty line and another with 1 char only.

1
this tests a WRONG closure with code after it (put some comment after the closure, or hit del to bring the one below) */
	Set @TestError 1.23
	
	/* the trick is: comment this line with //, it will enable "a" section and disable "b" section
	Set £TestSwapMultilineComment "a"
	/*/
	Set £TestSwapMultilineComment "b"
	//*/
	++ §testsPerformed
	Set £TestsCompleted "~£TestsCompleted~, ~^debugcalledfrom_0~"
	RETURN
}
>>FUNCtestStrParam () {
	GoSub -p FUNCshowlocals £filter="~^debugcalledfrom_1~" §force=1 ;
	++ §testsPerformed
	Set £TestsCompleted "~£TestsCompleted~, ~^debugcalledfrom_0~"
	RETURN
}
>>TFUNCtests () { GoSub FUNCtests ACCEPT } >>FUNCtests () {
	//GoSub FUNCtestDegrees showlocals
	if(^degreesx_player > 300) { //301 is the maximum Degrees player can look up is that
		//TODO put this on CircularOptionChoser
		//++ #FUNCshowlocals_enabled	if(#FUNCshowlocals_enabled > 1) Set #FUNCshowlocals_enabled 0
		if(&G_HologCfgOpt_ShowLocals == 21.1) { //TODOA use CFUNCconfigOptionToggle instead
			Set &G_HologCfgOpt_ShowLocals 21.0
		} else {
			Set &G_HologCfgOpt_ShowLocals 21.1
		}
		GoSub FUNCshowlocals
	}
	
	//if(^degreesx_player == 74.9) { //minimum Degrees player can look down is that
	if(^degreesx_player < 75) { // 74.9 is the minimum Degrees player can look down is that
		//TODO put this on CircularOptionChoser
		
		//fail teleport -pi //tele the player to its starting spawn point
		//Set @TstDistToSomeFixedPoint ^RealDist_PRESSUREPAD_GOB_0022 //this gives a wrong(?) huge value..
		//Set @TstDistToSomeFixedPoint ^Dist_PRESSUREPAD_GOB_0022 //this doesnt seem to work, the value wont change..
		//Set §TstDistToSomeFixedPoint @TstDistToSomeFixedPoint
		
		Rotate -a 0 0 0
		
		Set £ScriptDebug________________Tests "FUNCtests"
		Set §testsPerformed 0
		Set §testsEnded 0
		Set £TestsCompleted ""
		GoSub FUNCtestDistAbsPos
		GoSub FUNCtestPrintfFormats
		GoSub FUNCtestElseIf
		GoSub FUNCtestDegrees
		GoSub FUNCtestArithmetics
		GoSub FUNCtestLogicOperators
		GoSub FUNCtestCallStack1 //test for PR_WarnMsgShowsGotoGosubCallStack
		GoSub FUNCtestCalcNesting
		GoSub FUNCtestAsk
		GoSub FUNCtestModOverride
		GoSub FUNCtestModPatch
		GoSub -p FUNCtestStrParam £test="a b" £simple2=AsDf £simple="hologram.tiny.index4000.boxconfigoptions" £filter=".*(identified|stack).*" §force=1 ;
		
		Set §testsEnded 1
		GoSub -p FUNCshowlocals §force=1 ;
	}
	 
	GoSub FUNCshowlocals
	RETURN
}
