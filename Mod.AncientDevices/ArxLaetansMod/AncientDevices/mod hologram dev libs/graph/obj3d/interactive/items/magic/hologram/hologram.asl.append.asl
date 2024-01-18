/**
 * Copyright 2024 <https://github.com/Gussak>
 * 
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * 
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * 
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// INFO: to use this lib in your mod, rename this file and the parent paths to match your mod's name and location!

>>TFUNCshowlocals () { GoSub FUNCshowlocals ACCEPT } >>FUNCshowlocals ()  { //no £_aaaDebugScriptStackAndLog. this func is to easy disable showlocals.
	//INPUT: [§«force] 0=nothing 1=locals 2=globals(+locals) 3=always
	//INPUT: [£«filter] log will only show if filter is set
	//obs.: change G_HologCfgOpt_ShowLocals to your mod cfg var that can be enabled thru some action in game
	//ex.: GoSub -p FUNCshowlocals §»force=1 £»filter="testLocalVarName" ;
	//ex.: Set £FUNCshowlocals«filter "testLocalVarName"	GoSub -p FUNCshowlocals §»force=1 ; //to set before GoSub call
	//ex.: GoSub -p FUNCshowlocals §»force=2 £»filter="testGlobalVarName" ; //but matching names at local vars will show too
	//ex.: GoSub -p FUNCshowlocals §»force=3 ; // overkill, will show everything
	
	if(and(£«filter == "" && §«force < 3)) { // only allow force if filter is set, or if force is high >=3
		Set §«force 0
	}
	//Set §«force 0 //UNCOMMENT_ON_RELEASE as even with filters, this is about debugging the script. This override forces release to show nothing. the end user needs to comment this line to see such logs
	
	if(§«force >= 2) {
		showvars -f £«filter
	} else { if(or(&G_HologCfgOpt_ShowLocals == 21.1 || §«force >= 1)) {
		showlocals -f £«filter
	}	}
	
	//defaults for next call
	Set §«force 0
	Set £«filter ""
	RETURN
}

>>FUNCCustomCmdsB4DbgBreakpoint () {
	//INPUT: [£«DbgMsg]
	//INPUT: [£«filter] use ".*" regex to show all. the default filter will show all vars from the caller function
	
	if(£«DbgMsg != "") {
		Set £DebugMessage £«DbgMsg // £DebugMessage is detected by ScriptUtils.cpp::DebugBreakpoint()
	} else {
		Set £DebugMessage "(no helpful info was set)"
	}
	
	if(£«filter == "") {
		Set £«filter ^debugcalledfrom_1
	} else {
		Set £«filter "~£«filter~|~^debugcalledfrom_1~"// all vars from the caller function
	}
	
	Set £«filter "~£«filter~|~^debugcalledfrom_0~" // show also FUNCCustomCmdsB4DbgBreakpoint vars
	
	showvars -f "~£«filter~"
	
	GoSub FUNCDebugBreakpoint
	
	//reset to defaults b4 next call
	Set £«DbgMsg ""
	Set £«filter ""
	RETURN
}

/**
 * a GoSubTo target with "DebugBreakpoint" in it's name is (ignore case) detected by the cpp code, 
 * so it only works in debug mode and with a breakpoint placed there at:
 * 	src/script/ScriptUtils.cpp::DebugBreakpoint() at iDbgBrkPCount++
 */
>>FUNCDebugBreakpoint () { RETURN }
