::showhpFunc<-
{
	function OnGameEvent_player_hurt(params)
	{
		if(::mp_gamemode == "versus")return;
		local victim = GetPlayerFromUserID(params.userid);
		local attacker = GetPlayerFromUserID(params.attacker);
		if(IsPlayerABot(attacker)||victim.IsSurvivor())return;
		if(!victim.IsDead()&&!victim.IsDying()&&!victim.IsIncapacitated()){
			ShowHpBar(params.health,NetProps.GetPropInt(victim,"m_iMaxHealth"),attacker,0,victim.GetPlayerName());
		}
	}

	function OnGameEvent_infected_hurt(params)
	{
		if(::mp_gamemode == "versus")return;
		local victim = Ent(params.entityid);
		local attacker = GetPlayerFromUserID(params.attacker);
		if(IsPlayerABot(attacker) || attacker == null)return;
		local nowHp = NetProps.GetPropInt(victim,"m_iHealth");
		local maxHp = NetProps.GetPropInt(victim,"m_iMaxHealth");
		if(victim.GetClassname() == "witch"){
			ShowHpBar(nowHp,maxHp,attacker,0,"witch");
		}//else if(victim.GetClassname() == "infected" && nowHp > 0){
			
		//}
	}
	
	function OnGameEvent_player_death(params)
	{
		if(::mp_gamemode == "versus")return;
		local victim;
		if(params.victimname == "Infected"){
			return;
		}else if(params.victimname == "Witch"){
			victim = Ent(params.entityid);
		}else{
			victim = GetPlayerFromUserID(params.userid);
		}
		local attacker = GetPlayerFromUserID(params.attacker);
		if(IsPlayerABot(attacker) || (victim.IsPlayer()&&victim.GetZombieType()==9))return;
		local headshot = params.headshot;
		//switch(params.victimname)
		//{
			/*
			case "Infected" :
			break;
			*/
		//	default :
				if(!headshot)	ShowHpBar(-1,100,attacker,0,params.victimname);
				else			ShowHpBar(-1,100,attacker,headshot,params.victimname);
		//	break;
		//}
	}
	function ShowHpBar(nowHp,maxHp,clientWho,headshot,tgname=""){
		if(!maxHp)return;
		local headN = tgname.slice(0, 3).tostring();
		switch(headN){
			case "(1)" :
			case "(2)" :
			case "(3)" :
			case "(4)" :
			case "(5)" :
			case "(6)" :
			case "(7)" :
			case "(8)" :
				tgname = tgname.slice(3).tostring();
			break;
		}
		tgname = tgname.tolower();
		if(tgname == "tank" || tgname == "witch")clientWho = null;
		if(tgname != "tank" && tgname != "witch" && clientWho == null)return;
		local tgnameEn = znameLang(tgname, maxHp, 0);
		local tgnameKr = znameLang(tgname, maxHp, 1);
		local tgnameJp = znameLang(tgname, maxHp, 2);
		local tgnameEs = znameLang(tgname, maxHp, 3);
		if(tgnameEn == null)return;
		local hplen = 20;
		if(maxHp >= 100)hplen = 30;
		if(maxHp >= 1000)hplen = 50;
		if(maxHp >= 2000)hplen = 70;
		if(nowHp<=0){

			if(headshot == 1)
			{
				//헤드샷 처치
				::printlang(tgnameEn+" KILLED",
							tgnameKr+" 처치",
							tgnameJp+" 撃退",
							tgnameEs+" MATADO",
							-2, clientWho);
			}
			else
			{
				::printlang(tgnameEn+" KILLED",
							tgnameKr+" 처치",
							tgnameJp+" 撃退",
							tgnameEs+" MATADO",
							-2, clientWho);
			}
			return;
		}
		local percent = nowHp.tofloat()/maxHp.tofloat();
		local nowHpsLen = ceil(percent * hplen);

		local hpbar="";
		for(local i = 0; i <nowHpsLen; i++)hpbar+="█";
		for(local i = 0; i < (hplen-nowHpsLen); i++)hpbar+="░";

		::printlang(hpbar+"\n"+tgnameEn+" "+nowHp+"/"+maxHp,
					hpbar+"\n"+tgnameKr+" "+nowHp+"/"+maxHp,
					hpbar+"\n"+tgnameJp+" "+nowHp+"/"+maxHp,
					hpbar+"\n"+tgnameEs+" "+nowHp+"/"+maxHp,
					-2, clientWho);
		//::dprint(hpbar+"\n"+tgname+" "+nowHp+"/"+maxHp, 2, 4, clientWho);
	}

	function znameLang(zname, hp, lang){
		switch(zname){
			case "tank" :
				if(::hardmodeVars.hpShow <= 1){
					if(hp == 1250 || hp == 2500){
						switch(lang){
							case 0:	case 3:	return "Mini Tank";
							case 1:			return "미니 탱크";
							case 2:			return "ミニタンク";
						}
					}else{
						switch(lang){
							case 0:	case 3:	return "Tank";
							case 1:			return "탱크";
							case 2:			return "タンク";
						}
					}
				}
			break;
			
			case "witch" :
				if(::hardmodeVars.hpShow <= 1){
					switch(lang){
						case 0:	case 3:	return "Witch";
						case 1:			return "윗치";
						case 2:			return "ウィッチ";
					}
				}
			break;

			case "boomer" :
				if(::hardmodeVars.hpShow == 0){
					switch(lang){
						case 0:	case 3:	return "Boomer";
						case 1:			return "부머";
						case 2:			return "ブーマー";
					}
				}
			break;
			case "hunter" :
				if(::hardmodeVars.hpShow == 0){
					switch(lang){
						case 0:	case 3:	return "Hunter";
						case 1:			return "헌터";
						case 2:			return "ハンター";
					}
				}
			break;
			case "smoker" :
				if(::hardmodeVars.hpShow == 0){
					switch(lang){
						case 0:	case 3:	return "Smoker";
						case 1:			return "스모커";
						case 2:			return "スモーカー";
					}
				}
			break;
			case "jockey" :
				if(::hardmodeVars.hpShow == 0){
					switch(lang){
						case 0:	case 3:	return "Jockey";
						case 1:			return "자키";
						case 2:			return "ジョッキー";
					}
				}
			break;
			case "spitter" :
				if(::hardmodeVars.hpShow == 0){
					switch(lang){
						case 0:	case 3:	return "Spitter";
						case 1:			return "스피터";
						case 2:			return "スピッター";
					}
				}
			break;
			case "charger" :
				if(::hardmodeVars.hpShow == 0){
					switch(lang){
						case 0:	case 3:	return "Charger";
						case 1:			return "차저";
						case 2:			return "チャージャー";
					}
				}
			break;
		}
		return null;
	}
}

__CollectEventCallbacks(::showhpFunc, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);