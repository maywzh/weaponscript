::mp_gamemode <- Convars.GetStr("mp_gamemode").tolower();

Convars.SetValue("sv_consistency", 0);
Convars.SetValue("sv_pure_kick_clients", 0);

if (!("MANACAT" in getroottable())){
	::MANACAT <-{
	}
}

if(!("carlight" in ::MANACAT)){
	::MANACAT.carlight <- {
		check = false
		ver = "02/04/2024"
	}
	::MANACAT.slot51 <- function(ent){
		local msg = Convars.GetClientConvarValue("cl_language", ent.GetEntityIndex());
		switch(msg){
			case "korean":case "koreana":	msg = "경보차 다이나믹 라이트";	break;
			case "japanese":				msg = "警報車両ダイナミックライト";	break;
			case "spanish":					msg = "Dynamic Light Car Alarm";	break;
			case "schinese":				msg = "汽车警报器动态光";	break;
			case "tchinese":				msg = "汽車警報器動態光";	break;
			default:						msg = "Dynamic Light Car Alarm";	break;
		}
		ClientPrint( ent, 5, "\x02 - "+msg+" \x01 v"+::MANACAT.carlight.ver);
	};
}

printl( "<MANACAT> Dynamic Car Alarm Light Loaded. v"+::MANACAT.carlight.ver);

IncludeScript("manacat_caralarm_light/info");
if (!("manacatInfo" in getroottable())){
	IncludeScript("manacat/info");
}

IncludeScript("manacat_caralarm_light/rngitem");
if (!("manacat_rng_item" in getroottable())){
	IncludeScript("manacat/rngitem");
}

::carlight<-{
	debug = false

	function OnGameEvent_player_left_safe_area(params){
		local ent = null;
		while (ent = Entities.FindByClassname(ent, "prop_car_alarm")){
			if(ent.IsValid() && ent.GetModelName() == "models/props_vehicles/cara_95sedan.mdl"){
				ent.ValidateScriptScope();
				local scrScope = ent.GetScriptScope();

				IncludeScript("manacat_caralarm_light/alarmcar_light", g_MapScript);
				local light = g_MapScript.GetEntityGroup( "carLight" );
				g_MapScript.SpawnSingleAt( light, ent.GetOrigin(), ent.GetAngles() );

				local lightent = null;
				while (lightent = Entities.FindByClassname(lightent, "light_dynamic")){
					lightent.ValidateScriptScope();
					local lightname = lightent.GetName();
					if(lightname.slice(lightname.len()-1) == "" && !("attach" in lightent.GetScriptScope())){
						DoEntFire("!self", "SetParent", "!activator", 0.00, ent , lightent );
						DoEntFire("!self", "TurnOff", "", 0.0, null, lightent);
						scrScope.light <- lightent;
						lightent.GetScriptScope().attach <- ent;
					}
				}
				local timerent
				while (timerent = Entities.FindByClassname(timerent, "logic_timer")){
					timerent.ValidateScriptScope();
					local timername = timerent.GetName();
					if(timername.slice(timername.len()-1) == "" && !("attach" in timerent.GetScriptScope())){
						DoEntFire("!self", "SetParent", "!activator", 0.00, ent , timerent );
						scrScope.timer <- timerent;
						timerent.GetScriptScope().attach <- ent;
					}
				}

				scrScope["alarmLight"] <- function(){
					DoEntFire("!self", "Enable", "", 0.0, null, scrScope.timer);
				}
				scrScope["alarmLightEnd"] <- function(){
					scrScope.light.Kill();
					scrScope.timer.Kill();
				}

				ent.ConnectOutput("OnCarAlarmStart","alarmLight");
				ent.ConnectOutput("OnCarAlarmEnd","alarmLightEnd");
				//ent.ConnectOutput("OnHitByTank","alarmLightEnd");
				
			}
		}
	}

}

__CollectEventCallbacks(::carlight, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);