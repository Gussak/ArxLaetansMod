>>FUNCtestModOverride () {
	//create this cfg file and paste test.mod.override.holog there: 
	//  ArxLibertatis/mods/modloadorder.cfg
	//create this mod file, place this function test.mod.override.holog there and change the "original" text to something else:
	//  ArxLibertatis/mods/test.mod.override.holog/graph/obj3d/interactive/items/magic/hologram/hologram.asl.override.asl
	Set £TestModOverride "applied override2" //change this on the overrider !
	++ §testsPerformed
	Set £TestsCompleted "~£TestsCompleted~, FUNCtestModOverride"
	RETURN
}
