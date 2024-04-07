Convars.SetValue("sv_consistency", 0);
Convars.SetValue("sv_pure_kick_clients", 0);
//::mp_gamemode <- Convars.GetStr("mp_gamemode").tolower();

if (!("MANACAT" in getroottable())){
	::MANACAT <- {}
}

if(!("itemEx" in ::MANACAT)){
	::MANACAT.itemEx <- {
		check = false
		ver = 20240405
	}
	::MANACAT.slot10 <- function(ent){
		local msg = Convars.GetClientConvarValue("cl_language", ent.GetEntityIndex());
		switch(msg){
			case "korean":case "koreana":	msg = "기브 앤 테이크 (투척물 공유)";	break;
			case "japanese":				msg = "ギブ & テイク (投擲物の交換)";	break;
			case "spanish":					msg = "Dar y Tomar (compartir tiros)";	break;
			case "schinese":				msg = "礼尚往来 (投掷物共享)";	break;
			case "tchinese":				msg = "禮尚往來 (投擲物共享)";	break;
			default:						msg = "Give N Take (sharing throws)";	break;
		}
		ClientPrint( ent, 5, "\x02 - "+msg+" \x01 v"+::MANACAT.itemEx.ver);
	};
}

printl( "<MANACAT> Item Exchanger Loaded. v"+::MANACAT.itemEx.ver);

IncludeScript("manacat_gnt/info");
if (!("manacatInfo" in getroottable())){
	IncludeScript("manacat/info");
}
IncludeScript("manacat_gnt/rngitem");
if (!("manacat_rng_item" in getroottable())){
	IncludeScript("manacat/rngitem");
}
IncludeScript("manacat_gnt/manacatTimer");
if (!("manacatTimers" in getroottable())){
	IncludeScript("manacat/manacatTimer");
}
IncludeScript("manacat_gnt/commonTalker");
if (!("VocalCommonVars" in getroottable())){
	IncludeScript("manacat/commonTalker");
}

::itemExTalk<-{
	francisLastVocal = "",	louisLastVocal = "",	billLastVocal = "",	zoeyLastVocal = "",	coachLastVocal = "",	nickLastVocal = "",	ellisLastVocal = "",	rochelleLastVocal = "",
	speakTime = 0,

	//francistakepipe = ["takepipebomb01" "takepipebomb04" "takepipebomb05" "takepills01" "takefirstaid04"]
	//francistakemolo = ["takemolotov03" "takepills01" "takefirstaid04"]
	//francistakebackpipe = ["takemolotov02" "takemolotov03"]
	//francistakebackmolo = ["takepipebomb02" "takepipebomb03"]
	franciswelcome = ["youarewelcome04" "youarewelcome05" "youarewelcome06" "youarewelcome09" "youarewelcome11" "youarewelcome14"]
	francisgive = ["DLC1_C6M3_FinaleL4D1ThrowItems02" "DLC1_C6M3_FinaleL4D1ThrowItems03" "alertgiveitem01" "alertgiveitem02" "alertgiveitem03" "alertgiveitem04" "alertgiveitem05" "alertgiveitem06" "alertgiveitem07"]

	//louistakepipe = ["takepipebomb01" "takepipebomb05" "takepills01"]
	//louistakemolo = ["takemolotov03" "takepills01"]
	louiswelcome = ["youarewelcome03" "youarewelcome04" "youarewelcome05" "youarewelcome07" "youarewelcome09" "youarewelcome10" "youarewelcome13" "youarewelcome14" "youarewelcome16" "youarewelcome17"]
	louisgive = ["alertgiveitem01" "alertgiveitem02" "alertgiveitem03" "alertgiveitem04" "alertgiveitem05"]

	//billtakepipe = ["takepipebomb04" "takepills01" "takepills03"]
	//billtakemolo = ["takemolotov03" "takepills01" "takepills03"]
	billwelcome = ["youarewelcome01" "youarewelcome02" "youarewelcome04" "youarewelcome05" "youarewelcome08" "youarewelcome10"]
	billgive = ["alertgiveitem01" "alertgiveitem02" "alertgiveitem03" "alertgiveitem04" "alertgiveitem05" "alertgiveitem06" "alertgiveitem07"]

	//zoeytakepipe = ["takepipebomb04" "takefirstaid03" "takepills03" "takepills06" "takesubmachinegun01" "takesubmachinegun05"]
	//zoeytakemolo = ["takemolotov04" "takemolotov07" "takepills03" "takepills06" "takesubmachinegun01" "takesubmachinegun05"]
	zoeywelcome = ["youarewelcome03" "youarewelcome04" "youarewelcome05" "youarewelcome06" "youarewelcome08" "youarewelcome09" "youarewelcome12" "youarewelcome13" "youarewelcome14" "youarewelcome15" "youarewelcome16" "youarewelcome18" "youarewelcome20" "youarewelcome21" "youarewelcome23" "youarewelcome25" "youarewelcome30"]
	zoeygive = ["DLC1_C6M3_FinaleL4D1ThrowItems03" "alertgiveitem01" "alertgiveitem03" "alertgiveitem05" "alertgiveitem07" "alertgiveitem09" "alertgiveitem11" "alertgiveitem12" "alertgiveitem14" "alertgiveitem15" "alertgiveitem16"]

	coachwelcome = ["youarewelcome01" "youarewelcome02" "youarewelcome03" "youarewelcome04" "youarewelcome05"]
	coachgive = ["alertgiveitem01" "alertgiveitem04" "alertgiveitem05" "alertgiveitemc101" "alertgiveitemcombat01" "alertgiveitemcombat02" "alertgiveitemcombat03" "alertgiveitemcombat04" "alertgiveitemcombat05" "alertgiveitemstop01" "alertgiveitemstop02" "alertgiveitemstop03"]

	nickwelcome = ["youarewelcome01" "youarewelcome02" "youarewelcome03" "youarewelcome05" "youarewelcome08" "youarewelcome09" "youarewelcome10" "youarewelcome11" "youarewelcome12" "youarewelcome13" "youarewelcome14" "youarewelcome15" "youarewelcome16" "youarewelcome17" "youarewelcomec101" "youarewelcomec102" "youarewelcomec103" "youarewelcomec104" "youarewelcomec105" "youarewelcomec106" "youarewelcomec107" "youarewelcomec108" "youarewelcomec109"]
	nickgive = ["alertgiveitem02" "alertgiveitem03" "alertgiveitem04" "alertgiveitem05" "alertgiveitem06" "alertgiveitemc101" "alertgiveitemcombat01" "alertgiveitemcombat02" "alertgiveitemcombat03" "alertgiveitemstop04"]

	elliswelcome = ["youarewelcome01" "youarewelcome02" "youarewelcome03" "youarewelcome05" "youarewelcome08"]
	ellisgive = ["alertgiveitem01" "alertgiveitem02" "alertgiveitem03" "alertgiveitem04" "alertgiveitem06" "alertgiveitemcombat01" "alertgiveitemcombat02" "alertgiveitemcombat03" "alertgiveitemcombat04" "alertgiveitemstop01" "alertgiveitemstop02" "alertgiveitemstop05"]

	rochellewelcome = ["youarewelcome01" "youarewelcome02" "youarewelcome03" "youarewelcome04" "youarewelcome05" "youarewelcome09" "youarewelcome10"]
	rochellegive = ["alertgiveitem01" "alertgiveitem02" "alertgiveitem03" "alertgiveitem04" "alertgiveitemc101" "alertgiveitemcombat01" "alertgiveitemcombat04" "alertgiveitemstop01"]

	function VocalSelect(params){
		if(params.model == null || params.model == false || params.model == true)return;
		local vocal = "";
		switch(params.model){
			case "models/survivors/survivor_teenangst.mdl":
				vocal = "scenes/TeenGirl/";		break;
			case "models/survivors/survivor_biker.mdl":
				vocal = "scenes/Biker/";		break;
			case "models/survivors/survivor_namvet.mdl":
				vocal = "scenes/NamVet/";		break;
			case "models/survivors/survivor_manager.mdl":
				vocal = "scenes/Manager/";		break;
			case "models/survivors/survivor_mechanic.mdl":
				vocal = "scenes/Mechanic/";		break;
			case "models/survivors/survivor_producer.mdl":
				vocal = "scenes/Producer/";		break;
			case "models/survivors/survivor_gambler.mdl":
				vocal = "scenes/Gambler/";		break;
			case "models/survivors/survivor_coach.mdl":
				vocal = "scenes/Coach/";		break;
		}
		switch(params.code){
			case "welcome" :
				switch(params.model){
					case "models/survivors/survivor_teenangst.mdl":
						vocal += ::itemExTalk.zoeywelcome[RandomInt(0,::itemExTalk.zoeywelcome.len()-1)];		break;
					case "models/survivors/survivor_biker.mdl":
						vocal += ::itemExTalk.franciswelcome[RandomInt(0,::itemExTalk.franciswelcome.len()-1)];		break;
					case "models/survivors/survivor_namvet.mdl":
						vocal += ::itemExTalk.billwelcome[RandomInt(0,::itemExTalk.billwelcome.len()-1)];		break;
					case "models/survivors/survivor_manager.mdl":
						vocal += ::itemExTalk.louiswelcome[RandomInt(0,::itemExTalk.louiswelcome.len()-1)];		break;
					case "models/survivors/survivor_mechanic.mdl":
						vocal += ::itemExTalk.elliswelcome[RandomInt(0,::itemExTalk.elliswelcome.len()-1)];		break;
					case "models/survivors/survivor_producer.mdl":
						vocal += ::itemExTalk.rochellewelcome[RandomInt(0,::itemExTalk.rochellewelcome.len()-1)];		break;
					case "models/survivors/survivor_gambler.mdl":
						vocal += ::itemExTalk.nickwelcome[RandomInt(0,::itemExTalk.nickwelcome.len()-1)];		break;
					case "models/survivors/survivor_coach.mdl":
						vocal += ::itemExTalk.coachwelcome[RandomInt(0,::itemExTalk.coachwelcome.len()-1)];		break;
				}
			break;
			case "give" :
				switch(params.model){
					case "models/survivors/survivor_teenangst.mdl":
						vocal += ::itemExTalk.zoeygive[RandomInt(0,::itemExTalk.zoeygive.len()-1)];		break;
					case "models/survivors/survivor_biker.mdl":
						vocal += ::itemExTalk.francisgive[RandomInt(0,::itemExTalk.francisgive.len()-1)];		break;
					case "models/survivors/survivor_namvet.mdl":
						vocal += ::itemExTalk.billgive[RandomInt(0,::itemExTalk.billgive.len()-1)];		break;
					case "models/survivors/survivor_manager.mdl":
						vocal += ::itemExTalk.louisgive[RandomInt(0,::itemExTalk.louisgive.len()-1)];		break;
					case "models/survivors/survivor_mechanic.mdl":
						vocal += ::itemExTalk.ellisgive[RandomInt(0,::itemExTalk.ellisgive.len()-1)];		break;
					case "models/survivors/survivor_producer.mdl":
						vocal += ::itemExTalk.rochellegive[RandomInt(0,::itemExTalk.rochellegive.len()-1)];		break;
					case "models/survivors/survivor_gambler.mdl":
						vocal += ::itemExTalk.nickgive[RandomInt(0,::itemExTalk.nickgive.len()-1)];		break;
					case "models/survivors/survivor_coach.mdl":
						vocal += ::itemExTalk.coachgive[RandomInt(0,::itemExTalk.coachgive.len()-1)];		break;
				}
			break;
		}

		if(!::itemExTalk.VocalCheck(params.model, vocal, params.force)){
			params.tryn++;
			//printl(" : same speech as before, "+params.tryn+" retries.");
			if(params.tryn == 10){
				return vocal+".vcd"
			}
			return ::itemExTalk.VocalSelect(params);
		}else{
			//printl(" ");
			return vocal+".vcd";
		}
	}

	function VocalCheck(pmodel, vcd, force){
		local lastvocal = ""
		local speaker = ::VocalCommonFunc.findPlayer(pmodel);
		switch(pmodel){
			case "models/survivors/survivor_teenangst.mdl":
				lastvocal = ::itemExTalk.zoeyLastVocal;		break;
			case "models/survivors/survivor_biker.mdl":
				lastvocal = ::itemExTalk.francisLastVocal;		break;
			case "models/survivors/survivor_namvet.mdl":
				lastvocal = ::itemExTalk.billLastVocal;		break;
			case "models/survivors/survivor_manager.mdl":
				lastvocal = ::itemExTalk.louisLastVocal;		break;
			case "models/survivors/survivor_mechanic.mdl":
				lastvocal = ::itemExTalk.ellisLastVocal;		break;
			case "models/survivors/survivor_producer.mdl":
				lastvocal = ::itemExTalk.rochelleLastVocal;		break;
			case "models/survivors/survivor_gambler.mdl":
				lastvocal = ::itemExTalk.nickLastVocal;		break;
			case "models/survivors/survivor_coach.mdl":
				lastvocal = ::itemExTalk.coachLastVocal;		break;
		}
		if(vcd == lastvocal || (speaker.GetCurrentScene() != null && !force)){
			return false;
		}else{
			switch(pmodel){
				case "models/survivors/survivor_teenangst.mdl":
					::itemExTalk.zoeyLastVocal = vcd;		break;
				case "models/survivors/survivor_biker.mdl":
					::itemExTalk.francisLastVocal = vcd;		break;
				case "models/survivors/survivor_namvet.mdl":
					::itemExTalk.billLastVocal = vcd;		break;
				case "models/survivors/survivor_manager.mdl":
					::itemExTalk.louisLastVocal = vcd;		break;
				case "models/survivors/survivor_mechanic.mdl":
					::itemExTalk.ellisLastVocal = vcd;		break;
				case "models/survivors/survivor_producer.mdl":
					::itemExTalk.rochelleLastVocal = vcd;		break;
				case "models/survivors/survivor_gambler.mdl":
					::itemExTalk.nickLastVocal = vcd;		break;
				case "models/survivors/survivor_coach.mdl":
					::itemExTalk.coachLastVocal = vcd;		break;
			}
			return true;
		}
	}

	function speakVocal(params){
		if(Time() == ::itemExTalk.speakTime)return;
		local speaker = ::VocalCommonFunc.findPlayer(params.model);

		if(!speaker.IsIncapacitated() && !speaker.IsDominatedBySpecialInfected() && !speaker.IsStaggering()){
			::itemExTalk.speakTime = Time();
			local vocal = ::itemExTalk.VocalSelect({model = params.model, code = params.code, tryn = 1, force = params.force});
			//printl("["+speaker.GetPlayerName()+"]발화 "+vocal);
			if((speaker.GetCurrentScene() == null || params.force))speaker.PlayScene(vocal, 0.0);
			//else printl("대사 취소됨");
			return;
		}
	}
}

::itemExFunc<-{
	function OnGameEvent_round_start_post_nav(params){
		::manacatAddTimerByName("itemEx", 0.1, true, ::itemExFunc.update_itemEx);
	}
	
	/*
	function OnGameEvent_bot_player_replace(params){
	//	::manacatAddTimer(0.01, false, ::itemExFunc.itemOwnerReset, {player = GetPlayerFromUserID(params.player)});
	//	::manacatAddTimer(0.01, false, ::itemExFunc.itemOwnerReset, {player = GetPlayerFromUserID(params.bot)});
	}
	function OnGameEvent_player_bot_replace(params){
	//	::manacatAddTimer(0.01, false, ::itemExFunc.itemOwnerReset, {player = GetPlayerFromUserID(params.player)});
	//	::manacatAddTimer(0.01, false, ::itemExFunc.itemOwnerReset, {player = GetPlayerFromUserID(params.bot)});
	}
	function OnGameEvent_player_transitioned(params){
	//	::manacatAddTimer(0.01, false, ::itemExFunc.itemOwnerReset, {player = GetPlayerFromUserID(params.player)});
	}

	function itemOwnerReset(params){
		local invTable = {};
		GetInvTable(params.player, invTable);
		if("slot0" in invTable)NetProps.SetPropEntity(invTable.slot0, "m_hOwner", params.player);
		if("slot1" in invTable)NetProps.SetPropEntity(invTable.slot1, "m_hOwner", params.player);
		if("slot2" in invTable)NetProps.SetPropEntity(invTable.slot2, "m_hOwner", params.player);
		if("slot3" in invTable)NetProps.SetPropEntity(invTable.slot3, "m_hOwner", params.player);
		if("slot4" in invTable)NetProps.SetPropEntity(invTable.slot4, "m_hOwner", params.player);
	}*/

	function update_itemEx(params){
		local ent = null;
		while (ent = Entities.FindByClassname(ent, "player")){
			if(ent != null && ent.IsValid() && NetProps.GetPropInt( ent, "m_iTeamNum" ) == 2){
				if((ent.GetButtonMask() & (1 << 11)) > 0){
					local lookingent = ::itemExFunc.GetFocusEntity(ent);
					if(!lookingent || lookingent == null) return;
					local ptype = lookingent.GetClassname(); // "player"
					if(ptype == null || ptype != "player") return;

					::itemExFunc.exchangeItem(ent, lookingent, (lookingent.GetOrigin() - ent.GetOrigin()).Length());
				}
			}
		}
	}

	function exchangeItem(giver, taker, dist = -1){
		//if(!IsPlayerABot(giver) && IsPlayerABot(taker) && giver.IsSurvivor() && taker.IsSurvivor())
		if(!giver.IsValid() || !taker.IsValid() || !giver.IsSurvivor() || !taker.IsSurvivor() || IsPlayerABot(giver) || dist >= 293)return;
		//쿨타임
		if(!chkTime(giver))return;

		//공격자가 들고 있는 아이템
		local hold = giver.GetActiveWeapon();
		if(hold == null || !hold.IsValid())return;
		local hclass = hold.GetClassname();
		//피해자의 투척무기슬롯
		local botThrowslot = GetThrowItem(taker);
		if(botThrowslot != null)botThrowslot = botThrowslot.GetClassname();

		local vItems = {};	local aItems = {};
		local actionChk = 0;

		GetInvTable(taker,vItems);	GetInvTable(giver,aItems);

		if(hclass != null){
			if(hclass == "weapon_molotov" || hclass == "weapon_pipe_bomb" || hclass == "weapon_vomitjar"){
				if(!("slot2" in vItems) && !taker.IsIncapacitated()){ 
					giver.DropItem(hclass);
					hold.SetOrigin(giver.EyePosition()+giver.EyeAngles().Left().Scale(10)+giver.EyeAngles().Up().Scale(-15));
					local impulseVec = hold.GetVelocity().Scale(0.3);
					impulseVec.z = 222;
					impulseVec += giver.EyeAngles().Forward().Scale(100);
					hold.SetVelocity(Vector(0, 0, 0));
					hold.ApplyAbsVelocityImpulse(impulseVec);
					local passtime = 0.1;
				//	printl(dist + "  " + (dist/550))
					if(dist != -1)passtime = (dist/550);
					if(passtime < 0.1)passtime = 0.1;
					EntFire( "worldspawn", "RunScriptCode", "g_ModeScript.itemExFunc.itemEx({vp = "+taker.GetPlayerUserId()+", ap = "+giver.GetPlayerUserId()+", item = "+hold.GetEntityIndex()+"})", passtime );
				//	::manacatAddTimer(passtime, false, ::itemExFunc.itemEx, { vp = taker, ap = giver, item = hold });
					//EmitSoundOnClient("Hint.BigReward", giver);
					::itemExTalk.speakVocal({ model = giver.GetModelName(), code = "give", force = true });
					actionChk = 1;
					writeTime(giver);
				}
			}

			//하지만 가져오는 것은 밀치기가 좀 더 잘 먹히므로 존속
			if(//(::mp_gamemode == "coop" || ::mp_gamemode == "realism" || ::mp_gamemode == "survival") &&
			(IsPlayerABot(taker) || taker.IsIncapacitated()) && !IsPlayerABot(giver) && actionChk == 0 && dist < 85){
				local passChk = false;
				for(local i=2;i<=4;i++){
					local sloti = "slot"+i;
					if(!(sloti in vItems)) continue;
					if(!IsPlayerABot(taker) && sloti != "slot2") continue;
					if(i == 3 && giver.IsImmobilized())continue;
					local nowItem = vItems[sloti];
				
					if(!(sloti in aItems)){
						local wepClass = nowItem.GetClassname();
						local wskin = NetProps.GetPropInt(nowItem, "m_nSkin");

						passChk = true;
						giver.GiveItem(wepClass);
						EntFire( "worldspawn", "RunScriptCode", "g_ModeScript.itemExFunc.setSkin("+giver.GetPlayerUserId()+",\""+wepClass+"\","+NetProps.GetPropInt(nowItem, "m_nSkin")+")", 0.0 );

						nowItem.Kill();
						EntFire( "worldspawn", "RunScriptCode", "g_ModeScript.itemExTalk.speakVocal({model = \""+taker.GetModelName()+"\", code = \"welcome\", force = false})", 0.7 );
						writeTime(giver);
					}
				}

				if(passChk){
					EmitSoundOnClient("Pistol.ItemPickupRetract", giver);
				}
			}
		}
	}

	function setSkin(userid, wclass, skin){
		local player = GetPlayerFromUserID(userid);
		local throws = ::itemExFunc.GetThrowItem(player);
		local wslot = null;

		if(wclass == "weapon_molotov" || wclass == "weapon_pipe_bomb" || wclass == "weapon_vomitjar"){
			wslot = "slot2";
		}else if(wclass == "weapon_pain_pills" || wclass == "weapon_adrenaline"){
			wslot = "slot4";
		}else{
			wslot = "slot3";
		}
		if(wslot == null)return;

		local invTable = {};
		GetInvTable(player, invTable);
		if(!(wslot in invTable))return null;
		
		local weapon = invTable[wslot];
		
		if(weapon == null || !weapon.IsValid())return;

		NetProps.SetPropInt(weapon, "m_nSkin", skin);
		NetProps.SetPropInt(weapon, "m_nWeaponSkin", skin);
		
		if(wslot = "slot2"){
			local scrScope = player.GetScriptScope();
			scrScope.throwSkin <- skin;
		}
	}

	function itemEx(params){
		local ap = GetPlayerFromUserID(params.ap);		local vp = GetPlayerFromUserID(params.vp);		local item = Ent(params.item);
		if(ap == null || !ap.IsValid() || ap.GetClassname() != "player")return;
		if(vp == null || !vp.IsValid() || vp.GetClassname() != "player")vp = ap;
		if (item != null && item.IsValid()){
			local vItems = {}

			//DoEntFire("!self", "Use", "", 0, player2, weapon);
			GetInvTable(vp,vItems);
			if("slot2" in vItems)vp = ap;

			vp.GiveItem(item.GetClassname());
			printl(item);
			printl(NetProps.GetPropInt(item, "m_nWeaponSkin"));
			EntFire( "worldspawn", "RunScriptCode", "g_ModeScript.itemExFunc.setSkin("+vp.GetPlayerUserId()+",\""+item.GetClassname()+"\","+NetProps.GetPropInt(item, "m_nSkin")+")", 0.0 );
			DoEntFire("!self", "Kill", "", 0, null, item);

			if (!IsPlayerABot(vp))
				vp.SwitchToItem(item.GetClassname());

			if(ap != vp){
				DoEntFire("!self", "speakresponseconcept", "PlayerThanks", 1.8, null, vp);
				EmitSoundOnClient("Hint.BigReward", ap);	EmitSoundOnClient("Hint.LittleReward", vp);
			}
		}
	}

	function OnGameEvent_player_shoved(params){
		local victim = GetPlayerFromUserID(params.userid);
		local attacker = GetPlayerFromUserID(params.attacker);
		::itemExFunc.exchangeItem(attacker, victim);
	}

	function chkTime(tg){
		if(tg == null || !tg.IsValid())return;
		tg.ValidateScriptScope();
		local scrScope = tg.GetScriptScope();
		if(!("exTime" in scrScope))scrScope.exTime <- 0;
		if(Time() >= scrScope.exTime+1.3)return true; //기능 사용가능
		return false;
	}

	function writeTime(tg){
		if(tg == null || !tg.IsValid())return;
		tg.ValidateScriptScope();
		local scrScope = tg.GetScriptScope();
		scrScope.exTime <- Time();
	}

	function GetThrowItem(tg){
		local invTable = {};
		GetInvTable(tg, invTable);
		if(!("slot2" in invTable))return null;
		
		local weapon = invTable.slot2;
		
		if(weapon != null && weapon.IsValid())return weapon;
		
		return null;
	}

	function GetFocusEntity(player){
		if(player.IsValid){
			if (!("EyeAngles" in player))return;

			local startPt = player.EyePosition();
			local endPt = startPt + player.EyeAngles().Forward().Scale(999999);
	
			local m_trace = { start = startPt, end = endPt, ignore = player, mask = 33579137 };
			TraceLine(m_trace);
	
			if (!m_trace.hit || m_trace.enthit == null || m_trace.enthit == player)return null;
	
			if (m_trace.enthit.GetClassname() == "worldspawn" || !m_trace.enthit.IsValid())return null;
	
			return m_trace.enthit;
		}
		return;
	}
}

__CollectEventCallbacks(::itemExFunc, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);