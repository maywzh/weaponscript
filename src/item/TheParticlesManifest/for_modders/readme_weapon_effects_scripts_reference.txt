Urik: there used to be long and confusing explanation here, but I'll spare your time and try to cut it short.

The only legal way to have a custom THIRD PERSON effect per gun is to modify the weapon script.
( I guess you know that it sometimes causes trouble joining some online servers due to sv_consistency check denial, but it's a something we have to live with )

There are fields "MuzzleFlashEffect_1stPerson" and "MuzzleFlashEffect_3rdPerson" which are responsible for 1st and 3rd person effects respectively:

( the following example from weapon_pistol )

	// particle muzzle flash effect to play when fired	
	"MuzzleFlashEffect_1stPerson"		"weapon_muzzle_flash_pistol_FP"
	"MuzzleFlashEffect_3rdPerson"		"flashlight_thirdperson_glow3"	// see readme_weapon_scripts_reference.txt for explanation 


This mod already INCLUDES customized scripts that have effects for "MuzzleFlashEffect_3rdPerson" assigned.
PLEASE UNDERSTAND that this is meant to be a "system", not like "I'm gonna put there whatever I want", I've assigned these effects so that multiple mods can coexist by following these rules!


Before continuing, I'd like to add a couple words about the 1st person effect:

----------- A small note about "MuzzleFlashEffect_1stPerson" --------------------------------------
You DON'T need to alter "MuzzleFlashEffect_1stPerson" IF you removed the firing event { event AE_MUZZLEFLASH 0 "1" } from the .QC fire sequences.
If you DIDN'T remove the firing event from .QC, because you wanted to keep the bright flash that bounces off the walls, but you don't want the actual default FP effect, 
you can define "empty" for "MuzzleFlashEffect_1stPerson" ( empty is a dummy effect included with this mod ). Here's an example:


	// particle muzzle flash effect to play when fired	
	"MuzzleFlashEffect_1stPerson"		"empty"			// < note how I changed it to empty
	"MuzzleFlashEffect_3rdPerson"		"flashlight_thirdperson_glow3"	// see readme_weapon_scripts_reference.txt for explanation

BUT, if you removed { event AE_MUZZLEFLASH 0 "1" } from .QC firing sequences, you DON'T need to bother with this at all
------------------------------------------------------------------------------------------------------------------------


... let's continue.

Here's the thing: unfortunately, it doesn't quite work with custom effects that are loaded from addons or workshop addons.
Maybe the scripts either can't link effects that haven't been pre-cached at the moment of parsing the script, or the scripts are loaded before .pcf files ( I am talking about addons loading ).
All I know is that something just doesn't get linked properly, and effects don't play even though console might not say there are errors.

So the solution is to existing effects ( in particular, precached existing effects ).
So I tried to find all the unused effects ( that's right, game doesn't use them ( I'm fairly certain)) that meet the requirements.
Luckily, there was just enough of those to cover all the guns:

------------------------------------------------------------------------------------------------------------------------

// script name					// MuzzleFlashEffect_3rdPerson ( wrap in quotation marks " " in-script )

weapon_pumpshotgun.txt			//undecided as of last stand update
weapon_shotgun_chrome.txt		//undecided as of last stand update

weapon_autoshotgun.txt			//undecided as of last stand update
weapon_shotgun_spas.txt			//undecided as of last stand update

weapon_hunting_rifle.txt		//undecided as of last stand update
weapon_sniper_military.txt		//undecided as of last stand update
							
weapon_rifle.txt				flashlight_thirdperson_bak
weapon_rifle_ak47.txt			flashlight_thirdperson_mod
weapon_rifle_desert.txt			flashlight_thirdperson_beamlet
weapon_rifle_m60.txt			flashlight_firstperson_
							
weapon_smg.txt					//undecided as of last stand update
weapon_smg_silenced.txt			//undecided as of last stand update
														
weapon_pistol.txt				flashlight_thirdperson_glow3
weapon_pistol_magnum.txt		blood_impact_arterial_spray_3_child

weapon_rifle_sg552.txt			achieved

weapon_smg_mp5.txt				impact_water_child_splash
weapon_sniper_awp.txt			impact_mud_cheap
weapon_sniper_scout.txt			impact_paper_cheap


// Extra potential effects I haven't used, but decided to note here just in case.

blood_atomized_c
blood_impact_arterial_spray_2
blood_impact_arterial_spray_4


// Effects I used in earlier version, but it turned out they don't work online ( they aren't precached). These are blacklisted!
default							// originally in locator_fx.pcf
locator_generic					// originally in locator_fx.pcf
string_banner_01				// originally in rope_fx.pcf
mini_firework_flare				// originally in steamworks.pcf
mini_fireworks					// originally in steamworks.pcf

-----------------------------------------------------------------------------------------------------------------------------

Interesting thing about the "achieved" effect, is that steamworks.pcf isn't precached, and yet it works fine. My only theory is that "batch particle systems" variable that it has enabled has something to do with it.
Also, please don't ever consider borrowing "error" effect as a placeholder for anything, it's a debug effect and is useful ( what I mean is, don't modify it / break it ).


Now, what to do with the effects?
This mod has template .pcf files in particles/3p folder.
If, for example, you open particles/3p/weapon_pistol.pcf, you'll see it has an empty flashlight_thirdperson_glow3 effect.
THIS is the effect you should link YOUR custom effect(s) to:

flashlight_thirdperson_glow3 (parent) > super_revolver_TP (child)

NOTE that you don't necessarily have to store the actual effects there, you can link another empty effect!

If you do it that way, you can have a custom "support" .pcf mod that loads AFTER weapon_pistol.pcf and rewrites the empty super_revolver_TP with a proper effect.
That makes it easier to have multiple mods that use the same effect(s), or similar themed mods, or just for convenience of not having to update multiple mods but one "support" mod.

The way you choose to do this and store the files is entirely up to you.

For example, in the recent collaboration with Scream, I went with the following scheme:

[AK47 weapon script mod] > [AK-47 replacement mod] > [Infinite Warfare Particles Support mod] > [Particles Manifest]

Regarding the effects, that would look like this:

[AK47 custom script that defines flashlight_thirdperson_mod as the third person effect] > [AK47 mod that has particles/3p/weapon_rifle_ak47.pcf which links empty flashlight_thirdperson_mod to empty custom Volk_fire_3P effect] > [IW particles support mod that has proper Volk_fire_3P] > [ Particles Manifest that enables all the custom .pcf's]

This allows me to handle and update all the effects on my side, in my "support" mod, without having to ask the gun mods author to update their files.
