::hdmdSurvVars<-{
	playerList = []	
	playerCount = 0
	humanCount = 0
	kitCount = 0
	teamPower = 0.0	//팀 수행능력
	incapTime = -1 //-1이면 무력화된 적이 없는 것
	vomitTime = -1 //-1이면 부머즙에 맞은 적이 없는 것
	temphealIndex = 0 //진통제/아드 사용할 때마다 ++
	temphealList = [] //유휴 상태로 전환되었을 때 진통제/아드 효과가 끊어지는 것 방지
	reviveList = [] //구조 시행시 등록하고 구조 종료시 제거
	allInDangerTime = 0 //모두 잡히거나 죽었을 때 시간, 3초 뒤에도 상황 호전되지 않으면 피헤 원래대로 들어감

	incaphint = [] //무력화되었을 때 E키를 꾹 누르면 자살한다는 힌트, 언어별로 생성함
	incapfrancis = ["deathscream02" "deathscream05"]
	incaplouis = ["deathscream01" "deathscream08"]
	incapbill = ["deathscream07" "deathscream08"]
	incapzoey = ["deathscream01" "deathscream02" "deathscream03" "deathscream04"]
	incapcoach = ["deathscream07" "deathscream08"]
	incapnick = ["deathscream04" "deathscream05"]
	incapellis = ["deathscream04" "deathscream05" "deathscream06"]
	incaprochelle = ["hurtminor05"]
}

::hdmdSurvFunc<-{
	function countPlayer(params = {}){
		::hdmdSurvVars.playerList = [];		::hdmdSurvVars.playerCount = 0;		::hdmdSurvVars.humanCount = 0;
		local player = null;
		while (player = Entities.FindByClassname(player, "player")){
			local model = player.GetModelName();
			if(player.IsValid() && NetProps.GetPropIntArray( player, "m_iTeamNum", 0) == 2 && model != "models/infected/hunter.mdl" && model != "models/infected/hunter_l4d1.mdl"){
				if(!IsPlayerABot(player))::hdmdSurvVars.humanCount++;
				::hdmdSurvVars.playerList.append([model, player, false]);
				::hdmdSurvVars.playerCount++;
			}
		}
		::hdmdSurvFunc.ammo();
	}

	function groundCheck(){
		for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
			local ground = ::hdmdSurvFunc.groundEntCheck(::hdmdSurvVars.playerList[i][1]);
			if(ground != null)::hdmdSurvVars.playerList[i][2] = ground;
		}
	}

	function groundEntCheck(ent, n=0){//그라운드가 엘리베이터인지 그라운드인지 체크용, 그라운드라면 true
		if(!ent.IsValid() || ent == null)return null;
		local entType = ent.GetClassname();
		local ground = null;
		if(entType == "player" || entType == "prop_physics"){
			ground = NetProps.GetPropEntity( ent, "m_hGroundEntity" );
		}else{
			ground = NetProps.GetPropEntity( ent, "m_hMoveParent" );
		}
		if(ground == null)return null;
		local gclass = ground.GetClassname();
		if(gclass == "worldspawn")return true;//땅 도달
		if(gclass == "func_elevator" || gclass == "func_tracktrain")return false;
		if(n < 3)return groundEntCheck(ground, n+1);
		else	return null;
	}

	function findPlayer(model){
		for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
			if(::hdmdSurvVars.playerList[i][0] == model && ::hdmdSurvVars.playerList[i][1].IsValid()){
				return ::hdmdSurvVars.playerList[i][1];
			}
		}
	}

	function teamAnalysis(params = {}){//팀의 수행능력 평가
		local player = null;
		::hdmdSurvVars.teamPower = 0.0;
		::hdmdSurvVars.kitCount = 0;
		while (player = Entities.FindByClassname(player, "player")){
			if(player.IsValid() && NetProps.GetPropInt( player, "m_iTeamNum" ) == 2){
				local power = 0.0;
				if(player.IsDead() || player.IsDying()){
					power = 0.0;
				}else if(player.IsIncapacitated()){
					power = 0.2;
				}else{
					local hp = player.GetHealth();
					if(100 >= hp && hp > 80){
						power = 1.0;
					}else if(80 >= hp && hp > 40){
						power = 0.8;
					}else if(40 >= hp){
						power = 0.4;
					}
				}
				if(::hdmdSurvFunc.itemChk(player, "weapon_first_aid_kit")){
					if(power <= 0.4)power += 0.1;
					::hdmdSurvVars.kitCount++;
				}
				if(player.IsOnThirdStrike())power -= 0.1;
				if(IsPlayerABot(player))power /= 2;
				if(power < 0)power = 0;
				::hdmdSurvVars.teamPower += power;
			}
		}
	}

	function countKits(){//팀이 보유한 응급 처치 키트 갯수
		local _player = null;
		local kits = 0;
		while (_player = Entities.FindByClassname(_player, "player")){
			if(_player.IsValid())if(itemChk(_player, "weapon_first_aid_kit")){
				kits++;
			}
		}
		return kits;
	}

	function itemChk(surv, itemname){
		local items = {}
		GetInvTable(surv,items);
		foreach( slot, item in items ){
			if (item.GetClassname() == itemname){
				return true;
			}
		}
		return false;
	}

	function OnGameEvent_player_connect(params){
		::hdmdSurvFunc.countPlayer();
	}
	function OnGameEvent_player_connect_full(params){
		local player = GetPlayerFromUserID(params.userid);
		if(player == GetListenServerHost()){
			::hdmdState.admin = player.GetNetworkIDString();
			StringToFile("hardmode/admin.txt", ::hdmdState.admin);
		}
		::hdmdSurvFunc.countPlayer();
	}
	function OnGameEvent_player_disconnect(params){
		if(GetPlayerFromUserID(params.userid) == GetListenServerHost()){	//printl("서버 종료");
			::hardmodeVars.sessionData <- {};
			SaveTable("hdmd", ::hardmodeVars.sessionData);
			return;
		}
		::manacatAddTimer(0.1, false, ::hdmdSurvFunc.countPlayer, { });
		//::manacatAddTimer(0.1, false, ::hdmdSurvFunc.teamAnalysis, { });	//changeD에 포함됨
		::manacatAddTimer(0.2, false, ::hardmodeFunc.changeD, { });
	}
	function OnGameEvent_finale_win(params){
		::hardmodeVars.sessionData <- {};
		SaveTable("hdmd", ::hardmodeVars.sessionData);
		return;
	}
	function OnGameEvent_player_team(params){
		::hdmdSurvFunc.countPlayer();
		::hardmodeFunc.changeD({});

		local player = GetPlayerFromUserID(params.userid);
		if(player == null || !player.IsValid() || !player.IsSurvivor())return;
	}
	function OnGameEvent_bot_player_replace(params){
		::hdmdSurvFunc.countPlayer();
		local player = GetPlayerFromUserID(params.player);
		local bot = GetPlayerFromUserID(params.bot);
		::hdmdSurvFunc.throwerFix(bot, player);
	}
	function OnGameEvent_player_bot_replace(params){
		::hdmdSurvFunc.countPlayer();
		local player = GetPlayerFromUserID(params.player);
		local bot = GetPlayerFromUserID(params.bot);
		::hdmdSurvFunc.throwerFix(player, bot);
	}
	function throwerFix(player, bot){
		local ent = null;
		while (ent = Entities.FindByClassname(ent, "*_projectile")){
			if(ent.IsValid() && NetProps.GetPropEntity( ent, "m_hThrower" ) == player){
				NetProps.SetPropEntity( ent, "m_hThrower", bot );
			}
		}
		ent = null;
		while (ent = Entities.FindByClassname(ent, "inferno")){
			if(ent.IsValid() && NetProps.GetPropEntity( ent, "m_hOwnerEntity" ) == player){
				NetProps.SetPropEntity(	ent, "m_hOwnerEntity", bot );
			}
		}
		ent = null;
		while (ent = Entities.FindByClassname(ent, "fire_cracker_blast")){
			if(ent.IsValid() && NetProps.GetPropEntity( ent, "m_hOwnerEntity" ) == player){
				NetProps.SetPropEntity(	ent, "m_hOwnerEntity", bot );
			}
		}

		//진통제/아드레날린
		local len = ::hdmdSurvVars.temphealList.len();
		for(local i = 0; i < len; i++){
			if(::hdmdSurvVars.temphealList[i][1] == player){
				::hdmdSurvVars.temphealList[i][1] = bot;
			}
		}
	}
	function OnGameEvent_round_start_post_nav(params){
		::hdmdSurvFunc.countPlayer();
		::hdmdItemFunc.weapon_restore();
		::manacatAddTimer(0.0, false, ::hdmdItemFunc.weaponCall, {});
	}
	function OnGameEvent_player_first_spawn(params){
		::hdmdSurvFunc.countPlayer();
	}
	function OnGameEvent_player_entered_start_area(params){
		::hdmdSurvFunc.countPlayer();
	}
	function OnGameEvent_player_transitioned(params){
		::hdmdSurvFunc.countPlayer();
		local player = GetPlayerFromUserID(params.userid);
		if(!::hdmdState.start)DirectorScript.GetDirectorOptions().TempHealthDecayRate <- 0.0;
		::hdmdItemFunc.weapon_single_owner(player);
		::manacatAddTimer(0.1, false, ::hdmdItemFunc.item_restore, { pos = player.GetOrigin() });
		//::manacatAddTimer(0.1, false, ::hdmdItemFunc.weapon_single, {});
		::manacatAddTimer(0.1, false, ::hdmdItemFunc.weaponCall, {});
	}
	function OnGameEvent_player_spawn(params){
		local player = GetPlayerFromUserID(params.userid);
		local pztype = player.GetZombieType();

		if(player.GetZombieType() == 9){
			RestoreTable("hdmdintro", ::hardmodeVars.introData);
			if(Director.IsSessionStartMap()){
				if(!::hdmdState.introskip){
					local mapName = Director.GetMapName();
					::hdmdState.introskip = true;
					if("intro" in ::hardmodeVars.introData && ::hardmodeVars.introData["intro"] == mapName){
						::introFunc.IntroSkip({});
					}else{
						::hardmodeVars.introData["intro"] <- mapName;
					}
				}
			}
			SaveTable("hdmdintro", ::hardmodeVars.introData);
			if(::hdmdState.lv <= 6)return;
			::manacatAddTimer(5.0, false, ::startmsg, { });
			return;
		}
	}

	function OnGameEvent_player_death(params){
		if("userid" in params){
			local player = GetPlayerFromUserID(params.userid);
			if(player.IsSurvivor()){
				local username = GetPlayerFromUserID(params.userid).GetPlayerName();
				if("count_death" in ::hardmodeVars.sessionData)::hardmodeVars.sessionData["count_death"]++;
				::hdmdSurvFunc.teamAnalysis();
				::manacatAddTimer(1.0, false, ::hdmdSIFunc.releaseCap, { });
			/*	::changeDcall("▼ - "+username+" died",
							"▼ - "+username+" 사망",
							"▼ - "+username+"の死亡",
							"▼ - "+username+" ha fallecido");
				local sec = 0;
				if(::hdmdSurvVars.incapTime+30 > Time()){
					sec = ((Time()+30)-(::hdmdSurvVars.incapTime+30)).tostring();
					if(sec.find(".") != null)sec = sec.slice(0,sec.find(".")+2);
					if(sec.slice(sec.len()-2) == ".0")sec = sec.slice(0,sec.len()-2);
					::changeDcall("▼ - Incap set extended by "+sec+" seconds",
								"▼ - 무력화 상황 "+sec+"초 연장",
								"▼ - 無力化状況 "+sec+"超延長",
								"▼ - set de incapacitaciones extendido por "+sec+" segundos");
				}//*/
			}
		}
	}

	function OnGameEvent_player_incapacitated(params){
		if(GetPlayerFromUserID(params.userid).IsSurvivor()){
			::manacatAddTimer(1.0, false, ::hdmdSIFunc.releaseCap, { });
			::hdmdSurvVars.incapTime = Time();
			::hdmdState.incap = true;
			::manacatAddTimer(30.0, false, ::hdmdSurvFunc.incapOff, { });
		}
	}

	function OnGameEvent_player_incapacitated_start(params){
		//포기 힌트 생성
		local player = GetPlayerFromUserID(params.userid);
		local hint = null;
		if(player.IsValid() && !IsPlayerABot(player)){
			local lang = 0;
			switch(Convars.GetClientConvarValue("cl_language", player.GetEntityIndex())){
				case "korean":case "koreana":	lang = 1;	break;
				case "japanese":				lang = 2;	break;
				case "spanish":					lang = 3;	break;
				default:						lang = 0;	break;
			}
			
			local len = ::hdmdSurvVars.incaphint.len();
			for(local i = 0; i < len; i++){
				if(::hdmdSurvVars.incaphint[i][0] == player){
					hint = ::hdmdSurvVars.incaphint[i][1];
					break;
				}
			}

			if(hint == null){
				local msg = ["Hold to give up survival...", "누르고 있으면 생존을 포기합니다...", "生存を諦めるにはボタンを押し続けます...", "Mantenga para renunciar a la supervivencia..."];
				hint = g_ModeScript.CreateSingleSimpleEntityFromTable({
					classname = "env_instructor_hint",
					hint_allow_nodraw_target = "1",
					hint_alphaoption = "1",
					hint_caption = msg[lang],
					hint_color = "255 255 255",
					hint_forcecaption = "1",//0이면 벽 통과 안함, 1이면 벽 통과해서 표시
					hint_icon_offscreen = "use_binding",
					hint_icon_onscreen = "use_binding",
					hint_binding = "+duck"
					hint_instance_type = "1",
					hint_pulseoption = "0",
					hint_static = "1",//0이면 타겟에, 1이면 화면고정
					targetname = "hdmd_hint_incap",
				});
				::hdmdSurvVars.incaphint.append([player, hint]);
			}

			::manacatAddTimer(1.0, false, ::hdmdSurvFunc.giveupHintTimer, { player = player, hint = hint, delay = 0, hold = 0, flow = GetCurrentFlowDistanceForPlayer(player) });
		}
	}

	function allInDanger(){
		for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
			if(::hdmdSurvVars.playerList[i][1] == null || !::hdmdSurvVars.playerList[i][1].IsValid() ||
			::hdmdSurvVars.playerList[i][1].IsDead() || ::hdmdSurvVars.playerList[i][1].IsDying() || ::hdmdSurvVars.playerList[i][1].IsIncapacitated() ||::hdmdSurvVars.playerList[i][1].IsDominatedBySpecialInfected())continue;
			::hdmdSurvVars.allInDangerTime = Time();
			break;
		}
		return ::hdmdSurvVars.allInDangerTime;
	}

	function giveupHintTimer(params){
		if(params.hint != null && params.hint.IsValid() && params.player != null && params.player.IsValid()){
			if(params.player.IsIncapacitated()){
				local showswitch = true;
				if(Director.IsTankInPlay()){
					showswitch = false;
				}else{
					for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
						if(::hdmdSurvVars.playerList[i][1] == null || !::hdmdSurvVars.playerList[i][1].IsValid() ||
						::hdmdSurvVars.playerList[i][1].IsDead() || ::hdmdSurvVars.playerList[i][1].IsDying() || ::hdmdSurvVars.playerList[i][1].IsIncapacitated() ||::hdmdSurvVars.playerList[i][1].IsDominatedBySpecialInfected() ||
						::hdmdSurvVars.playerList[i][1] == params.player)continue;
						local criteria = (ResponseCriteria.GetValue(::hdmdSurvVars.playerList[i][1],"incheckpoint").tointeger() > 0) ? true : false;
						if(criteria){
						}else{//한명이라도 안전지대에 없음
							local dist = GetCurrentFlowDistanceForPlayer(::hdmdSurvVars.playerList[i][1]) - params.flow;
							if(dist < 1500){//거리도 멀지 않음
								params.delay = 0;	params.hold = 0;
								showswitch = false;
							}
						}
					}
				}
				if(showswitch && params.delay > 50 && params.hold <= 40)DoEntFire("!self", "ShowHint", "", 0.0, params.player, params.hint);
				else	DoEntFire("!self", "EndHint", "", 0.0, params.player, params.hint);
			}else{
				DoEntFire("!self", "EndHint", "", 0.0, params.player, params.hint);
				return;
			}
			params.delay++;
			if(params.delay > 50 && (NetProps.GetPropInt( params.player, "m_nButtons") & 4)==4){
				if(params.hold > 40){
					local vocal = "";
					switch(params.player.GetModelName()){
						case "models/survivors/survivor_teenangst.mdl":
							vocal = "scenes/TeenGirl/";
							vocal += ::hdmdSurvVars.incapzoey[RandomInt(0,::hdmdSurvVars.incapzoey.len()-1)];		break;
						case "models/survivors/survivor_biker.mdl":
							vocal = "scenes/Biker/";
							vocal += ::hdmdSurvVars.incapfrancis[RandomInt(0,::hdmdSurvVars.incapfrancis.len()-1)];		break;
						case "models/survivors/survivor_namvet.mdl":
							vocal = "scenes/NamVet/";
							vocal += ::hdmdSurvVars.incapbill[RandomInt(0,::hdmdSurvVars.incapbill.len()-1)];		break;
						case "models/survivors/survivor_manager.mdl":
							vocal = "scenes/Manager/";
							vocal += ::hdmdSurvVars.incaplouis[RandomInt(0,::hdmdSurvVars.incaplouis.len()-1)];		break;
						case "models/survivors/survivor_mechanic.mdl":
							vocal = "scenes/Mechanic/";
							vocal += ::hdmdSurvVars.incapellis[RandomInt(0,::hdmdSurvVars.incapellis.len()-1)];		break;
						case "models/survivors/survivor_producer.mdl":
							vocal = "scenes/Producer/";
							vocal += ::hdmdSurvVars.incaprochelle[RandomInt(0,::hdmdSurvVars.incaprochelle.len()-1)];		break;
						case "models/survivors/survivor_gambler.mdl":
							vocal = "scenes/Gambler/";
							vocal += ::hdmdSurvVars.incapnick[RandomInt(0,::hdmdSurvVars.incapnick.len()-1)];		break;
						case "models/survivors/survivor_coach.mdl":
							vocal = "scenes/Coach/";
							vocal += ::hdmdSurvVars.incapcoach[RandomInt(0,::hdmdSurvVars.incapcoach.len()-1)];		break;
					}
					vocal += ".vcd";
					params.player.PlayScene(vocal, 0.0);
					params.player.TakeDamage(1000,128,params.player);
				}
				params.hold++;
			}else{
				params.hold = 0;
			}
			::manacatAddTimer(0.1, false, ::hdmdSurvFunc.giveupHintTimer, params);
		}
	}

	function incapOff(params){
		if(::hdmdSurvVars.incapTime+30 <= Time()){
			::hdmdState.incap = false;
		}
	}

	function OnGameEvent_player_now_it(params){
		::hdmdSurvVars.vomitTime = Time();
	}

	function OnGameEvent_survivor_rescued(params){
		::hdmdSurvFunc.player_revive(GetPlayerFromUserID(params.victim), 1);
		::manacatAddTimer(0.5, false, ::hardmodeFunc.changeD, { });
	}

	function OnGameEvent_defibrillator_used(params){
		::hdmdSurvFunc.player_revive(GetPlayerFromUserID(params.subject), 2);
		::manacatAddTimer(0.5, false, ::hardmodeFunc.changeD, { });
	}

	function player_revive(player, rtype){
		if(player != null && player.IsValid()){
			if(::hdmdState.lv >= 5){
				player.SetReviveCount(1);
				if(rtype == 1){
					player.SetHealth(25);	player.SetHealthBuffer(25);
				}else{
					player.SetHealth(15);	player.SetHealthBuffer(35);
				}
			}else if(::hdmdState.lv >= 3){
				player.SetReviveCount(1);
				if(rtype == 1){
					player.SetHealth(30);	player.SetHealthBuffer(20);
				}else{
					player.SetHealth(20);	player.SetHealthBuffer(30);
				}
			}
		}
	}

	function OnGameEvent_item_pickup(params){
		if(params.item == "first_aid_kit"){
			::hdmdSurvVars.kitCount++;
			::hdmdSurvFunc.teamAnalysis();
		}
	}

	function OnGameEvent_player_use(params){
		//겹쳐져있는 아이템이 있는지 확인, 있으면 제거 (7등급 난이도 진통제 복사버그 때문에 추가한 기능)
		local item = Ent(params.targetid);
		local itemClass = item.GetClassname();
		local itemOrigin = item.GetOrigin();

		if(itemClass == "weapon_pain_pills_spawn" || itemClass == "weapon_adrenaline_spawn" || itemClass == "weapon_first_aid_kit_spawn"){
			local ent = null;
			while (ent = Entities.FindByClassname(ent, itemClass)){
				if(ent.IsValid() && ent != item){
					local dist = (ent.GetOrigin() - itemOrigin).Length();
					if(dist < 1)ent.Kill();
				}
			}
		}
	}

	function OnGameEvent_heal_end(params){
		::hdmdSurvVars.kitCount--;
	}

	function OnGameEvent_pills_used(params){
		if(::hardmodeVars.dmg == 1){
			::hdmdSurvVars.temphealIndex++;
			::hdmdSurvVars.temphealList.append([::hdmdSurvVars.temphealIndex, GetPlayerFromUserID(params.userid), 50]);
			::manacatAddTimer(0.05, false, ::hdmdSurvFunc.tempheal, { playerindex = ::hdmdSurvVars.temphealIndex, tick = 0.005 });
		}
	}

	function OnGameEvent_adrenaline_used(params){
		if(::hardmodeVars.dmg == 1){
			::hdmdSurvVars.temphealIndex++;
			::hdmdSurvVars.temphealList.append([::hdmdSurvVars.temphealIndex, GetPlayerFromUserID(params.userid), 25]);
			::manacatAddTimer(0.1, false, ::hdmdSurvFunc.tempheal, { playerindex = ::hdmdSurvVars.temphealIndex, tick = 0.01 });
		}
	}

	function tempheal(params){
		local len = ::hdmdSurvVars.temphealList.len()-1;
		for(local i = len; i >= 0; i--){
			if(::hdmdSurvVars.temphealList[i][0] == params.playerindex){
				if(::hdmdSurvVars.temphealList[i][1] == null || !::hdmdSurvVars.temphealList[i][1].IsValid())return;
				if(::hdmdSurvVars.temphealList[i][1].IsDead() || ::hdmdSurvVars.temphealList[i][1].IsIncapacitated())return;
				local model = ::hdmdSurvVars.temphealList[i][1].GetModelName();
				if(model == "models/infected/hunter.mdl" || model == "models/infected/hunter_l4d1.mdl")return;
				local hp = ::hdmdSurvVars.temphealList[i][1].GetHealth();
				local hpb = ::hdmdSurvVars.temphealList[i][1].GetHealthBuffer();
				if(hp + hpb >= 100){	::hdmdSurvVars.temphealList.remove(i);	return;	}
				if(::hdmdSurvVars.temphealList[i][2] > 0){
					::hdmdSurvVars.temphealList[i][2]--;
					::hdmdSurvVars.temphealList[i][1].SetHealthBuffer(hpb+1);
					if(hp + hpb + 1 == 100){	::hdmdSurvVars.temphealList.remove(i);	return;	}
					::manacatAddTimer(params.tick, false, ::hdmdSurvFunc.tempheal, params);
				}else{
					::hdmdSurvVars.temphealList.remove(i);
				}
				return;
			}
		}
	}

	function OnGameEvent_player_left_safe_area(params){
		::hdmdSurvFunc.teamAnalysis();
		::hdmdItemFunc.kit2pills();

		local currentlevel = ::hdmdState.lv;
		if(currentlevel > 5)currentlevel = 5;

		if(!::hdmdState.start){
			::hdmdState.start = true;
			::hardmodeVars.startTime = Time();
			//::hardmodeVars.minitankPos = 40+RandomInt(1,20);
			::manacatAddTimer(25.0, false, ::hardmodeFunc.start, { }); //25초 후 본게임 시작
			::manacatAddTimerByName("hdmd_SI", 0.5, true, ::hdmdSIFunc.SI_spawn_manager);
			::hdmdSurvFunc.first_aid_kit();
			::hdmdSIFunc.startAttack();

			local ent = null;
			while (ent = Entities.FindByClassname(ent, "weapon_tank_claw")){
				if(ent.IsValid() && ent.GetName() == "hdmd_restore_mark")ent.Kill();
			}
		//	Convars.SetValue("pain_pills_decay_rate", 0.27);
			DirectorScript.GetDirectorOptions().TempHealthDecayRate <- 0.27;
		}

		Convars.SetValue("survivor_friendly_fire_factor_easy",0.0);		Convars.SetValue("survivor_friendly_fire_factor_expert",0.15);
		Convars.SetValue("survivor_friendly_fire_factor_hard",0.12);	Convars.SetValue("survivor_friendly_fire_factor_normal",0.1);
	}

	function OnGameEvent_player_hurt(params){
		local player = GetPlayerFromUserID(params.userid);
		local attacker = GetPlayerFromUserID(params.attacker);
		if("weapon" in params){
			switch(params.weapon){
				case "charger_claw":
					::hdmdSIFunc.si_attack(attacker);break;
			}
		}
		if(player != null && player.IsValid() && NetProps.GetPropIntArray( player, "m_iTeamNum", 0) == 2 && NetProps.GetPropIntArray( attacker, "m_iTeamNum", 0) != 2){
			if(IsPlayerABot(player)){
				/*local len = ::hdmdSurvVars.reviveList.len();
				for(local i = 0; i < len; i++){
					if(::hdmdSurvVars.reviveList[i] == player){
						행동을 막을 수 있는 코드, game_ui로 얼리기 안됨, commandAbot으로 AI 리셋 안됨
					}
				}*/
			}else{
				//공격당하면 진행률 취소 (발전기 등)
				if((NetProps.GetPropInt( player, "m_nButtons") & 32) == 32){
					::hdmdSurvFunc.keyBlock({ survivor = player, key = 32 });
					::manacatAddTimer(0.01, false, ::hdmdSurvFunc.keyBlock, { survivor = player, key = 0 });
				}else{
					//기름 넣고 있을 때 공격당하면 진행률 취소
					local activeWeapon = player.GetActiveWeapon();
					if(activeWeapon != null && activeWeapon.IsValid() && activeWeapon.GetClassname() == "weapon_gascan"){
						::hdmdSurvFunc.keyBlock({ survivor = player, key = 33 });
						::manacatAddTimer(0.01, false, ::hdmdSurvFunc.keyBlock, { survivor = player, key = 0 });
						return;
					}
				}
			}
		}
	}

	function OnGameEvent_revive_begin(params){
		::hdmdSurvFunc.reviveListAdd(GetPlayerFromUserID(params.userid));
	}

	function OnGameEvent_revive_success(params){
		::hdmdSurvFunc.reviveListRemove(GetPlayerFromUserID(params.userid));
	}

	function OnGameEvent_revive_end(params){
		::hdmdSurvFunc.reviveListRemove(GetPlayerFromUserID(params.userid));
	}

	function reviveListAdd(player){
		local len = ::hdmdSurvVars.reviveList.len();
		for(local i = 0; i < len; i++){
			if(::hdmdSurvVars.reviveList[i] == player)return;
		}
		::hdmdSurvVars.reviveList.append(player);
	}

	function reviveListRemove(player){
		local len = ::hdmdSurvVars.reviveList.len()-1;
		for(local i = len; i >= 0; i--){
			if(::hdmdSurvVars.reviveList[i] == player)::hdmdSurvVars.reviveList.remove(i);
		}
	}

	function keyBlock(params){//0 = 해제
		NetProps.SetPropInt( params.survivor, "m_afButtonDisabled", params.key);
	}

	function burn_factor_ez(){
		return;
		Convars.SetValue("survivor_burn_factor_easy", 0.2);		Convars.SetValue("survivor_burn_factor_normal", 0.2);
		Convars.SetValue("survivor_burn_factor_hard", 0.3);		Convars.SetValue("survivor_burn_factor_expert", 0.5);
	}

	function burn_factor(){
		return;
		local tankaggro = Director.IsTankInPlay();
		if(::hdmdSurvVars.playerCount <= 2 || ::hardmodeVars.incapChk == true || tankaggro){
			burn_factor_ez();
		}else{
			if(::mp_gamemode == "coop" || ::mp_gamemode == "versus"){
				if(tankaggro)
					Convars.SetValue("z_burning_lifetime", 30);
				else Convars.SetValue("z_burning_lifetime", 60);
				switch(::hdmdState.lv){
					case 7:
						Convars.SetValue("survivor_burn_factor_easy", 0.3);		Convars.SetValue("survivor_burn_factor_normal", 0.4);
						Convars.SetValue("survivor_burn_factor_hard", 0.5);		Convars.SetValue("survivor_burn_factor_expert", 0.8);
						break;
					case 6:
						Convars.SetValue("survivor_burn_factor_easy", 0.2);		Convars.SetValue("survivor_burn_factor_normal", 0.2);
						Convars.SetValue("survivor_burn_factor_hard", 0.35);	Convars.SetValue("survivor_burn_factor_expert", 0.7);
						break;
					default:
						Convars.SetValue("survivor_burn_factor_easy", 0.2);		Convars.SetValue("survivor_burn_factor_normal", 0.2);
						Convars.SetValue("survivor_burn_factor_hard", 0.3);		Convars.SetValue("survivor_burn_factor_expert", 0.6);
						break;
				}
			}else if(::mp_gamemode == "realism"){
				if(tankaggro)
					Convars.SetValue("z_burning_lifetime", 30);
				else Convars.SetValue("z_burning_lifetime", 75);
				switch(::hdmdState.lv){
					case 7:
						Convars.SetValue("survivor_burn_factor_easy", 0.3);		Convars.SetValue("survivor_burn_factor_normal", 0.4);
						Convars.SetValue("survivor_burn_factor_hard", 0.6);		Convars.SetValue("survivor_burn_factor_expert", 0.9);
						break;
					case 6:
						Convars.SetValue("survivor_burn_factor_easy", 0.3);		Convars.SetValue("survivor_burn_factor_normal", 0.3);
						Convars.SetValue("survivor_burn_factor_hard", 0.5);		Convars.SetValue("survivor_burn_factor_expert", 0.8);
						break;
					default:
						Convars.SetValue("survivor_burn_factor_easy", 0.3);		Convars.SetValue("survivor_burn_factor_normal", 0.3);
						Convars.SetValue("survivor_burn_factor_hard", 0.35);	Convars.SetValue("survivor_burn_factor_expert", 0.7);
						break;
				}
			}
		}
	}

	function first_aid_kit(){
		if(::hdmdSurvVars.playerCount == 1 || !::hdmdState.start || ::hdmdState.gamemode == 1){
			Convars.SetValue("first_aid_kit_use_duration", 3);
			Convars.SetValue("survivor_revive_duration", 3);
			Convars.SetValue("first_aid_heal_percent", 0.9);
			Convars.SetValue("first_aid_kit_max_heal", 100);
		}else{
			Convars.SetValue("first_aid_kit_use_duration", 5);
			Convars.SetValue("survivor_revive_duration", 5);
			Convars.SetValue("first_aid_heal_percent", 0.8+((5-::hdmdState.lv)*0.025));
			if(::hdmdState.finale || Director.IsTankInPlay()){
				Convars.SetValue("first_aid_kit_max_heal", 100);
			}else{
				Convars.SetValue("first_aid_kit_max_heal", 95);
			}
		}

		if(::hdmdState.lv <= 3){
			Convars.SetValue("rescue_min_dead_time", 20);
		}else if(::hdmdState.lv == 4){
			Convars.SetValue("rescue_min_dead_time", 60);
		}else if(::hdmdState.lv == 5){
			Convars.SetValue("rescue_min_dead_time", 120);
		}else if(::hdmdState.lv == 6){
			Convars.SetValue("rescue_min_dead_time", 150);
		}else if(::hdmdState.lv == 7){
			Convars.SetValue("rescue_min_dead_time", 300);
		}
	}

	function hp_bonus(player, hp, limit){
		if(player != null && player.IsValid() && !player.IsDead() && !player.IsDying() && !player.IsIncapacitated() && !player.IsDominatedBySpecialInfected()){
			if(::hdmdSurvVars.playerCount == 1)limit *= 2;
			else if(::hdmdSurvVars.playerCount == 2)limit *= 1.5;
			else if(::hdmdSurvVars.playerCount == 3)limit *= 1.25;
			if(limit > 100)limit = 100;
			local chp = (player.GetHealth()+player.GetHealthBuffer()).tointeger();
			if(chp < limit){
				if(chp+hp > limit){
					hp += limit-(chp+hp);
				}
				if(hp >= 10)EmitSoundOnClient("Hint.BigReward", player);
				player.SetHealthBuffer(player.GetHealthBuffer()+hp);
			}
			if(player.GetHealth() < 15 && player.GetHealthBuffer() >= 1){
				local hp_b = player.GetHealthBuffer();
				if(player.GetHealthBuffer() > 15)hp_b = 15;
				player.SetHealth(player.GetHealth()+hp_b);
				player.SetHealthBuffer(player.GetHealthBuffer()-hp_b);
			}
		}
	}

	function OnGameEvent_weapon_fire(params){
		if(::hdmdState.gamemode == 0)return;
		local player = GetPlayerFromUserID(params.userid);		if(!player.IsSurvivor())return;
		if(params.weapon == "pumpshotgun" || params.weapon == "shotgun_chrome" || params.weapon == "autoshotgun" || params.weapon == "shotgun_spas"){
			local invTable = {};
			GetInvTable(player, invTable);
			if(!("slot0" in invTable))return;
			local weapon = invTable.slot0;		local mag = 0;
			local ammotype = NetProps.GetPropInt( weapon, "m_iPrimaryAmmoType" );
		//	local ammo = NetProps.GetPropIntArray( player, "m_iAmmo", ammotype );
			local clip = NetProps.GetPropInt( weapon, "m_iClip1" );
			local ammolimit = 0;
			switch(weapon.GetClassname()){
				case "weapon_pumpshotgun":case "weapon_shotgun_chrome":
					ammolimit = Convars.GetFloat("ammo_shotgun_max");
					mag = 8;	break;
				case "weapon_autoshotgun":case "weapon_shotgun_spas":
					ammolimit = Convars.GetFloat("ammo_autoshotgun_max");
					mag = 10;	break;
				default:return;
			}
			NetProps.SetPropIntArray( player, "m_iAmmo", ammolimit+mag-clip+1, ammotype );
		}
	}

	function OnGameEvent_weapon_reload(params){
		if(::hdmdState.gamemode == 0)return;
		local player = GetPlayerFromUserID(params.userid);
		local invTable = {};
		GetInvTable(player, invTable);
		if(!("slot0" in invTable))return;
		local weapon = invTable.slot0;		local mag = 0;
		local ammotype = NetProps.GetPropInt( weapon, "m_iPrimaryAmmoType" );
		local ammo = NetProps.GetPropIntArray( player, "m_iAmmo", ammotype );
		local clip = NetProps.GetPropInt( weapon, "m_iClip1" );
		local ammolimit = 0;
		switch(weapon.GetClassname()){
			case "weapon_smg":case "weapon_smg_silenced":case "weapon_smg_mp5":case "weapon_rifle":case "weapon_rifle_sg552":	mag = 50;	break;
			case "weapon_rifle_ak47":																							mag = 40;	break;
			case "weapon_hunting_rifle":																						mag = 15;	break;
			case "weapon_sniper_military":case "weapon_sniper_scout":case "weapon_sniper_awp":									mag = 30;	break;
		//	case "weapon_pumpshotgun":case "weapon_shotgun_chrome":																mag = 8;	break;
		//	case "weapon_autoshotgun":case "weapon_shotgun_spas":																mag = 10;	break;
		}
		switch(ammotype){
			case 3:ammolimit = Convars.GetFloat("ammo_assaultrifle_max");	break;
			case 5:ammolimit = Convars.GetFloat("ammo_smg_max");	break;
		//	case 7:ammolimit = Convars.GetFloat("ammo_shotgun_max");	break;
		//	case 8:ammolimit = Convars.GetFloat("ammo_autoshotgun_max");	break;
			case 9:ammolimit = Convars.GetFloat("ammo_huntingrifle_max");	break;
			case 10:ammolimit = Convars.GetFloat("ammo_sniperrifle_max;");	break;
		}
		if(ammolimit <= 0)return;
		if(ammo < ammolimit+mag)NetProps.SetPropIntArray( player, "m_iAmmo", ammolimit+mag, ammotype );
	}

	function ammo(){
		local assaultrifle = 30;
		local autoshotgun = 15;
		local huntingrifle = 15;
		local shotgun = 8;
		local smg = 50;
		local sniperrifle = 30;

		local ammo_assaultrifle = 0;
		local ammo_autoshotgun = 0;
		local ammo_huntingrifle = 0;
		local ammo_shotgun = 0;
		local ammo_smg = 0;
		local ammo_sniperrifle = 0;

		if(::hdmdState.ammo == 0){
				ammo_assaultrifle = assaultrifle*	12;
				ammo_autoshotgun = autoshotgun*		6;
				ammo_huntingrifle = huntingrifle*	10;
				ammo_shotgun = shotgun*				9;
				ammo_smg = smg*						13;
				ammo_sniperrifle = sniperrifle*		6;
		}else{
			if(::hdmdState.finale){
				ammo_assaultrifle = assaultrifle*	12;
				ammo_autoshotgun = autoshotgun*		6;
				ammo_huntingrifle = huntingrifle*	10;
				ammo_shotgun = shotgun*				9;
				ammo_smg = smg*						13;
				ammo_sniperrifle = sniperrifle*		6;
			}else{
				ammo_assaultrifle = assaultrifle*	15;
				ammo_autoshotgun = autoshotgun*		9;
				ammo_huntingrifle = huntingrifle*	12;
				ammo_shotgun = shotgun*				11;
				ammo_smg = smg*						15;
				ammo_sniperrifle = sniperrifle*		7;
			}

			local bonus = 0;
			if(::hdmdSurvVars.playerCount == 2)bonus = 2;
			else if(::hdmdSurvVars.playerCount == 1)bonus = 4;
			
			ammo_assaultrifle += assaultrifle*bonus;
			ammo_autoshotgun += autoshotgun*bonus;
			ammo_huntingrifle += huntingrifle*bonus;
			ammo_shotgun += shotgun*bonus;
			ammo_smg += smg*bonus;
			ammo_sniperrifle += sniperrifle*bonus;
		}

		Convars.SetValue("ammo_assaultrifle_max", ammo_assaultrifle);
		Convars.SetValue("ammo_autoshotgun_max", ammo_autoshotgun);
		Convars.SetValue("ammo_huntingrifle_max", ammo_huntingrifle);
		Convars.SetValue("ammo_shotgun_max",ammo_shotgun);
		Convars.SetValue("ammo_smg_max", ammo_smg);
		Convars.SetValue("ammo_sniperrifle_max", ammo_sniperrifle);

		local ent = null;
		while (ent = Entities.FindByClassname(ent, "player")){
			if(ent.IsValid() && ent.IsSurvivor()){
				local invTable = {};
				GetInvTable(ent, invTable);
				if(!("slot0" in invTable))continue;
				local weapon = invTable.slot0;
				local ammotype = NetProps.GetPropInt( weapon, "m_iPrimaryAmmoType" );
				local ammo = NetProps.GetPropIntArray( ent, "m_iAmmo", ammotype );
				local clip = NetProps.GetPropInt( weapon, "m_iClip1" );
				local ammolimit = 0;
				switch(ammotype){
					case 3:ammolimit = ammo_assaultrifle;	break;
					case 5:ammolimit = ammo_smg;	break;
					case 7:ammolimit = ammo_shotgun;	break;
					case 8:ammolimit = ammo_autoshotgun;	break;
					case 9:ammolimit = ammo_huntingrifle;	break;
					case 10:ammolimit = ammo_sniperrifle;	break;
				}
				if(ammolimit == 0)continue;
				if(ammotype != 7 && ammotype != 8 && clip == 0 && ammo != 0)	ammolimit+=weapon.GetMaxClip1();
				if(ammo > ammolimit)	NetProps.SetPropIntArray( ent, "m_iAmmo", ammolimit, ammotype );
			}
		}
	}
}

__CollectEventCallbacks(::hdmdSurvFunc, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);