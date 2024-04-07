::hdmdWitchVars<-{
	witch = 0 //지금까지 뜬 윗치의 수
	witches = 0 //필드에서 활동중인 윗치의 수
	witchList = [] //윗치가 뜰때마다 집어넣는 배열
	/*
	[0] = 윗치
	[1] = 스폰시간*/

	sessionDataBoss = {} //세션 세이브 로드
}

::hdmdWitchFunc<-{
	function OnGameEvent_witch_spawn(params){
		local zombie = Ent(params.witchid);
	//	if(!IsPlayerABot(zombie)){
	//		printl("<Human Player> Witch");	return;
	//	}
		::manacatAddTimer(0.5, false, ::hdmdWitchFunc.witchManage, { witch = zombie });
	}

	function witchManage(params){
		local currentTime = Time();
		::hardmodeFunc.toHardmodeSet();

		local nomsg = false;	local len = ::hdmdWitchVars.witchList.len();
		local chk = false;
		for(local i = 0; i < len; i++){
			if(::hdmdWitchVars.witchList[i][0] == params.witch){
				chk = true;
				break;
			}
		}
		if(!chk){
			::hdmdWitchVars.witchList.append([params.witch, currentTime]);
		}

		::manacatAddTimer(0.1, false, ::hdmdWitchFunc.SI_control_witch, { si = params.witch });
	}

	function SI_control_witch(params){
		if(params.si.IsValid() && params.si != null){
			local health = NetProps.GetPropInt(params.si,"m_iHealth");
			if(health > 0){
				if(!("posCount" in params))params.posCount <- 0;
				local currentOrigin = params.si.GetOrigin();
				if(!("pos" in params)){
					params.pos <- currentOrigin;
				}else{
					local seq = NetProps.GetPropIntArray( params.si, "m_nSequence", 0);
					if((params.pos - currentOrigin).Length() < 15 && health != 1000){
						if(seq != 61 && seq != 65 && seq != 66 && seq != 68 && seq != 72){//기어오르기 등
							params.posCount++;
						}
					}else{
						params.posCount <- 0;
					}
				}
				params.pos <- currentOrigin;
				::manacatAddTimer(0.1, false, ::hdmdWitchFunc.SI_control_witch, params);
			//	printl("윗치의 시퀀스" + NetProps.GetPropIntArray( params.si, "m_nSequence", 0))
			//	printl("윗치의 속도" + NetProps.GetPropFloatArray( params.si, "m_flSpeed", 0))
				
				if(params.posCount > 2){
					local front = currentOrigin + params.si.GetAngles().Forward().Scale(25);
					local chkpdoor = Entities.FindByClassnameNearest("prop_door_rotating_checkpoint", front, 145.0);
			//		DebugDrawBox(front, Vector(-12,-12,-12.0), Vector(12,12,12.0), 255, 0, 0, 64, 1.0);
					if(chkpdoor != null && NetProps.GetPropInt( chkpdoor, "m_eDoorState" ) == 0){
						if(chkpdoor == null || !chkpdoor.IsValid() || params.si == null || !params.si.IsValid())return;
						local doormodel = chkpdoor.GetModelName();
						if(doormodel == "models/props_doors/checkpoint_door_02.mdl" || doormodel == "models/props_doors/checkpoint_door_-02.mdl" || doormodel == "models/lighthouse/checkpoint_door_lighthouse02.mdl"){
							local currentAngle = chkpdoor.GetAngles()
							//if(currentAngle.x == params.angle.x && currentAngle.y == params.angle.y && currentAngle.z == params.angle.z){
								local doorOrigin = chkpdoor.GetOrigin();
								local doorang = chkpdoor.GetAngles();	local fwd = doorang.Forward();

								local product = (currentOrigin.x - doorOrigin.x)*fwd.x
												+ (currentOrigin.y - doorOrigin.y)*fwd.y
												+ (currentOrigin.z - doorOrigin.z)*fwd.z;
								
								local warpOrigin = doorOrigin + currentAngle.Left().Scale(-27);
								warpOrigin.z = currentOrigin.z;

								if(product <= 0.0)	params.si.SetOrigin(warpOrigin + currentAngle.Forward().Scale(-40));
								else				params.si.SetOrigin(warpOrigin + currentAngle.Forward().Scale(40));

								local eyeVector = params.si.GetOrigin();

								local vector = doorOrigin - eyeVector;
								local qy = Quaternion();	local qx = Quaternion();
								qy.SetPitchYawRoll(0, 90-atan2(vector.x, vector.y)*180/PI, 0);
								qx.SetPitchYawRoll(atan2(vector.z, sqrt(vector.x*vector.x+vector.y*vector.y))*-180/PI, 0, 0);
								local qr = Quaternion(
									qy.x*qx.x - qy.y*qx.y - qy.z*qx.z - qy.w*qx.w,
									qy.x*qx.y + qy.y*qx.x + qy.z*qx.w - qy.w*qx.z,
									qy.x*qx.z - qy.y*qx.w + qy.z*qx.x + qy.w*qx.y,
									qy.x*qx.w + qy.y*qx.z + qy.z*qx.y + qy.w*qx.x
								).ToQAngle();

								params.si.SetAngles(QAngle(0, qr.y*-1, 0));
							//}
						}
					}
				}
			}
		}
	}

	function OnGameEvent_witch_killed(params){
		local witch = Ent(params.witchid);
		local len = ::hdmdWitchVars.witchList.len();
		for(local i = 0; i < len; i++){
			if(::hdmdWitchVars.witchList[i][0] == witch){
				::hdmdWitchVars.witchList.remove(i);
				break;
			}
		}
		if(::hdmdState.gamemode == 1){
			local player = null;
			while (player = Entities.FindByClassname(player, "player")){
				::hdmdSurvFunc.hp_bonus(player, 25, 70);
			}
		}
	}

	function witch_pos(){
		local mapName = Director.GetMapName();
		::hdmdWitchVars.witchflow1 = RandomInt(10, 90);

		if(::mp_gamemode != "versus" || (::hardmodeVars.sessionData["mapname"] != mapName && ::mp_gamemode == "versus")){//세이브
			switch (mapName){
				case "c1m1_hotel":
					::hdmdWitchVars.witchflow1 = RandomInt(69, 74);
					::hdmdWitchVars.witchflow2 = RandomInt(74, 79);
					::hdmdWitchVars.witchflow3 = RandomInt(79, 85); break;
				case "c1m2_streets":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 35);
					::hdmdWitchVars.witchflow2 = RandomInt(35, 55);
					::hdmdWitchVars.witchflow3 = RandomInt(55, 77); break;
				case "c1m3_mall":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 30);
					::hdmdWitchVars.witchflow2 = RandomInt(66, 78);
					::hdmdWitchVars.witchflow2 = RandomInt(78, 88); break;
				case "c1m4_atrium":
					::hdmdWitchVars.witchflow1 = RandomInt(102, 102); break;
				case "c2m1_highway":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 35);
					::hdmdWitchVars.witchflow2 = RandomInt(35, 58);
					::hdmdWitchVars.witchflow3 = RandomInt(58, 80); break;
				case "c2m2_fairgrounds":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 33);
					::hdmdWitchVars.witchflow2 = RandomInt(33, 55);
					::hdmdWitchVars.witchflow3 = RandomInt(55, 75); break;
				case "c2m3_coaster":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 33);
					::hdmdWitchVars.witchflow2 = RandomInt(33, 55);
					::hdmdWitchVars.witchflow3 = RandomInt(55, 70); break;
				case "c2m4_barns":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 35);
					::hdmdWitchVars.witchflow2 = RandomInt(35, 58);
					::hdmdWitchVars.witchflow3 = RandomInt(58, 80); break;
				case "c2m5_concert":
					if(RandomInt(1,2)==1){
						::hdmdWitchVars.witchflow1 = RandomInt(42, 55);
						::hdmdWitchVars.witchflow2 = RandomInt(70, 70);
					}else{
						::hdmdWitchVars.witchflow1 = RandomInt(102, 102);
					}
					break;
				case "c3m1_plankcountry":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 43);
					::hdmdWitchVars.witchflow2 = RandomInt(53, 76); break;
				case "c3m2_swamp":
					::hdmdWitchVars.witchflow1 = RandomInt(16, 37);
					::hdmdWitchVars.witchflow2 = RandomInt(52, 70); break;
				case "c3m3_shantytown":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 28);
					::hdmdWitchVars.witchflow2 = RandomInt(28, 57); break;
				case "c3m4_plantation":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 33);
					::hdmdWitchVars.witchflow2 = RandomInt(33, 65); break;
				case "c4m1_milltown_a":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 33);
					::hdmdWitchVars.witchflow2 = RandomInt(33, 57);
					::hdmdWitchVars.witchflow3 = RandomInt(57, 80); break;
				case "c4m2_sugarmill_a":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 33);
					::hdmdWitchVars.witchflow2 = RandomInt(33, 55);
					::hdmdWitchVars.witchflow3 = RandomInt(55, 72); break;
				case "c4m3_sugarmill_b":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 21);
					::hdmdWitchVars.witchflow2 = RandomInt(26, 36);
					::hdmdWitchVars.witchflow3 = RandomInt(61, 72); break;
				case "c4m4_milltown_b":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 33);
					::hdmdWitchVars.witchflow2 = RandomInt(33, 66); break;
				case "c4m1_milltown_a":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 35);
					::hdmdWitchVars.witchflow2 = RandomInt(35, 65); break;
				case "c4m5_milltown_escape":
					::hdmdWitchVars.witchflow1 = RandomInt(102, 102); break;
				case "c4m1_milltown_a":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 35);
					::hdmdWitchVars.witchflow2 = RandomInt(35, 65); break;
				case "c5m1_waterfront":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 25);
					::hdmdWitchVars.witchflow2 = RandomInt(25, 50); break;
				case "c5m2_park":
					::hdmdWitchVars.witchflow1 = RandomInt(7, 30);
					::hdmdWitchVars.witchflow2 = RandomInt(30, 60);
					::hdmdWitchVars.witchflow3 = RandomInt(60, 80); break;
				case "c5m3_cemetery":
					::hdmdWitchVars.witchflow1 = RandomInt(5, 30);
					::hdmdWitchVars.witchflow2 = RandomInt(30, 60);
					::hdmdWitchVars.witchflow3 = RandomInt(68, 80); break;
				case "c5m4_quarter":
					::hdmdWitchVars.witchflow1 = RandomInt(5, 40);
					::hdmdWitchVars.witchflow2 = RandomInt(57, 77); break;
				case "c5m5_bridge":
					::hdmdWitchVars.witchflow1 = RandomInt(102, 102); break;
				case "c6m1_riverbank":
					::hdmdWitchVars.witchflow1 = RandomInt(1, 80); break;
				case "c6m2_bedlam":
					::hdmdWitchVars.witchflow1 = RandomInt(5, 25);
					::hdmdWitchVars.witchflow2 = RandomInt(25, 50); break;
				case "c6m3_port":
					::hdmdWitchVars.witchflow1 = RandomInt(102, 102); break;
				case "c7m1_docks":
					::hdmdWitchVars.witchflow1 = RandomInt(102, 102); break;
				case "c7m2_barge":
					::hdmdWitchVars.witchflow1 = RandomInt(1, 30); break;
					::hdmdWitchVars.witchflow2 = RandomInt(30, 59); break;
				case "c7m3_port":
					::hdmdWitchVars.witchflow1 = RandomInt(102, 102); break;
				case "c8m1_apartment":
					::hdmdWitchVars.witchflow1 = RandomInt(42, 60);
					::hdmdWitchVars.witchflow2 = RandomInt(60, 71);
					::hdmdWitchVars.witchflow3 = RandomInt(71, 85); break;
				case "c8m2_subway":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 33);
					::hdmdWitchVars.witchflow2 = RandomInt(33, 60);
					::hdmdWitchVars.witchflow3 = RandomInt(60, 81); break;
				case "c8m3_sewers":
					::hdmdWitchVars.witchflow1 = RandomInt(5, 40);
					::hdmdWitchVars.witchflow2 = RandomInt(57, 77); break;
				case "c8m4_interior":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 34);
					::hdmdWitchVars.witchflow2 = RandomInt(34, 78); break;
				case "c8m5_rooftop":
					if(RandomInt(1,2)==1)::hdmdWitchVars.witchflow1 = RandomInt(91, 100);
					else ::hdmdWitchVars.witchflow1 = RandomInt(102, 102);
					break;
				case "c9m1_alleys":
					::hdmdWitchVars.witchflow1 = RandomInt(7, 20);
					::hdmdWitchVars.witchflow2 = RandomInt(33, 69);break;
				case "c9m2_lots":
					::hdmdWitchVars.witchflow1 = RandomInt(3, 24);
					::hdmdWitchVars.witchflow2 = RandomInt(24, 50);
					::hdmdWitchVars.witchflow3 = RandomInt(50, 74); break;
				case "c10m1_caves":
					::hdmdWitchVars.witchflow1 = RandomInt(6, 25);
					::hdmdWitchVars.witchflow2 = RandomInt(25, 50);
					::hdmdWitchVars.witchflow3 = RandomInt(50, 80); break;
				case "c10m2_drainage":
					::hdmdWitchVars.witchflow1 = RandomInt(18, 36);
					::hdmdWitchVars.witchflow2 = RandomInt(50, 73); break;
				case "c10m3_ranchhouse":
					::hdmdWitchVars.witchflow1 = RandomInt(5, 33);
					::hdmdWitchVars.witchflow2 = RandomInt(33, 57);
					::hdmdWitchVars.witchflow3 = RandomInt(57, 80); break;
				case "c10m4_mainstreet":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 22);
					::hdmdWitchVars.witchflow2 = RandomInt(22, 39);
					::hdmdWitchVars.witchflow3 = RandomInt(39, 57); break;
				case "c10m5_houseboat":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 30);
					::hdmdWitchVars.witchflow2 = RandomInt(30, 60);
					::hdmdWitchVars.witchflow3 = RandomInt(60, 90); break;
				case "c11m1_greenhouse":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 30);
					::hdmdWitchVars.witchflow2 = RandomInt(30, 45);
					::hdmdWitchVars.witchflow3 = RandomInt(45, 54); break;
				case "c11m2_offices":
					::hdmdWitchVars.witchflow1 = RandomInt(30, 30);
					::hdmdWitchVars.witchflow2 = RandomInt(36, 56); 
					::hdmdWitchVars.witchflow3 = RandomInt(56, 80); break;
				case "c11m3_garage":
					::hdmdWitchVars.witchflow1 = RandomInt(5, 13);
					::hdmdWitchVars.witchflow2 = RandomInt(25, 55);
					::hdmdWitchVars.witchflow3 = RandomInt(55, 80); break;
				case "c11m4_terminal":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 30);
					::hdmdWitchVars.witchflow2 = RandomInt(40, 65); break;
				case "c11m5_runway":
					::hdmdWitchVars.witchflow1 = RandomInt(102, 102); break;
				case "c12m1_hilltop":
					::hdmdWitchVars.witchflow1 = RandomInt(30, 50); break;
				case "c12m2_traintunnel":
					::hdmdWitchVars.witchflow1 = RandomInt(16, 16);
					::hdmdWitchVars.witchflow2 = RandomInt(33, 60); break;
				case "c12m3_bridge":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 30);
					::hdmdWitchVars.witchflow2 = RandomInt(30, 50);
					::hdmdWitchVars.witchflow3 = RandomInt(50, 70); break;
				case "c12m4_barn":
					::hdmdWitchVars.witchflow1 = RandomInt(10, 22);
					::hdmdWitchVars.witchflow2 = RandomInt(30, 45);
					::hdmdWitchVars.witchflow3 = RandomInt(45, 64); break;
				case "c12m5_cornfield":
					::hdmdWitchVars.witchflow1 = RandomInt(20, 50);
					::hdmdWitchVars.witchflow2 = RandomInt(50, 60);
					::hdmdWitchVars.witchflow3 = RandomInt(90, 90); break;
				case "c13m1_alpinecreek":
					::hdmdWitchVars.witchflow1 = RandomInt(35, 65); break;
				case "c13m2_southpinestream":
					::hdmdWitchVars.witchflow1 = RandomInt(102, 102); break;
				case "c13m3_memorialbridge":
					::hdmdWitchVars.witchflow1 = RandomInt(13, 40);
					::hdmdWitchVars.witchflow2 = RandomInt(78, 78); break;
				case "c13m4_cutthroatcreek":
					::hdmdWitchVars.witchflow1 = RandomInt(102, 102); break;
				case "c14m2_lighthouse":
					::hdmdWitchVars.witchflow1 = RandomInt(102, 102); break;
			}
		

			local max = 3;
			if(::hdmdWitchVars.witchflow3 == 0){max = 2;}
			if(::hdmdWitchVars.witchflow2 == 0){max = 1;}
			::hdmdWitchVars.witchpos1 = RandomInt(1, max);
			::hdmdWitchVars.witchpos2 = RandomInt(::hdmdWitchVars.witchpos1, max);

			if(::hdmdWitchVars.witchpos2 == 1 && ::hdmdWitchVars.witchflow2 != 0 && ::hdmdWitchVars.witchflow1 < 40)::hdmdWitchVars.witchpos2 = 2;

			switch(::hdmdWitchVars.witchpos1){
				case 1: ::hdmdWitchVars.witchpos1flow = ::hdmdWitchVars.witchflow1;break;
				case 2: ::hdmdWitchVars.witchpos1flow = ::hdmdWitchVars.witchflow2;break;
				case 3: ::hdmdWitchVars.witchpos1flow = ::hdmdWitchVars.witchflow3;break;
			}
			switch(::hdmdWitchVars.witchpos2){
				case 1: ::hdmdWitchVars.witchpos2flow = ::hdmdWitchVars.witchflow1;break;
				case 2: ::hdmdWitchVars.witchpos2flow = ::hdmdWitchVars.witchflow2;break;
				case 3: ::hdmdWitchVars.witchpos2flow = ::hdmdWitchVars.witchflow3;break;
			}
			//StringToFile("hardmode/witch/1.txt", ::hdmdWitchVars.witchpos1flow.tostring());
			//StringToFile("hardmode/witch/2.txt", ::hdmdWitchVars.witchpos2flow.tostring());

			::hdmdWitchVars.sessionDataBoss["witch1"] <- ::hdmdWitchVars.witchpos1flow;
			::hdmdWitchVars.sessionDataBoss["witch2"] <- ::hdmdWitchVars.witchpos2flow;

			SaveTable("manacat_hdmd_boss", ::hdmdWitchVars.sessionDataBoss);
		//	printl("플로우 세이브 탱크1 "+::hdmdWitchVars.witchpos1flow);printl("플로우 세이브 탱크2 "+::hdmdWitchVars.witchpos2flow);

			// local SearchPlayer = null;	local startArea = 0;
			// while (SearchPlayer = Entities.FindByClassname(SearchPlayer, "player")){
			// 	if(IsPlayerABot(SearchPlayer) || SearchPlayer.IsSurvivor() == false)continue;
			// 	startArea = NavMesh.GetNavArea(SearchPlayer.GetOrigin(), 60.0);
			// 	break;
			// }
			
			local distwitch = 999;	local distwitchpos = null;
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
						if(distwitch > flow){
							distwitch = flow;	distwitchpos = pos;
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
			//::hdmdWitchVars.witchpos1flow = FileToString("hardmode/witch/1.txt").tointeger();
			//::hdmdWitchVars.witchpos2flow = FileToString("hardmode/witch/2.txt").tointeger();

			RestoreTable("manacat_hdmd_boss", ::hdmdWitchVars.sessionDataBoss);

			::hdmdWitchVars.witchpos1flow = ::hdmdWitchVars.sessionDataBoss["witch1"];
			::hdmdWitchVars.witchpos2flow = ::hdmdWitchVars.sessionDataBoss["witch2"];
		//	printl("플로우 로드 탱크1 "+::hdmdWitchVars.witchpos1flow);printl("플로우 로드 탱크2 "+::hdmdWitchVars.witchpos2flow);
		}
		
		/*printl("탱크 스폰 정보");
		printl("1탱크 : "+::hdmdWitchVars.witchpos1+" "+::hdmdWitchVars.witchpos1flow);
		printl("2탱크 : "+::hdmdWitchVars.witchpos2+" "+::hdmdWitchVars.witchpos2flow);
		printl("플로우1 : "+::hdmdWitchVars.witchflow1);
		printl("플로우2 : "+::hdmdWitchVars.witchflow2);
		printl("플로우3 : "+::hdmdWitchVars.witchflow3);//*/

		::hdmdWitchVars.witchspawn1 = ::hdmdWitchFunc.witch_gen_flow(::hdmdWitchVars.witchpos1flow, 1);
		::hdmdWitchVars.witchspawn2 = ::hdmdWitchFunc.witch_gen_flow(::hdmdWitchVars.witchpos2flow, 2);
	}

	function witchHP(){
		local witchHealth = 4000;
		if(Director.IsFirstMapInScenario()){
			if(::hdmdState.lv <= 5)			witchHealth = 3000;
			else if(::hdmdState.lv == 6)	witchHealth = 3500;
			else if(::hdmdState.lv == 7)	witchHealth = 4000;
		}else if(::hdmdState.finale){
			if(::hdmdState.lv <= 5)			witchHealth = 4000;
			else if(::hdmdState.lv == 6)	witchHealth = 4250;
			else if(::hdmdState.lv == 7)	witchHealth = 4500;
		}else{
			if(::hdmdState.lv <= 5)			witchHealth = 4000;
			else if(::hdmdState.lv == 6)	witchHealth = 4500;
			else if(::hdmdState.lv == 7)	witchHealth = 5000;
		}

		if(::hdmdSurvVars.playerCount == 1)			witchHealth /= 2;
		else if(::hdmdSurvVars.playerCount == 2)	witchHealth /= 1.25;
		else if(::hdmdSurvVars.playerCount > 4){
			witchHealth *= 1+((::hdmdSurvVars.playerCount-4)/8);
		}

		switch(Convars.GetStr("z_difficulty").tolower()){
			case "impossible" :		witchHealth *= 2;	break;
			case "hard" :			witchHealth *= 1.6;	break;
			case "easy" :			witchHealth *= 0.8;	break;
		}
	//	printl("탱크 체력 " + witchHealth);
		if(::hdmdState.gamemode == 1)witchHealth *= 0.6;
		return witchHealth;
	}

	function witch_gen_flow(flow, witchn){
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
		local tgname = "witch"+witchn;
		local witchspawn = SpawnEntityFromTable("info_zombie_spawn",
		{
			targetname = tgname
			population = "Witch"
			origin = spawnOrigin
			angles = Vector(0,0,0)
			offer_witch = "1"
		});
	//	printl("탱크 위치 : "+spawnOrigin);

		return witchspawn;
	//	DoEntFire("!self", "SpawnZombie", "", 0.0, null, witchspawn);
	//	witchspawn.Kill();
	//	if(witchn == 1){
	//		::hdmdWitchVars.witch1spawnDone = true;
	//	}else if(witchn == 2){
	//		::hdmdWitchVars.witch2spawnDone = true;
	//	}
	}
}

::finaleWitch <- function(){
	//printl("피날레 분석");
	local doubleWitchFinale = false;
	for(local i = 1; i < 100; i++){
		try{
			if(DirectorScript.GetDirectorOptions()["A_CustomFinale"+i] == 1){
				if(::hdmdState.lv > 5 && DirectorScript.GetDirectorOptions()["A_CustomFinaleValue"+i] == 1){
					DirectorScript.GetDirectorOptions()["WitchLimit"] <- 2;
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
					doubleWitchFinale = true;
				}
			}
		}catch(e){
			if(e.find("does not exist") != null){
				//printl(e);
				break;
			}
		}
	}
	if(doubleWitchFinale == true){
		DirectorScript.GetDirectorOptions()["WitchLimit"] <- 2;
		Convars.SetValue("z_witch_health", 3500);
	}else{
		DirectorScript.GetDirectorOptions()["WitchLimit"] <- 1;
		Convars.SetValue("z_witch_health", 4000);
	}
}
/*
::witch_gen <- function(){
	if(::hdmdWitchVars.witchpos1flow == -102 || ::hdmdState.finale)return;
	local SearchPlayer = null;
	while (SearchPlayer = Entities.FindByClassname(SearchPlayer, "player")){
		if(IsPlayerABot(SearchPlayer) || !SearchPlayer.IsSurvivor())continue;
		
	//	printl("탱크1 "+::hdmdWitchVars.witchspawn1);
	//	printl(::hdmdWitchVars.witchspawn1 == null);
	//	printl(::hdmdWitchVars.witchspawn1.IsValid());
	//	printl("탱크2 "+::hdmdWitchVars.witchspawn2);
	//	printl(::hdmdWitchVars.witchspawn2 == null);
	//	printl(::hdmdWitchVars.witchspawn2.IsValid());

		local playerOrigin = SearchPlayer.GetOrigin();
		local playerflow = GetCurrentFlowPercentForPlayer(SearchPlayer);
		local playerArea = NavMesh.GetNearestNavArea(playerOrigin, 60.0, true, true);
		
		//1번 탱크
		if(::hdmdWitchVars.witchspawn1 != null && ::hdmdWitchVars.witchpos1flow != 102){
			local spawnOrigin = ::hdmdWitchVars.witchspawn1.GetOrigin();
			local dist1 = (playerOrigin - spawnOrigin).Length();
			local spawnArea = NavMesh.GetNavArea(spawnOrigin, 60.0);
			local dist2 = NavMesh.NavAreaBuildPath(spawnArea, playerArea, Vector(0, 0, 0), 3000.0, 3, false);
			if(dist1 < 1200 || (dist2 && playerflow > ::hdmdWitchVars.witchpos1flow-10)){
				DoEntFire("!self", "SpawnZombie", "", 0.0, null, ::hdmdWitchVars.witchspawn1);
				::hdmdWitchVars.witchspawn1.Kill();
				::hdmdWitchVars.witchspawn1 = null;
				if(::hdmdWitchVars.witchpos1flow == ::hdmdWitchVars.witchpos2flow
				&& ::hdmdWitchVars.witchspawn2 != null && ::hdmdWitchVars.witchpos2flow != 102 && ::hdmdState.lv >= 6){
					DoEntFire("!self", "SpawnZombie", "", 0.0, null, ::hdmdWitchVars.witchspawn2);
					::hdmdWitchVars.witchspawn2.Kill();
					::hdmdWitchVars.witchspawn2 = null;
				}
			}
		}

		//2번 탱크
		if(::hdmdWitchVars.witchspawn2 != null && ::hdmdWitchVars.witchpos2flow != 102 && ::hdmdState.lv >= 6){
			local spawnOrigin = ::hdmdWitchVars.witchspawn2.GetOrigin();
			local dist1 = (playerOrigin - spawnOrigin).Length();
			local spawnArea = NavMesh.GetNavArea(spawnOrigin, 60.0);
			local dist2 = NavMesh.NavAreaBuildPath(spawnArea, playerArea, Vector(0, 0, 0), 3000.0, 3, false);
			if(dist1 < 1200 || (dist2 && playerflow > ::hdmdWitchVars.witchpos2flow-10)){
				DoEntFire("!self", "SpawnZombie", "", 0.0, null, ::hdmdWitchVars.witchspawn2);
				::hdmdWitchVars.witchspawn2.Kill();
				::hdmdWitchVars.witchspawn2 = null;
				if(::hdmdWitchVars.witchpos1flow == ::hdmdWitchVars.witchpos2flow
				&& ::hdmdWitchVars.witchspawn1 != null && ::hdmdWitchVars.witchpos1flow != 102){
					DoEntFire("!self", "SpawnZombie", "", 0.0, null, ::hdmdWitchVars.witchspawn1);
					::hdmdWitchVars.witchspawn1.Kill();
					::hdmdWitchVars.witchspawn1 = null;
				}
			}
		}
	}
}
*/

__CollectEventCallbacks(::hdmdWitchFunc, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);