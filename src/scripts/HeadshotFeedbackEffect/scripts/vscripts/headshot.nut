Convars.SetValue("sv_consistency", 0);
Convars.SetValue("sv_pure_kick_clients", 0);

if (!("MANACAT" in getroottable())){
	::MANACAT <- {}
}
if(!("headshot" in ::MANACAT)){
	::MANACAT.headshot <- {
		check = false
		ver = 20240405
	}
	::MANACAT.slot5 <- function(ent){
		local msg = Convars.GetClientConvarValue("cl_language", ent.GetEntityIndex());
		switch(msg){
			case "korean":case "koreana":	msg = "헤드샷 타격감 효과";	break;
			case "japanese":				msg = "ヘッドショット打撃効果";	break;
			case "spanish":					msg = "Headshot Feedback Effect";	break;
			default:						msg = "Headshot Feedback Effect";	break;
		}
		ClientPrint( ent, 5, "\x02 - "+msg+" \x01 v"+::MANACAT.headshot.ver);
	};
}

printl( "<MANACAT> Shot Feedback System Loaded. v"+::MANACAT.headshot.ver);

IncludeScript("manacat_headshot/info");
if (!("manacatInfo" in getroottable())){
	IncludeScript("manacat/info");
}

IncludeScript("manacat_headshot/manacatTimer");
if (!("manacatTimers" in getroottable())){
	IncludeScript("manacat/manacatTimer");
}

IncludeScript("manacat_headshot/rngitem");
if (!("manacat_rng_item" in getroottable())){
	IncludeScript("manacat/rngitem");
}


::headShotVars<-{
	bX = 0
	bY = 0
	bZ = 0
	bAttacker = 0
	bodygroup = 0
	effectHLv = 0
	effectBLv = 0

	smoker_tongue = []
}

::headShotFunc<-{
	function OnGameEvent_player_say(params){
		local _player = GetPlayerFromUserID(params.userid);
		if(_player == null)return;
		local _pName = _player.GetPlayerName();
		local _chat = params.text.tolower();

		if(_player == GetListenServerHost()){
			if(_chat == "!headshot"){
				switch(::headShotVars.effectHLv){
					case 0 :
						_player = null;
						while (_player = Entities.FindByClassname(_player, "player")){
							if(_player.IsValid() && !IsPlayerABot(_player)){
								switch(Convars.GetClientConvarValue("cl_language", _player.GetEntityIndex())){
									case "korean":case "koreana":	ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"헤드샷의 소리 효과를 끕니다.");break;
									case "japanese":				ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"ヘッドショットの音の効果を出しません。");break;
									case "spanish":					ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"Desactiva el sonido de los disparos a la cabeza.");break;
									default:						ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"Turn off the sound effect.");break;
								}
							}
						}
						StringToFile("feedback/headshot.txt", "1");
						::headShotVars.effectHLv = 1;
					break;
					case 1 :
						_player = null;
						while (_player = Entities.FindByClassname(_player, "player")){
							if(_player.IsValid() && !IsPlayerABot(_player)){
								switch(Convars.GetClientConvarValue("cl_language", _player.GetEntityIndex())){
									case "korean":case "koreana":	ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"헤드샷의 소리, 유혈 효과를 끕니다.");break;
									case "japanese":				ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"ヘッドショットの音、流血の効果を出しません。");break;
									case "spanish":					ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"Desactiva el sonido y la sangre de los disparos a la cabeza.");break;
									default:						ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"Turn off the sound, blood effect.");break;
								}
							}
						}
						StringToFile("feedback/headshot.txt", "2");
						::headShotVars.effectHLv = 2;
					break;
					case 2 :
						_player = null;
						while (_player = Entities.FindByClassname(_player, "player")){
							if(_player.IsValid() && !IsPlayerABot(_player)){
								switch(Convars.GetClientConvarValue("cl_language", _player.GetEntityIndex())){
									case "korean":case "koreana":	ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"헤드샷의 소리, 유혈 효과를 켭니다.");break;
									case "japanese":				ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"ヘッドショットの音、流血の効果を出します。");break;
									case "spanish":					ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"Activa el sonido y la sangre del efecto de disparos a la cabeza.");break;
									default:						ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"Turn on the sound, blood of headshot effect.");break;
								}
							}
						}
						StringToFile("feedback/headshot.txt", "0");
						::headShotVars.effectHLv = 0;
					break;
				}
			}else if(_chat == "!bodyshot"){
				switch(::headShotVars.effectBLv){
					case 0 :
						_player = null;
						while (_player = Entities.FindByClassname(_player, "player")){
							if(_player.IsValid() && !IsPlayerABot(_player)){
								switch(Convars.GetClientConvarValue("cl_language", _player.GetEntityIndex())){
									case "korean":case "koreana":	ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"바디샷의 소리 효과를 끕니다.");break;
									case "japanese":				ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"ボディショットの音の効果を出しません。");break;
									case "spanish":					ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"Desactiva el sonido de los disparos en el torso.");break;
									default:						ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"Turn off the sound of bodyshot effect.");break;
								}
							}
						}
						StringToFile("feedback/bodyshot.txt", "1");
						::headShotVars.effectBLv = 1;
					break;
					case 1 :
						_player = null;
						while (_player = Entities.FindByClassname(_player, "player")){
							if(_player.IsValid() && !IsPlayerABot(_player)){
								switch(Convars.GetClientConvarValue("cl_language", _player.GetEntityIndex())){
									case "korean":case "koreana":	ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"바디샷의 소리, 유혈 효과를 끕니다.");break;
									case "japanese":				ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"ボディショットの音、流血の効果を出しません。");break;
									case "spanish":					ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"Desactiva el sonido y la sangre de los disparos al torso.");break;
									default:						ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"Turn off the sound, blood of bodyshot effect.");break;
								}
							}
						}
						StringToFile("feedback/bodyshot.txt", "2");
						::headShotVars.effectBLv = 2;
					break;
					case 2 :
						_player = null;
						while (_player = Entities.FindByClassname(_player, "player")){
							if(_player.IsValid() && !IsPlayerABot(_player)){
								switch(Convars.GetClientConvarValue("cl_language", _player.GetEntityIndex())){
									case "korean":case "koreana":	ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"바디샷의 소리, 유혈 효과를 켭니다.");break;
									case "japanese":				ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"ボディショットの音、流血の効果を出します。");break;
									case "spanish":					ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"Activa el sonido y la sangra de los disparos al torso.");break;
									default:						ClientPrint( _player, 5, "Headshot Effect: "+"\x01"+"Turn on the sound, blood of bodyshot effect.");break;
								}
							}
						}
						StringToFile("feedback/bodyshot.txt", "0");
						::headShotVars.effectBLv = 0;
					break;
				}
			}//else if(_chat == "!pre"){
			//	PrecacheFunc(1);
			//	headshotEffect(_player.GetOrigin(), 2);
			//}
		}
	}

	function OnGameEvent_round_start_post_nav(params){
		::headShotVars.effectHLv = FileToString("feedback/headshot.txt");
		if(::headShotVars.effectHLv == null)::headShotVars.effectHLv = 0;
		else ::headShotVars.effectHLv = ::headShotVars.effectHLv.tointeger();
		if(::headShotVars.effectHLv >= 3 || ::headShotVars.effectHLv < 0)::headShotVars.effectHLv = 0;
		::headShotVars.effectBLv = FileToString("feedback/bodyshot.txt");
		if(::headShotVars.effectBLv == null)::headShotVars.effectBLv = 0;
		else ::headShotVars.effectBLv = ::headShotVars.effectBLv.tointeger();
		if(::headShotVars.effectBLv >= 3 || ::headShotVars.effectBLv < 0)::headShotVars.effectBLv = 0;
	}

	function OnGameEvent_player_first_spawn(params){
		if(GetPlayerFromUserID(params.userid).IsSurvivor())PrecacheFunc(1);
	}

	function OnGameEvent_player_transitioned(params){
		if(GetPlayerFromUserID(params.userid).IsSurvivor())PrecacheFunc(1);
	}

	function PrecacheFunc(params){
		local ent = null;
		while (ent = Entities.FindByClassname(ent, "player")){
			if (ent.IsValid() && ent.IsSurvivor()){
			//	PrecacheSound("Pitchfork.ImpactFlesh");
			//	PrecacheSound("Player.FallDamage");
			//	PrecacheSound("Zombie.BulletImpact");
			//	PrecacheSound("Flesh.Break");
				
				local particles = ["gore_blood_spurt_generic_2", "blood_impact_red_01_mist",
				"blood_impact_headshot_01", "gore_wound_back_fallback",
				"blood_impact_red_01_goop_backspray", "gore_wound_arterial_spray_fallback"];
				local len = particles.len();
				for(local i = 0; i < len; i++){
					local precachePtc = particles[i];
					PrecacheEntityFromTable({
						classname = "info_particle_system"
						angles = Vector(0,0,0)
						effect_name = precachePtc
						start_active = "1"
						origin = Vector(0,0,0)
					});
				}
			}
		}
	}

	function OnGameEvent_player_death(params){
		if(::headShotVars.effectHLv >= 2)return;
		local victim;
		local headshot = params.headshot;
		if(::headShotVars.bodygroup == 1)headshot = 1;
		local attacker = GetPlayerFromUserID(params.attacker);
		local bullet = bulletchk(params.weapon);

		if(params.victimname == "Infected"){
			if(params.type == 2097280 || params.type == 1075839104){
				playSound(attacker, Ent(params.entityid), params.type, 3);
				return;
			}else if(params.type == -2145386492 || params.type == -1071644668){
				playSound(attacker, Ent(params.entityid), params.type, 4);
				return;
			}
			if(headshot){
				if(bullet == 0)return;
				killshotEffect(Vector(::headShotVars.bX, ::headShotVars.bY, ::headShotVars.bZ), 1);playSound(attacker, Ent(params.entityid), bullet);
			}else{
				switch(params.type){
					case 8 : case 2056 : case 268435464 : //불
					case 131072 : //탱크가 죽을때
					case 134217792 : //파이프폭탄
					case 33554432 : case 16777280 : case 1090519104 : case 1107296256 : //유탄
					return;
					case 128 : //구타
					case 67108864 : //전기톱
						playSound(attacker, Ent(params.entityid), params.type, 2);
					break;
					default :
						if(bullet == 0)return;
						killshotEffect(Vector(::headShotVars.bX, ::headShotVars.bY, ::headShotVars.bZ), 2);playSound(attacker, Ent(params.entityid), bullet, 2);
					break;
				}
			}
			return;
		}else if(params.victimname == "Witch"){
			victim = Ent(params.entityid);
		}else{
			victim = GetPlayerFromUserID(params.userid);
		}
		
		if(IsPlayerABot(attacker) || (victim.IsPlayer() && victim.GetZombieType()==9) || (victim.IsPlayer() && victim.GetZombieType()==8))return;

		if(headshot){
			if(bullet == 0)return;
			skeet(victim, attacker);
			killshotEffect(Vector(::headShotVars.bX, ::headShotVars.bY, ::headShotVars.bZ), 1);playSound(attacker, victim, bullet);
		}else{
			if(params.type != 128 && bullet == 0)return;
			skeet(victim, attacker);
			if(params.type == 128){
				killshotEffect(Vector(::headShotVars.bX, ::headShotVars.bY, ::headShotVars.bZ), 2);playSound(attacker, victim, 128, 2);
			}else{
				killshotEffect(Vector(::headShotVars.bX, ::headShotVars.bY, ::headShotVars.bZ), 2);playSound(attacker, victim, bullet, 2);
			}
		}
	}

	function OnGameEvent_tongue_grab(params){
		local smoker = GetPlayerFromUserID(params.userid);
		local victim = GetPlayerFromUserID(params.victim);

		local len = ::headShotVars.smoker_tongue.len();
		local find = false;
		for(local i = 0; i < len; i++){
			if(::headShotVars.smoker_tongue[i][0] == smoker){
				find = true;
				::headShotVars.smoker_tongue[i][1] = victim;
				break;
			}
		}
		if(!find)::headShotVars.smoker_tongue.append([smoker, victim]);
	}

	function skeet(victim, attacker){
		if("GetZombieType" in victim){
			local ztype = victim.GetZombieType();
			local skeet = false;
			local siSeq = NetProps.GetPropInt(victim,"m_nSequence");
			if(ztype == 3 && (siSeq == 64 || siSeq == 67))skeet = true;
			else if(ztype == 5 && siSeq == 10)skeet = true;
			else if(ztype == 6 && siSeq == 5)skeet = true;
			else if(ztype == 1 && (siSeq == 27 || siSeq == 30)){
				local len = ::headShotVars.smoker_tongue.len();
				for(local i = 0; i < len; i++){
					if(::headShotVars.smoker_tongue[i][0] == victim && ::headShotVars.smoker_tongue[i][1] == attacker){
						skeet = true;	::headShotVars.smoker_tongue.remove(i);		break;
					}
				}
			}
			if(skeet){
				skeetEffect(Vector(::headShotVars.bX, ::headShotVars.bY, ::headShotVars.bZ));
				EmitSoundOnClient("HunterZombie.Pounce.Hit", attacker)
				EmitAmbientSoundOn("HunterZombie.Pounce.Hit", 1.0, 350, 100,victim);
			}
			local len = ::headShotVars.smoker_tongue.len();
			for(local i = 0; i < len; i++){
				if(::headShotVars.smoker_tongue[i][0] == victim){
					::headShotVars.smoker_tongue.remove(i);		len--;
				}
			}
		}
	}

	function OnGameEvent_bullet_impact(params){
		::headShotVars.bodygroup = 0;
		::headShotVars.bX = params.x;
		::headShotVars.bY = params.y;
		::headShotVars.bZ = params.z;
		::headShotVars.bAttacker = GetPlayerFromUserID(params.userid);
	}

	function OnGameEvent_player_hurt(params){
		if(::headShotVars.effectHLv >= 2)return;
		local attacker = null;
		if("attackerentid" in params)attacker = EntIndexToHScript(params.attackerentid);
		else if("attacker" in params)attacker = GetPlayerFromUserID(params.attacker);
		local victim = GetPlayerFromUserID(params.userid);

		//testdamagetype(params.type);

		if(NetProps.GetPropIntArray( victim, "m_iTeamNum", 0) != 2){
			local vtype = victim.GetZombieType();
			
			if(NetProps.GetPropInt(victim,"m_nSequence") != 73 && NetProps.GetPropInt(victim,"m_nSequence") != 74 && attacker != null){
				if(params.hitgroup == 1 && vtype!=8){
					if(::headShotVars.effectHLv < 1 && vtype!=8 && (params.type&2)==2)::manacatAddTimer(0.095, false, ::latesound, { tgp = attacker, tgs = "Zombie.BulletImpact" });
					headshotEffect(Vector(::headShotVars.bX, ::headShotVars.bY, ::headShotVars.bZ), params.type);
				}else{
					if(vtype == 8 && (params.type&2)==2)killshotEffect(Vector(::headShotVars.bX, ::headShotVars.bY, ::headShotVars.bZ), 3);
					bodyshotEffect(Vector(::headShotVars.bX, ::headShotVars.bY, ::headShotVars.bZ), params.type);
				}
			}
		}else{
			local soundcode = "";	local dec = 0;
			if("attackerentid" in params && "type" in params && params.attackerentid == 0 && params.type == 32){
				if(params.dmg_health >= 210 || (victim.IsOnThirdStrike() && params.dmg_health >= (victim.GetHealth() + victim.GetHealthBuffer()))){
					EmitSoundOnClient("Weapon.HitInfected", victim);
					EmitSoundOnClient("HunterZombie.Pounce.Hit", victim);
					EmitAmbientSoundOn("Weapon.HitInfected", 1.0, 350, 100, victim);
				}
			}else if(attacker != null && attacker.GetClassname() == "witch"){
				if(victim.IsIncapacitated())soundcode = ["Claw.HitFlesh"];
				else soundcode = ["Claw.HitFlesh" "WitchZombie.ShredVictim"];	dec = 1;
			}else if("weapon" in params){
				if(params.weapon == "tank_rock"){
					soundcode = ["Flesh.Break" "Player.FallDamage"];	dec = 2;
				}else if(params.weapon == "tank_claw"){
					if(victim.IsIncapacitated())soundcode = ["HulkZombie.PunchIncap" "Player.FallDamage"];
					else soundcode = ["ChargerZombie.HitPerson" "Player.FallDamage"];	dec = 2;
				}
			}
			if(soundcode != ""){
				local soundlist = soundcode.len();
				local player = null;	local tgorigin = victim.GetOrigin();
				while (player = Entities.FindByClassname(player, "player")){
					if(player != null && player.IsValid()){
						local dist = (tgorigin - player.GetOrigin()).Length();
						if(dist > 400)dist = 400;
						dist /= 400;	dist = 1.0 - dist;
						dist /= dec;
						for(local j = 0;  j < soundlist; j++){
							EmitAmbientSoundOn(soundcode[j], dist, 500, 100, player);
						}
					}
				}
			}
		}
	}

	function OnGameEvent_player_incapacitated(params){
		local victim = GetPlayerFromUserID(params.userid);
		local attacker = null;
		if("attackerentid" in params)attacker = EntIndexToHScript(params.attackerentid);
		else if("attacker" in params)attacker = GetPlayerFromUserID(params.attacker);

		if(NetProps.GetPropIntArray( victim, "m_iTeamNum", 0) == 2){
			local soundcode = "";	local dec = 0;
			if("attackerentid" in params && "type" in params && params.attackerentid == 0 && params.type == 32){
				EmitSoundOnClient("Weapon.HitInfected", victim);
				EmitAmbientSoundOn("Weapon.HitInfected", 1.0, 350, 100, victim);
			}else if(attacker != null && attacker.GetClassname() == "witch"){
				if(victim.IsIncapacitated())soundcode = ["Claw.HitFlesh"];
				else soundcode = ["Claw.HitFlesh" "WitchZombie.ShredVictim"];	dec = 1;
			}else if("weapon" in params){
				if(params.weapon == "tank_rock"){
					soundcode = ["Flesh.Break" "Player.FallDamage"];	dec = 2;
				}else if(params.weapon == "tank_claw"){
					if(victim.IsIncapacitated())soundcode = ["HulkZombie.PunchIncap" "Player.FallDamage"];
					else soundcode = ["ChargerZombie.HitPerson" "Player.FallDamage"];	dec = 2;
				}
			}
			if(soundcode != ""){
				local soundlist = soundcode.len();
				local player = null;	local tgorigin = victim.GetOrigin();
				while (player = Entities.FindByClassname(player, "player")){
					if(player != null && player.IsValid()){
						local dist = (tgorigin - player.GetOrigin()).Length();
						if(dist > 400)dist = 400;
						dist /= 400;	dist = 1.0 - dist;
						dist /= dec;
						for(local j = 0;  j < soundlist; j++){
							EmitAmbientSoundOn(soundcode[j], dist, 500, 100, player);
						}
					}
				}
			}
		}
	}

	function OnGameEvent_ability_use(params){
		if(params.ability == "ability_throw"){
			local tank = GetPlayerFromUserID(params.userid);
			::manacatAddTimer(1.5, false, ::headShotFunc.rock_trace, {si = tank});
		}
	}

	function rock_trace(params){
		if(params.si == null || !params.si.IsValid())return;

		local tgrock = null;
		while (tgrock = Entities.FindByClassname(tgrock, "tank_rock")){
			if(tgrock.IsValid() && NetProps.GetPropEntity( tgrock, "m_hThrower" ) == params.si){
				::manacatAddTimer(0.05, false, ::headShotFunc.rock, {rock = tgrock, tank = params.si, origin = tgrock.GetOrigin(), model = tgrock.GetModelName()});
				
				return;
			}
		}
	}

	function rock(params){
		if(params.rock == null || !params.rock.IsValid()){
			if(params.tank == null || !params.tank.IsValid() || params.tank.IsDead() || params.tank.IsDying() || params.tank.IsIncapacitated())return;
			local sound = "";	local soundcode = "";
			if(params.model == "models/props_debris/concrete_chunk01a.mdl"){
				sound = "rock.impacthard";
				soundcode = "Boulder.ImpactHard";
			}else if(params.model == "models/props_foliage/tree_trunk.mdl"){
				sound = "Wood_Plank.Break";
				soundcode = "Wood_Plank.Break";
			}
			local soundEnt = SpawnEntityFromTable("ambient_generic",
			{
				cspinup = "0"
				health = "10"
				lfomodpitch = "0"
				lfomodvol = "0"
				lforate = "0"
				lfotype = "0"
				message = sound
				pitch = "100"
				pitchstart = "100"
				preset = "0"
				radius = "256"
				spawnflags = "16"
				spindown = "0"
				spinup = "0"
				volstart = "0"
				origin = params.origin
			});
			DoEntFire("!self", "PlaySound", "", 0.0, null, soundEnt);
			DoEntFire("!self", "Kill", "", 3.0, null, soundEnt);
			local player = null;
			while (player = Entities.FindByClassname(player, "player")){
				if(player != null && player.IsValid()){
					local dist = (params.origin - player.GetOrigin()).Length();
					if(dist > 2000)dist = 2000;
					dist /= 2000;	dist = 1.0 - dist;
					
					EmitAmbientSoundOn(soundcode, dist, 500, 100, player);
					EmitAmbientSoundOn(soundcode, dist, 500, 100, player);
					EmitAmbientSoundOn(soundcode, dist, 500, 100, player);
					EmitAmbientSoundOn(soundcode, dist, 500, 100, player);
					EmitAmbientSoundOn(soundcode, dist, 500, 100, player);
				}
			}
		}else{
			params.origin = params.rock.GetOrigin();
			::manacatAddTimer(0.05, false, ::headShotFunc.rock, params);
		}
	}

	/*
	function OnGameEvent_entity_shoved(params){
		if(params.entityid == 0)return;
		local ent = Ent(params.entityid);
		if(ent == null || !ent.IsValid())return;
		if(ent.GetClassname() == "prop_door_rotating"){
			printl("쿤을 쳐버렸네");
			printl("문 모델 : "+ent.GetModelName());
			local model = ent.GetModelName();
			switch(ent.GetModelName()){
				case "models/props_doors/doormainmetal01.mdl":
				case "models/Props_Doors/DoorMainMetal01_DM01.mdl":
				case "models/Props_Doors/DoorMainMetal01_DM02.mdl":
				case "models/Props_Doors/DoorMainMetal01_DM03.mdl":
				case "models/Props_Doors/DoorMainMetal01_DM04.mdl":
				case "models/Props_Doors/DoorMainMetal01_DM05.mdl":
				case "models/Props_Doors/DoorMainMetal01_DM06.mdl":
				case "models/Props_Doors/DoorMainMetal01_DM07.mdl":
				case "models/props_doors/doormainmetalsmall01.mdl":
				case "models/Props_Doors/DoorMainMetalSmall01_DM01.mdl":
				case "models/Props_Doors/DoorMainMetalSmall01_DM02.mdl":
				case "models/Props_Doors/DoorMainMetalSmall01_DM03.mdl":
				case "models/Props_Doors/DoorMainMetalSmall01_DM04.mdl":
				case "models/Props_Doors/DoorMainMetalSmall01_DM05.mdl":
				case "models/Props_Doors/DoorMainMetalSmall01_DM06.mdl":
				case "models/Props_Doors/DoorMainMetalSmall01_DM07.mdl":
					printl("철문");
					EmitSoundOnClient("Doors.Metal.Pound1", GetPlayerFromUserID(params.attacker));
					//EmitAmbientSoundOn("Doors.Metal.Pound1", 1.0, 350, 100, GetPlayerFromUserID(params.attacker));
				break;
				case "models/props_doors/doormain01.mdl":
				case "models/Props_Doors/DoorDM01_01.mdl":
				case "models/Props_Doors/DoorDM02_01.mdl":
				case "models/Props_Doors/DoorDM03_01.mdl":
				case "models/props_doors/doormain01_small.mdl":
				case "models/Props_Doors/DoorMain01_Small_01.mdl":
				case "models/Props_Doors/DoorMain02_Small_01.mdl":
				case "models/Props_Doors/DoorMain03_Small_01.mdl":
					printl("목문");
					EmitSoundOnClient("Doors.Wood.Pound1", GetPlayerFromUserID(params.attacker));
					//EmitAmbientSoundOn("Doors.Wood.Pound1", 1.0, 350, 100, GetPlayerFromUserID(params.attacker));
				break;
			}
		}
	}
	*/

	function OnGameEvent_infected_hurt(params){
		if(::headShotVars.effectHLv >= 2)return;

		local tgvictim = Ent(params.entityid);
		local attacker = GetPlayerFromUserID(params.attacker);
		if(tgvictim.GetClassname() == "witch"){
			if(params.hitgroup == 1){
				if(::headShotVars.effectHLv < 1 && (params.type&2)==2)::manacatAddTimer(0.095, false, ::latesound, { tgp = attacker, tgs = "Zombie.BulletImpact" });
				headshotEffect(Vector(::headShotVars.bX, ::headShotVars.bY, ::headShotVars.bZ), params.type);
			}else{
				bodyshotEffect(Vector(::headShotVars.bX, ::headShotVars.bY, ::headShotVars.bZ), params.type);
			}
		}else if(tgvictim.GetClassname() == "infected"){
			if(params.hitgroup == 1){
				::headShotVars.bodygroup = 1;
				headshotEffect(Vector(::headShotVars.bX, ::headShotVars.bY, ::headShotVars.bZ), params.type);
			}else{
				bodyshotEffect(Vector(::headShotVars.bX, ::headShotVars.bY, ::headShotVars.bZ), params.type);
			}
		}
	}

	function bulletchk(wtype){
		switch(wtype){
			case "pistol":case "pistol_magnum":case "dual_pistols":
			case "smg":case "smg_silenced":case "smg_mp5":
			case "pumpshotgun":case "shotgun_chrome":case "autoshotgun":case "shotgun_spas":
			case "rifle":case "rifle_ak47":case "rifle_desert":case "rifle_sg552":case "rifle_m60":
			case "hunting_rifle":case "sniper_military":case "sniper_awp":case "sniper_scout":
			return 2;
		}
		return 0;
	}
	/*
	function testdamagetype(wtype){
		printl("  DMG TYPE  : "+wtype);
		printl("DMG_GENERIC : "+((wtype&0)==0));
		printl("DMG_CRUSH   : "+((wtype&1)==1));
		printl("DMG_BULLET  : "+((wtype&2)==2)+" - - -");
		printl("DMG_SLASH   : "+((wtype&4)==4));
		printl("DMG_BURN    : "+((wtype&8)==8));
		printl("DMG_CLUB    : "+((wtype&128)==128));
		printl("DMG_DIRECT  : "+((wtype&268435456)==268435456));	
	}//*/

	function particlePos(list, pos){
		local len = list.len();
		for(local i = 0; i < len; i++){
			local effect = SpawnEntityFromTable("info_particle_system",
			{
				angles = Vector( 0, RandomInt(0,359), 0 )
				effect_name = list[i]
				start_active = "1"
				origin = pos
			});
			DoEntFire("!self", "Kill", "", 1.0, null, effect);
		}
	}

	function headshotEffect(pos, wtype){
		if((wtype&2)!=2)return;//데미지타입이 DMG_BULLET가 아니라면 취소
		if(::headShotVars.bX != 0 && ::headShotVars.bY != 0 && ::headShotVars.bZ != 0)
			particlePos(["gore_blood_spurt_generic_2", "blood_impact_red_01_mist"], pos);
	}

	function bodyshotEffect(pos, wtype){
		if(::headShotVars.effectBLv >= 2 || (wtype&2)!=2)return;
		particlePos(["blood_impact_red_01_mist"], pos);
	}
	
	function skeetEffect(pos){
		if(::headShotVars.bX != 0 && ::headShotVars.bY != 0 && ::headShotVars.bZ != 0)
			particlePos(["blood_impact_headshot_01", "blood_impact_headshot_01"], pos);
	}

	function killshotEffect(pos, killtype){
		switch(killtype){
			case 1 :
				particlePos(["blood_impact_headshot_01", "blood_impact_red_01_goop_backspray"], pos);return;
			case 2 :
				particlePos(["gore_wound_arterial_spray_fallback", "gore_blood_spurt_generic_2"], pos);return;
			case 3 :
				particlePos(["gore_wound_back_fallback"], pos);return;
		}
	}

	function playSound(tgplayer, tgvictim, wtype, headshotV = 1){
		/*if(headshotV == 3){//둔기킬
			EmitAmbientSoundOn("Melee.HitLimb", 1.0, 350, 100,tgplayer);
			return;
		}else if(headshotV == 4){//예기킬
			EmitAmbientSoundOn("PlayerZombie.AttackHit", 1.0, 350, 100,tgplayer);
			return;
		}*/
		if((wtype&2)!=2 && wtype != 128 && wtype != 67108864)return;
		
		if((::headShotVars.bX != 0 && ::headShotVars.bY != 0 && ::headShotVars.bZ != 0) || wtype == 67108864 || wtype == 128){
			if(::headShotVars.effectHLv < 1){
				if(headshotV == 1){//헤드샷
					::manacatAddTimer(0.095, false, ::latesound, { tgp = tgplayer, tgs = "Pitchfork.ImpactFlesh" });
					::manacatAddTimer(0.295, false, ::latesound, { tgp = tgplayer, tgs = "Player.FallDamage" });
					::manacatAddTimer(0.15, false, ::latesound, { tgp = tgplayer, tgs = "Zombie.BulletImpact" });
					//::manacatAddTimer(2.2, false, ::latesound, { tgp = tgplayer, tgs = "Melee.HitHead" });
					EmitSoundOnClient("Flesh.Break", tgplayer);
					EmitAmbientSoundOn("Flesh.Break", 1.0, 350, 100,tgvictim);
					EmitAmbientSoundOn("Flesh.Break", 1.0, 500, 100,tgvictim);
					try{
						if(tgvictim.GetZombieType()!=8){
							EmitAmbientSoundOn("Zombie.BulletImpact", 1.0, 350, 100,tgvictim);
							EmitAmbientSoundOn("Zombie.BulletImpact", 1.0, 500, 100,tgvictim);
							::manacatAddTimer(0.15, false, ::lateAmbient, { tgp = tgvictim, tgs = "Zombie.BulletImpact" });
						}
					}catch(e){
						EmitAmbientSoundOn("Zombie.BulletImpact", 1.0, 350, 100,tgvictim);
						EmitAmbientSoundOn("Zombie.BulletImpact", 1.0, 500, 100,tgvictim);
						::manacatAddTimer(0.15, false, ::lateAmbient, { tgp = tgvictim, tgs = "Zombie.BulletImpact" });
					}
				}else{//바디샷
					if(::headShotVars.effectBLv < 1){
						switch(wtype){
							case 8 : case 2056 : case 268435464 : //불
							case 131072 : //탱크가 죽을때
							case 134217792 : //파이프폭탄
							case 2097280 : case 1075839104 : case -2145386492 : case -1071644668 : // 근접
							break;
							case 67108864 : //전기톱
								EmitSoundOnClient("PlayerZombie.AttackHit", tgplayer);
								EmitAmbientSoundOn("PlayerZombie.AttackHit", 1.0, 350, 100,tgvictim);
								EmitAmbientSoundOn("PlayerZombie.AttackHit", 1.0, 350, 100,tgvictim);
							break;
							case 128 : //구타
								EmitAmbientSoundOn("Breakable.MatFlesh", 1.0, 350, 100,tgplayer);
								EmitAmbientSoundOn("Player.FallDamage", 1.0, 350, 100,tgplayer);
							break;
							default :
								::manacatAddTimer(0.025, false, ::latesound, { tgp = tgplayer, tgs = "Zombie.BulletImpact" });
								EmitAmbientSoundOn("Zombie.BulletImpact", 0.7, 350, 100,tgvictim);
							break;
						}
					}
				}
			}
		}
		local pos = Vector(::headShotVars.bX, ::headShotVars.bY, ::headShotVars.bZ);
		::headShotVars.bX = 0; ::headShotVars.bY = 0; ::headShotVars.bZ = 0;
		if(headshotV == 1){
			headshotEffect(pos, wtype);
		}else{
			bodyshotEffect(pos, wtype);
		}
		return null;
	}
}

::latesound <- function(params){
	local tgplayer = params["tgp"];
	local tgsound = params["tgs"];
	EmitSoundOnClient(tgsound, tgplayer);
}

::lateAmbient <- function(params){
	local tgplayer = params["tgp"];
	local tgsound = params["tgs"];
	EmitAmbientSoundOn(tgsound, 1.0, 500, 100,tgplayer);
}

__CollectEventCallbacks(::headShotFunc, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);