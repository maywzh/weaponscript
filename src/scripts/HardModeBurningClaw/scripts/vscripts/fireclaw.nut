if (!("MANACAT" in getroottable())){
	::MANACAT <- {}
}

if(!("fireclaw" in ::MANACAT)){
	::MANACAT.fireclaw <- {
		check = false
		ver = 20240405
	}
	::MANACAT.slot31 <- function(ent){
		local msg = Convars.GetClientConvarValue("cl_language", ent.GetEntityIndex());
		switch(msg){
			case "korean":case "koreana":	msg = "불타는 손톱";	break;
			case "japanese":				msg = "燃える爪";	break;
			case "spanish":					msg = "Garra ardiente";	break;
			case "schinese":				msg = "火爪儿";	break;
			case "tchinese":				msg = "火爪兒";	break;
			default:						msg = "Burning Claw";	break;
		}
		ClientPrint( ent, 5, "\x02 - "+msg+" \x01 v"+::MANACAT.fireclaw.ver);
	};
}

printl( "<MANACAT> Extra Fire Damage Loaded. v"+::MANACAT.fireclaw.ver);

IncludeScript("manacat_fireclaw/info");
if (!("manacatInfo" in getroottable())){
	IncludeScript("manacat/info");
}

IncludeScript("manacat_fireclaw/rngitem");
if (!("manacat_rng_item" in getroottable())){
	IncludeScript("manacat/rngitem");
}

//테스트 영상 촬영용
//Convars.SetValue("sv_vote_plr_map_limit", 9999);
//Convars.SetValue("sv_vote_creation_timer", 0);
//Convars.SetValue("sb_all_bot_game", 1);
//Convars.SetValue("sb_stop", 1);
//Convars.SetValue("z_special_burn_dmg_scale", 0.1);

::fireclaw<-{
	function OnGameEvent_player_hurt(params){
		local victim = GetPlayerFromUserID(params.userid);
		local attacker = GetPlayerFromUserID(params.attacker);
		if(attacker == null || !attacker.IsValid() || !("GetZombieType" in attacker) || !attacker.IsOnFire())return;
		if("GetZombieType" in victim && "weapon" in params){
			if(NetProps.GetPropInt( victim, "m_iTeamNum" ) == 2 && params.type != 8){
				local extrafire = 0;
				local delay = false;
				if(params.weapon == "hunter_claw" || params.weapon == "jockey_claw"){
					if(params.dmg_health > 30){
						extrafire = (params.dmg_health/20);
					}else{
						extrafire = (params.dmg_health/10);
					}
					if(extrafire <= 0)extrafire = 1;
					if(victim.GetSpecialInfectedDominatingMe() == attacker)delay = true;
				}else if(params.weapon == "boomer_claw" || params.weapon == "spitter_claw"){
					extrafire = (params.dmg_health/10);
					if(extrafire <= 1)extrafire++;
				}else if(params.weapon == "smoker_claw"){
					if(victim.GetSpecialInfectedDominatingMe() != attacker){//혀로 잡은 경우에는 불 피해가 들어가지 않음
						extrafire = (params.dmg_health/10);
						if(extrafire <= 0)extrafire = 1;
					}else{
						local activity = attacker.GetSequenceActivityName(attacker.GetSequence());
						if(activity == "ACT_TERROR_SMOKER_CRITICAL_ATTACK_IDLE"){
							extrafire = (params.dmg_health/5);
							if(extrafire <= 0)extrafire = 1;
						}
					}
				}else if(params.weapon == "charger_claw" || params.weapon == "tank_claw"){
					if(params.dmg_health > 2){//2 이하의 피해를 받는 경우는 충돌 충격파 뿐이므로 무시함
						extrafire = (params.dmg_health/5);
					}
				}
				victim.ValidateScriptScope();
				local scrScope = victim.GetScriptScope();

				if(delay){
					if("extrafiretime" in scrScope){
						if(scrScope.extrafiretime+1 <= Time()){
							scrScope.extrafiretime <- Time();
						}else{
							return;
						}
					}else{
						scrScope.extrafiretime <- Time();
					}
				}
				if(extrafire > 0){
					victim.TakeDamage(extrafire, 8, attacker);
				}
			}
		}
	}

	function OnGameEvent_charger_carry_start(params){
		local victim = GetPlayerFromUserID(params.victim);		if(victim == null || !victim.IsValid())return;
		local charger = GetPlayerFromUserID(params.userid);		if(charger == null || !charger.IsValid())return;
		charger.ValidateScriptScope();
		local scrScope = charger.GetScriptScope();
		scrScope.carryTime <- Time();
		EntFire( "worldspawn", "RunScriptCode", "g_ModeScript.fireclaw.carryCharger()", 0.3 );
	}

	function carryCharger(){
		local charger = null;
		while (charger = Entities.FindByClassname(charger, "player")){
			if(charger != null && charger.IsValid() && NetProps.GetPropInt(charger, "m_zombieClass") == 6){
				local victim = NetProps.GetPropEntity(charger, "m_carryVictim");
				if(victim != null && victim.IsValid()){
					charger.ValidateScriptScope();
					local scrScope = charger.GetScriptScope();
					if(scrScope.carryTime+0.3 <= Time()){
						EntFire( "worldspawn", "RunScriptCode", "g_ModeScript.fireclaw.carryCharger()", 0.3 );
						scrScope.carryTime <- Time();
						if(charger.IsOnFire()){
							victim.TakeDamage(1, 8, charger);
						}
					}
				}
			}
		}
	}
}

__CollectEventCallbacks(::fireclaw, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);