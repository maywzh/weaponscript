::hdmdTankVars<-{
	tank = 0 //지금까지 뜬 탱크의 수
	tanks = 0 //필드에서 활동중인 탱크의 수
	tankList = [] //탱크가 뜰때마다 집어넣는 배열
	/*
	[0] = 탱크
	[1] = 스폰시간
	[2] = 투석시간
	[3] = 다음 투석 가능시간
	[4] = 탐색한 투석 대상
	[5] = 돌 던지는 폼
	[6] = 강제 이동 목표 좌표(미니건 사용시) [0] = 현재 명령 좌표 [1] = 이전 명령 좌표
	[7] = 강제 이동 명령 수행중인가? true or false
	[8] = 강제 이동 타겟 바꾼 시간
	[9] = 강제 이동 타겟
	[10] = 불붙어서 물가 내비 검색했던 시간*/

	tankpos1 = 0
	tankpos1flow = 102
	tankspawn1 = null
	tank1spawnStart = false

	tankpos2 = 0
	tankpos2flow = 102
	tankspawn2 = null
	tank2spawnStart = false

	tankflow1 = -102
	tankflow2 = 0
	tankflow3 = 0

//	reviverList = [] //탱크가 활동중인데 살리는 사람 리스트

	//헛방대책
	punch = [] //각 탱크별 펀치 쿨타임중인지, 이 리스트에 있으면 펀치 쿨타임중인 탱크라는 뜻
	punchList = [] //탱크가 누가 누굴 때렸는지, [0]탱크, [1]피격자
	punchRetreat = [] //헛방 후 후퇴중인 탱크 리스트
	dmg_done = 0
	dmg_2tank = 0
	mounted_weapon_user = null

	door_pound = 0 //은신처 문을 3번 두드리면 강제로 열린다
	door_pound_time = 0 //탱크가 은신처 문을 두드린 시간, 갱신 텀은 1초
	door_pound_hint = null //게임교사 힌트메시지가 존재하지 않고 있다면 null
	door_pound_hint_witch = null //위의 윗치버전

	sessionDataBoss = {} //세션 세이브 로드

	kkangList = [] //깡 리스트
	waterList = [] //불타면 들어갈 물 내비 리스트
	infernoList = [] //불 리스트
	fireList = [] //불타는 내비영역
	fireListTime = [] //불타는 내비영역이 확인된 시간 (재귀 확산 중복체크용)
}

::hdmdTankFunc<-{
	function OnGameEvent_player_left_safe_area(params){
		::hdmdTankFunc.tank_pos();
		if(::hdmdTankVars.tankpos1flow == 102 && ::hdmdTankVars.tankpos2flow == 102)DirectorScript.GetDirectorOptions().DisallowThreatType <- null;//탱크 스폰지점이 102면 금지 해제, 디렉터에 맡김
	}

	function tank_zombie(){
		local cp = ::hdmdSurvVars.teamPower;
		local swing = 0;
		local miss = 0;
		local burn = 0;//불 데미지 경감 팩터
		
		if(1 >= ::hdmdSurvVars.teamPower && ::hdmdSurvVars.teamPower > 0){
			burn += 20;
		}else if(2 >= ::hdmdSurvVars.teamPower && ::hdmdSurvVars.teamPower > 1){
			burn += 30;
			miss = 0.4;
		}else if(3 >= ::hdmdSurvVars.teamPower && ::hdmdSurvVars.teamPower > 2){
			burn += 40;
			swing = 0.4;
			miss = 0.4;
		}else{
			burn += 50;
			swing = 0.9;
			miss = 0.4;
		}
		if(::hdmdState.finale){
			burn -= 25;
		}
		
	//	Convars.SetValue("tank_attack_range", 49+cp);
	//	Convars.SetValue("tank_swing_range", 55+cp);
		Convars.SetValue("tank_swing_fast_interval", 0.6);
		if(::mp_gamemode != "versus"){
			cp--;
			Convars.SetValue("tank_swing_interval", 1.5-(swing*(cp/3)));
			Convars.SetValue("tank_swing_miss_interval", 1.0-(miss*(cp/3)));
			Convars.SetValue("z_tank_throw_interval", 15-(45*(cp/3)));
			if(burn < 0)burn = 0;
			Convars.SetValue("tank_burn_duration", 75+burn);
			Convars.SetValue("tank_burn_duration_hard", 80+burn*2);
			Convars.SetValue("tank_burn_duration_expert", 85+burn*3);
		}
	}

	function kkangListManage(tank = null){
		local kkanglen = ::hdmdTankVars.kkangList.len();
		if(kkanglen == 0){
			local ent = null;
			while (ent = Entities.FindByClassname(ent, "prop_physics")){
				local entOrigin = ent.GetOrigin();	entOrigin.z += 20;
				if((NetProps.GetPropInt( ent, "m_spawnflags" ) & 4) != 4 && (NetProps.GetPropInt( ent, "m_spawnflags" ) & 32768) != 32768
				&& NetProps.GetPropInt(ent, "m_hasTankGlow") == 1 && NetProps.GetPropInt(ent, "m_breakableType") != 2)::hdmdTankVars.kkangList.append(ent);
			}

			while (ent = Entities.FindByClassname(ent, "prop_physics_multiplayer")){
				local entOrigin = ent.GetOrigin();	entOrigin.z += 20;
				if((NetProps.GetPropInt( ent, "m_spawnflags" ) & 4) != 4
				&& NetProps.GetPropInt(ent, "m_hasTankGlow") == 1)::hdmdTankVars.kkangList.append(ent);
			}

			while (ent = Entities.FindByClassname(ent, "prop_car_alarm")){
				local entOrigin = ent.GetOrigin();	entOrigin.z += 20;
				if((NetProps.GetPropInt( ent, "m_spawnflags" ) & 4) != 4
				&& NetProps.GetPropInt(ent, "m_hasTankGlow") == 1)::hdmdTankVars.kkangList.append(ent);
			}
		}else{
			if(tank == null){
				for(local i = 0; i < kkanglen; i++){
					if(::hdmdTankVars.kkangList[i] == null || !::hdmdTankVars.kkangList[i].IsValid()){
						::hdmdTankVars.kkangList.remove(i);		kkanglen--;
					}
				}
			}else{
				local origin = tank.GetOrigin();
				for(local i = 0; i < kkanglen; i++){
					if(::hdmdTankVars.kkangList[i] != null && ::hdmdTankVars.kkangList[i].IsValid()){
						local entOrigin = ::hdmdTankVars.kkangList[i].GetOrigin();	entOrigin.z += 20;
						if(::hdmdSIFunc.CanSee(tank, entOrigin, 131083) && (entOrigin-origin).Length() < 180)return true;
					}
				}
			}
		}
		return false;
	}

	function waterManage(tank = null){//탱크가 지정되면 가장 가까운 물가를 확보
		return;
		local waterlen = ::hdmdTankVars.waterList.len();
		if(waterlen == 0){
			local navTable = {};	NavMesh.GetAllAreas(navTable);
			foreach(areaName, nav in navTable){
				local pos = nav.GetCenter();
				local flow = GetFlowPercentForPosition(pos, false);

				pos.z += 20;
				local endArea = NavMesh.GetNavArea(pos, 60.0);

				if( !nav.HasAvoidanceObstacle(100.0) && nav.GetSizeX() > 40 && nav.GetSizeY() > 40 && !nav.IsBlocked(3, false)
				&& ((!nav.IsDegenerate() && nav.IsUnderwater() && !nav.IsDamaging()))){
					local begin = pos;
					local finish = nav.GetCenter();	finish.z -= 99999;
					
					local m_trace = { start = pos, end = finish, mask = 131083 };
					TraceLine(m_trace);

					local depth = (pos - m_trace.pos).Length();
					if(depth < 40){
						DebugDrawBox(m_trace.pos, Vector((nav.GetSizeX()/2)*-1,(nav.GetSizeY()/2)*-1,-12.0), Vector((nav.GetSizeX()/2),(nav.GetSizeY()/2),12.0), 0, 0, 255, 64, 12.0);
						DebugDrawBox(begin, Vector((nav.GetSizeX()/2)*-1,(nav.GetSizeY()/2)*-1,-12.0), Vector((nav.GetSizeX()/2),(nav.GetSizeY()/2),12.0), 0, 0, 255, 64, 12.0);
						::hdmdTankVars.waterList.append([nav, pos])
					}
				}
			}
		}else if(tank != null){
			local len = ::hdmdTankVars.tankList.len();
			for(local i = 0; i < len; i++){
				if(::hdmdTankVars.tankList[i][0] == tank && ::hdmdTankVars.tankList[i][10] < Time()){
					::hdmdTankVars.tankList[i][10] = Time()+3;
					local tankOrigin = tank.GetOrigin();
					local mdist = 1000;	local tgnav = null;
					local tgwaterOrigin = Vector(0,0,0);
					for(local i = 0; i < waterlen; i++){
						local waterOrigin = Vector(::hdmdTankVars.waterList[i][1].x, ::hdmdTankVars.waterList[i][1].y, ::hdmdTankVars.waterList[i][1].z);
						local dist = (tankOrigin - waterOrigin).Length();
						waterOrigin.z += 40;
						if(dist >= 0 && dist < mdist){
							local view = ::hdmdSIFunc.CanSee(tank, waterOrigin);
							printl(dist+"  "+mdist+"  "+view);
							if(view){
								mdist = dist;	tgnav = ::hdmdTankVars.waterList[i][0];		tgwaterOrigin = Vector(waterOrigin.x, waterOrigin.y, waterOrigin.z);
								printl(::hdmdTankVars.waterList[i][0] + "  " + dist);
								DebugDrawBox(waterOrigin, Vector((tgnav.GetSizeX()/2)*-1,(tgnav.GetSizeY()/2)*-1,-12.0), Vector((tgnav.GetSizeX()/2),(tgnav.GetSizeY()/2),12.0), 0, 255, 0, 64, 12.0);
							}
						}
					}
					DebugDrawBox(tgwaterOrigin, Vector((tgnav.GetSizeX()/2)*-1,(tgnav.GetSizeY()/2)*-1,-12.0), Vector((tgnav.GetSizeX()/2),(tgnav.GetSizeY()/2),12.0), 0, 0, 255, 64, 12.0);
					printl("가장 가까운 물가 : "+tgnav+"  "+mdist+"    "+tgwaterOrigin+"     "+tankOrigin);
					return tgwaterOrigin;
				}
			}
		}
		return null;
	}

	function OnGameEvent_tank_spawn(params){
		local zombie = GetPlayerFromUserID(params.userid);
	//	if(!IsPlayerABot(zombie)){
	//		printl("<Human Player> Tank");	return;
	//	}
		if(::hdmdTankVars.tanks == 0)::hdmdTankVars.dmg_done = 0;
		::manacatAddTimer(0.5, false, ::hdmdTankFunc.tankspawn, { tank = zombie });
	}

	function tankspawn(params){
		::hdmdTankVars.kkangList = [];//깡 리스트 초기화
		::hdmdTankFunc.kkangListManage();
		::hdmdTankFunc.tank_count();

		local currentTime = Time();
		::hardmodeFunc.toHardmodeSet();

		local nomsg = false;	local len = ::hdmdTankVars.tankList.len();
		local chk = false;
		for(local i = 0; i < len; i++){
			if(::hdmdTankVars.tankList[i][0] == params.tank){
				chk = true;
				break;
			}
		}
		if(!chk){
			::hdmdTankVars.tankList.append([params.tank, currentTime, -100, -100, null, 0, [null, null], false, 0, null, 0]);
			::hdmdTankVars.tank++;
		}

		//탱크 체력 설정
		local tankHealth = ::hdmdTankFunc.tankHP();

		NetProps.SetPropIntArray( params.tank, "m_iMaxHealth", tankHealth, 0 );
		NetProps.SetPropIntArray( params.tank, "m_iHealth", tankHealth, 0 );
		
		::manacatAddTimer(0.1, false, ::hdmdTankFunc.SI_control_tank, { si = params.tank });

		if(::hdmdTankVars.tanks >= 2){
			if(::hdmdSurvVars.playerCount == 1)			::hdmdTankVars.dmg_2tank = 1200;
			else if(::hdmdSurvVars.playerCount == 2)	::hdmdTankVars.dmg_2tank = 1800;
			else if(::hdmdState.lv <= 5)				::hdmdTankVars.dmg_2tank = 2200;
			else if(::hdmdState.lv == 6)				::hdmdTankVars.dmg_2tank = 2500;
			else if(::hdmdState.lv == 7)				::hdmdTankVars.dmg_2tank = 2800;
		}
	}

	function tankrush(tank){
		for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
			if(::hdmdSurvVars.playerList[i][2] == true){//한명이라도 정상적인 그라운드 위에 있어야 탱크 활성화
				return;
			}
		}
	}

	function SI_control_tank(params){
		if(params.si.IsValid() && !params.si.IsDead() && !params.si.IsDying() && !params.si.IsIncapacitated()){
			::manacatAddTimer(0.1, false, ::hdmdTankFunc.SI_control_tank, params);
			if(params.si.GetHealth()==1){
				params.si.TakeDamage(1, 129, params.si);
				return;
			}

			local tankN = ::hdmdTankVars.tankList.len();
			for(local i = 0; i < tankN; i++){
				if(::hdmdTankVars.tankList[i][0] == params.si){tankN = i;break;}
			}
			if(tankN == -1)return;

			local origin = params.si.GetOrigin();		local mindist = 99999;
			for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
				if(!::hdmdSurvVars.playerList[i][1].IsValid() || ::hdmdSurvVars.playerList[i][1].IsDead() || ::hdmdSurvVars.playerList[i][1].IsDying())continue;
				local dist = (::hdmdSurvVars.playerList[i][1].GetOrigin() - origin).Length();
				if(dist < mindist)	mindist = dist;
			}

			local aggro = Director.IsTankInPlay();
			local siSeq = NetProps.GetPropInt( params.si, "m_nSequence");
			local activity = params.si.GetSequenceActivityName(params.si.GetSequence());
			local movetype = NetProps.GetPropInt( params.si, "movetype");
		//	printl(" 시퀀스 "+siSeq);
			//printl(params.si.GetActiveWeapon().SetNetProp("m_flNextPrimaryAttack", Time() + 2.0);)

			local nearSurv = ::hdmdSIFunc.findNearSurv({from = params.si, visible = true, noincap = true});
			local nearDist = nearSurv[1];	local nearVisible = nearSurv[2];	nearSurv = nearSurv[0];
			if(nearSurv == null || !nearSurv.IsValid())return;

			/*//탱크 투석지점 예상
			local rockOrigin = params.si.EyePosition();
			local rockDist = (params.si.EyePosition() - nearSurv.GetOrigin()).Length();
			local targetPos = nearSurv.EyePosition()+nearSurv.GetVelocity().Scale(0.4)+Vector(0,0,rockDist/6.2);
			local tankViewAngle = ::hdmdSIFunc.SI_control_eye({si = params.si, tgVector = targetPos});
			tankViewAngle.z += rockDist/400;
			local newForce = tankViewAngle.Forward().Scale(800);
			DebugDrawLine(rockOrigin, rockOrigin+newForce, 255, 0, 0, true, 0.1);
			DebugDrawBox(targetPos, Vector(-3.0,-3.0,-3.0), Vector(3.0,3.0,3.0), 255, 0, 0, 64, 0.1);
			*/

			//사다리에 매달려있는채로 머리 위에 있으면 그냥 밀어내면서 올라가기
			if("ladder_chase" in params){
				if(params.ladder_chase == null || !params.ladder_chase.IsValid() || params.ladder_chase.IsDead() || params.ladder_chase.IsDying()
				|| params.ladder_chase.IsIncapacitated() || params.ladder_chase.IsDominatedBySpecialInfected()
				|| NetProps.GetPropInt( params.ladder_chase, "movetype") != 9){
					params.rawdelete("ladder_chase");
					CommandABot( { cmd = 0, target = nearSurv, bot = params.si } );
				}
				return;
			}else{
				if(NetProps.GetPropInt( nearSurv, "movetype") == 9){
					if(::hdmdSIFunc.visionCheck(params.si, nearSurv.EyePosition(), nearSurv, 15, params.si.GetAngles().Up())){
						local tankground = NavMesh.GetNearestNavArea(origin, 150.0, true, true);
						if(tankground != null){
							local tankladder = {}
							for(local i = 0; i < 4; i++){
								tankground.GetLadders(i, tankladder);
								if(tankladder.len() != 0){
									foreach(ladder in tankladder){
										local top = NavMesh.GetNearestNavArea(ladder.GetTopOrigin(), 150.0, true, true);
										if(top != null){
											CommandABot( { cmd = 1, pos = top.GetCenter(), bot = params.si } );
											params.ladder_chase <- nearSurv;
											return;
										}
									}
								}
							}
						}
						return;
					}
				}
			}

			//사다리탈때 주변에 있으면 밀어내기
			if(movetype == 9)::hdmdTankFunc.tank_ladder_push(params.si);

			//위치 갱신
			if(::hdmdState.start && aggro && ::hdmdTankFunc.GetTankThrowTime(params.si)[0]+5 < Time()){
				if(!("originArray" in params)){
					params.originArray <- [params.si.GetOrigin()];
					params.originRecord <- 0;
				}else{
					if(params.originRecord < 5){
						params.originRecord++;
					}else{
						params.originRecord = 0;
						params.originArray.insert(0, params.si.GetOrigin());
						local len = params.originArray.len();
						if(len > 4)params.originArray.pop();	len--;
						local stuck = 0;
						for(local i = 1; i < len; i++){
							local dist = (params.originArray[0]-params.originArray[i]).Length();
							if(dist < 15)stuck++;
						}
						if(stuck >= 3){
							//위치가 그대로면 점프펀치 한번 날리고 주변 장애물 제거
							NetProps.SetPropIntArray( params.si, "m_afButtonForced", 3, 0);
							local ent = null;
							while (ent = Entities.FindByClassname(ent, "prop_physics")){
								if(ent != null && ent.IsValid() && (ent.GetOrigin()-params.originArray[0]).Length() < 80){
									ent.TakeDamage(100, 128, params.si);
								}
							}
							while (ent = Entities.FindByClassname(ent, "func_breakable")){
								if(ent != null && ent.IsValid() && (ent.GetOrigin()-params.originArray[0]).Length() < 300){
									DoEntFire("!self", "break", "", 0.0, null, ent);
								}
							}
							return;
						}else{
							local key = (NetProps.GetPropIntArray( params.si, "m_afButtonForced", 0) & ~3);
							NetProps.SetPropIntArray( params.si, "m_afButtonForced", key.tointeger(), 0);
						}
					}
				}
			}

			/*if(params.si.IsOnFire()){
				local waterside = ::hdmdTankFunc.waterManage(params.si);
				if(waterside != null){
					CommandABot( { cmd = 1, pos = waterside, bot = params.si } );
				}
				//불에 타면 물로 들어가라고
			}*/

		//이동속도 (3등급 난이도부터)
			if(::hdmdState.lv >= 3){
				local speed = 0;
				if(::hdmdSurvVars.teamPower <= 2)		speed = 210;
				else if(::hdmdSurvVars.teamPower <= 3)	speed = 212;
				else									speed = 215;
				Convars.SetValue("z_tank_speed", speed);
				speed = 1.0;
				
				if(mindist > 700)									speed = 1.0+((mindist-700)/1000);

				if(speed > 1.5)speed = 1.5;
				
				if(movetype == 9)														speed = 1.5;
				else if(movetype == 11 && speed < 2.5 &&
				(activity == "ACT_TERROR_CLIMB_36_FROM_STAND" || activity == "ACT_TERROR_CLIMB_38_FROM_STAND" || activity == "ACT_TERROR_CLIMB_50_FROM_STAND" || activity == "ACT_TERROR_CLIMB_70_FROM_STAND"
				|| activity == "ACT_TERROR_CLIMB_115_FROM_STAND" || activity == "ACT_TERROR_CLIMB_130_FROM_STAND" || activity == "ACT_TERROR_CLIMB_150_FROM_STAND" || activity == "ACT_TERROR_CLIMB_166_FROM_STAND"))
																						speed = 2.5;
				else if(params.si.IsOnFire() && ::hdmdState.lv >= 4 && speed < 1.2)		speed = 1.2;
				else if(speed < 1.0)													speed = 1.0;

			//	printl("스피드 : "+speed + " 무브타입 : " + movetype + " 시퀀스 : " + siSeq);

				NetProps.SetPropFloatArray( params.si, "m_flLaggedMovementValue", speed, 0 );
			}else{
				NetProps.SetPropFloatArray( params.si, "m_flLaggedMovementValue", 1.0, 0 );
			}

		//투석 후 휴식 제거 (4등급 난이도부터)
			if(::hdmdState.lv >= 4){
				if(siSeq == 60){//시퀀스  60은 빨리감기 할 시 멈추므로
					params.si.SetSequence(54);
				}else if(activity == "ACT_TERROR_RAGE_AT_ENEMY" || activity == "ACT_TERROR_RAGE_AT_KNOCKDOWN"){//탱크 돌던지기 후 숨고르기, 시퀀스 54~57(에너미) / 58~60(넉다운)
					NetProps.SetPropFloatArray( params.si, "m_flCycle", 1000.0, 0);
				}
			}

			local punch = false;	local attack = false;
			if(!attack){
				for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
					if(!::hdmdSurvVars.playerList[i][1].IsValid())continue;
					local dist = (::hdmdSurvVars.playerList[i][1].GetOrigin() - params.si.GetOrigin()).Length();
					if(dist < 90
					//&& ::hdmdSIFunc.visionCheck(params.si, ::hdmdSurvVars.playerList[i][1].EyePosition(), ::hdmdSurvVars.playerList[i][1], 45)
					){
						punch = true;//	printl("펀치 발진" + (NetProps.GetPropFloatArray( params.si.GetActiveWeapon(), "m_flNextPrimaryAttack", 0) < Time()) + "  " + (::hdmdTankFunc.GetTankThrowTime(params.si)[1] < Time()));
					//	printl("시간" + Time() + "  " + (NetProps.GetPropFloatArray( params.si.GetActiveWeapon(), "m_flNextPrimaryAttack", 0)) + "  " + (::hdmdTankFunc.GetTankThrowTime(params.si)[1]));
						local viewAngle = ::hdmdSIFunc.SI_control_eye({si = params.si, tgVector = nearSurv.EyePosition()});
						params.si.SnapEyeAngles(viewAngle);
					}
				}

				if(punch && NetProps.GetPropFloatArray( params.si.GetActiveWeapon(), "m_flNextPrimaryAttack", 0) < Time()
				&& ::hdmdTankFunc.GetTankThrowTime(params.si)[1] < Time()){
					::hdmdTankFunc.attack_start({si = params.si, attack = 2049});//점펀돌
					attack = true;
				}
			}
			
			if(!attack){
				//주변에 깡이 있으면 공격
				if(::hdmdTankFunc.kkangListManage(params.si)){
					::hdmdTankFunc.attack_start({si = params.si, attack = 1});
				}
			}

			/*
			local mounted_weapon_use = false;	local mounted_user = false;	local targetOri = null;
			for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
				if(!::hdmdSurvVars.playerList[i][1].IsValid())continue;
				if(NetProps.GetPropEntity(::hdmdSurvVars.playerList[i][1], "m_hUseEntity") != null){
					if(::hdmdTankVars.mounted_weapon_user != ::hdmdSurvVars.playerList[i][1]){
						::hdmdTankVars.mounted_weapon_user = ::hdmdSurvVars.playerList[i][1];
						mounted_user = true;
						if(::hdmdTankVars.tankList[tankN][8]+10 < Time()){
							::hdmdTankVars.tankList[tankN][8] = Time();
							::hdmdTankVars.tankList[tankN][9] = nearSurv;
						}
					}
					mounted_weapon_use = true;
				}
			}
			if(::hdmdTankVars.tankList[tankN][9] != null && ::hdmdTankVars.tankList[tankN][9].IsValid()){
				targetOri = ::hdmdTankVars.tankList[tankN][9].GetOrigin();
			//	local begin = ::hdmdTankVars.tankList[tankN][9].GetOrigin();
			//	local finish = ::hdmdTankVars.tankList[tankN][9].GetOrigin();	finish.z -= 99999;
				
			//	local m_trace = { start = begin, end = finish, mask = 131083 };
			//	TraceLine(m_trace);

			//	targetOri = m_trace.pos;

			//	local height = (begin - m_trace.pos).Length();
			//	if(height < 80){
			//		너무 높은 곳에 있는데
			//	}
			}
			//신규유저일 필요가 없다. 무브명령은 지속적이기 때문에
			//마운트건 해제 후 재사용시 무브명령이 취소되는지를 확인해서
			//취소가 된다면 = 신규사용시 재명령 내릴 필요 O
			//취소가 안된다면 = 신규사용여부와 무관하게 마운트건 사용중이기만 하면 지정장소 이동명령 루틴수행
				if(mounted_weapon_use){
					//printl("무기를 사용중");
					//if(mounted_user){
						//printl("신규 유저");
						//::manacatAddTimer(0.2, false, ::CommandABot, { cmd = 0, target = nearSurv, bot = params.si });
						if(::hdmdTankVars.tankList[tankN][9] == null || !::hdmdTankVars.tankList[tankN][9].IsValid() ||
						::hdmdTankVars.tankList[tankN][9].IsDead() || ::hdmdTankVars.tankList[tankN][9].IsDying() || ::hdmdTankVars.tankList[tankN][9].IsIncapacitated() || ::hdmdTankVars.tankList[tankN][9].IsDominatedBySpecialInfected()){
							::hdmdTankVars.tankList[tankN][6][0] = null;
							::hdmdTankVars.tankList[tankN][7] = false;
							::hdmdTankVars.tankList[tankN][8] = 0;
							::hdmdTankVars.tankList[tankN][9] = nearSurv;
						}else if(::hdmdTankVars.tankList[tankN][6][0] == null || (::hdmdTankVars.tankList[tankN][6][0] != null &&
						((::hdmdTankVars.tankList[tankN][6][0] - targetOri).Length() > 56 || (::hdmdTankVars.tankList[tankN][6][0] - origin).Length() < 56))){
							if(NetProps.GetPropEntity(::hdmdTankVars.tankList[tankN][9], "m_hUseEntity") != null){
								targetOri += NetProps.GetPropEntity(::hdmdTankVars.tankList[tankN][9], "m_hUseEntity").GetForwardVector().Scale(-40);
							}
							targetOri += Vector(0, 0, 20);
							::hdmdTankVars.tankList[tankN][6][0] = targetOri;
							::hdmdTankVars.tankList[tankN][7] = false;
							DebugDrawBox(origin, Vector(-30.0,-30.0,-30.0), Vector(30.0,30.0,30.0), 255, 0, 0, 32, 5.0);
						}
						//CommandABot( { cmd = 1, pos = targetOri, bot = params.si } );
					//}
				}else if(::hdmdTankVars.tankList[tankN][9] != null && ::hdmdTankVars.tankList[tankN][9].IsValid()){
					::hdmdTankVars.mounted_weapon_user = null;
					::hdmdTankVars.tankList[tankN][6][0] = null;
					::hdmdTankVars.tankList[tankN][7] = false;
					if(!::hdmdTankVars.tankList[tankN][9].IsDead() && !::hdmdTankVars.tankList[tankN][9].IsDying() && !::hdmdTankVars.tankList[tankN][9].IsIncapacitated() && !::hdmdTankVars.tankList[tankN][9].IsDominatedBySpecialInfected()){
						printl("공격 명령 타겟 : "+ ::hdmdTankVars.tankList[tankN][9]);
						CommandABot( { cmd = 0, target = ::hdmdTankVars.tankList[tankN][9], bot = params.si } );//이게 필요할지 예상한 이유 : 계속 이동중인 AI에게 즉시 공격명령을 내리기 위해
					}
					::hdmdTankVars.tankList[tankN][9] = null;
					printl("공격 명령");
				}
			//미니건/중기관총 데미지는 너프해야 할 듯
			//강제이동 명령 실행
			if(::hdmdTankVars.tankList[tankN][6][0] != null && (::hdmdTankVars.tankList[tankN][6][1] == null || (::hdmdTankVars.tankList[tankN][6][1] != null &&
			(::hdmdTankVars.tankList[tankN][6][0].x != ::hdmdTankVars.tankList[tankN][6][1].x || ::hdmdTankVars.tankList[tankN][6][0].y != ::hdmdTankVars.tankList[tankN][6][1].y || ::hdmdTankVars.tankList[tankN][6][0].z != ::hdmdTankVars.tankList[tankN][6][1].z)))){
				if(::hdmdTankVars.tankList[tankN][7] == false && movetype != 9 && 
				(activity != "ACT_TERROR_CLIMB_36_FROM_STAND" && activity != "ACT_TERROR_CLIMB_38_FROM_STAND" && activity != "ACT_TERROR_CLIMB_50_FROM_STAND" && activity != "ACT_TERROR_CLIMB_70_FROM_STAND" &&
				activity != "ACT_TERROR_CLIMB_115_FROM_STAND" && activity != "ACT_TERROR_CLIMB_130_FROM_STAND" && activity != "ACT_TERROR_CLIMB_150_FROM_STAND" && activity != "ACT_TERROR_CLIMB_166_FROM_STAND")){
					::hdmdTankVars.tankList[tankN][7] = true;
					::hdmdTankVars.tankList[tankN][6][1] = ::hdmdTankVars.tankList[tankN][6][0];
					CommandABot( { cmd = 1, pos = ::hdmdTankVars.tankList[tankN][6][0], bot = params.si } );
					DebugDrawBox(::hdmdTankVars.tankList[tankN][6][0], Vector(-3.0,-3.0,-3.0), Vector(3.0,3.0,3.0), 255, 0, 0, 64, 5.0);
					printl("이동 명령" + ::hdmdTankVars.tankList[tankN][6][0] + "   " + ::hdmdTankVars.tankList[tankN][6][1]);

				//	CommandABot( { cmd = 0, target = ::hdmdTankVars.tankList[tankN][9], bot = params.si } );
				//	printl("공격 명령 타겟2 : "+ ::hdmdTankVars.tankList[tankN][9]);
				}
			}
			*/
		}
	}

	function attack_start(params){
		if(NetProps.GetPropFloatArray( params.si.GetActiveWeapon(), "m_flNextPrimaryAttack", 0) < Time()
		&& ::hdmdTankFunc.GetTankThrowTime(params.si)[1] < Time()){
			local chkPunchButton = NetProps.GetPropIntArray( params.si, "m_afButtonForced", 0) == ( NetProps.GetPropIntArray( params.si, "m_afButtonForced", 0) | params.attack );

			NetProps.SetPropIntArray( params.si, "m_afButtonForced", 0, 0);

		//	if(!::CanTraceToLocation(params.si, tgOri))return;
			if(!chkPunchButton){
				NetProps.SetPropIntArray( params.si, "m_afButtonForced", params.attack, 0); //1 = 펀치 2048 = 투석
			}
			::manacatAddTimer(0.1, false, ::hdmdTankFunc.attack_end, params);
		}
	}

	function attack_end(params){
		local key = (NetProps.GetPropIntArray( params.si, "m_afButtonForced", 0) & ~2049);
		NetProps.SetPropIntArray( params.si, "m_afButtonForced", key.tointeger(), 0);
	}

	function OnGameEvent_ability_use(params){
		if(params.ability == "ability_throw"){
			local tank = GetPlayerFromUserID(params.userid);
			NetProps.SetPropIntArray( tank, "m_afButtonDisabled", 2048, 0);
			::manacatAddTimer(8.0, false, ::hdmdTankFunc.throw_allow, {si = tank});
			local len = ::hdmdTankVars.tankList.len();
			for(local i = 0; i < len; i++){
				if(::hdmdTankVars.tankList[i][0] == tank){
					::hdmdTankFunc.SetTankThrowTime(tank);

					if(::hdmdState.lv >= 4){
						::manacatAddTimer(1.9, false, ::hdmdTankFunc.SI_control_tank_rock_adjust, {si = tank});
						::manacatAddTimer(0.5, false, ::hdmdTankFunc.SI_control_tank_rock, {si = tank});

						local speed = NetProps.GetPropFloatArray( tank, "m_flGroundSpeed", 0);
						if(speed > 100){
							local fv = tank.GetForwardVector();
							local fx = fv.x*(speed+5);		local fy = fv.y*(speed+5);
							local pushVec = Vector(fx,fy,255);

							tank.SetVelocity(pushVec);
						}
					}

					break;
				}
			}
		}
		//if(GetPlayerFromUserID(params.userid).GetClassname())
	}

	function throw_allow(params){
		if(params.si == null || !params.si.IsValid()
		|| params.si.IsDead() || params.si.IsDying() || params.si.IsIncapacitated())return;
		NetProps.SetPropIntArray( params.si, "m_afButtonDisabled", 0, 0);
	}

	function SI_control_tank_rock(params){
		if(params.si == null || !params.si.IsValid())return;
		local nearSurv = ::hdmdSIFunc.findNearSurv({from = params.si, visible = true, noincap = true});
		local nearDist = nearSurv[1]; nearSurv = nearSurv[0];
		local siSeq = NetProps.GetPropIntArray( params.si, "m_nSequence", 0);
		if(siSeq == 49 || siSeq == 50 || siSeq == 51){
			::manacatAddTimer(0.1, false, ::hdmdTankFunc.SI_control_tank_rock, params);
			if(nearSurv == null || !nearSurv.IsValid())return;
			CommandABot( { cmd = 0, target = nearSurv, bot = params.si } );
			NetProps.SetPropEntity( params.si, "m_lookatPlayer", nearSurv );
			local len = ::hdmdTankVars.tankList.len();
			for(local i = 0; i < len; i++){
				if(::hdmdTankVars.tankList[i][0] == params.si){
					::hdmdTankVars.tankList[i][4] = nearSurv;
					::hdmdTankVars.tankList[i][5] = siSeq;
					break;
				}
			}
		}
	}

	function SI_control_tank_rock_adjust(params){
		if(params.si == null || !params.si.IsValid())return;
		local rock = null;	local find = false;
		while (rock = Entities.FindByClassname(rock, "tank_rock")){
			if(rock.IsValid() && NetProps.GetPropEntityArray( rock, "m_hThrower", 0 ) == params.si){
				::manacatAddTimer(0.0, false, ::hdmdTankFunc.SI_control_tank_rock_adjust_orbit, {rock = rock, si = params.si, siOrigin = params.si.GetOrigin()});
				return;
			}
		}

		if(!find){
			::manacatAddTimer(0.0, false, ::hdmdTankFunc.SI_control_tank_rock_adjust, params);
		}
	}

	function SI_control_tank_rock_adjust_orbit(params){
		if(params.rock == null || !params.rock.IsValid())return;
		local rockOrigin = params.rock.GetOrigin();
		if(rockOrigin.x != params.siOrigin.x || rockOrigin.y != params.siOrigin.y || rockOrigin.z != params.siOrigin.z){
			local seq = 0;
			local targetSurv = null;
			local len = ::hdmdTankVars.tankList.len();
			for(local i = 0; i < len; i++){
				if(::hdmdTankVars.tankList[i][0] == params.si){
					targetSurv = ::hdmdTankVars.tankList[i][4];
					seq = ::hdmdTankVars.tankList[i][5];
					break;
				}
			}
			if(targetSurv == null || !targetSurv.IsValid())return;
			
			if(seq == 50 || ::hdmdState.lv >= 6 || RandomInt(1,2) != 1){//밑돌이거나 50%의 확률, 혹은 6렙 이상부터는 100% 꺾돌
				local rockDist = (params.si.EyePosition() - targetSurv.GetOrigin()).Length();
				local targetPos = targetSurv.EyePosition()+Vector(0,0,rockDist/6.2);
				if(seq == 50)targetPos += Vector(0,0,rockDist/55);//밑돌은 좀 더 높게
				local prediction = targetSurv.GetVelocity();	prediction.z = 0;	prediction = prediction.Scale(0.4);
				targetPos += prediction;
				local flag = NetProps.GetPropInt(targetSurv,"m_fFlags");
				local isOnGround = flag == ( flag | 1 );
				if(isOnGround)targetPos.z -= 30;
				local tankViewAngle = ::hdmdSIFunc.SI_control_eye({si = params.rock, tgVector = targetPos});
				tankViewAngle.z += rockDist/500;
				local newForce = tankViewAngle.Forward().Scale(800);
				//DebugDrawLine(rockOrigin, rockOrigin+newForce, 0, 255, 0, true, 5);
				
				params.rock.SetVelocity(Vector(0, 0, 0));
				params.rock.ApplyAbsVelocityImpulse(newForce);
			}
			return;
		}else{
			::manacatAddTimer(0.0, false, ::hdmdTankFunc.SI_control_tank_rock_adjust_orbit, params);
		}
	}

	function OnGameEvent_tank_killed(params){
		local tank = GetPlayerFromUserID(params.userid);
		local len = ::hdmdTankVars.tankList.len();
		for(local i = 0; i < len; i++){
			if(::hdmdTankVars.tankList[i][0] == tank){
				::hdmdTankVars.tankList.remove(i);
				break;
			}
		}
		local tank = null;
		while (tank = Entities.FindByClassname(tank, "player")){
			if(!::hdmdState.finale && tank.IsValid() && tank.GetZombieType() == 8 && !tank.IsDead() && !tank.IsDying() && !tank.IsIncapacitated()){
				local tankHealth = (NetProps.GetPropInt( tank, "m_iMaxHealth" )/10)*8;
				NetProps.SetPropInt( tank, "m_iMaxHealth", tankHealth );
				NetProps.SetPropInt( tank, "m_iHealth", tankHealth );
			}
		}
		if(::hdmdState.gamemode == 1){
			local player = null;
			while (player = Entities.FindByClassname(player, "player")){
				::hdmdSurvFunc.hp_bonus(player, 25, 70);
			}
		}
	}

	function SetTankThrowTime(tank){
		if(tank == null || !tank.IsValid())return;
		local len = ::hdmdTankVars.tankList.len();
		for(local i = 0; i < len; i++){
			if(::hdmdTankVars.tankList[i][0] == tank){
				::hdmdTankVars.tankList[i][2] = Time();
				::hdmdTankVars.tankList[i][3] = Time()+Convars.GetFloat("z_tank_throw_interval");
				return;
			}
		}
	}

	function GetTankThrowTime(tank){
		if(tank == null || !tank.IsValid())return [-100, -100];
		local len = ::hdmdTankVars.tankList.len();
		for(local i = 0; i < len; i++){
			if(::hdmdTankVars.tankList[i][0] == tank){
				if(::hdmdTankVars.tankList[i][2] == null)return [-100, -100];
				return [::hdmdTankVars.tankList[i][2], ::hdmdTankVars.tankList[i][3]];
			}
		}
	}

/*	function OnGameEvent_revive_begin(params){
		if(Director.IsTankInPlay()){
			local player = GetPlayerFromUserID(params.userid);
			::manacatAddTimer(1.5, false, ::hdmdTankFunc.SI_control_tank_check_reviver, {reviver = player});
			::hdmdTankVars.reviverList.append(player);
		}
	}*/

	function OnGameEvent_revive_success(params){
		local player = GetPlayerFromUserID(params.subject);
		local playerOrigin = player.GetOrigin();
		local tank = null;	local tgTank = null;	local tgDist = 99999;
		while (tank = Entities.FindByClassname(tank, "player")){
			if(tank.IsValid() && tank.GetZombieType() == 8 && !tank.IsDead() && !tank.IsDying() && !tank.IsIncapacitated()){
				local dist = (playerOrigin - tank.GetOrigin()).Length();
				if(dist < tgDist){
					tgDist = dist;	tgTank = tank;
				}
			}
		}
		if(tgTank != null && tgDist < 1200){
			::hdmdTankFunc.targetFix_revive({repeat = 10, tank = tgTank, target = player})
		}
	}

	function targetFix_revive(params){
		if(params.tank == null || !params.tank.IsValid() || params.tank.IsDead() || params.tank.IsDying() || params.tank.IsIncapacitated())return;
		if(params.repeat > 0){
			params.repeat--;
			::manacatAddTimer(0.1, false, ::hdmdTankFunc.targetFix_revive, params);
			if(params.target.GetHealth() + params.target.GetHealthBuffer() < 40){
				CommandABot( { cmd = 0, target = params.target, bot = params.tank } );
			}
		}
		return;
	}

	/*function OnGameEvent_revive_end(params){
		local player = GetPlayerFromUserID(params.userid);
		::hdmdTankFunc.reviveList_remove(player);
	}

	function reviveList_remove(player){
		local len = ::hdmdTankVars.reviverList.len();
		for(local i = 0; i < len; i++){
			if(::hdmdTankVars.reviverList[i] == player || ::hdmdTankVars.reviverList[i] == null || !::hdmdTankVars.reviverList[i].IsValid()){
				::hdmdTankVars.reviverList.remove(i);	len--;
			}
		}
	}

	function SI_control_tank_check_reviver(params){
		if(Director.IsTankInPlay() && params.reviver != null && params.reviver.IsValid() && !params.reviver.IsDead() && !params.reviver.IsDying()){
			local len = ::hdmdTankVars.reviverList.len();
			for(local i = 0; i < len; i++){
				if(::hdmdTankVars.reviverList[i] == params.reviver){
					local tgVector = params.reviver.GetOrigin();
					local tank = null;	local tgtank = null;	local tgdist = 99999;
					while (tank = Entities.FindByClassname(tank, "player")){
						if(tank.IsValid() && tank.GetZombieType() == 8 && !tank.IsDead() && !tank.IsDying() && !tank.IsIncapacitated()){
							local dist = (tgVector - tank.GetOrigin()).Length();
							if(dist < tgdist){
								tgdist = dist;	tgtank = tank;
							}
						}
					}
					if(tgtank != null && tgdist < 700){
						printl(tgdist + "거리에서 소생중인 생존자 감지");
						local seq = NetProps.GetPropIntArray( params.reviver, "m_nSequence", 0);
						printl(params.reviver.GetSequenceActivityName(params.reviver.GetSequence()));
						::manacatAddTimer(0.1, false, ::hdmdTankFunc.SI_control_tank_chase_reviver, {tank = tgtank, reviver = params.reviver, sequence = seq});
					}
					return;
				}
			}
		}
	}

	function SI_control_tank_chase_reviver(params){
		if(Director.IsTankInPlay() && params.reviver != null && params.reviver.IsValid() && !params.reviver.IsDead() && !params.reviver.IsDying()
		 && params.tank != null && params.tank.IsValid() && !params.tank.IsDead() && !params.tank.IsDying() && !params.tank.IsIncapacitated()){
			local seq = NetProps.GetPropIntArray( params.reviver, "m_nSequence", 0);
			if(seq == params.sequence){
				printl("소생중 추격");
				CommandABot( { cmd = 0, target = params.reviver, bot = params.tank } );
				::manacatAddTimer(0.1, false, ::hdmdTankFunc.SI_control_tank_chase_reviver, params);
			}
		}
	}*/

	function door_pound_sound(params){
		local doormodel = params.door.GetModelName();		local poundsound = "";
		if(doormodel == "models/props_doors/checkpoint_door_02.mdl" || doormodel == "models/props_doors/checkpoint_door_-02.mdl"){
			poundsound = "Breakable.MatMetal";
		}else if(doormodel == "models/lighthouse/checkpoint_door_lighthouse02.mdl"){
			poundsound = "WoodenDoor.Break";
		}
		EmitAmbientSoundOn("HulkZombie.Punch", 1.0, 350, 100, params.door);
		params.door.PrecacheScriptSound(poundsound);
		EmitAmbientSoundOn(poundsound, 1.0, 350, 100, params.door);
	}

	function doorOpen(params){
		::hdmdTankFunc.door_pound_sound({door = params.door});
		::hdmdTankVars.door_pound = 0;
		DoEntFire("!self", "Open", "", 0.1, null, params.door);
		local doorOrigin = params.door.GetOrigin();
		
		::manacatAddTimer(0.1, false, ::hdmdTankFunc.tank_punch_knockback_door, { door = params.door });
		::manacatAddTimer(3.0, false, ::hdmdTankFunc.doorReset, { door = params.door, open_f = params.open_f, open_b = params.open_b });
	}

	function doorOpenFail(params){//탱크가 문을 두드려도 열리지 않으면 탱크를 문 앞으로 워프
		if(params.door == null || !params.door.IsValid() || params.opener == null || !params.opener.IsValid())return;
		local currentAngle = params.door.GetAngles()
		if(currentAngle.x == params.angle.x && currentAngle.y == params.angle.y && currentAngle.z == params.angle.z){
			local openerOrigin = params.opener.GetOrigin();
			local doorOrigin = params.door.GetOrigin();
			local doorang = params.door.GetAngles();	local fwd = doorang.Forward();

			local product = (openerOrigin.x - doorOrigin.x)*fwd.x
							+ (openerOrigin.y - doorOrigin.y)*fwd.y
							+ (openerOrigin.z - doorOrigin.z)*fwd.z;
			
			local warpOrigin = doorOrigin + currentAngle.Left().Scale(-27);
			warpOrigin.z = openerOrigin.z;

			if(product > 0.0)	params.opener.SetOrigin(warpOrigin + params.angle.Forward().Scale(-30));
			else				params.opener.SetOrigin(warpOrigin + params.angle.Forward().Scale(30));
		}
	}

	function tank_punch_knockback_door(params){
		if(params.door == null || !params.door.IsValid())return;
		local doorOrigin = params.door.GetOrigin() + params.door.GetAngles().Left().Scale(-25) + Vector(0,0,-25);
	//	printl(doorOrigin);
		for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
			local player = ::hdmdSurvVars.playerList[i][1];
			if(!player.IsValid())continue;
			local dist = (player.GetOrigin() - doorOrigin).Length();
			if(dist < 90){
				player.Stagger(doorOrigin);
			}
		}
	}

	function doorReset(params){
		if(params.door == null || !params.door.IsValid())return;
		params.door.__KeyValueFromString("opendir", "0");
		params.door.__KeyValueFromString("speed", "200");
		params.door.__KeyValueFromString("spawnflags", "8192");
		NetProps.SetPropFloat( params.door, "m_flDistance", 90.0);
		NetProps.SetPropVector( params.door, "m_angRotationOpenForward", params.open_f);
		NetProps.SetPropVector( params.door, "m_angRotationOpenBack", params.open_b);
	}

	function door_shake(params){//문이 흔들리는 효과
		if(!("repeat" in params)){
			params.repeat <- 0;
			params.oriF <- 0.4-(RandomInt(0,1)*0.8);
			params.oriL <- 0.45-(RandomInt(0,1)*0.9);
			params.angY <- 2-(RandomInt(0,1)*4);
			params.angZ <- 0.5-(RandomInt(0,1)*1.0);
		}else{
			params.repeat++;
			local n = ((6.0-params.repeat)/6.0);
			if(params.repeat == 1 || params.repeat == 3 || params.repeat == 5){
				params.door.SetOrigin(params.origin+params.door.GetAngles().Forward().Scale(params.oriF*n)+params.door.GetAngles().Left().Scale(-1*params.oriL*n));
				params.door.SetAngles(params.angles+QAngle(0,params.angY*n,-1*params.angZ*n));
			}else if(params.repeat == 2 || params.repeat == 4 || params.repeat == 6){
				params.door.SetOrigin(params.origin+params.door.GetAngles().Forward().Scale(-1*params.oriF*n)+params.door.GetAngles().Left().Scale(params.oriL*n));
				params.door.SetAngles(params.angles+QAngle(0,-1*params.angY*n,params.angZ*n));
			}else{
				params.door.SetOrigin(params.origin);
				params.door.SetAngles(params.angles);
				params.door.__KeyValueFromString("spawnflags", "8192");
				return;
			}
		}
		::manacatAddTimer(0.02, false, ::hdmdTankFunc.door_shake, params);
	}

	function OnGameEvent_weapon_fire(params){
		if(params.weapon == "tank_claw"){
			local tank = GetPlayerFromUserID(params.userid);
			local tankOrigin = tank.GetOrigin();
			local front = tank.EyePosition() + tank.EyeAngles().Forward().Scale(25);
			local back = tankOrigin + tank.EyeAngles().Forward().Scale(-40);
			local normdoor = Entities.FindByClassnameNearest("prop_door_rotating", front, 45.0);
			if(normdoor != null && NetProps.GetPropInt( normdoor, "m_eDoorState" ) == 0){
				if(::hdmdTankVars.door_pound_time <= Time()){
					::hdmdTankVars.door_pound_time = Time()+1;
					local doorang = normdoor.GetAngles();	local fwd = doorang.Forward();
					local doorOrigin = normdoor.GetOrigin();
					local product = (tankOrigin.x - doorOrigin.x)*fwd.x
									+ (tankOrigin.y - doorOrigin.y)*fwd.y
									+ (tankOrigin.z - doorOrigin.z)*fwd.z;
					local dir = "0";
					if(product > 0.0)	dir = "2";
					else				dir = "1";

					::manacatAddTimer(1.0, false, ::hdmdTankFunc.doorOpenFail, { door = normdoor, angle = doorang, tank = tank, dir = dir });
				}
			}
			local chkpdoor = Entities.FindByClassnameNearest("prop_door_rotating_checkpoint", front, 45.0);
			if(chkpdoor != null && NetProps.GetPropInt( chkpdoor, "m_eDoorState" ) == 0){
				::hdmdTankFunc.door_open_try({chkpdoor = chkpdoor, back = back, openerPos = tankOrigin, opener = tank, tank = true});
				return;	//문을 두들기면 펀치 유효성을 체크하지 않는다 (헛방 후퇴하지 않는다)
			}

			local siSeq = NetProps.GetPropIntArray( tank, "m_nSequence", 0);
			if(siSeq < 16 || 21 < siSeq){
				local len = ::hdmdTankVars.punch.len();
				for(local i = 0; i < len; i++){
					if(::hdmdTankVars.punch[i] == tank)return;
				}
				::hdmdTankVars.punch.append(tank);
				::manacatAddTimer(0.6, false, ::hdmdTankFunc.punchCheck, { si = tank });
				::manacatAddTimer(1.0, false, ::hdmdTankFunc.punchRemove, { si = tank });

				local speed = NetProps.GetPropFloatArray( tank, "m_flGroundSpeed", 0);
				if(speed > 150){
					local nearSurv = ::hdmdSIFunc.findNearSurv({from = tank, visible = true, noincap = true});
					local nearDist = nearSurv[1];// nearSurv = nearSurv[0];
					if(nearDist < 160){
						local fv = tank.GetForwardVector();
						local fx = fv.x*(speed+5);		local fy = fv.y*(speed+5);
						local pushVec = Vector(fx,fy,255);

						tank.SetVelocity(pushVec);
					}
				}
			}

			::manacatAddTimer(0.4, false, ::hdmdTankFunc.punchObject, { tank = tank });
		}
	}

	function door_open_try(params){
		local chkpdoor = params.chkpdoor;
		local back = params.back;
		local openerPos = params.openerPos;
		if(::hdmdTankVars.door_pound_time <= Time()){//m_eDoorState = 0:닫힘 1:열리는중 2:열림 3:닫히는중
			::hdmdTankVars.door_pound_time = Time()+1;
			chkpdoor.__KeyValueFromString("spawnflags", "32768");
			if(params.tank){
				if(::hdmdState.lv >= 7){
					::hdmdTankVars.door_pound+=4;
				}else if(::hdmdState.lv == 6){
					::hdmdTankVars.door_pound+=2;
				}else{
					::hdmdTankVars.door_pound++;
				}
			}else{
				if(::hdmdState.lv >= 7){
					::hdmdTankVars.door_pound+=6;
				}else if(::hdmdState.lv == 6){
					::hdmdTankVars.door_pound+=3;
				}else{
					::hdmdTankVars.door_pound+=2;
				}
			}
			if(::hdmdTankVars.door_pound < 5 && !NavMesh.GetNearestNavArea(back, 100.0, true, true).HasSpawnAttributes(2048)){
				local delay = 0.3;
				if(!params.tank)delay = 0.0;
				::manacatAddTimer(delay, false, ::hdmdTankFunc.door_shake, {door = chkpdoor, origin = chkpdoor.GetOrigin(), angles = chkpdoor.GetAngles()});
				::manacatAddTimer(delay+0.2, false, ::hdmdTankFunc.door_pound_sound, { door = chkpdoor });

				if(params.tank && (::hdmdTankVars.door_pound_hint == null || !::hdmdTankVars.door_pound_hint.IsValid())){
					::hdmdTankFunc.hintView({chkpdoor = chkpdoor, tank = true});
				}else if(!params.tank && (::hdmdTankVars.door_pound_hint_witch == null || !::hdmdTankVars.door_pound_hint_witch.IsValid())){
					::hdmdTankFunc.hintView({chkpdoor = chkpdoor, tank = false});
				}
			}else{
				if(::hdmdTankVars.door_pound_hint != null && ::hdmdTankVars.door_pound_hint.IsValid())DoEntFire("!self", "Kill", "", 0.0, null, ::hdmdTankVars.door_pound_hint);
				if(::hdmdTankVars.door_pound_hint_witch != null && ::hdmdTankVars.door_pound_hint_witch.IsValid())DoEntFire("!self", "Kill", "", 0.0, null, ::hdmdTankVars.door_pound_hint_witch);
				local doorang = chkpdoor.GetAngles();	local fwd = doorang.Forward();
				local doorOrigin = chkpdoor.GetOrigin();
				local product = (openerPos.x - doorOrigin.x)*fwd.x
								+ (openerPos.y - doorOrigin.y)*fwd.y
								+ (openerPos.z - doorOrigin.z)*fwd.z;
				local dir = "0";
				chkpdoor.__KeyValueFromString("speed", "800");
				local open_f = NetProps.GetPropVector( chkpdoor, "m_angRotationOpenForward" );
				local open_b = NetProps.GetPropVector( chkpdoor, "m_angRotationOpenBack" );
				
				if(product > 0.0)	dir = "2";
				else				dir = "1";
				chkpdoor.__KeyValueFromString("opendir", dir);

				::manacatAddTimer(0.3, false, ::hdmdTankFunc.doorOpen, { door = chkpdoor, open_f = open_f, open_b = open_b });
				open_f += Vector(0,-9,0);
				open_b += Vector(0,9,0);
				NetProps.SetPropVector( chkpdoor, "m_angRotationOpenForward", open_f);
				NetProps.SetPropVector( chkpdoor, "m_angRotationOpenBack", open_b);
				::manacatAddTimer(1.0, false, ::hdmdTankFunc.doorOpenFail, { door = chkpdoor, angle = doorang, opener = params.opener, dir = dir });
			}
		}
	}

	function hintView(params){
		local chkpdoor = params.chkpdoor;
		local tank = params.tank;
		local tgname =  "hdmd_hint_tank_door";
		if(!tank)tgname = "hdmd_hint_witch_door";
		local hintpoint = {
			classname = "info_target_instructor_hint",
			targetname = tgname,
			origin = chkpdoor.GetOrigin() + chkpdoor.GetAngles().Left().Scale(-26)// + Vector(0,0,-25)
		};

	//	DebugDrawBox(chkpdoor.GetOrigin() + chkpdoor.GetAngles().Left().Scale(-26), Vector(-3.0,-3.0,-3.0), Vector(3.0,3.0,3.0), 255, 0, 0, 64, 5.0);

		local doorname = "";
		local msg = [];
		local hint_pos = "0";
		if(tank){
			::hdmdTankVars.door_pound_hint = g_ModeScript.CreateSingleSimpleEntityFromTable(hintpoint);
			doorname = ::hdmdTankVars.door_pound_hint.GetName();
			msg = ["The tank is hitting the door! Be prepared for invasion.", "탱크가 문을 두드리고 있습니다! 침입에 대비하십시오.", "タンクがドアを叩いています！ 侵入に備えてください。", "¡El Tank está golpeando la puerta! Prepárense para invadir."];
		}else{
			::hdmdTankVars.door_pound_hint_witch = g_ModeScript.CreateSingleSimpleEntityFromTable(hintpoint);
			doorname = ::hdmdTankVars.door_pound_hint_witch.GetName();
			msg = ["The witch is hitting the door! Be prepared for invasion.", "윗치가 문을 두드리고 있습니다! 침입에 대비하십시오.", "ウィッチがドアを叩いています！ 侵入に備えてください。", "¡El Witch está golpeando la puerta! Prepárense para invadir."];
			hint_pos = "1";
		}

		local playerLangList = [[],[],[],[]];
		local hintList = [null,null,null,null];
		local listener = null;
		while (listener = Entities.FindByClassname(listener, "player")){
			if(listener.IsValid() && !IsPlayerABot(listener)){
				local lang = 0;
				switch(Convars.GetClientConvarValue("cl_language", listener.GetEntityIndex())){
					case "korean":case "koreana":	lang = 1;	break;
					case "japanese":				lang = 2;	break;
					case "spanish":					lang = 3;	break;
					default:						lang = 0;	break;
				}
				playerLangList[lang].append(listener);
			}
		}
	//	local door = Entities.FindByModel(null, "models/props_doors/checkpoint_door_02.mdl");
	//	printl(door.GetName());
		local langlen = playerLangList.len();
		for(local i = 0; i < langlen; i++){
			local playerlen = playerLangList[i].len();
			if(playerlen > 0){
				local hinttbl ={
					classname = "env_instructor_hint",
					hint_allow_nodraw_target = "1",
					hint_alphaoption = "3",
					hint_caption = msg[i],
					hint_color = "255 255 255",
					hint_forcecaption = "1",//0이면 벽 통과 안함, 1이면 벽 통과해서 표시
					hint_icon_offscreen = "icon_alert_red",
					hint_icon_onscreen = "icon_door",
					hint_instance_type = "2",
					hint_pulseoption = "1",
					hint_static = hint_pos,//0이면 타겟에, 1이면 화면고정
					hint_target = doorname,
					targetname = "hdmd_hint",
				};
				hintList[i] = g_ModeScript.CreateSingleSimpleEntityFromTable(hinttbl);
				for(local j = 0; j < playerlen; j++){
					local nav = NavMesh.GetNearestNavArea(playerLangList[i][j].GetOrigin(), 100.0, true, true);
					if(nav != null && nav.HasSpawnAttributes(2048)){
						DoEntFire("!self", "ShowHint", "", 0.0, playerLangList[i][j], hintList[i]);
					}
				}
				DoEntFire("!self", "Kill", "", 10.0, null, hintList[i]);
			}
		}
		if(tank)DoEntFire("!self", "Kill", "", 10.0, null, ::hdmdTankVars.door_pound_hint);
		else	DoEntFire("!self", "Kill", "", 10.0, null, ::hdmdTankVars.door_pound_hint_witch);
	}

	function punchObject(params){
		local tank = params.tank;	local tankOrigin = tank.GetOrigin();
		::hdmdTankFunc.kkangListManage();	local frontEnt = false;
		local fwd = tank.GetAngles().Forward();
		local kkanglen = ::hdmdTankVars.kkangList.len();	local kkangListFB = [];//true면 앞, false면 뒤
		for(local i = 0; i < kkanglen; i++){
			local entOrigin = ::hdmdTankVars.kkangList[i].GetOrigin();	entOrigin.z += 20;
			if(::hdmdTankVars.kkangList[i] != null && ::hdmdTankVars.kkangList[i].IsValid() && (entOrigin-tankOrigin).Length() < 180){
				if(::hdmdSIFunc.CanSee(tank, entOrigin, 131083)){
					local o1 = tankOrigin;
					local o2 = entOrigin;
					local product = (o1["x"] - o2["x"]) * fwd["x"] + (o1["y"] - o2["y"]) * fwd["y"] + (o1["z"] - o2["z"]) * fwd["z"];
					if (product > 0.0)		{//printl("뒤");
						kkangListFB.append([::hdmdTankVars.kkangList[i],false]);
					}else					{//printl("앞");
						kkangListFB.append([::hdmdTankVars.kkangList[i],true]);
						frontEnt = true;
					}
				}
			}
		}
		kkanglen = kkangListFB.len();
		for(local i = 0; i < kkanglen; i++){
			if(kkangListFB[i][1] == frontEnt){//앞에 있는 오브젝트가 있으면 앞에 있는 것들, 없으면 뒤에 있는 오브젝트들
				local ent = kkangListFB[i][0];
				ent.SetVelocity(Vector(0, 0, 0));
				if(ent != null && ent.IsValid()){
					local activity = tank.GetSequenceActivityName(tank.GetSequence());
					if(activity == "ACT_TANK_OVERHEAD_THROW"
					|| activity == "ACT_TERROR_CLIMB_36_FROM_STAND" || activity == "ACT_TERROR_CLIMB_38_FROM_STAND" || activity == "ACT_TERROR_CLIMB_50_FROM_STAND" || activity == "ACT_TERROR_CLIMB_70_FROM_STAND"
					|| activity == "ACT_TERROR_CLIMB_115_FROM_STAND" || activity == "ACT_TERROR_CLIMB_130_FROM_STAND" || activity == "ACT_TERROR_CLIMB_150_FROM_STAND" || activity == "ACT_TERROR_CLIMB_166_FROM_STAND")return;
					EmitAmbientSoundOn("HulkZombie.Punch", 1.0, 350, 100,params.tank);
				//	DoEntFire("!self", "break", "", 0.0, null, ent);
					ent.TakeDamage(100, 128, tank);
					local tgV = tank.EyePosition() + tank.EyeAngles().Forward().Scale(2000) + tank.GetVelocity().Scale(0.8);
					local fv = ::hdmdSIFunc.SI_control_eye({si = ent, tgVector = tgV}).Forward();//tank.GetForwardVector();
					local fx = fv.x*(1000);		local fy = fv.y*(1000);		local fz = fv.z*(1000);
					local pushVec = Vector(fx,fy,fz+100);

				//	ent.SetVelocity(pushVec);
					ent.ApplyAbsVelocityImpulse(pushVec);
					ent.ApplyLocalAngularVelocityImpulse(Vector(100+(RandomInt(0,1)*-200),100+(RandomInt(0,1)*-200),550+(RandomInt(0,1)*-1100)));
				}
				/*//탱크의 앞으로 끌어와서 치기
				if(ent != null && ent.IsValid() && (ent.GetOrigin()-tankOrigin).Length() < 180){
					local front = ::hdmdSIFunc.visionCheck(tank, ent.GetOrigin(), null, 30);
					if (!front){
					//	DoEntFire("!self", "break", "", 0.0, null, ent);
						ent.TakeDamage(100, 128, tank);
						local tgV = tank.EyePosition() + tank.EyeAngles().Forward().Scale(50) + tank.GetVelocity().Scale(0.8);
						printl(tgV);
						local fv = ::hdmdSIFunc.SI_control_eye({si = ent, tgVector = tgV}).Forward();//tank.GetForwardVector();
						printl("fv"+ fv + "  "+tank.GetForwardVector());
						local fx = fv.x*(245);		local fy = fv.y*(245);
						local pushVec = Vector(fx,fy,175);

					//	ent.SetVelocity(pushVec);
						ent.SetVelocity(Vector(0, 0, 0));
						ent.ApplyAbsVelocityImpulse(pushVec);
						ent.ApplyLocalAngularVelocityImpulse(Vector(250,0,0));
					}
				}
				*/
			}
		}
	}
	

	function punchCheck(params){
		local len = ::hdmdTankVars.punchList.len();
		local miss = true;
		for(local i = 0; i < len; i++){
			if(::hdmdTankVars.punchList[i][0] == params.si){
				::hdmdTankVars.punchList.remove(i);
				len--;
				miss = false;
			}
		}

		if(miss){
			::manacatAddTimer(0.1, false, ::hdmdTankFunc.punchRetreat, { si = params.si });
		}
	}

	function punchRetreat(params){
	//	printl(Time()+"  "+NetProps.GetPropFloatArray( params.si.GetActiveWeapon(), "m_flNextPrimaryAttack", 0));
		if(params.si == null || !params.si.IsValid())return;
		if(NetProps.GetPropFloatArray( params.si.GetActiveWeapon(), "m_flNextPrimaryAttack", 0)-0.9 < Time()){
			local len = ::hdmdTankVars.punchRetreat.len();
			for(local i = 0; i < len; i++){
				if(::hdmdTankVars.punchRetreat[i] == params.si){
					::hdmdTankVars.punchRetreat.remove(i);	len--;
				}
			}
			local nearSurv = ::hdmdSIFunc.findNearSurv({from = params.si, visible = true, noincap = true});
			local nearDist = nearSurv[1]; nearSurv = nearSurv[0];
			CommandABot( { cmd = 0, target = nearSurv, bot = params.si } );
			// ::printlang(" ",
			// 			"\x03<탱크> 후퇴종료 ",
			// 			" ",
			// 			" ",
			// 			1);
			return;
		}
			// ::printlang(" ",
			// 			"\x03<탱크> 후퇴 ",
			// 			" ",
			// 			" ",
			// 			1);
		::manacatAddTimer(0.1, false, ::hdmdTankFunc.punchRetreat, params);

		for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
			if(!::hdmdSurvVars.playerList[i][1].IsValid() || ::hdmdSurvVars.playerList[i][1].IsDead() || ::hdmdSurvVars.playerList[i][1].IsDying()
			|| ::hdmdSurvVars.playerList[i][1].IsIncapacitated() || ::hdmdSurvVars.playerList[i][1].IsDominatedBySpecialInfected()
			|| ::hdmdSurvVars.playerList[i][1].GetActiveWeapon() == null)continue;
			local dist = (::hdmdSurvVars.playerList[i][1].GetOrigin() - params.si.GetOrigin()).Length();
		//	::printlang(" ",
		//				"\x03<탱크> 거리 "+dist,
		//				" ",
		//				" ",
		//				1);
			local playerWeapon = ::hdmdSurvVars.playerList[i][1].GetActiveWeapon().GetClassname();
			if(dist < 250 && (playerWeapon == "weapon_melee" || playerWeapon == "weapon_chainsaw")){
				local len = ::hdmdTankVars.punchRetreat.len();
				local chk = false;
				for(local j = 0; j < len; j++){
					if(::hdmdTankVars.punchRetreat[j] == params.si){
						chk = true;	break;
					}
				}
				if(!chk){
					::hdmdTankVars.punchRetreat.append(params.si);
					local vecVision = ::hdmdSurvVars.playerList[i][1].EyePosition();
				//	local siVision = params.si.EyePosition();
				//	local vecTargetNorm = Vector(vecVision.x, vecVision.y, vecVision.z);
				//	vecTargetNorm.x -= siVision.x;
				//	vecTargetNorm.y -= siVision.y;
				//	vecTargetNorm.z -= siVision.z;
				//	vecTargetNorm.x = vecTargetNorm.x/vecTargetNorm.Norm();
				//	vecTargetNorm.y = vecTargetNorm.y/vecTargetNorm.Norm();
				//	vecTargetNorm.z = vecTargetNorm.z/vecTargetNorm.Norm();

				//	if(180/PI*acos(params.si.EyeAngles().Forward().Dot(vecTargetNorm)) < 135){//탱크가 생존자를 보는 범위
					//	local m_trace = { start = vecVision, end = siVision, ignore = ::hdmdSurvVars.playerList[i][1], mask = 33579137 };
					//	TraceLine(m_trace);
					//	if("enthit" in m_trace && m_trace.enthit == params.si){
							local targetPos = vecVision + ::hdmdSurvVars.playerList[i][1].EyeAngles().Forward().Scale(400);
							targetPos.z = params.si.GetOrigin().z+40;
							local tgnav = NavMesh.GetNearestNavArea(targetPos, 150.0, true, true);
							if(tgnav != null){
								tgnav = tgnav.GetCenter();
								CommandABot( { cmd = 1, pos = tgnav, bot = params.si } );
							}
					//	}
				//	}
				}
			}
		}
	}

	function punchRemove(params){
		if(params.si != null && params.si.IsValid()){
			if(NetProps.GetPropFloatArray( params.si.GetActiveWeapon(), "m_flNextPrimaryAttack", 0)-0.25 < Time()){
				local len = ::hdmdTankVars.punch.len();
				for(local i = 0; i < len; i++){
					if(::hdmdTankVars.punch[i] == params.si){
					//	printl("펀치 제거");
						::hdmdTankVars.punch.remove(i);
						len--;
					}
				}
				return;
			}
			::manacatAddTimer(0.1, false, ::hdmdTankFunc.punchRemove, params);
		}
	}

	function OnGameEvent_player_hurt(params){
		local victim = GetPlayerFromUserID(params.userid);
		local attacker = GetPlayerFromUserID(params.attacker);
		if("GetZombieType" in victim && "weapon" in params){
			if(victim.GetZombieType()==8){
				if(params.type != 131072 && ("GetZombieType" in attacker && attacker.GetZombieType() != 8) && ::hdmdTankVars.dmg_done < 50000)
					::hdmdTankVars.dmg_done += params.dmg_health;//사망지속딜 제외
				if(::hdmdTankVars.tanks >= 2 && !::hdmdState.finale && ::hdmdTankVars.dmg_done > ::hdmdTankVars.dmg_2tank && ::hdmdTankVars.dmg_done < 50000){
					victim.TakeDamage(victim.GetHealth(), 129, victim);
					::hdmdTankVars.dmg_done = 50000;
				}
				
				if(params.weapon == "tank_rock"){
					victim.SetHealth(victim.GetHealth()+params.dmg_health);
					local rock = null;
					while (rock = Entities.FindByClassname(rock, "tank_rock")){
						if(rock.IsValid()){
							local pos = rock.GetOrigin();
							local breaker = SpawnEntityFromTable("prop_dynamic",
							{
								model = "models/props/de_nuke/crate_extralarge.mdl"
								origin = pos
								angles = Vector(0, 0, 0)
								solid = "6"
								rendermode = "1"
								renderamt = "0"
							});
							DoEntFire("!self", "Kill", "", 0.002, null, breaker);
						}
					}
				}else if(params.weapon == "melee" || params.weapon == "chainsaw"){
					if(NetProps.GetPropFloatArray( victim.GetActiveWeapon(), "m_flNextPrimaryAttack", 0) < Time())return;
					local attacker = GetPlayerFromUserID(params.attacker);
					CommandABot( { cmd = 0, target = attacker, bot = victim } );
					local viewAngle = ::hdmdSIFunc.SI_control_eye({si = victim, tgVector = attacker.EyePosition()});
					victim.SnapEyeAngles(viewAngle);
				}
			}else if(victim.GetZombieType()==9 && params.weapon == "tank_claw"){
				local tank = GetPlayerFromUserID(params.attacker);
				::hdmdTankVars.punchList.append([tank, victim]);
				return;
			}
		}
	}

	function tank_ladder_push(tank){
		if(!tank.IsValid() || tank.IsDead() || tank.IsDying() || tank.IsIncapacitated())return;

		for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
			local player = ::hdmdSurvVars.playerList[i][1];
			if(!player.IsValid() || player.IsDead() || player.IsDying()
			|| player.IsIncapacitated() || player.IsDominatedBySpecialInfected()
			|| player.GetActiveWeapon() == null)continue;
			local dist = (player.GetOrigin() - tank.GetOrigin()).Length();
			if(dist < 65){
				local impulseVec = ::hdmdSIFunc.SI_control_eye({si = player, tgVector = tank.GetOrigin()});
				impulseVec = impulseVec.Forward().Scale(-320);
				impulseVec.z = 100;

				player.SetVelocity(Vector(0, 0, 0));
				player.ApplyAbsVelocityImpulse(impulseVec);
			}
		}
	}

	function tank_punch_knockback(tank, player, punchtype = 0){
		local invTable = {};
		GetInvTable( player, invTable );
		if ( "slot0" in invTable )
			NetProps.SetPropEntity( invTable["slot0"], "m_hOwner", null );
		if ( "slot1" in invTable )
			NetProps.SetPropEntity( invTable["slot1"], "m_hOwner", null );
		if ( "slot2" in invTable )
			NetProps.SetPropEntity( invTable["slot2"], "m_hOwner", null );
		if ( "slot3" in invTable )
			NetProps.SetPropEntity( invTable["slot3"], "m_hOwner", null );
		if ( "slot4" in invTable )
			NetProps.SetPropEntity( invTable["slot4"], "m_hOwner", null );
		if ( "slot5" in invTable )
			player.DropItem(invTable["slot5"].GetClassname());

		local viewmodel;	local weaponModel = 0;
		while (viewmodel = Entities.FindByClassname(viewmodel, "predicted_viewmodel")){
			if(viewmodel.IsValid() && NetProps.GetPropEntityArray( viewmodel, "m_hOwner", 0 ) == player){
				weaponModel = NetProps.GetPropIntArray( viewmodel, "m_nModelIndex", 0 );
				NetProps.SetPropIntArray( viewmodel, "m_hWeapon", 0, 0 );
				NetProps.SetPropIntArray( viewmodel, "m_nModelIndex", 0, 0 );
			}
		}

		local game_ui = SpawnEntityFromTable("game_ui",
		{
			FieldOfView = "-1.0"
			spawnflags = "32"
		});
		DoEntFire("!self", "Activate", "", 0.0, player, game_ui);
		DoEntFire("!self", "PlayerOff", "", 0.0, player, game_ui);
		
		::manacatAddTimer(0.2, false, ::hdmdTankFunc.tank_punch_knockback_stop, { tgp = player, tgui = game_ui });

		local impulseVec = ::hdmdSIFunc.SI_control_eye({si = player, tgVector = tank.GetOrigin()});
		if(punchtype == 0){//쓰러진 사람 주변 스플
			impulseVec = impulseVec.Forward().Scale(-520);
			impulseVec.z = 260;
		}else{//통상펀치 주변 스플
			impulseVec = impulseVec.Forward().Scale(-850);
			impulseVec.z = 260;
		}

		player.SetVelocity(Vector(0, 0, 0));
		player.ApplyAbsVelocityImpulse(impulseVec);
	}

	function tank_punch_knockback_stop(params){
		local flag = NetProps.GetPropInt(params.tgp,"m_fFlags");
		local isOnGround = flag == ( flag | 1 );

		if(isOnGround){
			if("ground" in params){
				DoEntFire("!self", "Deactivate", "", 0.0, params.tgp, params.tgui);
				DoEntFire("!self", "Kill", "", 0.0, null, params.tgui);

				local game_ui = SpawnEntityFromTable("game_ui",
				{
					FieldOfView = "-1.0"
					spawnflags = "96"
				});
				DoEntFire("!self", "Activate", "", 0.0, params.tgp, game_ui);
				DoEntFire("!self", "PlayerOff", "", 0.0, params.tgp, game_ui);
				DoEntFire("!self", "Deactivate", "", 0.0, params.tgp, game_ui);
				DoEntFire("!self", "Kill", "", 0.0, null, game_ui);
				local invTable = {};
				GetInvTable( params.tgp, invTable );
				if ( "slot0" in invTable )
					NetProps.SetPropEntity( invTable["slot0"], "m_hOwner", params.tgp );
				if ( "slot1" in invTable )
					NetProps.SetPropEntity( invTable["slot1"], "m_hOwner", params.tgp );
				if ( "slot2" in invTable )
					NetProps.SetPropEntity( invTable["slot2"], "m_hOwner", params.tgp );
				if ( "slot3" in invTable )
					NetProps.SetPropEntity( invTable["slot3"], "m_hOwner", params.tgp );
				if ( "slot4" in invTable )
					NetProps.SetPropEntity( invTable["slot4"], "m_hOwner", params.tgp );
			}else{
				EmitSoundOnClient("Player.JumpLand", params.tgp)
				params.ground <- true;
				::manacatAddTimer(1.0, false, ::hdmdTankFunc.tank_punch_knockback_stop, params);
			}
		}else{
			::manacatAddTimer(0.1, false, ::hdmdTankFunc.tank_punch_knockback_stop, params);
		}
	}
	/*
	function OnGameEvent_hegrenade_detonate(params){//화염병
		::manacatAddTimer(1.0, false, ::hdmdTankFunc.findDamageNav, {type = "inferno"});
	}

	function OnGameEvent_scavenge_gas_can_destroyed(params){//기름통
		::manacatAddTimer(1.0, false, ::hdmdTankFunc.findDamageNav, {type = "inferno"});
	}

	function OnGameEvent_break_prop(params){//기름통&불꽃놀이
		local prop = Ent(params.entindex);
		local model = prop.GetModelName();
		if(model == "models/props_junk/gascan001a.mdl"){
			::manacatAddTimer(1.0, false, ::hdmdTankFunc.findDamageNav, {type = "inferno"});
			//local propOrigin = prop.GetOrigin();
			//DebugDrawBox(propOrigin, Vector(-12,-12,-12.0), Vector(12,12,12.0), 255, 0, 0, 64, 12.0);
		}else if(model == "models/props_junk/explosive_box001.mdl"){
			::manacatAddTimer(1.0, false, ::hdmdTankFunc.findDamageNav, {type = "fire_cracker_blast"});
		}
	}

	function findDamageNav(params){
		if(!("nav" in params)){
			printl("이거 검사중");
			local inferno = null;
			while (inferno = Entities.FindByClassname(inferno, params.type)){
				if(::hdmdTankVars.infernoList.find(inferno) == null){
					::hdmdTankVars.infernoList.append(inferno);
					local firePoint = NavMesh.GetNearestNavArea(inferno.GetOrigin(), 150, true, true);
					::manacatAddTimer(0.5, false, ::hdmdTankFunc.findDamageNav, { nav = firePoint });
					::manacatAddTimer(1.0, false, ::hdmdTankFunc.findDamageNav, { nav = firePoint });
					::manacatAddTimer(1.5, false, ::hdmdTankFunc.findDamageNav, { nav = firePoint });
					::manacatAddTimer(2.0, false, ::hdmdTankFunc.findDamageNav, { nav = firePoint });
					::manacatAddTimer(3.0, false, ::hdmdTankFunc.findDamageNav, { nav = firePoint });
					::manacatAddTimer(15.0, false, ::hdmdTankFunc.UnblockDamageNav, { });
				//	DebugDrawBox(inferno.GetOrigin(), Vector(-200.0,-200.0,-40.0), Vector(200.0,200.0,40.0), 255, 0, 0, 128, 8.0);
				}
			}
			return;
		}

		if(params.nav == null)return;
		local tgnav = params.nav;
		local spread = false;	local currentTime = Time();
		local firenav = ::hdmdTankVars.fireList.find(tgnav);
		if(firenav != null && ::hdmdTankVars.fireListTime[firenav] != currentTime){
			::hdmdTankVars.fireListTime[firenav] = currentTime;
			spread = true;//중복방지를 위해 검사했던 영역은 모아야 함
		}else if(!tgnav.HasAvoidanceObstacle(100.0) && !tgnav.IsBlocked(3, false) && ((!tgnav.IsDegenerate() && tgnav.IsDamaging()))){
			::hdmdTankVars.fireList.append(tgnav);
			::hdmdTankVars.fireListTime.append(currentTime);
			tgnav.MarkAsBlocked(3);
			DebugDrawBox(tgnav.GetCenter(), Vector((tgnav.GetSizeX()/2)*-1,(tgnav.GetSizeY()/2)*-1,-12.0), Vector((tgnav.GetSizeX()/2),(tgnav.GetSizeY()/2),12.0), 255, 0, 0, 64, 12.0);
			spread = true;
		}

		if(spread){
			local navTable = {};
			for(local i = 0; i < 4; i++){
				tgnav.GetAdjacentAreas(i,navTable);
				foreach(areaName, nav in navTable){
					if(nav != null)::hdmdTankFunc.findDamageNav({nav = nav});
				}
			}
		}
	}

	function UnblockDamageNav(params){
		local len = ::hdmdTankVars.infernoList.len();
		for(local i = 0; i < len; i++){
			if(::hdmdTankVars.infernoList[i] == null || !::hdmdTankVars.infernoList[i].IsValid()){
				::hdmdTankVars.infernoList.remove(i);	len--;
			}
		}

		len = ::hdmdTankVars.fireList.len();
		for(local i = len-1; i >= 0; i--){
			if(::hdmdTankVars.fireList[i].IsBlocked(3, false) && !::hdmdTankVars.fireList[i].IsDamaging()){
				local tgnav = ::hdmdTankVars.fireList[i];
				tgnav.UnblockArea();
				DebugDrawBox(tgnav.GetCenter(), Vector((tgnav.GetSizeX()/2)*-1,(tgnav.GetSizeY()/2)*-1,-12.0), Vector((tgnav.GetSizeX()/2),(tgnav.GetSizeY()/2),12.0), 0, 255, 0, 64, 3.0);
				::hdmdTankVars.fireList.remove(i);
				::hdmdTankVars.fireListTime.remove(i);
			}
		}
	}//*/

	function OnGameEvent_player_death(params){
		if("userid" in params){
			local player = GetPlayerFromUserID(params.userid);
			if("GetZombieType" in player && player.GetZombieType() == 8){
				::hdmdTankFunc.tank_count();

				if(::hdmdTankVars.tanks != 0)return;
				::hardmodeFunc.changeD({});

				if(::hdmdState.lv <= 2)return;
				if(RandomInt(1,3) == 1){
					::manacatAddTimer(9.0, false, ::ZSpawner, { ztype = 10, zsound = "mob" }); //z_spawn mob
				}else{
					::manacatAddTimer(9.0, false, ::hdmdSIFunc.SI_spawn, {capture=4});
				}
			}
		}
	}

	function tank_count(){
		local tank; local tanks = 0;
		while (tank = Entities.FindByClassname(tank, "player")){
			if(tank.IsValid() && "GetZombieType" in tank && tank.GetZombieType() == 8
			&& !tank.IsDead() && !tank.IsDying() && !tank.IsIncapacitated()){
				tanks++;
			}
		}
		if(tanks != ::hdmdTankVars.tanks)::hdmdTankVars.tanks = tanks;
	}

	function tank_pos(){
		local mapName = Director.GetMapName();
		::hdmdTankVars.tankflow1 = RandomInt(10, 90);

		if(::mp_gamemode != "versus" || (::hardmodeVars.sessionData["mapname"] != mapName && ::mp_gamemode == "versus")){//세이브
			switch (mapName){
				case "c1m1_hotel":
					::hdmdTankVars.tankflow1 = RandomInt(69, 74);
					::hdmdTankVars.tankflow2 = RandomInt(74, 79);
					::hdmdTankVars.tankflow3 = RandomInt(79, 85); break;
				case "c1m2_streets":
					::hdmdTankVars.tankflow1 = RandomInt(10, 35);
					::hdmdTankVars.tankflow2 = RandomInt(35, 55);
					::hdmdTankVars.tankflow3 = RandomInt(55, 77); break;
				case "c1m3_mall":
					::hdmdTankVars.tankflow1 = RandomInt(10, 30);
					::hdmdTankVars.tankflow2 = RandomInt(66, 78);
					::hdmdTankVars.tankflow2 = RandomInt(78, 88); break;
				case "c1m4_atrium":
					::hdmdTankVars.tankflow1 = RandomInt(102, 102); break;
				case "c2m1_highway":
					::hdmdTankVars.tankflow1 = RandomInt(10, 35);
					::hdmdTankVars.tankflow2 = RandomInt(35, 58);
					::hdmdTankVars.tankflow3 = RandomInt(58, 80); break;
				case "c2m2_fairgrounds":
					::hdmdTankVars.tankflow1 = RandomInt(10, 33);
					::hdmdTankVars.tankflow2 = RandomInt(33, 55);
					::hdmdTankVars.tankflow3 = RandomInt(55, 75); break;
				case "c2m3_coaster":
					::hdmdTankVars.tankflow1 = RandomInt(10, 33);
					::hdmdTankVars.tankflow2 = RandomInt(33, 55);
					::hdmdTankVars.tankflow3 = RandomInt(55, 70); break;
				case "c2m4_barns":
					::hdmdTankVars.tankflow1 = RandomInt(10, 35);
					::hdmdTankVars.tankflow2 = RandomInt(35, 58);
					::hdmdTankVars.tankflow3 = RandomInt(58, 80); break;
				case "c2m5_concert":
					if(RandomInt(1,2)==1){
						::hdmdTankVars.tankflow1 = RandomInt(42, 55);
						::hdmdTankVars.tankflow2 = RandomInt(70, 70);
					}else{
						::hdmdTankVars.tankflow1 = RandomInt(102, 102);
					}
					break;
				case "c3m1_plankcountry":
					::hdmdTankVars.tankflow1 = RandomInt(10, 43);
					::hdmdTankVars.tankflow2 = RandomInt(53, 76); break;
				case "c3m2_swamp":
					::hdmdTankVars.tankflow1 = RandomInt(16, 37);
					::hdmdTankVars.tankflow2 = RandomInt(52, 70); break;
				case "c3m3_shantytown":
					::hdmdTankVars.tankflow1 = RandomInt(10, 28);
					::hdmdTankVars.tankflow2 = RandomInt(28, 57); break;
				case "c3m4_plantation":
					::hdmdTankVars.tankflow1 = RandomInt(10, 33);
					::hdmdTankVars.tankflow2 = RandomInt(33, 65); break;
				case "c4m1_milltown_a":
					::hdmdTankVars.tankflow1 = RandomInt(10, 33);
					::hdmdTankVars.tankflow2 = RandomInt(33, 57);
					::hdmdTankVars.tankflow3 = RandomInt(57, 80); break;
				case "c4m2_sugarmill_a":
					::hdmdTankVars.tankflow1 = RandomInt(10, 33);
					::hdmdTankVars.tankflow2 = RandomInt(33, 55);
					::hdmdTankVars.tankflow3 = RandomInt(55, 72); break;
				case "c4m3_sugarmill_b":
					::hdmdTankVars.tankflow1 = RandomInt(10, 21);
					::hdmdTankVars.tankflow2 = RandomInt(26, 36);
					::hdmdTankVars.tankflow3 = RandomInt(61, 72); break;
				case "c4m4_milltown_b":
					::hdmdTankVars.tankflow1 = RandomInt(10, 33);
					::hdmdTankVars.tankflow2 = RandomInt(33, 66); break;
				case "c4m1_milltown_a":
					::hdmdTankVars.tankflow1 = RandomInt(10, 35);
					::hdmdTankVars.tankflow2 = RandomInt(35, 65); break;
				case "c4m5_milltown_escape":
					::hdmdTankVars.tankflow1 = RandomInt(102, 102); break;
				case "c4m1_milltown_a":
					::hdmdTankVars.tankflow1 = RandomInt(10, 35);
					::hdmdTankVars.tankflow2 = RandomInt(35, 65); break;
				case "c5m1_waterfront":
					::hdmdTankVars.tankflow1 = RandomInt(10, 25);
					::hdmdTankVars.tankflow2 = RandomInt(25, 50); break;
				case "c5m2_park":
					::hdmdTankVars.tankflow1 = RandomInt(7, 30);
					::hdmdTankVars.tankflow2 = RandomInt(30, 60);
					::hdmdTankVars.tankflow3 = RandomInt(60, 80); break;
				case "c5m3_cemetery":
					::hdmdTankVars.tankflow1 = RandomInt(5, 30);
					::hdmdTankVars.tankflow2 = RandomInt(30, 60);
					::hdmdTankVars.tankflow3 = RandomInt(68, 80); break;
				case "c5m4_quarter":
					::hdmdTankVars.tankflow1 = RandomInt(5, 40);
					::hdmdTankVars.tankflow2 = RandomInt(57, 77); break;
				case "c5m5_bridge":
					::hdmdTankVars.tankflow1 = RandomInt(102, 102); break;
				case "c6m1_riverbank":
					::hdmdTankVars.tankflow1 = RandomInt(1, 80); break;
				case "c6m2_bedlam":
					::hdmdTankVars.tankflow1 = RandomInt(5, 25);
					::hdmdTankVars.tankflow2 = RandomInt(25, 50); break;
				case "c6m3_port":
					::hdmdTankVars.tankflow1 = RandomInt(102, 102); break;
				case "c7m1_docks":
					::hdmdTankVars.tankflow1 = RandomInt(102, 102); break;
				case "c7m2_barge":
					::hdmdTankVars.tankflow1 = RandomInt(1, 30); break;
					::hdmdTankVars.tankflow2 = RandomInt(30, 59); break;
				case "c7m3_port":
					::hdmdTankVars.tankflow1 = RandomInt(102, 102); break;
				case "c8m1_apartment":
					::hdmdTankVars.tankflow1 = RandomInt(42, 60);
					::hdmdTankVars.tankflow2 = RandomInt(60, 71);
					::hdmdTankVars.tankflow3 = RandomInt(71, 85); break;
				case "c8m2_subway":
					::hdmdTankVars.tankflow1 = RandomInt(10, 33);
					::hdmdTankVars.tankflow2 = RandomInt(33, 60);
					::hdmdTankVars.tankflow3 = RandomInt(60, 81); break;
				case "c8m3_sewers":
					::hdmdTankVars.tankflow1 = RandomInt(5, 40);
					::hdmdTankVars.tankflow2 = RandomInt(57, 77); break;
				case "c8m4_interior":
					::hdmdTankVars.tankflow1 = RandomInt(10, 34);
					::hdmdTankVars.tankflow2 = RandomInt(34, 78); break;
				case "c8m5_rooftop":
					if(RandomInt(1,2)==1)::hdmdTankVars.tankflow1 = RandomInt(91, 100);
					else ::hdmdTankVars.tankflow1 = RandomInt(102, 102);
					break;
				case "c9m1_alleys":
					::hdmdTankVars.tankflow1 = RandomInt(7, 20);
					::hdmdTankVars.tankflow2 = RandomInt(33, 69);break;
				case "c9m2_lots":
					::hdmdTankVars.tankflow1 = RandomInt(3, 24);
					::hdmdTankVars.tankflow2 = RandomInt(24, 50);
					::hdmdTankVars.tankflow3 = RandomInt(50, 74); break;
				case "c10m1_caves":
					::hdmdTankVars.tankflow1 = RandomInt(6, 25);
					::hdmdTankVars.tankflow2 = RandomInt(25, 50);
					::hdmdTankVars.tankflow3 = RandomInt(50, 80); break;
				case "c10m2_drainage":
					::hdmdTankVars.tankflow1 = RandomInt(18, 36);
					::hdmdTankVars.tankflow2 = RandomInt(50, 73); break;
				case "c10m3_ranchhouse":
					::hdmdTankVars.tankflow1 = RandomInt(5, 33);
					::hdmdTankVars.tankflow2 = RandomInt(33, 57);
					::hdmdTankVars.tankflow3 = RandomInt(57, 80); break;
				case "c10m4_mainstreet":
					::hdmdTankVars.tankflow1 = RandomInt(10, 22);
					::hdmdTankVars.tankflow2 = RandomInt(22, 39);
					::hdmdTankVars.tankflow3 = RandomInt(39, 57); break;
				case "c10m5_houseboat":
					::hdmdTankVars.tankflow1 = RandomInt(10, 30);
					::hdmdTankVars.tankflow2 = RandomInt(30, 60);
					::hdmdTankVars.tankflow3 = RandomInt(60, 90); break;
				case "c11m1_greenhouse":
					::hdmdTankVars.tankflow1 = RandomInt(10, 30);
					::hdmdTankVars.tankflow2 = RandomInt(30, 45);
					::hdmdTankVars.tankflow3 = RandomInt(45, 54); break;
				case "c11m2_offices":
					::hdmdTankVars.tankflow1 = RandomInt(30, 30);
					::hdmdTankVars.tankflow2 = RandomInt(36, 56); 
					::hdmdTankVars.tankflow3 = RandomInt(56, 80); break;
				case "c11m3_garage":
					::hdmdTankVars.tankflow1 = RandomInt(5, 13);
					::hdmdTankVars.tankflow2 = RandomInt(25, 55);
					::hdmdTankVars.tankflow3 = RandomInt(55, 80); break;
				case "c11m4_terminal":
					::hdmdTankVars.tankflow1 = RandomInt(10, 30);
					::hdmdTankVars.tankflow2 = RandomInt(40, 65); break;
				case "c11m5_runway":
					::hdmdTankVars.tankflow1 = RandomInt(102, 102); break;
				case "c12m1_hilltop":
					::hdmdTankVars.tankflow1 = RandomInt(30, 50); break;
				case "c12m2_traintunnel":
					::hdmdTankVars.tankflow1 = RandomInt(16, 16);
					::hdmdTankVars.tankflow2 = RandomInt(33, 60); break;
				case "c12m3_bridge":
					::hdmdTankVars.tankflow1 = RandomInt(10, 30);
					::hdmdTankVars.tankflow2 = RandomInt(30, 50);
					::hdmdTankVars.tankflow3 = RandomInt(50, 70); break;
				case "c12m4_barn":
					::hdmdTankVars.tankflow1 = RandomInt(10, 22);
					::hdmdTankVars.tankflow2 = RandomInt(30, 45);
					::hdmdTankVars.tankflow3 = RandomInt(45, 64); break;
				case "c12m5_cornfield":
					::hdmdTankVars.tankflow1 = RandomInt(20, 50);
					::hdmdTankVars.tankflow2 = RandomInt(50, 60);
					::hdmdTankVars.tankflow3 = RandomInt(90, 90); break;
				case "c13m1_alpinecreek":
					::hdmdTankVars.tankflow1 = RandomInt(35, 65); break;
				case "c13m2_southpinestream":
					::hdmdTankVars.tankflow1 = RandomInt(102, 102); break;
				case "c13m3_memorialbridge":
					::hdmdTankVars.tankflow1 = RandomInt(13, 40);
					::hdmdTankVars.tankflow2 = RandomInt(78, 78); break;
				case "c13m4_cutthroatcreek":
					::hdmdTankVars.tankflow1 = RandomInt(102, 102); break;
				case "c14m2_lighthouse":
					::hdmdTankVars.tankflow1 = RandomInt(102, 102); break;
			}
		

			local max = 3;
			if(::hdmdTankVars.tankflow3 == 0){max = 2;}
			if(::hdmdTankVars.tankflow2 == 0){max = 1;}
			::hdmdTankVars.tankpos1 = RandomInt(1, max);
			::hdmdTankVars.tankpos2 = RandomInt(::hdmdTankVars.tankpos1, max);

			if(::hdmdTankVars.tankpos2 == 1 && ::hdmdTankVars.tankflow2 != 0 && ::hdmdTankVars.tankflow1 < 40)::hdmdTankVars.tankpos2 = 2;

			switch(::hdmdTankVars.tankpos1){
				case 1: ::hdmdTankVars.tankpos1flow = ::hdmdTankVars.tankflow1;break;
				case 2: ::hdmdTankVars.tankpos1flow = ::hdmdTankVars.tankflow2;break;
				case 3: ::hdmdTankVars.tankpos1flow = ::hdmdTankVars.tankflow3;break;
			}
			switch(::hdmdTankVars.tankpos2){
				case 1: ::hdmdTankVars.tankpos2flow = ::hdmdTankVars.tankflow1;break;
				case 2: ::hdmdTankVars.tankpos2flow = ::hdmdTankVars.tankflow2;break;
				case 3: ::hdmdTankVars.tankpos2flow = ::hdmdTankVars.tankflow3;break;
			}
			//StringToFile("hardmode/tank/1.txt", ::hdmdTankVars.tankpos1flow.tostring());
			//StringToFile("hardmode/tank/2.txt", ::hdmdTankVars.tankpos2flow.tostring());

			::hdmdTankVars.sessionDataBoss["tank1"] <- ::hdmdTankVars.tankpos1flow;
			::hdmdTankVars.sessionDataBoss["tank2"] <- ::hdmdTankVars.tankpos2flow;

			SaveTable("manacat_hdmd_boss", ::hdmdTankVars.sessionDataBoss);
		//	printl("플로우 세이브 탱크1 "+::hdmdTankVars.tankpos1flow);printl("플로우 세이브 탱크2 "+::hdmdTankVars.tankpos2flow);

			// local SearchPlayer = null;	local startArea = 0;
			// while (SearchPlayer = Entities.FindByClassname(SearchPlayer, "player")){
			// 	if(IsPlayerABot(SearchPlayer) || SearchPlayer.IsSurvivor() == false)continue;
			// 	startArea = NavMesh.GetNavArea(SearchPlayer.GetOrigin(), 60.0);
			// 	break;
			// }
			
			local disttank = 999;	local disttankpos = null;
			local distwitch = 999;	local distwitchpos = null;

			local navTable = {};	NavMesh.GetAllAreas(navTable);
			foreach(areaName, nav in navTable){
				local pos = nav.GetCenter();
				local flow = GetFlowPercentForPosition(pos, false);

				pos.z += 20;
				local endArea = NavMesh.GetNavArea(pos, 60.0);

				if( !nav.HasAvoidanceObstacle(100.0) && nav.GetSizeX() > 40 && nav.GetSizeY() > 40 && !nav.IsBlocked(2, false)
				&& ((nav.IsSpawningAllowed() && nav.HasSpawnAttributes(131072)/*escape_route*/ && !nav.IsDegenerate() && !nav.IsDamaging())
				|| nav.HasSpawnAttributes(2048)/*checkpoint*/)){
					local waterzone = false;
					if(!nav.IsUnderwater()){
						waterzone = true;
					}else{
						local begin = Vector(pos.x, pos.y, pos.z);
						local finish = nav.GetCenter();	finish.z -= 99999;
						
						local m_trace = { start = pos, end = finish, mask = 131083 };
						TraceLine(m_trace);

						local depth = (pos - m_trace.pos).Length();
						if(depth < 40){
							waterzone = true;
						}
					}
					if(waterzone){
						if(disttank > flow){
							disttank = flow;	disttankpos = pos;
						}
						::hdmdState.escape_route.append([flow, nav, pos]);
						//DebugDrawBox(pos, Vector((nav.GetSizeX()/2)*-1,(nav.GetSizeY()/2)*-1,-12.0), Vector((nav.GetSizeX()/2),(nav.GetSizeY()/2),12.0), 0, 255, 255, 64, 50.0);
					}
				}
			}
		/*	local len = ::hdmdState.escape_route.len();
			for(local i = 0; i < len; i++){
				printl(len+"개의 구역 / 탈출경로 : "+::hdmdState.escape_route[i][0]+"  "+::hdmdState.escape_route[i][1]);
			}//*/
		}else{//로드
			//::hdmdTankVars.tankpos1flow = FileToString("hardmode/tank/1.txt").tointeger();
			//::hdmdTankVars.tankpos2flow = FileToString("hardmode/tank/2.txt").tointeger();

			RestoreTable("manacat_hdmd_boss", ::hdmdTankVars.sessionDataBoss);

			::hdmdTankVars.tankpos1flow = ::hdmdTankVars.sessionDataBoss["tank1"];
			::hdmdTankVars.tankpos2flow = ::hdmdTankVars.sessionDataBoss["tank2"];
		//	printl("플로우 로드 탱크1 "+::hdmdTankVars.tankpos1flow);printl("플로우 로드 탱크2 "+::hdmdTankVars.tankpos2flow);
		}
		
		/*printl("탱크 스폰 정보");
		printl("1탱크 : "+::hdmdTankVars.tankpos1+" "+::hdmdTankVars.tankpos1flow);
		printl("2탱크 : "+::hdmdTankVars.tankpos2+" "+::hdmdTankVars.tankpos2flow);
		printl("플로우1 : "+::hdmdTankVars.tankflow1);
		printl("플로우2 : "+::hdmdTankVars.tankflow2);
		printl("플로우3 : "+::hdmdTankVars.tankflow3);//*/

		::hdmdTankVars.tankspawn1 = ::hdmdTankFunc.tank_gen_flow(::hdmdTankVars.tankpos1flow, 1);
		::hdmdTankVars.tankspawn2 = ::hdmdTankFunc.tank_gen_flow(::hdmdTankVars.tankpos2flow, 2);
	}

	function tankHP(){
		local tankHealth = 4000;
		if(Director.IsFirstMapInScenario()){
			if(::hdmdState.lv <= 5)			tankHealth = 3000;
			else if(::hdmdState.lv == 6)	tankHealth = 3500;
			else if(::hdmdState.lv == 7)	tankHealth = 4000;
		}else if(::hdmdState.finale){
			if(::hdmdState.lv <= 5)			tankHealth = 4000;
			else if(::hdmdState.lv == 6)	tankHealth = 4250;
			else if(::hdmdState.lv == 7)	tankHealth = 4500;
		}else{
			if(::hdmdState.lv <= 5)			tankHealth = 4000;
			else if(::hdmdState.lv == 6)	tankHealth = 4500;
			else if(::hdmdState.lv == 7)	tankHealth = 5000;
		}

		if(::hdmdSurvVars.playerCount == 1)			tankHealth /= 2;
		else if(::hdmdSurvVars.playerCount == 2)	tankHealth /= 1.25;
		else if(::hdmdSurvVars.playerCount > 4){
			tankHealth *= 1+((::hdmdSurvVars.playerCount-4)/8);
		}

		switch(Convars.GetStr("z_difficulty").tolower()){
			case "impossible" :		tankHealth *= 2;	break;
			case "hard" :			tankHealth *= 1.6;	break;
			case "easy" :			tankHealth *= 0.8;	break;
		}
	//	printl("탱크 체력 " + tankHealth);
		if(::hdmdState.gamemode == 1)tankHealth *= 0.6;
		return tankHealth;
	}

	function tank_gen_flow(flow, tankn){
		local allowArea = [];
		local len = ::hdmdState.escape_route.len();
		local plus15 = flow+15;
		if(plus15 > 99)plus15 = 99;
		local plus50 = flow+50;
		if(plus50 > 105)plus50 = 105;
		for(local i = 0; i < len; i++){
			if(plus50 >= ::hdmdState.escape_route[i][0] && ::hdmdState.escape_route[i][0] >= plus15){
				allowArea.append(::hdmdState.escape_route[i][2]);
			}
		}
		
		local len = allowArea.len();
		if(len == 0)return null;
	//	printl("허용 거리 : "+plus15+" "+plus50);
	//	printl("허용 영역 수 : "+len);
		local spawnOrigin = allowArea[RandomInt(0, len-1)];
		local tgname = "tank"+tankn;
		local tankspawn = SpawnEntityFromTable("info_zombie_spawn",
		{
			targetname = tgname
			population = "Tank"
			origin = spawnOrigin
			angles = Vector(0,0,0)
			offer_tank = "1"
		});
	//	printl("탱크 위치 : "+spawnOrigin);

		return tankspawn;
	//	DoEntFire("!self", "SpawnZombie", "", 0.0, null, tankspawn);
	//	tankspawn.Kill();
	//	if(tankn == 1){
	//		::hdmdTankVars.tank1spawnDone = true;
	//	}else if(tankn == 2){
	//		::hdmdTankVars.tank2spawnDone = true;
	//	}
	}
}

::finaleTank <- function(){
	//printl("피날레 분석");
	local doubleTankFinale = false;
	for(local i = 1; i < 100; i++){
		try{
			if(DirectorScript.GetDirectorOptions()["A_CustomFinale"+i] == 1){
				if(::hdmdState.lv > 5 && DirectorScript.GetDirectorOptions()["A_CustomFinaleValue"+i] == 1){
					DirectorScript.GetDirectorOptions()["TankLimit"] <- 2;
					DirectorScript.GetDirectorOptions()["A_CustomFinaleValue"+i] <- 2.1;
				}else if(::hdmdState.lv <= 5 && DirectorScript.GetDirectorOptions()["A_CustomFinaleValue"+i] == 2.1){
					DirectorScript.GetDirectorOptions()["A_CustomFinaleValue"+i] <- 1;
				}
			}
		}catch(e){
			if(e.find("does not exist") != null){
				//printl(e);
				break;
			}
		}
	}

	for(local i = 1; i < 100; i++){
		try{
			if(DirectorScript.GetDirectorOptions()["A_CustomFinale"+i] == 1){
				//printl("탱크 숫자" + DirectorScript.GetDirectorOptions()["A_CustomFinaleValue"+i]);
				if(DirectorScript.GetDirectorOptions()["A_CustomFinaleValue"+i] >= 2){
					doubleTankFinale = true;
				}
			}
		}catch(e){
			if(e.find("does not exist") != null){
				//printl(e);
				break;
			}
		}
	}
	if(doubleTankFinale == true){
		DirectorScript.GetDirectorOptions()["TankLimit"] <- 2;
		Convars.SetValue("z_tank_health", 3500);
	}else{
		DirectorScript.GetDirectorOptions()["TankLimit"] <- 1;
		Convars.SetValue("z_tank_health", 4000);
	}
}

::tank_gen <- function(){
	if(::hdmdTankVars.tankpos1flow == -102 || ::hdmdState.finale)return;
	local SearchPlayer = null;
	while (SearchPlayer = Entities.FindByClassname(SearchPlayer, "player")){
		if(IsPlayerABot(SearchPlayer) || !SearchPlayer.IsSurvivor())continue;
		
	//	printl("탱크1 "+::hdmdTankVars.tankspawn1);
	//	printl(::hdmdTankVars.tankspawn1 == null);
	//	printl(::hdmdTankVars.tankspawn1.IsValid());
	//	printl("탱크2 "+::hdmdTankVars.tankspawn2);
	//	printl(::hdmdTankVars.tankspawn2 == null);
	//	printl(::hdmdTankVars.tankspawn2.IsValid());

		local playerOrigin = SearchPlayer.GetOrigin();
		local playerflow = GetCurrentFlowPercentForPlayer(SearchPlayer);
		local playerArea = NavMesh.GetNearestNavArea(playerOrigin, 60.0, true, true);
		
		//1번 탱크
		if(::hdmdTankVars.tankspawn1 != null && ::hdmdTankVars.tankpos1flow != 102){
			local spawnOrigin = ::hdmdTankVars.tankspawn1.GetOrigin();
			local dist1 = (playerOrigin - spawnOrigin).Length();
			local spawnArea = NavMesh.GetNavArea(spawnOrigin, 60.0);
			local dist2 = NavMesh.NavAreaBuildPath(spawnArea, playerArea, Vector(0, 0, 0), 3000.0, 3, false);
			if(dist1 < 1200 || (dist2 && playerflow > ::hdmdTankVars.tankpos1flow-10)){
				DoEntFire("!self", "SpawnZombie", "", 0.0, null, ::hdmdTankVars.tankspawn1);
				::hdmdTankVars.tankspawn1.Kill();
				::hdmdTankVars.tankspawn1 = null;
				if(::hdmdTankVars.tankpos1flow == ::hdmdTankVars.tankpos2flow
				&& ::hdmdTankVars.tankspawn2 != null && ::hdmdTankVars.tankpos2flow != 102 && ::hdmdState.lv >= 6){
					DoEntFire("!self", "SpawnZombie", "", 0.0, null, ::hdmdTankVars.tankspawn2);
					::hdmdTankVars.tankspawn2.Kill();
					::hdmdTankVars.tankspawn2 = null;
				}
			}
		}

		//2번 탱크
		if(::hdmdTankVars.tankspawn2 != null && ::hdmdTankVars.tankpos2flow != 102 && ::hdmdState.lv >= 6){
			local spawnOrigin = ::hdmdTankVars.tankspawn2.GetOrigin();
			local dist1 = (playerOrigin - spawnOrigin).Length();
			local spawnArea = NavMesh.GetNavArea(spawnOrigin, 60.0);
			local dist2 = NavMesh.NavAreaBuildPath(spawnArea, playerArea, Vector(0, 0, 0), 3000.0, 3, false);
			if(dist1 < 1200 || (dist2 && playerflow > ::hdmdTankVars.tankpos2flow-10)){
				DoEntFire("!self", "SpawnZombie", "", 0.0, null, ::hdmdTankVars.tankspawn2);
				::hdmdTankVars.tankspawn2.Kill();
				::hdmdTankVars.tankspawn2 = null;
				if(::hdmdTankVars.tankpos1flow == ::hdmdTankVars.tankpos2flow
				&& ::hdmdTankVars.tankspawn1 != null && ::hdmdTankVars.tankpos1flow != 102){
					DoEntFire("!self", "SpawnZombie", "", 0.0, null, ::hdmdTankVars.tankspawn1);
					::hdmdTankVars.tankspawn1.Kill();
					::hdmdTankVars.tankspawn1 = null;
				}
			}
		}
	}
}

__CollectEventCallbacks(::hdmdTankFunc, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);