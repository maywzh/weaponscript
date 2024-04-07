::hdmdSIVars<-{
	attackList = []//성공한 공격을 담아놓는 배열, survivor.nut의 player_hurt에서 채워주고 가해특좀이 죽으면 제거
	siList = []
	//[0] = 특좀
	//[1] = 행동패턴의 상태
	//차저 : 0 = 이동, 1 = 공격
	//[2] = 특좀이 피격당한 시간

	fireList = []//불에 타는 특좀들

	hunter_jump = []//헌터 급습 피해를 위해 점프시 높이를 저장하는 배열
	hunter_pounce = []//[0]헌터 번호 [] [1]누적 피해
	jockey_jump = []//자키 급습 시간 기록
	jockey_ride = []//자키가 급습데미지를 줄 때 효과음이 나는 시간 (살 찢기는 효과음이 너무 시끄러워서)
	smoker_urgent_shot = 0//스모커가 당길 때 급히 쏴서 맞춘 횟수
	charger_mind = 0 //4가 될 때마다 공격하러 접근할지 이동할지를 판단

	boomerRes = 300 //부머 리스폰 확률 (최대값 1000)

	capture = []//특좀의 스폰 배열, [0]시간 [1]좀비타입 [2]강제?
	support = []//
	support_last = 0//마지막으로 스폰되었던 뿌리기 특좀 타입
	support_last_repeat = 0//같은 뿌리기 특좀이 얼마나 연속적으로 나왔나
	capture_w = 0 //스폰 대기중인 잡기 특좀 수
	support_w = 0 //스폰 대기중인 뿌리기 특좀 수

	death = [0,0,0,0,0,0,0]//특좀 타입별 사망시간

	spawn_cmd = 0
	spawn_time = 0.0
	spawn_delay = 0 //잔류 특좀이 있을 때 +12
	spawn_delay_state = 0 //incap +10  tank +15
	spawn_delay_vomit = 0 //부머즙에 맞았으면 +8
	//spawn_delay_horde = 0 //호드가 충분하면 +5

	//테스트용
	SIspawns = ""
}

::hdmdSIFunc<-{
	function SI_spawn_manager(params){
		local criteria = 0;
		if(::hdmdSurvVars.teamPower >= 2.5 && !Director.IsTankInPlay())criteria = 1;
		local len = ::hdmdSIVars.siList.len();
		local attackers = 0;
		for(local i = 0; i < len; i++){
			if(::hdmdSIVars.siList[i][0] == null || !::hdmdSIVars.siList[i][0].IsValid())continue;
			local ztype = ::hdmdSIVars.siList[i][0].GetZombieType();
			if(ztype != 2 && ztype != 4){
				attackers++;
			}
		}
		if((attackers <= 1
		|| (attackers <= ::hdmdSurvVars.playerCount/2 && ::hdmdState.gamemode == 1)) 
		&& ::hdmdSIVars.spawn_cmd == 0 && ::hdmdState.regular){
			local spawnTime = 30.0 + ((4-::hdmdSurvVars.teamPower)*2);
			if(::hdmdState.gamemode == 1)spawnTime /= 3;
			::hdmdSIVars.spawn_time = Time()+spawnTime;
			if(::hdmdState.gamemode == 0)		::hdmdSIVars.spawn_delay = 12;
			else if(::hdmdState.gamemode == 1)	::hdmdSIVars.spawn_delay = 4;
			::manacatAddTimer(5.0, false, ::hdmdSIFunc.SI_spawn, {});
			::hdmdSIVars.spawn_cmd = 1;
		}
	}

	function SI_spawn(params){
		local lvdelay = 6-::hdmdState.lv;
		if(lvdelay < 3)lvdelay = 3;
		local randomDelay = 1.75+(RandomInt(0,lvdelay*10)/10);
		if("AdminSystem" in getroottable() && AdminSystem.Vars.DirectorDisabled){
			::manacatAddTimer(randomDelay, false, ::hdmdSIFunc.SI_spawn, params);	return;
		}

		if(::hdmdState.gamemode == 0){
			local ctime = Time();
			if(!("activate" in params)){
				if(::hdmdSIVars.spawn_cmd == 1){
					::hdmdSIVars.spawn_cmd = 2;
					params.activate <- true;
					if(::hdmdSurvVars.teamPower <= 1){
						//1인플에 준하는 상황이면 쿼드캡을 한번에 내보내지 않도록 함
						if		(::hdmdState.lv >= 5)	::hdmdSIVars.capture_w = 3;
						else if	(::hdmdState.lv <= 4)	::hdmdSIVars.capture_w = 2;
					}else{
						if		(::hdmdState.lv >= 7){
							if(RandomInt(1,2)==1)		::hdmdSIVars.capture_w = 4;
							else						::hdmdSIVars.capture_w = 3;
						}else if(::hdmdState.lv == 6){
							if(RandomInt(1,3)==1)		::hdmdSIVars.capture_w = 4;
							else						::hdmdSIVars.capture_w = 3;
						}else if(::hdmdState.lv == 5){
							if(RandomInt(1,4)==1)		::hdmdSIVars.capture_w = 4;
							else						::hdmdSIVars.capture_w = 3;
						}else if(::hdmdState.lv == 4){	::hdmdSIVars.capture_w = 3;
						}else if(::hdmdState.lv == 3){
							if(RandomInt(1,2)==1)		::hdmdSIVars.capture_w = 3;
							else						::hdmdSIVars.capture_w = 2;
						}else if(::hdmdState.lv == 2){
							if(RandomInt(1,3)==1)		::hdmdSIVars.capture_w = 3;
							else						::hdmdSIVars.capture_w = 2;
						}else{
							if(RandomInt(1,4)==1)		::hdmdSIVars.capture_w = 3;
							else						::hdmdSIVars.capture_w = 2;
						}
					}
					::hdmdSIVars.support_w = 1;
				}
				if("capture" in params){
					if(::hdmdSIVars.capture_w < params.capture)::hdmdSIVars.capture_w = params.capture;
				}
				if("support" in params){
					if(::hdmdSIVars.support_w < params.support)::hdmdSIVars.support_w = params.support;
				}
			}
			if("activate" in params){
				if(!("delay" in params))params.delay <- 0;

				//잡기 특좀이 있으면 스폰 딜레이 여유를 주고, 잡기 특좀이 한마리도 없으면 딜레이를 줄임
				local len = ::hdmdSIVars.siList.len();
				local attackers = 0;
				for(local i = 0; i < len; i++){
					if(::hdmdSIVars.siList[i][0] == null || !::hdmdSIVars.siList[i][0].IsValid())continue;
					local ztype = ::hdmdSIVars.siList[i][0].GetZombieType();
					if(ztype != 2 && ztype != 4){
						attackers = 1;
					}
				}
				::hdmdSIVars.spawn_delay_state = 0;::hdmdSIVars.spawn_delay_vomit = 0;
				if(attackers == 0)::hdmdSIVars.spawn_delay = 0;
				if(::hdmdState.incap)::hdmdSIVars.spawn_delay_state = 20;
				if(::hdmdSurvVars.vomitTime != -1 && ::hdmdSurvVars.vomitTime+30 > ctime){
					if(::hdmdSIVars.spawn_delay_state >= 10){
						::hdmdSIVars.spawn_delay_vomit = 5;
					}else{
						::hdmdSIVars.spawn_delay_vomit = 10;
					}
				}

				//탱크 교전상황일 때 탱크 수 고려해서 내보낼 특좀 수를 조절
				else if(Director.IsTankInPlay()){
					if(::hdmdTankVars.tanks >= 2){
						if(::hdmdSIVars.spawn_delay_state < 10)::hdmdSIVars.spawn_delay_state = 10;
						if(::hdmdSIVars.capture_w >= 2)::hdmdSIVars.capture_w = 1;
					}else{
						if(::hdmdSIVars.spawn_delay_state < 5)::hdmdSIVars.spawn_delay_state = 5;
						if(::hdmdSIVars.capture_w >= 3)::hdmdSIVars.capture_w = 2;
					}
				}
				
				if(Time() > ::hdmdSIVars.spawn_time+::hdmdSIVars.spawn_delay+::hdmdSIVars.spawn_delay_state+::hdmdSIVars.spawn_delay_vomit){
					local si = null;	local sitype = 0;
					if(::hdmdSIVars.capture_w > 0){
						if(::hdmdSIVars.capture.len() > 0)si = ::hdmdSIVars.capture.remove(0);
						::hdmdSIVars.capture_w--;	sitype = 1;
					}else if(::hdmdSIVars.support_w > 0){
						if(::hdmdSIVars.support.len() > 0)si = ::hdmdSIVars.support.remove(0);
						::hdmdSIVars.support_w--;	sitype = 2;
					}
					local verify = false;
					if(si != null)verify = ::hdmdSIFunc.ZSpawn( { type = si, pos = null, ang = QAngle(0,0,0) } );
					if(verify == true){
						if(sitype == 2){
							if(si != ::hdmdSIVars.support_last){
								::hdmdSIVars.support_last = si;
								::hdmdSIVars.support_last_repeat = 0;
							}else{
								::hdmdSIVars.support_last_repeat++;
							}
						}
					}else if(verify == false){
						if(sitype == 1){
							::hdmdSIVars.capture_w++;
						}else if(sitype == 2){
							::hdmdSIVars.support_w++;
						}
					}

					if(::hdmdSIVars.capture_w > 0 || ::hdmdSIVars.support_w > 0){
						::hdmdSIVars.spawn_cmd = 3;
						::manacatAddTimer(randomDelay, false, ::hdmdSIFunc.SI_spawn, params);
					}else{
						::hdmdSIVars.spawn_cmd = 0;
					}
				}else{
					::manacatAddTimer(randomDelay, false, ::hdmdSIFunc.SI_spawn, params);
					return;
				}
			}
		}else if(::hdmdState.gamemode == 1){
			local hunter_count = 0;
			local player_count = 0;
			local hunter;
			while (hunter = Entities.FindByClassname(hunter, "player")){
				if(hunter.IsValid() && !hunter.IsDead() && !hunter.IsDying() && !hunter.IsIncapacitated()){
					if(hunter.GetZombieType() == 3)hunter_count++;
					else if(hunter.GetZombieType() == 9)player_count++;
				}
			}
			::hdmdSIVars.spawn_delay_state = 0;
			if(::hdmdState.incap)::hdmdSIVars.spawn_delay_state = 20;
			//탱크 교전상황일 때 헌터 스폰 딜레이 약간 늘림
			else if(Director.IsTankInPlay()){
				if(::hdmdTankVars.tanks >= 2){
					if(::hdmdSIVars.spawn_delay_state < 10)::hdmdSIVars.spawn_delay_state = 10;
				}else{
					if(::hdmdSIVars.spawn_delay_state < 5)::hdmdSIVars.spawn_delay_state = 5;
				}
			}

			if(hunter_count <= 1)::hdmdSIVars.spawn_time -= 1;
			if(player_count == 1)		hunter = 2;
			else if(player_count == 2)	hunter = 3;
			else if(player_count == 3)	hunter = 5;
			else if(player_count == 4)	hunter = 6;
			else if(player_count == 5)	hunter = 8;
			else if(player_count == 6)	hunter = 9;
			else if(player_count == 7)	hunter = 11;
			else						hunter = 12;
			
			if(Time() > ::hdmdSIVars.spawn_time+::hdmdSIVars.spawn_delay+::hdmdSIVars.spawn_delay_state){
				if(hunter_count < hunter){
					::hdmdSIFunc.ZSpawn( { type = 3, pos = null, ang = QAngle(0,0,0) } );
					::hdmdSIVars.spawn_cmd = 3;
					::manacatAddTimer(randomDelay, false, ::hdmdSIFunc.SI_spawn, params);
				}else{
					::hdmdSIVars.spawn_cmd = 0;
				}
			}else{
				::manacatAddTimer(randomDelay, false, ::hdmdSIFunc.SI_spawn, params);
					return;
			}
		}
	}

	function SI_spawn_set(params = {}){
		SessionOptions.SmokerLimit <- 0;
		SessionOptions.BoomerLimit <- 0;
		SessionOptions.HunterLimit <- 0;
		SessionOptions.SpitterLimit <- 0;
		SessionOptions.JockeyLimit <- 0;
		SessionOptions.ChargerLimit <- 0;
		::hdmdSIVars.capture = [];	::hdmdSIVars.support = [];
		local table = [1,3,5,6];
		local len = 4;
		for(local i = 0; i < 4; i++){
			::hdmdSIVars.capture.append(table.remove(RandomInt(0,len-1)));	len--;
		}
		local table = [2,4];
		local len = 2;
		for(local i = 0; i < 2; i++){
			::hdmdSIVars.support.append(table.remove(RandomInt(0,len-1)));	len--;
		}
	}

	function OnGameEvent_player_spawn(params){
		::hdmdSurvFunc.teamAnalysis();
		local zombie = GetPlayerFromUserID(params.userid);
		local ztype = zombie.GetZombieType();
		if(::hdmdState.gamemode == 0)::hdmdSIFunc.spawnSound({ztype = ztype, ori = zombie.GetOrigin()});

		if(ztype <= 6){
			if(ztype != 2 && ztype != 4)::hdmdSIVars.SIspawns += ztype;
			switch(ztype){
				case 1: /*스모커*/
					::hdmdSIVars.siList.append([zombie, 0, 0]);
					::hdmdSIFunc.setSI({si = zombie, type = ztype});
					::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_speed, { si = zombie, sitype = ztype });
					::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_control_smoker, { si = zombie });
				//	::manacatAddTimer(0.1, false, ::hdmdSIFunc.outcast, {si = zombie, unconcern = 0});
					return;
				case 2: /*부머*/
					::hdmdSIVars.siList.append([zombie, 0, 0]);
					::hdmdSIFunc.setSI({si = zombie, type = ztype});
					::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_speed, { si = zombie, sitype = ztype });
					::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_control_boomer, { si = zombie });
					::manacatAddTimer(0.1, false, ::hdmdSIFunc.outcast, {si = zombie, unconcern = 0});
					return;
				case 3:
					::hdmdSIVars.siList.append([zombie, 0, 0]);
					::hdmdSIFunc.setSI({si = zombie, type = ztype});
					::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_speed, { si = zombie, sitype = ztype });
					::hdmdSIVars.hunter_jump.append([zombie, -1]);
					::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_control_hunter, { si = zombie });
					return;
				case 4: /*스피터*/
					::hdmdSIVars.siList.append([zombie, 0, 0]);
					::hdmdSIFunc.setSI({si = zombie, type = ztype});
					::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_speed, { si = zombie, sitype = ztype });
					::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_control_spitter, { si = zombie });
					::manacatAddTimer(0.1, false, ::hdmdSIFunc.outcast, {si = zombie, unconcern = 0});
					return;
				case 5:
					::hdmdSIVars.siList.append([zombie, 0, 0]);
					::hdmdSIFunc.setSI({si = zombie, type = ztype});
					::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_speed, { si = zombie, sitype = ztype });
					::hdmdSIVars.jockey_ride.append([zombie, 0]);
					::hdmdSIVars.jockey_jump.append([zombie, -1, true]);
					if(::hdmdState.lv <= 5)return;
					::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_control_jockey, { si = zombie });
					return;
				case 6:
					::hdmdSIVars.siList.append([zombie, 0, 0]);
					::hdmdSIFunc.setSI({si = zombie, type = ztype});
					::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_speed, { si = zombie, sitype = ztype });
					if(::hdmdState.lv <= 4)return;
					::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_control_charger, { si = zombie });
					return;
			}
		}
	}

	function spawnSound(params){
		local soundClose = "";
		local soundFar = "";
		local volClose = 0.3;
		local volFar = 0.3;	
		switch(params.ztype){
			case 1:		soundClose = "Event.SmokerAlertClose";		soundFar = "Event.SmokerAlertFar";		break;
			case 2:		soundClose = "Event.BoomerAlertClose";		soundFar = "Event.BoomerAlertFar";		volClose = 0.2;		volFar = 0.2;	break;
			case 3:		soundClose = "Event.HunterAlertClose";		soundFar = "Event.HunterAlertFar";		break;
			case 4:		soundClose = "Event.SpitterAlertClose";		soundFar = "Event.SpitterAlertFar";		volClose = 0.2;		volFar = 0.2;	break;
			case 5:		soundClose = "Event.JockeyAlertClose";		soundFar = "Event.JockeyAlertFar";		break;
			case 6:		soundClose = "Event.ChargerAlertClose";		soundFar = "Event.ChargerAlertFar";		break;
		}
		for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
			if(::hdmdSurvVars.playerList[i][1] == null || !::hdmdSurvVars.playerList[i][1].IsValid() ||
			::hdmdSurvVars.playerList[i][1].IsDead() || ::hdmdSurvVars.playerList[i][1].IsDying() || ::hdmdSurvVars.playerList[i][1].IsIncapacitated() || ::hdmdSurvVars.playerList[i][1].IsDominatedBySpecialInfected())continue;
			local dist = (::hdmdSurvVars.playerList[i][1].GetOrigin() - params.ori).Length();
			if(dist < 625)		EmitAmbientSoundOn(soundClose, volClose, 500, 100, ::hdmdSurvVars.playerList[i][1]);
			else				EmitAmbientSoundOn(soundFar, volFar, 500, 100, ::hdmdSurvVars.playerList[i][1]);
		}
	}

	function setSI(params){
		local hp = 1;
		switch(params.type){
			case 1: //스모커
				if(::hdmdSurvVars.playerCount == 1)			hp = 175;
				else if(::hdmdSurvVars.playerCount == 2)	hp = 200;
				else if(::hdmdSurvVars.playerCount == 3)	hp = 225;
				else										hp = 250;
				if(::hdmdSurvVars.playerCount == 1){
					Convars.SetValue("tongue_hit_delay", 20);
					if(::hdmdState.lv >= 6)
							Convars.SetValue("tongue_miss_delay", 3);
					else	Convars.SetValue("tongue_miss_delay", 15);
				}else if(::hdmdState.finale){
					if(::hdmdSurvVars.playerCount == 2 || ::hdmdState.incap || Director.IsTankInPlay()){
						Convars.SetValue("tongue_hit_delay", 16);
						if(::hdmdState.lv >= 6)
								Convars.SetValue("tongue_miss_delay", 3);
						else	Convars.SetValue("tongue_miss_delay", 14);
					}else{
						Convars.SetValue("tongue_hit_delay", 12);
						if(::hdmdState.lv >= 6)
								Convars.SetValue("tongue_miss_delay", 3);
						else	Convars.SetValue("tongue_miss_delay", 12);
					}
				}else{
					if(::hdmdSurvVars.playerCount == 2 || ::hdmdState.incap || Director.IsTankInPlay()){
						Convars.SetValue("tongue_hit_delay", 12);
						if(::hdmdState.lv >= 6)
								Convars.SetValue("tongue_miss_delay", 3);
						else	Convars.SetValue("tongue_miss_delay", 12);
					}else{
						Convars.SetValue("tongue_hit_delay", 8);
						if(::hdmdState.lv >= 6)
								Convars.SetValue("tongue_miss_delay", 3);
						else	Convars.SetValue("tongue_miss_delay", 8);
					}
				}
				if(::hdmdSurvVars.playerCount == 1)	Convars.SetValue("tongue_break_from_damage_amount", 50);
				else if(::hdmdState.lv >= 7) 		Convars.SetValue("tongue_break_from_damage_amount", 300);
				else if(::hdmdState.lv == 6) 		Convars.SetValue("tongue_break_from_damage_amount", 250);
				else if(::hdmdState.lv == 5) 		Convars.SetValue("tongue_break_from_damage_amount", 200);
				else if(::hdmdState.lv == 4)		Convars.SetValue("tongue_break_from_damage_amount", 150);
				else								Convars.SetValue("tongue_break_from_damage_amount", 50);
				break;
			case 2: //부머
				if(::hdmdSurvVars.playerCount == 1){
					hp = 50;
				}else if(::hdmdState.finale){
					hp = 60;
				}else{
					hp = 70;
				}
				break;
			case 3: //헌터
				if(::hdmdState.gamemode == 0){
					if(::hdmdSurvVars.playerCount == 1)			hp = 175;
					else if(::hdmdSurvVars.playerCount == 2)	hp = 200;
					else if(::hdmdSurvVars.playerCount == 3)	hp = 225;
					else										hp = 250;
				}else if(::hdmdState.gamemode == 1){
					if(::hdmdSurvVars.playerCount == 1)			hp = 150;
					else if(::hdmdSurvVars.playerCount == 2)	hp = 170;
					else if(::hdmdSurvVars.playerCount == 3)	hp = 185;
					else										hp = 200;
				}
				if(::hdmdState.lv >= 5){
					Convars.SetValue("z_pounce_stumble_radius", 160);
					Convars.SetValue("z_max_stagger_duration", 0.9);
				}else if(::hdmdState.lv == 4){
					Convars.SetValue("z_pounce_stumble_radius", 100);
					Convars.SetValue("z_max_stagger_duration", 0.6);
				}else if(::hdmdState.lv == 3){
					Convars.SetValue("z_pounce_stumble_radius", 50);
					Convars.SetValue("z_max_stagger_duration", 0.3);
				}else{
					Convars.SetValue("z_pounce_stumble_radius", 0);
					Convars.SetValue("z_max_stagger_duration", 0);
				}
				break;
			case 4: //스피터
				if(::hdmdState.finale || ::hdmdSurvVars.playerCount == 1){
					Convars.SetValue("z_spit_interval", 16);
					hp = 100;
				}else{
					Convars.SetValue("z_spit_interval", 12);
					hp = 150;
				}
				break;
			case 5: //자키
				if(::hdmdSurvVars.playerCount == 1)			hp = 200;
				else if(::hdmdSurvVars.playerCount == 2)	hp = 235;
				else if(::hdmdSurvVars.playerCount == 3)	hp = 275;
				else										hp = 325;
				if(::hdmdState.lv >= 5){
					Convars.SetValue("z_pounce_stumble_radius", 160);
					Convars.SetValue("z_max_stagger_duration", 0.9);
				}else if(::hdmdState.lv == 4){
					Convars.SetValue("z_pounce_stumble_radius", 100);
					Convars.SetValue("z_max_stagger_duration", 0.6);
				}else if(::hdmdState.lv == 3){
					Convars.SetValue("z_pounce_stumble_radius", 50);
					Convars.SetValue("z_max_stagger_duration", 0.3);
				}else{
					Convars.SetValue("z_pounce_stumble_radius", 0);
					Convars.SetValue("z_max_stagger_duration", 0);
				}
				if(::hdmdState.lv >= 5)		Convars.SetValue("z_leap_interval", 0.0);
				else						Convars.SetValue("z_leap_interval", 0.5);
				break;
			case 6: //차저
				if(::hdmdSurvVars.playerCount == 1)			hp = 400;
				else if(::hdmdSurvVars.playerCount == 2)	hp = 450;
				else if(::hdmdSurvVars.playerCount == 3)	hp = 525;
				else										hp = 600;
				if(::hdmdState.finale || ::hdmdSurvVars.playerCount <= 2){
			//		Convars.SetValue("z_charge_max_speed", 500);
				}else{
			//		Convars.SetValue("z_charge_max_speed", 550);
				}
				break;
				
		}
		//if(params.type != 2 && params.type != 4)hp = 10000;
		NetProps.SetPropIntArray( params.si, "m_iMaxHealth", hp, 0 );
		NetProps.SetPropIntArray( params.si, "m_iHealth", hp, 0 );
	}

	//밀쳐낸 특좀이 긁는 것 방지
	function OnGameEvent_player_shoved(params){
		local si = GetPlayerFromUserID(params.userid);
		local sitype = si.GetZombieType();
		if(sitype == 3 || sitype == 5){
			local buttons = NetProps.GetPropIntArray( si, "m_afButtonDisabled", 0)
			NetProps.SetPropIntArray( si, "m_afButtonDisabled", (buttons | 2048), 0);
			local function allowAttack(si){
				if(!si.IsValid())return;
				NetProps.SetPropIntArray( si, "m_afButtonDisabled", 0, 0);
			}

			::manacatAddTimer(1.5, false, allowAttack, si);
		}
	}

	function SI_append(ztype){
		if(::hdmdState.gamemode == 0){
			local wait = false;
			if(ztype == 2 || ztype == 4){
				local len = ::hdmdSIVars.support.len();
				for(local i = 0; i < len; i++){
					if(::hdmdSIVars.support[i] == ztype){
						wait = true;	break;
					}
				}
				if(!wait){
					if(::hdmdSIVars.support_last_repeat >= 2){
						::hdmdSIVars.support.append(ztype);
					}else{
						local start = len-2;
						if(start < 0)start = 0;
						local end = len;
						if(end < 0)end = 0;
						::hdmdSIVars.support.insert(RandomInt(start,end), ztype);
					}
				}
			}else if(ztype <= 6){
				local len = ::hdmdSIVars.capture.len();
				for(local i = 0; i < len; i++){
					if(::hdmdSIVars.capture[i] == ztype && ::hdmdState.gamemode == 0){
						wait = true;	break;
					}
				}
				if(!wait){
					local start = len-2;
					if(start < 0)start = 0;
					local end = len;
					if(end < 0)end = 0;
					::hdmdSIVars.capture.insert(RandomInt(start,end), ztype);
				}
			}
		}
	}

	function OnGameEvent_player_death(params){
		if("userid" in params){
			local si = GetPlayerFromUserID(params.userid);
			local ztype = si.GetZombieType();
			::hdmdSIFunc.SI_append(ztype);
			if(ztype != 9){
				if(1 <= ztype && ztype <= 6){
					::hdmdSIVars.death[ztype] = Time();
				}
				local len = ::hdmdSIVars.attackList.len();
				for(local i = 0; i < len; i++){
					if(::hdmdSIVars.attackList[i][0] == si){
						::hdmdSIVars.attackList.remove(i);	len--;
					}
				}
				len = ::hdmdSIVars.siList.len();
				for(local i = 0; i < len; i++){
					if(::hdmdSIVars.siList[i][0] == si){
						::hdmdSIVars.siList.remove(i);	len--;
					}
				}
				if(ztype == 3){
					len = ::hdmdSIVars.hunter_jump.len();
					for(local i = 0; i < len; i++){
						if(::hdmdSIVars.hunter_jump[i][0] == si){
							::hdmdSIVars.hunter_jump.remove(i);	len--;
						}
					}
					if(::hdmdState.gamemode == 1){
						local killer = GetPlayerFromUserID(params.attacker);
						::hdmdSurvFunc.hp_bonus(killer, 10, 45);
					}
				}else if(ztype == 5){
					len = ::hdmdSIVars.jockey_jump.len();
					for(local i = 0; i < len; i++){
						if(::hdmdSIVars.jockey_jump[i][0] == si){
							::hdmdSIVars.jockey_ride.remove(i);
							::hdmdSIVars.jockey_jump.remove(i);	len--;
						}
					}
				}

				::hdmdSIFunc.fireListRemove(si);
			}
		}
	}

	function OnGameEvent_player_disconnect(params){
		if("userid" in params){
			local player = GetPlayerFromUserID(params.userid);
			if(player == null || !player.IsValid())return;
			if(!player.IsSurvivor())fireListRemove(player);
		}
	}

	function OnGameEvent_weapon_fire(params){
		if(params.weapon == "jockey_claw"){
			local jockey = GetPlayerFromUserID(params.userid);
			local len = ::hdmdSIVars.jockey_jump.len();
			for(local i = 0; i < len; i++){
				if(::hdmdSIVars.jockey_jump[i][0] == jockey){
					if(::hdmdSIVars.jockey_jump[i][2] == true && ::hdmdSIVars.jockey_jump[i][1] <= Time()-1){
						::hdmdSIVars.jockey_jump[i][2] = false;
						::hdmdSIVars.jockey_jump[i][1] = Time();
						
						::manacatAddTimer(0.0, false, ::hdmdSIFunc.SI_control_jockey_leap, {si = jockey});
					}
				}
			}
		}else if(::hdmdSurvVars.teamPower <= 2.5 || ::hdmdState.lv <= 4){
			local attacker = GetPlayerFromUserID(params.userid);
			local victim = attacker.GetSpecialInfectedDominatingMe();
			if(victim != null && victim.IsValid() && victim.GetZombieType() == 1){
				if(params.weapon == "weapon_melee")return;
				local targetPos = victim.GetAttachmentOrigin(victim.LookupAttachment("smoker_mouth"));
				local tolerance = 2;
				if(::hdmdState.lv == 5)			tolerance = 1.5;
				else if(::hdmdState.lv == 6)	tolerance = 1.25;
				else if(::hdmdState.lv == 7)	tolerance = 1;
				if(::hdmdSIFunc.visionCheck(attacker, targetPos, null, tolerance)){
					switch(params.weapon){
						case "smg":case "smg_silenced":case "smg_mp5":
							::hdmdSIVars.smoker_urgent_shot+=2;break;
						case "pistol":case "rifle":case "rifle_ak47":case "rifle_sg552":case "rifle_m60":case "autoshotgun":case "shotgun_spas":
							::hdmdSIVars.smoker_urgent_shot+=4;break;
						default:
							::hdmdSIVars.smoker_urgent_shot=8;break;
					}
					if(::hdmdSIVars.smoker_urgent_shot >= 8)victim.TakeDamage(500, 2, attacker);
				}
			}
		}
	}

	function OnGameEvent_player_hurt(params){
		if(::hdmdState.lv >= 4){
			local victim = GetPlayerFromUserID(params.userid);
			local attacker = GetPlayerFromUserID(params.attacker);
			if(victim == null || !victim.IsValid() || attacker == null || !attacker.IsValid())return;
			local ztype = victim.GetZombieType();
			local timeChk = ::hdmdSIFunc.hurt_jump(victim);
			if(!timeChk)return;
			if(ztype == 5){
				local flag = NetProps.GetPropInt(victim,"m_fFlags");
				local isOnGround = flag == ( flag | 1 );
				if(isOnGround){
					local impulseVec = Vector(0, 0, 0);//victim.GetVelocity();
					local impulseVec2 = ::hdmdSIFunc.SI_control_eye({si = victim, tgVector = attacker.EyePosition()});
					impulseVec += impulseVec2.Forward().Scale(320);
					impulseVec += impulseVec2.Left().Scale(190+(-380*(RandomInt(0,1))));
					impulseVec += impulseVec2.Up().Scale(265);
					victim.SetVelocity(Vector(0, 0, 0));
					victim.ApplyAbsVelocityImpulse(impulseVec);
				}
			}
		}
	}

	function hurt_jump(hurter){
		local len = ::hdmdSIVars.siList.len();
		local currentTime = Time();
		for(local i = 0; i < len; i++){
			if(::hdmdSIVars.siList[i][0] == null || !::hdmdSIVars.siList[i][0].IsValid() || ::hdmdSIVars.siList[i][0] != hurter)continue;
			if(::hdmdSIVars.siList[i][2] < currentTime){
				::hdmdSIVars.siList[i][2] = currentTime+1;
				return true;
			}
		}
		return false;
	}

	function OnGameEvent_lunge_pounce(params){
		local victim = GetPlayerFromUserID(params.victim);
		local attacker = GetPlayerFromUserID(params.userid);
		//헌터모드 전용
		if(::hdmdState.gamemode == 1){
			local chk = true;
			local len = ::hdmdSIVars.hunter_pounce.len();
			for(local i = 0; i < len; i++)if(::hdmdSIVars.hunter_pounce[i][0] == attacker)chk = false;
			if(chk)::hdmdSIVars.hunter_pounce.append([attacker, victim, 0]);
		}
		if(::hdmdState.lv >= 3 && ::hdmdSurvVars.teamPower >= 1.7){
			local min = 150;	local max = 1000;
			local distDmg = floor(3.0 + (12*(params.distance-min)/max));

			local len = ::hdmdSIVars.hunter_jump.len();
			for(local i = 0; i < len; i++){
				if(::hdmdSIVars.hunter_jump[i][0] == attacker){
					local heightDmg = (::hdmdSIVars.hunter_jump[i][1] - attacker.GetOrigin().z) / 40;
					if(heightDmg > 1)distDmg += heightDmg;
				}
			}

			if(distDmg < 1) distDmg = 1;
			else if(distDmg >= 25) distDmg = 25;

			if(distDmg >= 5){
				EmitSoundOnClient("HunterZombie.Pounce.Hit", attacker)
				EmitAmbientSoundOn("HunterZombie.Pounce.Hit", 1.0, 350, 100,victim);
			}

			victim.TakeDamage(distDmg, 129, attacker);
		}
		::manacatAddTimer(2.0, false, ::hdmdSIFunc.releaseCap, { });
	}

	function OnGameEvent_pounce_end(params){
		//헌터모드 전용
		::hdmdSIFunc.pounce_stop(params);
	}

	function OnGameEvent_pounce_stopped(params){
		//헌터모드 전용
		::hdmdSIFunc.pounce_stop(params);
	}

	function pounce_stop(params){
		if("victim" in params && "userid" in params){
			local victim = GetPlayerFromUserID(params.victim);
			local attacker = GetPlayerFromUserID(params.userid);
			local len = ::hdmdSIVars.hunter_pounce.len();
			for(local i = 0; i < len; i++){
				if(::hdmdSIVars.hunter_pounce[i][0] == attacker){
					::hdmdSIVars.hunter_pounce.remove(i);	len--;
				}
			}
		}
	}

	function OnGameEvent_charger_pummel_start(params){
		::manacatAddTimer(2.0, false, ::hdmdSIFunc.releaseCap, { });
	}

	function OnGameEvent_jockey_ride(params){
		::manacatAddTimer(2.0, false, ::hdmdSIFunc.releaseCap, { });
	}

	function OnGameEvent_tongue_grab(params){//타이머 필요
		local tongue_delay = Convars.GetFloat("tongue_choke_damage_interval");
		::manacatAddTimer(1.0, false, ::hdmdSIFunc.tongue_dmg, {victim = GetPlayerFromUserID(params.victim), t_delay = tongue_delay});
		::manacatAddTimer(2.0, false, ::hdmdSIFunc.releaseCap, { });
	}

	function tongue_dmg(params){
		if(params.victim == null || !params.victim.IsValid() || !params.victim.IsDominatedBySpecialInfected())return;
		local smoker = params.victim.GetSpecialInfectedDominatingMe();
		if(smoker.GetZombieType() != 1)return;
		::manacatAddTimer(params.t_delay, false, ::hdmdSIFunc.tongue_dmg, params);
		if(params.t_delay == 0.25){
			params.victim.TakeDamage(1.1, 1048576, smoker);
		}else{
			params.victim.TakeDamage(3.1, 1048576, smoker);
		}
	}

	function releaseCap(params){
		local release = false;	local player = null;
		if(::hdmdSurvVars.playerCount <= 2 || ::hdmdState.gamemode == 1){
			for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
				player = ::hdmdSurvVars.playerList[i][1];
				if(player == null || !player.IsValid()
				|| player.IsDead() || player.IsDying() || player.IsIncapacitated())continue;

				if(!player.IsDominatedBySpecialInfected())return;
			}

			if(::hdmdState.gamemode == 0){
				for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
					player = ::hdmdSurvVars.playerList[i][1];
					if(player == null || !player.IsValid()
					|| player.IsDead() || player.IsDying() || player.IsIncapacitated())continue;

					if(player.IsDominatedBySpecialInfected()){
						EmitSoundOnClient("Weapon.HitInfected", player);
						local si = player.GetSpecialInfectedDominatingMe();
						if(si.GetZombieType() != 3){
							if(::hdmdSurvVars.playerCount == 1)
									player.TakeDamage(10, 128, si);
							else	player.TakeDamage(25, 128, si);
						}else if(::hdmdState.gamemode == 1){
							if(::hdmdSurvVars.playerCount == 1)
									player.TakeDamage(6, 128, si);
							else	player.TakeDamage(8, 128, si);
						}
						si.Stagger(player.GetOrigin());
						si.TakeDamage(1000, 128, null);
						release = true;
					}
				}
			}else if(::hdmdState.gamemode == 1){
				for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
					player = ::hdmdSurvVars.playerList[i][1];
					if(player == null || !player.IsValid()
					|| player.IsDead() || player.IsDying() || player.IsIncapacitated())continue;

					if(player.IsDominatedBySpecialInfected()){
						EmitSoundOnClient("Weapon.HitInfected", player);
						player.TakeDamage(10, 128, null);
						release = true;
					}
				}
				local hunter;
				while (hunter = Entities.FindByClassname(hunter, "player")){
					if(hunter.IsValid() && !hunter.IsDead() && !hunter.IsDying() && hunter.GetZombieType() == 3){
						hunter.Stagger(hunter.GetOrigin());
						hunter.TakeDamage(1000, 128, null);
						release = true;
					}
				}
			}
		}
		if(release){
			local ent = null;
			while (ent = Entities.FindByClassname(ent, "infected")){
				if(ent.IsValid()){
					ent.TakeDamage(1, 33554432, player);
				}
			}
		}
	}

	function si_attack(si){
		local len = ::hdmdSIVars.attackList.len();
		for(local i = 0; i < len; i++){
			if(::hdmdSIVars.attackList[i][0] == si){
				::hdmdSIVars.attackList[i][1]++;
				return;
			}
		}
		::hdmdSIVars.attackList.append([si, 1]);
	}

	/*
	function OnGameEvent_infected_death(params){
		//잡좀&윗치를 잡을 때 확률적으로 잡좀 1마리 재배치
		if(::hdmdState.lv == 1)return;
		local gameDif = Convars.GetStr("z_difficulty").tolower();
		
		if(gameDif == "impossible"){
			if(RandomInt(1,6) == 1){
				//printl(Time() + " - - - - - - - - - - - - - - - - - - - - - - - - - -<reinput> 1/6");
				::SpawnZombieNearSurv();
			}
		}else if(gameDif == "hard"){
			if(RandomInt(1,4) == 1){
				//printl(Time() + " - - - - - - - - - - - - - - - - - - - - - - - - - -<reinput> 1/4");
				::SpawnZombieNearSurv();
			}
		}else if(RandomInt(1,3) == 1){
				//printl(Time() + " - - - - - - - - - - - - - - - - - - - - - - - - - -<reinput> 1/3");
				::SpawnZombieNearSurv();
		}
	}*/

	function special_zombie(){
		local ck = ::hdmdSurvVars.kitCount;
		local max = 4;
		local interval = 0;

		if(::hdmdSurvVars.kitCount == 0)interval += 3;
		if(::hdmdSurvVars.teamPower <= 1.6)interval += 4;
		if(::hdmdState.finale){
			interval += 5;
			max -= 1;
		}

		switch(::hdmdSurvVars.playerCount){
			case 1:
				interval += 15;
				max -= 2;
				break;
			case 2:
				interval += 9;
				max -= 1;
				break;
			case 3:
				interval += 4;
				max -= 1;
				break;
		}
		interval += 2*(4-ck);
		if(::hdmdState.lv >= 4)					max++;
		if(ck<=2)								max -= 1;
		if(max < 2)								max = 2;

		if(Director.IsTankInPlay()){
			if(interval < 10)	interval = 10;	max = 2;
		}else{
		}
		if(::hdmdState.lv >= 6)					max++;

		SessionOptions.cm_MaxSpecials <- max;//DirectorScript.GetDirectorOptions().cm_MaxSpecials <- max;
		SessionOptions.MaxSpecials <- max;//DirectorScript.GetDirectorOptions().MaxSpecials <- max;
		SessionOptions.cm_DominatorLimit <- 4;
		//SessionOptions.cm_BaseSpecialLimit <- max;//DirectorScript.GetDirectorOptions().cm_BaseSpecialLimit <- max;

		if(interval > 20)interval = 20;
		Convars.SetValue("z_special_spawn_interval", 25+interval);
	}

	function SI_speed(params){
		if(params.si == null || !params.si.IsValid()){
			::hdmdSIFunc.SI_append(3);	return;
		}else if(!params.si.IsDead() && !params.si.IsDying()){
			::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_speed, params);
			switch(params.sitype){
				case 1:case 5:case 6:
					if(::hdmdState.lv >= 3){
						local speed = 1.0;
						if(NetProps.GetPropInt( params.si, "movetype" ) == 9)	speed = 1.5;
						NetProps.SetPropFloat( params.si, "m_flLaggedMovementValue", speed );
					}
				return;
				case 2:case 4:
					if(::hdmdState.lv >= 4){
						local speed = 1.0;
						if(NetProps.GetPropInt( params.si, "movetype" ) == 9)	speed = 1.5;
						NetProps.SetPropFloat( params.si, "m_flLaggedMovementValue", speed );
					}
				return;
				case 3:
					local siSeq = NetProps.GetPropIntArray( params.si, "m_nSequence", 0);

					if(::hdmdState.lv >= 3){
						local speed = 1.0;
						if(NetProps.GetPropInt( params.si, "movetype" ) == 9)	speed = 1.5;
						else if(siSeq == 8 || siSeq == 11)						speed = 1.2;
						NetProps.SetPropFloat( params.si, "m_flLaggedMovementValue", speed );
					}
				return;
			}
		}
	}

	function SI_control_hunter(params){
		if(params.si == null || !params.si.IsValid()){
			::hdmdSIFunc.SI_append(3);	return;
		}else if(!params.si.IsDead() && !params.si.IsDying()){
			if(!IsPlayerABot(params.si)){
				printl("<Human Player> "+params.si);
				return;
			}//*/
			::manacatAddTimer(0.075, false, ::hdmdSIFunc.SI_control_hunter, params);

			local activity = params.si.GetSequenceActivityName(params.si.GetSequence());
			if(activity == "ACT_TERROR_HUNTER_POUNCE_MELEE")return;//쥐어뜯기
			if(::hdmdState.lv <= 3)return;
			local flag = NetProps.GetPropInt(params.si,"m_fFlags");
			local isOnGround = flag == ( flag | 1 );

			if(activity == "ACT_TERROR_HUNTER_POUNCE_IDLE"){//급습 피해 계산에 활용할 활공 높이 기록
				local len = ::hdmdSIVars.hunter_jump.len();
				local hunterPos = params.si.GetOrigin();
				for(local i = 0; i < len; i++){
					if(::hdmdSIVars.hunter_jump[i][0] == params.si){
						if(::hdmdSIVars.hunter_jump[i][1] < hunterPos.z)::hdmdSIVars.hunter_jump[i][1] = hunterPos.z;
						break;
					}
				}
			}

			local chkLungeButton = NetProps.GetPropIntArray( params.si, "m_afButtonForced", 0) == ( NetProps.GetPropIntArray( params.si, "m_afButtonForced", 0) | 1 );

			local nearSurv = ::hdmdSIFunc.findNearSurv({from = params.si, visible = true, noincap = true});
			local nearDist = nearSurv[1]; nearSurv = nearSurv[0];
			if(nearSurv == null) return;

			local hunterMoveSeq = ["ACT_CROUCHIDLE", "ACT_RUN_CROUCH", "ACT_JUMP", "ACT_TERROR_HUNTER_POUNCE", "ACT_TERROR_HUNTER_POUNCE_IDLE"];
			local hunterMoveLen = hunterMoveSeq.len();

			local tgOri = nearSurv.GetOrigin()+Vector(0,0,35);
			local tgOriUp = tgOri+Vector(0,0,65);

			NetProps.SetPropInt( params.si, "m_afButtonForced", 0);

			local look = false;
			if(::hdmdSIFunc.CanSee(params.si, tgOri) || (::hdmdSIFunc.CanSee(params.si, tgOriUp) && ::hdmdSIFunc.CanSee(nearSurv, tgOriUp))){
				look = true;
				local key = (NetProps.GetPropInt( params.si, "m_afButtonForced") | 4);
				NetProps.SetPropIntArray( params.si, "m_afButtonForced", key.tointeger(), 0); //4 = 쪼그리기 키
			}else{
				local key = (NetProps.GetPropInt( params.si, "m_afButtonForced") & ~4);
				NetProps.SetPropIntArray( params.si, "m_afButtonForced", key.tointeger(), 0); //4 = 쪼그리기 키
			}

			for(local i = 0; i < hunterMoveLen; i++){
				if(activity == hunterMoveSeq[i]){
					if(!chkLungeButton && look){
						local tgV = nearSurv.EyePosition();
						tgV += nearSurv.GetVelocity().Scale(0.5);
						local viewAngle = ::hdmdSIFunc.SI_control_eye({si = params.si, tgVector = tgV});
						if(-80 < viewAngle.x && viewAngle.x < -35)viewAngle.x -= 4;
						else if(-35 < viewAngle.x && viewAngle.x < 30)viewAngle.x -= 2;
						else if(30 < viewAngle.x && viewAngle.x < 60)viewAngle.x -= 4;
						else viewAngle.x -= 6;
						params.si.SnapEyeAngles(viewAngle);
						local key = (NetProps.GetPropInt( params.si, "m_afButtonForced") | 9); //1 = 급습키, 8 = 앞으로 키, 합쳐서 9
						NetProps.SetPropInt( params.si, "m_afButtonForced", key.tointeger());
					}else{
						local key = (NetProps.GetPropInt( params.si, "m_afButtonForced") & ~9);
						NetProps.SetPropInt( params.si, "m_afButtonForced", key.tointeger());
					}
					return;
				}
			}
		}
	}

	function SI_control_hunter_lunge(params){//헌터의 기만점프
		local nearSurv = ::hdmdSIFunc.findNearSurv({from = params.si, visible = true, noincap = true});
		local nearDist = nearSurv[1]; nearSurv = nearSurv[0];
		if(nearSurv == null) return;

		local impulseVec = params.si.GetVelocity();
		if(::hdmdSIFunc.visionCheck(nearSurv, params.si.EyePosition(), params.si, 30)){
			if(RandomInt(1,5)==1)return;
			local angleAd = 180/RandomInt(10,20);
			if(RandomInt(1,2)==1)angleAd *= -1;
			local impulseVecMag = sqrt(impulseVec.x*impulseVec.x + impulseVec.y*impulseVec.y);
			local angle = (atan2(impulseVec.y, impulseVec.x) + (PI/angleAd));
			impulseVec.x = cos(angle)*impulseVecMag;
			impulseVec.y = sin(angle)*impulseVecMag;
		//	impulseVec.z += RandomInt(-20,60)*3;
			
		}
		local targetOrigin = nearSurv.GetOrigin();
		local hunterOrigin = params.si.GetOrigin();
	//	printl("높이차이" + (hunterOrigin.z-targetOrigin.z));
		if(targetOrigin.z < hunterOrigin.z && (targetOrigin - hunterOrigin).Length() > 300){
			if(RandomInt(1,2)==1){
				targetOrigin.z = 0;	hunterOrigin.z = 0;
				impulseVec.z += (targetOrigin - hunterOrigin).Length()/3;
			}
		}
		params.si.SetVelocity(Vector(0, 0, 0));
		params.si.ApplyAbsVelocityImpulse(impulseVec);
	}

	function SI_control_jockey_leap(params){
		if(params.si == null || !params.si.IsValid())return;
		local nearSurv = ::hdmdSIFunc.findNearSurv({from = params.si, visible = true, noincap = true});
		local nearDist = nearSurv[1]; nearSurv = nearSurv[0];

		if(nearSurv == null)return;

		local impulseVec = params.si.GetVelocity();
		local impulseVec2 = ::hdmdSIFunc.SI_control_eye({si = params.si, tgVector = nearSurv.EyePosition()});
		impulseVec += impulseVec2.Forward().Scale(100);
		impulseVec += impulseVec2.Up().Scale(15);

		if(nearDist > 150 && ::hdmdSIFunc.visionCheck(nearSurv, params.si.GetOrigin()+Vector(0,0,25), params.si, 18)){
		//	if(RandomInt(1,4)==1)return;
			local angleAd = 180/30;
			if(RandomInt(1,2)==1)angleAd *= -1;
			local impulseVecMag = sqrt(impulseVec.x*impulseVec.x + impulseVec.y*impulseVec.y);
			local angle = (atan2(impulseVec.y, impulseVec.x) + (PI/angleAd));
			impulseVec.x = cos(angle)*impulseVecMag;
			impulseVec.y = sin(angle)*impulseVecMag;
		//	impulseVec.z += RandomInt(-20,60)*3;
			
		}
		/*
		local targetOrigin = nearSurv.GetOrigin();
		local hunterOrigin = params.si.GetOrigin();
		printl("높이차이" + (hunterOrigin.z-targetOrigin.z));
		if(targetOrigin.z < hunterOrigin.z && (targetOrigin - hunterOrigin).Length() > 300){
			targetOrigin.z = 0;	hunterOrigin.z = 0;
			impulseVec.z += 300+(targetOrigin - hunterOrigin).Length()/3;
		}*/
		params.si.SetVelocity(Vector(0, 0, 0));
		params.si.ApplyAbsVelocityImpulse(impulseVec);
	}

	function SI_control_jockey(params){
		if(params.si == null || !params.si.IsValid()){
			::hdmdSIFunc.SI_append(5);	return;
		}else if(!params.si.IsDead() && !params.si.IsDying()){
			::manacatAddTimer(0.075, false, ::hdmdSIFunc.SI_control_jockey, params);
			local chkAttackButton = NetProps.GetPropIntArray( params.si, "m_afButtonForced", 0) == ( NetProps.GetPropIntArray( params.si, "m_afButtonForced", 0) | 1 );
		//	local chkJumpButton = NetProps.GetPropIntArray( params.si, "m_afButtonForced", 0) == ( NetProps.GetPropIntArray( params.si, "m_afButtonForced", 0) | 2 );
			local siSeq = NetProps.GetPropIntArray( params.si, "m_nSequence", 0);
			if(siSeq == 8)return;//올라타기
			local flag = NetProps.GetPropInt(params.si,"m_fFlags");
			local isOnGround = flag == ( flag | 1 );

			if(isOnGround){
				local len = ::hdmdSIVars.jockey_jump.len();
				for(local i = 0; i < len; i++){
					if(::hdmdSIVars.jockey_jump[i][0] == params.si){
						::hdmdSIVars.jockey_jump[i][2] = true;	break;
					}
				}
			}
		
			local siVision = params.si.EyePosition()+Vector(0,0,10);	local look = false;

			for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
				if(!::hdmdSurvVars.playerList[i][1].IsValid() || !::CanTraceToLocation(params.si, ::hdmdSurvVars.playerList[i][1].EyePosition()))continue;
				//DebugDrawLine(::hdmdSurvVars.playerList[i][1].EyePosition(), siVision, 255, 0, 0, true, 5);
				if(::hdmdSIFunc.CanSee(::hdmdSurvVars.playerList[i][1], siVision, 33570827)){
					local dist = (::hdmdSurvVars.playerList[i][1].GetOrigin() - params.si.GetOrigin()).Length();
					if(dist < 1000 &&
					::hdmdSIFunc.visionCheck(params.si, ::hdmdSurvVars.playerList[i][1].EyePosition(), ::hdmdSurvVars.playerList[i][1], 55)){
						look = true;//printl("보고 있음");
						break;
					}else if(::hdmdState.lv >= 7 && ::hdmdSIFunc.visionCheck(::hdmdSurvVars.playerList[i][1], params.si.GetOrigin()+Vector(0,0,22), params.si, 10)){
						look = true;//printl("보여지고 있음");
						break;
					}
				}
			}
			if(look){
			//	if(RandomInt(1,3)!=1){
					if(chkAttackButton || !isOnGround){
						local key = (NetProps.GetPropIntArray( params.si, "m_afButtonForced", 0) & ~1);
						NetProps.SetPropIntArray( params.si, "m_afButtonForced", key.tointeger(), 0);
					}else{
						local nearSurv = ::hdmdSIFunc.findNearSurv({from = params.si, visible = true, noincap = true});
						local nearDist = nearSurv[1]; nearSurv = nearSurv[0];
						if(nearSurv != null){
							local EyeAngles = ::hdmdSIFunc.SI_control_eye({si = params.si, tgVector = nearSurv.GetOrigin()+Vector(0,0,40)});
						//	local EyeAngles = params.si.EyeAngles();
						//	EyeAngles.y += 20;
							params.si.SnapEyeAngles(EyeAngles);
							NetProps.SetPropIntArray( params.si, "m_afButtonForced", 1, 0); //1 = 급습키
						}
					}
			/*	}else{
					if(chkJumpButton == false){
						NetProps.SetPropIntArray( params.si, "m_afButtonForced", 2, 0); //2 = 점프키
					}else{
						local key = (NetProps.GetPropIntArray( params.si, "m_afButtonForced", 0) & ~2);
						NetProps.SetPropIntArray( params.si, "m_afButtonForced", key.tointeger(), 0);
					}
				}//*/
				return;
			}
		}
	}

	function SI_control_charger(params){
		if(params.si == null || !params.si.IsValid()){
			::hdmdSIFunc.SI_append(6);	return;
		}else if(!params.si.IsDead() && !params.si.IsDying()){
			::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_control_charger, params);
			local siSeq = NetProps.GetPropIntArray( params.si, "m_nSequence", 0);
			if(siSeq == 29)return;//내리박기
			local nearSurv = ::hdmdSIFunc.findNearSurv({from = params.si, visible = true, noincap = true});
			local nearDist = nearSurv[1];	local nearVisible = nearSurv[2];	nearSurv = nearSurv[0];
			if(nearSurv == null || !nearSurv.IsValid())return;

			local len = ::hdmdSIVars.attackList.len();	local hitCount = 0;
			for(local i = 0; i < len; i++){
				if(::hdmdSIVars.attackList[i][0] == params.si)	hitCount = ::hdmdSIVars.attackList[i][1];
			}

			local action = 0;
			if(!nearVisible || (400 < nearDist && params.si.GetHealth() < 280) ||
			(160 < nearDist && NetProps.GetPropIntArray( params.si, "m_iMaxHealth", 0 ) == NetProps.GetPropIntArray( params.si, "m_iHealth", 0 ) && hitCount < 2)){
				if(NetProps.GetPropIntArray( params.si, "m_afButtonDisabled", 0) != 1){
					NetProps.SetPropIntArray( params.si, "m_afButtonDisabled", 1, 0); //돌진 금지
				}
				action = 1;		//printl("이동");
			}else{
				if(::hdmdSIFunc.CanSee(params.si, nearSurv.EyePosition(), 131083)
				&& NetProps.GetPropIntArray( params.si, "m_afButtonDisabled", 0) == 1){
					NetProps.SetPropIntArray( params.si, "m_afButtonDisabled", 0, 0); //돌진 금지 해제
					CommandABot( { cmd = 3, bot = params.si } );
				}
				action = 2;		//printl("공격");
			}

			::hdmdSIVars.charger_mind++;
			if(::hdmdSIVars.charger_mind == 4){
				::hdmdSIVars.charger_mind = 0;
				if(action == 1){
					CommandABot( { cmd = 1, pos = nearSurv.GetOrigin(), bot = params.si } );
				}else if(action == 2){
					CommandABot( { cmd = 0, target = nearSurv, bot = params.si } );
				}
			}

			//::manacatAddTimer(0.075, false, ::hdmdSIFunc.SI_control_charger, params);
			

			local charge = false;
		//	local siVision = params.si.EyePosition();
			if(hitCount >= 1/*2회에서 1회로 바꿈*/){
				for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
					if(!::hdmdSurvVars.playerList[i][1].IsValid())continue;
					local dist = (::hdmdSurvVars.playerList[i][1].GetOrigin() - params.si.GetOrigin()).Length();
					if(dist < 100 && ::hdmdSIFunc.CanSee(params.si, ::hdmdSurvVars.playerList[i][1].EyePosition(), 131083) &&
					::hdmdSIFunc.visionCheck(params.si, ::hdmdSurvVars.playerList[i][1].EyePosition(), ::hdmdSurvVars.playerList[i][1], 35)){
						charge = true;	//printl("차저 발진");
					}
				}
			}
			
			if(charge){
				local chkChargeButton = NetProps.GetPropIntArray( params.si, "m_afButtonForced", 0) == ( NetProps.GetPropIntArray( params.si, "m_afButtonForced", 0) | 1 );

				local TargetPlayer = NetProps.GetPropEntityArray( params.si, "m_lookatPlayer", 0 );
				if(TargetPlayer == null) return;

				NetProps.SetPropIntArray( params.si, "m_afButtonForced", 0, 0);

			//	if(!::CanTraceToLocation(params.si, tgOri))return;
				if(!chkChargeButton){
					NetProps.SetPropIntArray( params.si, "m_afButtonForced", 1, 0); //1 = 돌진키
				}else{
					local key = (NetProps.GetPropIntArray( params.si, "m_afButtonForced", 0) & ~1);
					NetProps.SetPropIntArray( params.si, "m_afButtonForced", key.tointeger(), 0);
				}
				return;
			}
		}
	}

	function SI_control_spitter(params){
		if(params.si == null || !params.si.IsValid()){
			::hdmdSIFunc.SI_append(4);	return;
		}else if(!params.si.IsDead() && !params.si.IsDying()){
			::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_control_spitter, params);
			return;
		}
	}

	function SI_control_boomer(params){
		if(params.si == null || !params.si.IsValid()){
			::hdmdSIFunc.SI_append(2);	return;
		}else if(!params.si.IsDead() && !params.si.IsDying()){
			::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_control_boomer, params);
			return;
		}
	}

	function SI_control_boomer_vomit(params){//보완 필요 (뿌린 후에는 조작 풀게)
		if(params.si.IsValid() && !params.si.IsDead() && !params.si.IsDying()){
			local nearSurv = ::hdmdSIFunc.findNearSurv({from = params.si, visible = true, novomit = true});
			local nearDist = nearSurv[1];	local nearVisible = nearSurv[2];	nearSurv = nearSurv[0];

			::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_control_boomer_vomit, params);
			
			local siSeq = NetProps.GetPropIntArray( params.si, "m_nSequence", 0);

			NetProps.SetPropIntArray( params.si, "m_afButtonForced", 0, 0);
			if(nearDist < 400){
				local siModel = params.si.GetModelName();
				if((siModel == "models/infected/boomette.mdl" && siSeq == 1)
				|| (siModel == "models/infected/boomer.mdl" && siSeq == 2)
				|| (siModel == "models/infected/boomer_l4d1.mdl" && siSeq == 2)){
					local viewAngle = ::hdmdSIFunc.SI_control_eye({si = params.si, tgVector = nearSurv.EyePosition()});
					
					params.si.SnapEyeAngles(viewAngle);
				}
				return;
			}
		}
	}

	function SI_control_eye(params){
		local eyeVector = params.si.GetOrigin();
		if("EyePosition" in params.si)eyeVector = params.si.EyePosition();

		local vector = params.tgVector - eyeVector;
		local qy = Quaternion();	local qx = Quaternion();
		qy.SetPitchYawRoll(0, 90-atan2(vector.x, vector.y)*180/PI, 0);
		qx.SetPitchYawRoll(atan2(vector.z, sqrt(vector.x*vector.x+vector.y*vector.y))*-180/PI, 0, 0);
		local qr = Quaternion(
			qy.x*qx.x - qy.y*qx.y - qy.z*qx.z - qy.w*qx.w,
			qy.x*qx.y + qy.y*qx.x + qy.z*qx.w - qy.w*qx.z,
			qy.x*qx.z - qy.y*qx.w + qy.z*qx.x + qy.w*qx.y,
			qy.x*qx.w + qy.y*qx.z + qy.z*qx.y + qy.w*qx.x
		).ToQAngle();

		return QAngle(qr.x, qr.y*-1, 0);
	}

	function visionCheck(viewer, target, targetEnt=null, tolerance=50, viewerAng=0){
		local startpos = viewer.EyePosition();
		local targetNorm = Vector(target.x, target.y, target.z);
		targetNorm.x -= startpos.x;	targetNorm.y -= startpos.y;	targetNorm.z -= startpos.z;
		targetNorm.x = targetNorm.x/targetNorm.Norm();
		targetNorm.y = targetNorm.y/targetNorm.Norm();
		targetNorm.z = targetNorm.z/targetNorm.Norm();

		if(viewerAng == 0)viewerAng = viewer.EyeAngles().Forward();

		if(180/PI*acos(viewerAng.Dot(targetNorm)) < tolerance){
			if(targetEnt != null){
				local m_trace = { start = startpos, end = target, ignore = viewer, mask = 33579137 };
				TraceLine(m_trace);
				if("enthit" in m_trace && m_trace.enthit == targetEnt){
					return true;
				}else{
					return false;
				}
			}else{
				return true;
			}
		}
		return false;
	}

	function SI_control_smoker(params){
		if(params.si == null || !params.si.IsValid()){
			::hdmdSIFunc.SI_append(1);	return;
		}else if(!params.si.IsDead() && !params.si.IsDying()){
			::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_control_smoker, params);
			return;
		}
	}

	function OnGameEvent_ability_use(params){
		if(params.ability == "ability_spit" && ::hdmdState.lv >= 2){
			local si = GetPlayerFromUserID(params.userid);

			local speed = NetProps.GetPropFloatArray( si, "m_flGroundSpeed", 0);
			local fv = si.GetForwardVector();
			local fx = fv.x*(speed+5);		local fy = fv.y*(speed+5);
			local pushVec = Vector(fx,fy,255);

			si.SetVelocity(pushVec);
		}else if(params.ability == "ability_vomit" && ::hdmdState.lv >= 3){
			local boomer = GetPlayerFromUserID(params.userid);

			::manacatAddTimer(0.1, false, ::hdmdSIFunc.SI_control_boomer_vomit, { si = boomer });
		}else if(params.ability == "ability_charge" && ::hdmdState.lv >= 3){
			local charger = GetPlayerFromUserID(params.userid);
			local nearSurv = ::hdmdSIFunc.findNearSurv({from = charger, visible = true, noincap = true});
			local nearDist = nearSurv[1];	local nearVisible = nearSurv[2];	nearSurv = nearSurv[0];
			if(nearSurv == null || !nearSurv.IsValid())return;
			local tgV = nearSurv.EyePosition();
			if(nearDist > 600)nearDist = 600;
			tgV += nearSurv.GetVelocity().Scale(0.175+((nearDist/600)*0.825));
			local viewAngle = ::hdmdSIFunc.SI_control_eye({si = charger, tgVector = tgV});
			
			charger.SnapEyeAngles(viewAngle);
		//	DebugDrawLine(nearSurv.EyePosition(), tgV, 0, 255, 0, true, 5);
		//	DebugDrawLine(charger.EyePosition(), tgV, 255, 0, 0, true, 5);
		}else if(params.ability == "ability_lunge"){
			local hunter = GetPlayerFromUserID(params.userid);
			if(NetProps.GetPropInt(hunter, "m_isAttemptingToPounce") != 1){
				StopAmbientSoundOn("HunterZombie.Pounce", hunter);
				EmitAmbientSoundOn("HunterZombie.Pounce", 1.0, 350, 100, hunter);
				NetProps.SetPropInt(hunter, "m_isAttemptingToPounce", 1);
			}
			if(::hdmdState.lv >= 3){
				::manacatAddTimer(0.0, false, ::hdmdSIFunc.SI_control_hunter_lunge, { si = hunter });

				local hunterPos = hunter.GetOrigin();
				local len = ::hdmdSIVars.hunter_jump.len();
				for(local i = 0; i < len; i++){
					if(::hdmdSIVars.hunter_jump[i][0] == hunter){
						::hdmdSIVars.hunter_jump[i][1] = hunterPos.z;
					}
				}
			}
		}else if(params.ability == "ability_tongue"){
			::hdmdSIVars.smoker_urgent_shot = 0;
		}
	}

	function outcast(params){
		if(params.si == null || !params.si.IsValid() || params.si.IsDead())return;
		local pos = params.si.GetOrigin();
		local flow = GetCurrentFlowPercentForPlayer(params.si);

		local surv = [];
		for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
			if(::hdmdSurvVars.playerList[i][1] != null && ::hdmdSurvVars.playerList[i][1].IsValid() && !::hdmdSurvVars.playerList[i][1].IsDead()){
				surv.append(::hdmdSurvVars.playerList[i][1]);
			}
		}
		local len = surv.len();
		for(local i = 0; i < len; i++){
			local playerflow = GetCurrentFlowPercentForPlayer(surv[i])-3;
			local playerpos = surv[i].GetOrigin();
			local dist = (playerpos - pos).Length();
			if(playerflow < flow || (playerflow > flow && dist < 850)){
			//	printl(params.si+" 범위 안에 "+surv[i].GetPlayerName()+" 존재함  dist : "+dist);
				params.unconcern = 0;	break;
			}

			local posleft = pos + Vector(0,0,40) + surv[i].EyeAngles().Left().Scale(60);
			local posright = pos + Vector(0,0,40) + surv[i].EyeAngles().Left().Scale(-60);
			if(	::hdmdSIFunc.CanSee(surv[i], pos) ||
				::hdmdSIFunc.CanSee(surv[i], pos + Vector(0,0,100)) ||
				::hdmdSIFunc.CanSee(surv[i], posleft) ||
				::hdmdSIFunc.CanSee(surv[i], posright))
			{
			//	printl(surv[i].GetPlayerName()+"에게 보여짐");
				params.unconcern = 0;	break;
			}
		}

		if(params.unconcern > 15){
		/*	::printlang("\x01   Cannot be used in versus mode.",
						"\x01   낙오 특좀 삭제 : "+params.si.GetModelName(),
						"\x01   対戦モードでは使用できません。",
						"\x01   No se puede utilizar en modo versus.",
						-3);
			::printlang("\x01   Cannot be used in versus mode.",
						"\x01   삭제 플로우 : "+flow+ "  삭제 좌표 : "+params.si.GetOrigin(),
						"\x01   対戦モードでは使用できません。",
						"\x01   No se puede utilizar en modo versus.",
						-3);*/
			local drop = params.si.GetOrigin();
			::hdmdSIFunc.SI_spawn({ztype = params.si.GetZombieType()})
			drop.z -= 5000;
			params.si.SetOrigin(drop);
			params.si.TakeDamage(1000,128,params.si);
			return;
		}else{
			params.unconcern++;
			::manacatAddTimer(0.2, false, ::hdmdSIFunc.outcast, params);
		}
	}

	function CanSee(ent, finish, traceMask = 33636363){
		local begin = ent.GetOrigin();
		if(ent.GetClassname() == "player")begin = ent.EyePosition();
		
		local m_trace = { start = begin, end = finish, ignore = ent, mask = traceMask };
		TraceLine(m_trace);
		
		if (m_trace.pos.x == finish.x && m_trace.pos.y == finish.y && m_trace.pos.z == finish.z)
			return true;
		
		return false;
	}

	function findNearSurv(params){
		if(!("visible" in params))params.visible <- false;
		local tgDist = 50000;		local tgDistSub = 50000;
		local tgSurv = null;		local tgSurvSub = null;
		local fromOrigin = params.from.GetOrigin();
		local fromVision = fromOrigin;
		if("EyePosition" in params.from)fromVision = params.from.EyePosition();
		for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
			if(!::hdmdSurvVars.playerList[i][1].IsValid())continue;
			if("novomit" in params && params.novomit && ::hdmdSurvVars.playerList[i][1].IsIT())continue;
			if("noincap" in params && params.noincap && ::hdmdSurvVars.playerList[i][1].IsIncapacitated())continue;
			if(::hdmdSurvVars.playerList[i][1].IsDead() || ::hdmdSurvVars.playerList[i][1].IsDying() || ::hdmdSurvVars.playerList[i][1].IsDominatedBySpecialInfected() || ::hdmdSurvVars.playerList[i][1].IsGettingUp())continue;

			local look = false;
			local finish = ::hdmdSurvVars.playerList[i][1].EyePosition();
			local m_trace = { start = fromVision, end = finish, ignore = params.from, mask = 33636363 };//mask = 33579137 <- 펜스 통과하는 시야
			TraceLine(m_trace);
			if(("enthit" in m_trace && m_trace.enthit == ::hdmdSurvVars.playerList[i][1]) || (m_trace.pos.x == finish.x && m_trace.pos.y == finish.y && m_trace.pos.z == finish.z))	look = true;

			local dist = (::hdmdSurvVars.playerList[i][1].GetOrigin() - fromOrigin).Length();
			if((params.visible && look) || !params.visible){
				if(dist < tgDist){
					tgDist = dist;
					tgSurv = ::hdmdSurvVars.playerList[i][1];
				}
			}
			if(dist < tgDistSub){
				tgDistSub = dist;
				tgSurvSub = ::hdmdSurvVars.playerList[i][1];
			}
		}
		if(tgSurv != null)	return [tgSurv, tgDist, true];
		else				return [tgSurvSub, tgDistSub, false];	//보이는 생존자가 아무도 없을땐 가장 가까운 생존자
	}

	function OnGameEvent_player_now_it(params){//부머즙에 맞으면 그쪽으로 특좀 어그로가 쏠리는 것 방지
		local len = ::hdmdSIVars.siList.len();
		for(local i = 0; i < len; i++){
			if(::hdmdSIVars.siList[i][0] == null || !::hdmdSIVars.siList[i][0].IsValid())continue;
			local ztype = ::hdmdSIVars.siList[i][0].GetZombieType();
			if(ztype != 2 && ztype != 4){
				local nearSurv = ::hdmdSIFunc.findNearSurv({from = ::hdmdSIVars.siList[i][0], visible = true, noincap = true});
				local nearDist = nearSurv[1];	local nearVisible = nearSurv[2];	nearSurv = nearSurv[0];
				if(nearSurv == null || !nearSurv.IsValid())continue;
				CommandABot( { cmd = 0, target = nearSurv, bot = ::hdmdSIVars.siList[i][0] } );
			}
		}
	}

	function fireListRemove(player){
		local len = ::hdmdSIVars.fireList.len();
		for(local i = 0; i < len; i++){
			if(::hdmdSIVars.fireList[i][0] == player){
				::hdmdSIVars.fireList.remove(i);
				len--;
			//	printl(player+" 화상 제거");
			}
		}
	}

	function ZSpawn(params){
		local cm_MaxSpecials = SessionOptions.cm_MaxSpecials;
		local MaxSpecials = SessionOptions.MaxSpecials;
		local cm_DominatorLimit = SessionOptions.cm_DominatorLimit;
		SessionOptions.cm_MaxSpecials <- 12;
		SessionOptions.MaxSpecials <- 12;
		SessionOptions.cm_DominatorLimit <- 12;

		::ZSpawn( params );

		SessionOptions.cm_MaxSpecials <- cm_MaxSpecials;
		SessionOptions.MaxSpecials <- MaxSpecials;
		SessionOptions.cm_DominatorLimit <- cm_DominatorLimit;

		return ::hdmdSIFunc.ZSpawn_verify(params.type);
	}

	function ZSpawn_verify(ztype){
		local player = null;
		while (player = Entities.FindByClassname(player, "player")){
			if(player.IsValid() && !player.IsDead() && !player.IsDying() && !player.IsIncapacitated() && player.GetZombieType() == ztype){
				return true;
			}
		}
		::hdmdSIFunc.SI_append(ztype);
		return false;
	}

//	function ZSpawn_table(params){//안쓰기로 점점
//		local len = params.table.len();
//		for(local i = 0; i < len; i++){
//			local delay = 1.2*i;
//			local si = params.table.remove(RandomInt(0,len-1));	len--;
//		//	::manacatAddTimer(delay, false, ::hdmdSIFunc.ZSpawn, { type = si, pos = null, ang = QAngle(0,0,0) } );
//		}
//	}

	function startAttack(){
		local chkSpawn = 0;
		local captures = 0;		local supports = 0;
		if(Director.IsFirstMapInScenario()){
			if		(::hdmdState.lv == 7){	captures=3;supports=1;	::hdmdSIVars.spawn_time = Time()+6.0;	}
			else if (::hdmdState.lv == 6){	captures=3;supports=1;	::hdmdSIVars.spawn_time = Time()+8.0;	}
			else if (::hdmdState.lv == 5){	captures=2;supports=1;	::hdmdSIVars.spawn_time = Time()+10.0;	}
			else if (::hdmdState.lv == 4){	captures=2;supports=1;	::hdmdSIVars.spawn_time = Time()+10.0;	}
			else if (::hdmdState.lv == 3){	captures=2;supports=1;	::hdmdSIVars.spawn_time = Time()+12.0;	}
			else{													::hdmdSIVars.spawn_time = Time()+12.0;
				if(RandomInt(1,2)==1){		captures=1;supports=1;	}
				else{						captures=2;supports=0;	}
			}
		}else{		//printl(Time() + "<left_chkP>");
			if		(::hdmdState.lv == 7){	captures=4;supports=1;	::hdmdSIVars.spawn_time = Time()+6.0;	}
			else if (::hdmdState.lv == 6){	captures=3;supports=1;	::hdmdSIVars.spawn_time = Time()+8.0;	}
			else if (::hdmdState.lv == 5){	captures=3;supports=1;	::hdmdSIVars.spawn_time = Time()+10.0;	}
			else if (::hdmdState.lv == 4){	captures=2;supports=1;	::hdmdSIVars.spawn_time = Time()+10.0;	}
			else if (::hdmdState.lv == 3){	captures=2;supports=1;	::hdmdSIVars.spawn_time = Time()+12.0;	}
			else{													::hdmdSIVars.spawn_time = Time()+12.0;
				if(RandomInt(1,2)==1){		captures=1;supports=1;	}
				else{						captures=2;supports=0;	}
			}
		}
		::hdmdSIVars.spawn_cmd = 1;
		::manacatAddTimer(5.0, false, ::hdmdSIFunc.SI_spawn, {capture = captures, support = supports});
	}
}

::setAggressiveSpecials <- function(){
	//printl("특수좀비 상태 전환");
	local ground = false;
	for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
		if(::hdmdSurvVars.playerList[i][2] == true){//한명이라도 정상적인 그라운드 위에 있어야 탱크 활성화
			ground = true;break;
		}
	}
	if(::hdmdState.lv >= 4){
		if(ground){
			DirectorScript.GetDirectorOptions().cm_AggressiveSpecials <- true;
			//탱크에게 생존자의 1데미지를 줘서 강제로 쫓아오게 만들기
			local tank;		local someplayer;
			while (someplayer = Entities.FindByClassname(someplayer, "player")){
				if(someplayer.IsValid()){
					if(someplayer.GetZombieType() == 9){
						break;
					}
				}
			}
			local len = ::hdmdTankVars.tankList.len();
			while (tank = Entities.FindByClassname(tank, "player")){
				if(tank.IsValid()){
					//printl("탱크 "+NetProps.GetPropIntArray( tank, "m_lookatPlayer", 0 ));	
					if(tank.GetZombieType() == 8 && NetProps.GetPropIntArray( tank, "m_lookatPlayer", 0 ) == -1){
						for(local i = 0; i < len; i++){
							if(tank.IsValid() && ::hdmdTankVars.tankList[i][0] == tank && ::hdmdTankVars.tankList[i][1] < Time()){
								NetProps.SetPropIntArray( tank, "m_lookatPlayer", 1, 0 );
								//tank.TakeDamage(1, 128, someplayer);
								local punch = tank.GetActiveWeapon();
								tank.TakeDamageEx(punch, someplayer, punch, someplayer.GetOrigin(), someplayer.GetOrigin(), 1, 128);
							}
						}
					}
				}
			}
		}

		//윗치가 은신처까지 들어오도록
		DirectorScript.GetDirectorOptions().AllowWitchesInCheckpoints <- true;
	}else{
		DirectorScript.GetDirectorOptions().cm_AggressiveSpecials <- false;
		DirectorScript.GetDirectorOptions().AllowWitchesInCheckpoints <- false;
	}
}

::hdmdSIFunc.SI_spawn_set();

__CollectEventCallbacks(::hdmdSIFunc, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);