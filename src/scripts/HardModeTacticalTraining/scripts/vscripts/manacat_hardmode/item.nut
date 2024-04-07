::hdmdItemVars<-{
	kit2pills = 0 //진통제로 변환된 키트 수 (변환 수량을 제한해야 하므로)
	kit2pills_item = 0 //맵전환시 아이템 위치 기억

	pistolData = [] //현재 맵의 전환된 권총
	shotgunData = [] //현재 맵의 전환된 샷건
	rifleData = [] //현재 맵의 전환된 라플
	sniperData = [] //현재 맵의 전환된 스나
	weaponData = [] //현재 맵의 전환된 무기들 [0] = 너프된 무기 엔티티 | [1] = 원래 무기 클래스 | [2] = 원래 스킨
}

::hdmdItemFunc<-{
	function GetLandmarkOrigin(){
		local ent = null;	local landmark = "";
		while (ent = Entities.FindByClassname(ent, "info_changelevel")){
			if(ent.IsValid()){
				local name = NetProps.GetPropString(ent, "m_landmarkName");
				if(name != ""){
					landmark = name;	ent = null;	break;
				}
			}
		}
		while (ent = Entities.FindByClassname(ent, "info_landmark")){
			if(ent.IsValid()){
			//	printl("랜드마크 : "+ent)
				if(ent.GetName() == landmark){
					return [ent.GetOrigin(), ent.GetName()];
				}
			}
		}

		return false;
	}

	function kit2pills(){
		::hardmodeVars.itemData.clear();
		if(::hdmdState.lv <= 6)return;
		local mapName = Director.GetMapName();
		//if(mapName == "c4m3_sugarmill_b")return;

		local landmarkOrigin = ::hdmdItemFunc.GetLandmarkOrigin();
		if(landmarkOrigin != false){
			::hardmodeVars.itemData["landmark"] <- landmarkOrigin[1];
			landmarkOrigin = landmarkOrigin[0];
		}

		local function converWeapon(ent,convertClass,landmark){
			local pos = ent.GetOrigin();
			local ang = ent.GetAngles(); local angvec = Vector(ang.x,ang.y,ang.z);

			if(  ((-3 <= ang.x && ang.x <= 3) || (357 <= ang.x && ang.x <= 363)) && ((-3 <= ang.z && ang.z <= 3) || (357 <= ang.z && ang.z <= 363))  ){
				if(::hdmdItemVars.kit2pills == 0){pos = pos + ang.Left().Scale(2.5); angvec.y += 30;}
					SpawnEntityFromTable("prop_dynamic",
					{
						targetname = "hdmd_pills"
						model = "models/w_models/weapons/w_eq_painpills.mdl"
						origin = pos
						angles = angvec
					//	count = "1"
						solid = "0"
						spawnflags = "264"
					});
					::hardmodeVars.itemData["pills"+::hdmdItemVars.kit2pills_item] <- (landmark.x-pos.x)+":"+(landmark.y-pos.y)+":"+(landmark.z-pos.z)+":"+angvec.x+":"+angvec.y+":"+angvec.z;
					::hdmdItemVars.kit2pills_item++;
				if(::hdmdItemVars.kit2pills == 0){pos = pos + ang.Left().Scale(-5); angvec.y -= 60;
					SpawnEntityFromTable("prop_dynamic",
					{
						targetname = "hdmd_pills"
						model = "models/w_models/weapons/w_eq_painpills.mdl"
						origin = pos
						angles = angvec
					//	count = "1"
						solid = "0"
						spawnflags = "264"
					});
					::hardmodeVars.itemData["pills"+::hdmdItemVars.kit2pills_item] <- (landmark.x-pos.x)+":"+(landmark.y-pos.y)+":"+(landmark.z-pos.z)+":"+angvec.x+":"+angvec.y+":"+angvec.z;
					::hdmdItemVars.kit2pills_item++;
				}
			}else{
				pos.z += 3;
				if(::hdmdItemVars.kit2pills == 0){pos = pos + ang.Left().Scale(3); angvec.y += 30;}
					local item = SpawnEntityFromTable(convertClass,
					{
						targetname = "hdmd_pills"
						origin = pos
						angles = ang
						count = "1"
						solid = "6"
						spawnflags = "1"
					});
				local item2 = null;
				if(::hdmdItemVars.kit2pills == 0){pos = pos + ang.Left().Scale(-6); angvec.y -= 60; angvec.x = 0; angvec.z = 0; pos.z -= 2;
					item2 = SpawnEntityFromTable(convertClass,
					{
						targetname = "hdmd_pills"
						origin = pos
						angles = ang
						count = "1"
						solid = "6"
						spawnflags = "1"
					});
				}

				local function fixitem(params){
					local tgitem = params["ent"];
					local num = params["num"];
					local landmark = params["lm"];
					local pos = tgitem.GetOrigin();
					local ang = tgitem.GetAngles(); local angvec = Vector(ang.x,ang.y,ang.z);

					if(num == 2){ang.x = 0;ang.z = 0;}

					local fixitem = SpawnEntityFromTable("prop_dynamic",
					{
						targetname = "hdmd_pills"
						model = "models/w_models/weapons/w_eq_painpills.mdl"
						origin = pos
						angles = angvec
					//	count = "1"
						solid = "0"
						spawnflags = "264"
					});
					if(::hardmodeFunc.standCheck(fixitem)){
						angvec = Vector(0, angvec.y, 0);
						fixitem.SetAngles(QAngle(0, angvec.y, 0));
					}
					::hardmodeVars.itemData["pills"+::hdmdItemVars.kit2pills_item] <- (landmark.x-pos.x)+":"+(landmark.y-pos.y)+":"+(landmark.z-pos.z)+":"+angvec.x+":"+angvec.y+":"+angvec.z;
					::hdmdItemVars.kit2pills_item++;
					tgitem.Kill();
				}
				::manacatAddTimer(0.8, false, fixitem, { ent = item, num = 1, lm = landmark });
				if(::hdmdItemVars.kit2pills == 0)::manacatAddTimer(0.8, false, fixitem, { ent = item2, num = 2, lm = landmark });
			}
			local pos = ent.GetOrigin();
			local ang = ent.GetAngles();
			local angvec = Vector(ang.x, ang.y, ang.z);

			::hardmodeVars.itemData["kits"+::hdmdItemVars.kit2pills_item] <- (landmark.x-pos.x)+":"+(landmark.y-pos.y)+":"+(landmark.z-pos.z)+":"+angvec.x+":"+angvec.y+":"+angvec.z;
			::hdmdItemVars.kit2pills_item++;
			ent.Kill();
		}

		local ent = null;
		while(ent = Entities.FindByClassname(ent, "weapon_*spawn")){
			if(ent.GetModelName() == "models/w_models/weapons/w_eq_Medkit.mdl"){
				if((mapName != "c5m4_quarter" && ::hdmdItemVars.kit2pills == 2) || (mapName == "c5m4_quarter" && ::hdmdItemVars.kit2pills == 5))return;
				local tgent = null; local near = false;
				while (tgent = Entities.FindByClassname(tgent, "player")){
					if(tgent.IsValid())if(tgent.IsSurvivor()){
						local dist = (tgent.GetOrigin() - ent.GetOrigin()).Length();
						if(dist < 1500){
							near = true;
							break;
						}
					}
				}
				if(near)continue;
				local location = NavMesh.GetNearestNavArea(ent.GetOrigin(), 150.0, true, true);
				local chkpoint = false;
				if(location == null)continue;
				if(location != null && location.HasSpawnAttributes(2048))chkpoint = true;

				if(chkpoint){
					converWeapon(ent,"weapon_pain_pills_spawn", landmarkOrigin);
					::hdmdItemVars.kit2pills++;
				}
			}
		}
	}

	function item_restore(params){
	//	if(::hdmdState.spawnCheckpointItem)return;
	//	::hdmdState.spawnCheckpointItem = true;
		RestoreTable("hdmd_item", ::hardmodeVars.itemData);
		if(::hardmodeVars.itemData.len() == 0 || (Director.IsSessionStartMap() && Time() < 10)){
			::hardmodeVars.itemData.clear();
		}else{
			local ent = null;
		/*	while (ent = Entities.FindByClassname(ent, "weapon_tank_claw")){
				if(ent.IsValid() && ent.GetName() == "hdmd_restore_mark")return;
			}
			local n = SpawnEntityFromTable("weapon_tank_claw",
			{
				targetname = "hdmd_restore_mark"
				origin = params.pos
				angles = Vector(0,0,0)
				spawnflags = "5" //Fix
				solid = "1"
			});
			NetProps.SetPropInt( n, "m_nModelIndex", 0); //Disable the model//*/
			if("landmark" in ::hardmodeVars.itemData){
				ent = null;	local landmarkOrigin = null;
				while (ent = Entities.FindByClassname(ent, "info_landmark")){
					if(ent.IsValid()){
						if(ent.GetName() == ::hardmodeVars.itemData["landmark"]){
							::hardmodeVars.itemData["landmark"] <- ent.GetName();
							landmarkOrigin = ent.GetOrigin();	break;
						}
					}
				}
				if(landmarkOrigin != null){
					if(::hdmdState.lv >= 7){
						for(local i = 0; i < 7; i++){
							if("pills"+i in ::hardmodeVars.itemData){
								local pills = split(::hardmodeVars.itemData["pills"+i], ":");
								local pos = landmarkOrigin-Vector(pills[0].tofloat(), pills[1].tofloat(), pills[2].tofloat());
								local ang = Vector(pills[3].tofloat(), pills[4].tofloat(), pills[5].tofloat());
								if(::hardmodeVars.itemData["landmark"] == "coldstream3_coldstream4"){
									pos = landmarkOrigin+Vector(pills[0].tofloat(), pills[1].tofloat(), 0);
									pos.z = landmarkOrigin.z-pills[2].tofloat();
									ang = Vector(ang.x, pills[4].tofloat()+180, ang.z);
								}
								local nearItem = Entities.FindByClassnameNearest("weapon_pain_pills_spawn", pos, 1.0);
								if(nearItem == null || nearItem.GetName() != "hdmd_pills"){
									SpawnEntityFromTable("weapon_pain_pills_spawn",
									{
										targetname = "hdmd_pills"
										origin = pos
										angles = ang
										spawnflags = "6"
										solid = "4"
									});
								}
							}
						}
					}else{
						for(local i = 0; i < 7; i++){
							if("kits"+i in ::hardmodeVars.itemData){
								local kits = split(::hardmodeVars.itemData["kits"+i], ":");
								local pos = landmarkOrigin-Vector(kits[0].tofloat(), kits[1].tofloat(), kits[2].tofloat());
								local ang = Vector(kits[3].tofloat(), kits[4].tofloat(), kits[5].tofloat());
								if(::hardmodeVars.itemData["landmark"] == "coldstream3_coldstream4"){
									pos = landmarkOrigin+Vector(kits[0].tofloat(), kits[1].tofloat(), 0);
									pos.z = landmarkOrigin.z-kits[2].tofloat();
									ang = Vector(ang.x, kits[4].tofloat()+180, ang.z);
								}
								local nearItem = Entities.FindByClassnameNearest("weapon_first_aid_kit_spawn", pos, 1.0);
								if(nearItem == null || nearItem.GetName() != "hdmd_kits"){
									SpawnEntityFromTable("weapon_first_aid_kit_spawn",
									{
										targetname = "hdmd_kits"
										origin = pos
										angles = ang
										spawnflags = "6"
										solid = "4"
									});
								}
							}
						}
					}
				}
			}
		}
		SaveTable("hdmd_item", ::hardmodeVars.itemData);
	}

	function weapon_pistol(){
		::hardmodeVars.pistolData.clear();
		local mapName = Director.GetMapName();
		//if(mapName == "c4m3_sugarmill_b")return;

		if(::hdmdState.pistol == 1){
			//너프
			::hdmdItemFunc.weapon_multi_nerf(["models/w_models/weapons/w_desert_eagle.mdl"],
				["weapon_pistol_spawn"], "pistol", 0);
			::hdmdItemFunc.weapon_single_nerf(["models/w_models/weapons/w_desert_eagle.mdl"],
				["models/v_models/v_desert_eagle.mdl"],
				["weapon_pistol"], 0, 0);
		}else{
			//복구
			::hdmdItemFunc.weapon_multi_restore("pistol",
				["weapon_pistol_magnum_spawn"]);
			::hdmdItemFunc.weapon_single_restore(0);
		}
	}

	function weapon_shotgun(){
		::hardmodeVars.shotgunData.clear();
		local mapName = Director.GetMapName();
		//if(mapName == "c4m3_sugarmill_b")return;

		if(::hdmdState.shotgun == 1){
			//너프
			::hdmdItemFunc.weapon_multi_nerf(["models/w_models/weapons/w_autoshot_m4super.mdl", "models/w_models/weapons/w_shotgun_spas.mdl"],
				["weapon_pumpshotgun_spawn", "weapon_shotgun_chrome_spawn"], "shotgun", 0);
			::hdmdItemFunc.weapon_single_nerf(["models/w_models/weapons/w_autoshot_m4super.mdl", "models/w_models/weapons/w_shotgun_spas.mdl"],
				["models/v_models/v_autoshotgun.mdl", "models/v_models/v_shotgun_spas.mdl"],
				["weapon_pumpshotgun", "weapon_shotgun_chrome"], 1, 0);
		}else{
			//복구
			::hdmdItemFunc.weapon_multi_restore("shotgun",
				["weapon_autoshotgun_spawn", "weapon_shotgun_spas_spawn"]);
			::hdmdItemFunc.weapon_single_restore(1);
		}
	}

	function weapon_rifle(){
		::hardmodeVars.rifleData.clear();
		local mapName = Director.GetMapName();
		//if(mapName == "c4m3_sugarmill_b")return;

		if(::hdmdState.rifle == 1){
			//너프
			::hdmdItemFunc.weapon_multi_nerf(["models/w_models/weapons/w_rifle_m16a2.mdl", "models/w_models/weapons/w_rifle_ak47.mdl", "models/w_models/weapons/w_desert_rifle.mdl", "models/w_models/weapons/w_rifle_sg552.mdl"],
				["weapon_smg_spawn", "weapon_smg_silenced_spawn"], "rifle", 2);
			::hdmdItemFunc.weapon_single_nerf(["models/w_models/weapons/w_rifle_m16a2.mdl", "models/w_models/weapons/w_rifle_ak47.mdl", "models/w_models/weapons/w_desert_rifle.mdl", "models/w_models/weapons/w_rifle_sg552.mdl"],
				["models/v_models/v_rifle.mdl", "models/v_models/v_rifle_AK47.mdl", "models/v_models/v_desert_rifle.mdl", "models/v_models/v_rif_sg552.mdl"],
				["weapon_smg", "weapon_smg_silenced"], 2, 2);
		}else{
			//복구
			::hdmdItemFunc.weapon_multi_restore("rifle",
				["weapon_rifle_spawn", "weapon_rifle_ak47_spawn", "weapon_rifle_desert_spawn", "weapon_rifle_sg552_spawn"]);
			::hdmdItemFunc.weapon_single_restore(2);
		}
	}

	function weapon_sniper(){
		::hardmodeVars.sniperData.clear();
		local mapName = Director.GetMapName();
		//if(mapName == "c4m3_sugarmill_b")return;

		if(::hdmdState.sniper == 1){
			//너프
			::hdmdItemFunc.weapon_multi_nerf(["models/w_models/weapons/w_sniper_mini14.mdl", "models/w_models/weapons/w_sniper_military.mdl", "models/w_models/weapons/w_sniper_awp.mdl"],
				["weapon_sniper_scout_spawn"], "sniper", 0);
			::hdmdItemFunc.weapon_single_nerf(["models/w_models/weapons/w_sniper_mini14.mdl", "models/w_models/weapons/w_sniper_military.mdl", "models/w_models/weapons/w_sniper_awp.mdl"],
				["models/v_models/v_huntingrifle.mdl", "models/v_models/v_sniper_military.mdl", "models/v_models/v_snip_awp.mdl"],
				["weapon_sniper_scout"], 3, 0);
		}else{
			//복구
			::hdmdItemFunc.weapon_multi_restore("sniper",
				["weapon_hunting_rifle_spawn", "weapon_sniper_military_spawn", "weapon_sniper_awp_spawn"]);
			::hdmdItemFunc.weapon_single_restore(3);
		}
	}

	function weapon_single(params = {}){
		local ptypes = ["weapon_pistol", "weapon_smg", "weapon_smg_silenced", "weapon_pumpshotgun", "weapon_shotgun_chrome", "weapon_sniper_scout"];
		local gtypes = ["weapon_pistol_magnum", "weapon_rifle", "weapon_rifle_sg552", "weapon_rifle_ak47", "weapon_rifle_desert", "weapon_autoshotgun", "weapon_shotgun_spas", "weapon_hunting_rifle", "weapon_sniper_military", "weapon_sniper_awp"];
		RestoreTable("hdmd_weapon", ::hardmodeVars.weaponData);
		SaveTable("hdmd_weapon", ::hardmodeVars.weaponData);
		if(::hardmodeVars.weaponData.len() == 0 || (Director.IsSessionStartMap() && Time() < 10)){
			::hardmodeVars.weaponData.clear();
		}else{
			local ent = null;
			if("landmark" in ::hardmodeVars.weaponData){
				ent = null;	local landmarkOrigin = null;
				while (ent = Entities.FindByClassname(ent, "info_landmark")){
					if(ent.IsValid()){
						if(ent.GetName() == ::hardmodeVars.weaponData["landmark"]){
							::hardmodeVars.weaponData["landmark"] <- ent.GetName();
							landmarkOrigin = ent.GetOrigin();	break;
						}
					}
				}
				if(landmarkOrigin != null){
					for(local i = 0; i < 100; i++){
						if("weapon"+i in ::hardmodeVars.weaponData){
							local weapon = split(::hardmodeVars.weaponData["weapon"+i], ":");
							local pos = landmarkOrigin-Vector(weapon[0].tofloat(), weapon[1].tofloat(), weapon[2].tofloat());
							local ang = Vector(weapon[3].tofloat(), weapon[4].tofloat(), weapon[5].tofloat());
							if(::hardmodeVars.weaponData["landmark"] == "coldstream3_coldstream4"){
								pos = landmarkOrigin+Vector(weapon[0].tofloat(), weapon[1].tofloat(), 0);
								pos.z = landmarkOrigin.z-weapon[2].tofloat();
								ang = Vector(ang.x, weapon[4].tofloat()+180, ang.z);
							}
							local nearItem = Entities.FindByClassnameNearest(ptypes[weapon[6].tointeger()], pos, 20.0);
							if(nearItem != null && nearItem.GetHealth() == 0){
								nearItem.SetHealth(1);
								::hdmdItemVars.weaponData.append([nearItem, gtypes[weapon[7].tointeger()], weapon[8].tointeger(), weapon[9].tointeger()]);
							}
						}
					}
				}
			}
		}
	}

	function weapon_single_owner(player){
		local ptypes = ["weapon_pistol", "weapon_smg", "weapon_smg_silenced", "weapon_pumpshotgun", "weapon_shotgun_chrome", "weapon_sniper_scout"];
		local gtypes = ["weapon_pistol_magnum", "weapon_rifle", "weapon_rifle_sg552", "weapon_rifle_ak47", "weapon_rifle_desert", "weapon_autoshotgun", "weapon_shotgun_spas", "weapon_hunting_rifle", "weapon_sniper_military", "weapon_sniper_awp"];
		if(player == null || !player.IsValid())return;
		RestoreTable("hdmd_weapon", ::hardmodeVars.weaponData);
		SaveTable("hdmd_weapon", ::hardmodeVars.weaponData);
		local pmodel = player.GetModelName();
		for(local i = 0; i < 10; i++){
			if("weapon_owner"+i in ::hardmodeVars.weaponData){
				local weapon = split(::hardmodeVars.weaponData["weapon_owner"+i], ":");
				if(weapon[0] == pmodel){
					local ptype = ptypes[weapon[1].tointeger()];
					local invTable = {};	local weapon_restore = null;
					GetInvTable(player, invTable);
					if(ptype == "weapon_pistol" || ptype == "weapon_pistol_magnum"){
						if(!("slot1" in invTable))continue;
						weapon_restore = invTable.slot1;
					}else{
						if(!("slot0" in invTable))continue;
						weapon_restore = invTable.slot0;
					}
					if(weapon_restore != null)::hdmdItemVars.weaponData.append([weapon_restore, gtypes[weapon[2].tointeger()], weapon[3].tointeger(), weapon[4].tointeger()]);
				}
			}
		}
	}

	function weaponCall(params){
		::hdmdItemFunc.weapon_single({});
		//↑다른건 좌표만 가지고 있다가 변환할때 찾는 거라 상관없지만 이건 무기엔티티를 직접 링크해서 갖고 있어야 하기 때문에 무기가 생성되기 전에 시도하면 링크할 엔티티를 찾지 못한다
		::hdmdItemFunc.weapon_pistol();
		::hdmdItemFunc.weapon_shotgun();
		::hdmdItemFunc.weapon_rifle();
		::hdmdItemFunc.weapon_sniper();
	}

	function weapon_restore(){
		local list = ["pistol", "shotgun", "rifle", "sniper"]

		for(local i = 0; i < 4; i++){
			local tableName = "hdmd_"+list[i];
			local tname = list[i]+"Data";
			RestoreTable(tableName, ::hardmodeVars[tname]);
			if(::hardmodeVars[tname].len() == 0 || (Director.IsSessionStartMap() && Time() < 10)){
				::hardmodeVars[tname].clear();
			}else{
				local ent = null;
				if("landmark" in ::hardmodeVars[tname]){
					ent = null;	local landmarkOrigin = null;
					while (ent = Entities.FindByClassname(ent, "info_landmark")){
						if(ent.IsValid()){
							if(ent.GetName() == ::hardmodeVars[tname]["landmark"]){
								::hardmodeVars[tname]["landmark"] <- ent.GetName();
								landmarkOrigin = ent.GetOrigin();	break;
							}
						}
					}
					if(landmarkOrigin != null){
						for(local i = 0; i < 100; i++){
							if("weapon"+i in ::hardmodeVars[tname]){
								local weapon = split(::hardmodeVars[tname]["weapon"+i], ":");
								local pos = landmarkOrigin-Vector(weapon[0].tofloat(), weapon[1].tofloat(), weapon[2].tofloat());
								local ang = Vector(weapon[3].tofloat(), weapon[4].tofloat(), weapon[5].tofloat());
								if(::hardmodeVars[tname]["landmark"] == "coldstream3_coldstream4"){
									pos = landmarkOrigin+Vector(weapon[0].tofloat(), weapon[1].tofloat(), 0);
									pos.z = landmarkOrigin.z-weapon[2].tofloat();
									ang = Vector(ang.x, weapon[4].tofloat()+180, ang.z);
								}
								::hdmdItemVars[tname].append(pos.x+":"+pos.y+":"+pos.z+":"+ang.x+":"+ang.y+":"+ang.z+":"+weapon[6]+":"+weapon[7]+":"+weapon[8]+":1:-");
							}
						}
					}
				}
			}
			SaveTable(tableName, ::hardmodeVars[tname]);
		}
	}

	function weapon_multi_nerf(w_models, ptypes, wtype, skinR = 0){
		local list = wtype+"Data";
		local landmarkOrigin = ::hdmdItemFunc.GetLandmarkOrigin();
		if(landmarkOrigin != false){
			::hardmodeVars[list]["landmark"] <- landmarkOrigin[1];
			landmarkOrigin = landmarkOrigin[0];
		}
		local ent = null;	local itemN = 0;
		while(ent = Entities.FindByClassname(ent, "weapon_*_spawn")){
			if(!ent.IsValid() || ent.GetClassname().find("_spawn") == null)continue;
			local model = ent.GetModelName();	local gtype = w_models.find(model);

			if( gtype != null ){
				local pos = ent.GetOrigin();
				local ang = ent.GetAngles(); ang = Vector(ang.x,ang.y,ang.z);
				local len = ptypes.len();	local ptype = ptypes[RandomInt(0,len-1)];
				if(skinR == 0)skinR++;		local skinV = RandomInt(0,skinR-1);

				local location = NavMesh.GetNearestNavArea(pos, 150.0, true, true);	local chkpoint = 0;
				if(location != null && landmarkOrigin != false && location.HasSpawnAttributes(2048)){
					::hardmodeVars[list]["weapon"+itemN] <- (landmarkOrigin.x-pos.x)+":"+(landmarkOrigin.y-pos.y)+":"+(landmarkOrigin.z-pos.z)+":"+ang.x+":"+ang.y+":"+ang.z+":"+ptype+":"+gtype+":"+NetProps.GetPropInt(ent, "m_nWeaponSkin")+":1";
					itemN++;	chkpoint = 1;
				}
				::hdmdItemVars[list].append(pos.x+":"+pos.y+":"+pos.z+":"+ang.x+":"+ang.y+":"+ang.z+":"+ptype+":"+gtype+":"+NetProps.GetPropInt(ent, "m_nWeaponSkin")+":"+chkpoint);

				local countV = NetProps.GetPropInt(ent, "m_itemCount");
				SpawnEntityFromTable(ptype,
				{
					targetname = "hdmd_weapon"
					origin = pos, angles = ang
					spawnflags = "0"
					solid = "6"
					count = countV, skin = skinV, weaponskin = skinV
				});
				ent.Kill();
			}
		}
	}

	function weapon_multi_restore(wtype, ptypes){
		local list = wtype+"Data";
		local len = ::hdmdItemVars[list].len();
		for(local i = 0; i < len; i++){				//printl(::hdmdItemVars[list][i]);
			local weapon = split(::hdmdItemVars[list][i], ":");
			local pos = Vector(weapon[0].tofloat(), weapon[1].tofloat(), weapon[2].tofloat());
			local ang = Vector(weapon[3].tofloat(), weapon[4].tofloat(), weapon[5].tofloat());
			local nearItem = Entities.FindByClassnameNearest(weapon[6], pos, 1.0);
			if(weapon[9] == "1")nearItem = Entities.FindByClassnameNearest(weapon[6], pos, 10.0);
			local skinV = weapon[8];	if(skinV.tointeger() < 0)skinV = "0";
			if(nearItem != null && nearItem.GetHealth() == 0){
				nearItem.SetHealth(1);
				local countV = NetProps.GetPropInt(nearItem, "m_itemCount");
				nearItem.Kill();
				SpawnEntityFromTable(ptypes[weapon[7].tointeger()],
				{
					targetname = "hdmd_weapon"
					origin = pos, angles = ang
					spawnflags = "0"
					solid = "6"
					count = countV, skin = skinV, weaponskin = skinV
				});
			}
		}
		::hdmdItemVars[list] = [];
	}

	function weapon_single_nerf(w_models, v_models, ptypes, wtype, skinR = 0){//wtype 0 = 권총 | 1 = 샷건 | 2 = 라이플 | 3 = 스나
		local ent = null;
		while(ent = Entities.FindByClassname(ent, "weapon_*")){
			if(!ent.IsValid() || ent.GetHealth() != 0 || ent.GetClassname().find("_spawn") != null)continue;
			local model = ent.GetModelName();	local classname = ent.GetClassname();
			local weapon = null;	local weaponSkin = 0;

			local len = ptypes.len();	local ptype = ptypes[RandomInt(0,len-1)];
			if(skinR == 0)skinR++;		local skinV = RandomInt(0,skinR-1);

			if( w_models.find(model) != null ){
				local pos = ent.GetOrigin();	pos.z += 5;
				local ang = ent.GetAngles();	ang = Vector(ang.x, ang.y, ang.z);
				local flags = NetProps.GetPropInt(ent, "m_spawnflags");
				weapon = SpawnEntityFromTable(ptype,
				{
					targetname = "hdmd_weapon"
					origin = pos, angles = ang
					spawnflags = flags
					solid = "6"
					skin = skinV, weaponskin = skinV
				});
				local impulseVec = weapon.GetVelocity();	impulseVec.z += 160;
				weapon.ApplyAbsVelocityImpulse(impulseVec);
			}else
			if( v_models.find(model) != null ){
				local owner = NetProps.GetPropEntity(ent, "m_hOwner");
				local ammotype_old = NetProps.GetPropInt( ent, "m_iPrimaryAmmoType" );
				local ammo_old = NetProps.GetPropIntArray( owner, "m_iAmmo", ammotype_old );
				owner.GiveItem(ptype);
				local invTable = {};
				GetInvTable(owner, invTable);
				if(ammotype_old != 1 && ammotype_old != 2){
					if(!("slot0" in invTable))continue;
					weapon = invTable.slot0;
					local ammotype = NetProps.GetPropInt( weapon, "m_iPrimaryAmmoType" );
					local ammo = ::hdmdItemFunc.ammo_scale(NetProps.GetPropInt(ent, "m_iClip1"), ammo_old, ent.GetClassname(), weapon.GetClassname());
					if(ammo != false)NetProps.SetPropIntArray( owner, "m_iAmmo", ammo[1], ammotype );
				}else{
					if(!("slot1" in invTable))continue;
					weapon = invTable.slot1;
				}
			}

			if(weapon != null){
				weaponSkin = NetProps.GetPropInt(ent, "m_nWeaponSkin");
				local ammo = ::hdmdItemFunc.ammo_scale(NetProps.GetPropInt(ent, "m_iClip1"), NetProps.GetPropInt(ent, "m_iExtraPrimaryAmmo"), ent.GetClassname(), weapon.GetClassname());
				if(ammo != false){
					NetProps.SetPropInt( weapon, "m_iClip1", ammo[0] );
					NetProps.SetPropInt( weapon, "m_iExtraPrimaryAmmo", ammo[1] );
				}
				ent.SetHealth(1);	ent.Kill();
				::hdmdItemVars.weaponData.append([weapon, classname, weaponSkin, wtype]);
			}
		}
	}

	function weapon_single_restore(wtype){//wtype 0 = 권총 | 1 = 샷건 | 2 = 라이플 | 3 = 스나
		RestoreTable("hdmd_weapon", ::hardmodeVars.weaponData);
		SaveTable("hdmd_weapon", ::hardmodeVars.weaponData);
		local len = ::hdmdItemVars.weaponData.len();
		for(local i = 0; i < len; i++){
			if(::hdmdItemVars.weaponData[i][3] != wtype)continue;
			local weapon = ::hdmdItemVars.weaponData[i];
			if(weapon[0] != null && weapon[0].IsValid()){
				local owner = NetProps.GetPropEntity(weapon[0], "m_hOwner");
				if(owner == null){
					local pos = weapon[0].GetOrigin();	pos.z += 5;
					local ang = weapon[0].GetAngles();	ang = Vector(ang.x, ang.y, ang.z);
					local skinV = weapon[2];	if(skinV < 0)skinV = 0;
					local weapon_restore = SpawnEntityFromTable(weapon[1],
					{
						targetname = "hdmd_weapon"
						origin = pos, angles = ang
						spawnflags = "0"
						solid = "6"
						skin = skinV, weaponskin = skinV
					});
					local impulseVec = weapon_restore.GetVelocity();	impulseVec.z += 160;
					weapon_restore.ApplyAbsVelocityImpulse(impulseVec);
					local ammo = ::hdmdItemFunc.ammo_scale(NetProps.GetPropInt(weapon[0], "m_iClip1"), NetProps.GetPropInt(weapon[0], "m_iExtraPrimaryAmmo"), weapon[0].GetClassname(), weapon[1]);
					if(ammo != false){
						NetProps.SetPropInt( weapon_restore, "m_iClip1", ammo[0] );
						NetProps.SetPropInt( weapon_restore, "m_iExtraPrimaryAmmo", ammo[1] );
					}
				}else{
					local ammotype_old = NetProps.GetPropInt( weapon[0], "m_iPrimaryAmmoType" );
					local ammo_old = NetProps.GetPropIntArray( owner, "m_iAmmo", ammotype_old );
					owner.GiveItem(weapon[1]);
					local invTable = {};
					GetInvTable(owner, invTable);
					if(ammotype_old != 1 && ammotype_old != 2){
						weapon_restore = invTable.slot0;
						local ammotype = NetProps.GetPropInt( weapon_restore, "m_iPrimaryAmmoType" );
						local ammo = ::hdmdItemFunc.ammo_scale(NetProps.GetPropInt(weapon[0], "m_iClip1"), ammo_old, weapon[0].GetClassname(), weapon[1]);
						if(ammo != false){
							NetProps.SetPropInt( weapon_restore, "m_iClip1", ammo[0] );
							NetProps.SetPropIntArray( owner, "m_iAmmo", ammo[1], ammotype );
						}
					}else{
						weapon_restore = invTable.slot1;
					}
				}
				weapon[0].Kill();
			}
		}
		len = ::hdmdItemVars.weaponData.len();
		for(local i = 0; i < len; i++){
			if(!::hdmdItemVars.weaponData[i][0].IsValid()){
				::hdmdItemVars.weaponData.remove(i);	i--;	len--;
			}
		}
	}

	function save_weapon(){
		local ptypes = ["weapon_pistol", "weapon_smg", "weapon_smg_silenced", "weapon_pumpshotgun", "weapon_shotgun_chrome", "weapon_sniper_scout"];
		local gtypes = ["weapon_pistol_magnum", "weapon_rifle", "weapon_rifle_sg552", "weapon_rifle_ak47", "weapon_rifle_desert", "weapon_autoshotgun", "weapon_shotgun_spas", "weapon_hunting_rifle", "weapon_sniper_military", "weapon_sniper_awp"];
					
		::hardmodeVars.weaponData.clear();
		local landmarkOrigin = ::hdmdItemFunc.GetLandmarkOrigin();
		if(landmarkOrigin != false){
			::hardmodeVars.weaponData["landmark"] <- landmarkOrigin[1];
			landmarkOrigin = landmarkOrigin[0];
		}
		local len = ::hdmdItemVars.weaponData.len();	local itemN = 0;	local itemO = 0;
		for(local i = 0; i < len; i++){
			local weapon = ::hdmdItemVars.weaponData.remove(0);
			if(weapon[0].IsValid()){
				local owner = NetProps.GetPropEntity(weapon[0], "m_hOwner");
				if(owner == null){
					local location = NavMesh.GetNearestNavArea(weapon[0].GetOrigin(), 150.0, true, true);
					local chkpoint = false;
					if(location == null)continue;
					if(location != null && location.HasSpawnAttributes(2048)){
						local pos = weapon[0].GetOrigin();
						local ang = weapon[0].GetAngles(); ang = Vector(ang.x,ang.y,ang.z);
						::hardmodeVars.weaponData["weapon"+itemN] <- (landmarkOrigin.x-pos.x)+":"+(landmarkOrigin.y-pos.y)+":"+(landmarkOrigin.z-pos.z)+":"+ang.x+":"+ang.y+":"+ang.z+":"+ptypes.find(weapon[0].GetClassname())+":"+gtypes.find(weapon[1])+":"+weapon[2]+":"+weapon[3];
						itemN++;
					}
				}else{
					::hardmodeVars.weaponData["weapon_owner"+itemO] <- owner.GetModelName()+":"+ptypes.find(weapon[0].GetClassname())+":"+gtypes.find(weapon[1])+":"+weapon[2]+":"+weapon[3];
					itemO++;
				}
			}
		}
		SaveTable("hdmd_weapon", ::hardmodeVars.weaponData);
	}

	function ammo_scale(clip, ammo, beforeW, afterW){
		if(beforeW == "weapon_pistol" || beforeW == "weapon_pistol_magnum")return false;
		local clip_max = 0;	local ammo_max = 0;
		switch(beforeW){
			case "weapon_smg":case "weapon_smg_silenced":case "weapon_smg_mp5":case "weapon_smg_spawn":case "weapon_smg_silenced_spawn":case "weapon_smg_mp5_spawn":
				clip_max = 50;ammo_max = Convars.GetFloat("ammo_smg_max");break;
			case "weapon_rifle":case "weapon_rifle_spawn":case "weapon_rifle_sg552":case "weapon_rifle_sg552_spawn":
				clip_max = 50;ammo_max = Convars.GetFloat("ammo_assaultrifle_max");break;
			case "weapon_rifle_desert":case "weapon_rifle_desert_spawn":
				clip_max = 60;ammo_max = Convars.GetFloat("ammo_assaultrifle_max");break;
			case "weapon_rifle_ak47":case "weapon_rifle_ak47_spawn":
				clip_max = 40;ammo_max = Convars.GetFloat("ammo_assaultrifle_max");break;
			case "weapon_hunting_rifle":case "weapon_hunting_rifle_spawn":
				clip_max = 15;ammo_max = Convars.GetFloat("ammo_huntingrifle_max");break;
			case "weapon_sniper_scout":case "weapon_sniper_scout_spawn":
				clip_max = 15;ammo_max = Convars.GetFloat("ammo_sniperrifle_max");break;
			case "weapon_sniper_military":case "weapon_sniper_military_spawn":
				clip_max = 30;ammo_max = Convars.GetFloat("ammo_sniperrifle_max");break;
			case "weapon_sniper_awp":case "weapon_sniper_awp_spawn":
				clip_max = 20;ammo_max = Convars.GetFloat("ammo_sniperrifle_max");break;
			case "weapon_pumpshotgun":case "weapon_shotgun_chrome":case "weapon_pumpshotgun_spawn":case "weapon_shotgun_chrome_spawn":
				clip_max = 8;ammo_max = Convars.GetFloat("ammo_shotgun_max");break;
			case "weapon_autoshotgun":case "weapon_shotgun_spas":case "weapon_autoshotgun_spawn":case "weapon_shotgun_spas_spawn":
				clip_max = 10;ammo_max = Convars.GetFloat("ammo_autoshotgun_max");break;
		}
		local clip_p = clip.tofloat()/clip_max*100;local ammo_p = ammo.tofloat()/ammo_max*100;
		switch(afterW){
			case "weapon_smg":case "weapon_smg_silenced":case "weapon_smg_mp5":case "weapon_smg_spawn":case "weapon_smg_silenced_spawn":case "weapon_smg_mp5_spawn":
				clip_max = 50;ammo_max = Convars.GetFloat("ammo_smg_max");break;
			case "weapon_rifle":case "weapon_rifle_spawn":case "weapon_rifle_sg552":case "weapon_rifle_sg552_spawn":
				clip_max = 50;ammo_max = Convars.GetFloat("ammo_assaultrifle_max");break;
			case "weapon_rifle_desert":case "weapon_rifle_desert_spawn":
				clip_max = 60;ammo_max = Convars.GetFloat("ammo_assaultrifle_max");break;
			case "weapon_rifle_ak47":case "weapon_rifle_ak47_spawn":
				clip_max = 40;ammo_max = Convars.GetFloat("ammo_assaultrifle_max");break;
			case "weapon_hunting_rifle":case "weapon_hunting_rifle_spawn":
				clip_max = 15;ammo_max = Convars.GetFloat("ammo_huntingrifle_max");break;
			case "weapon_sniper_scout":case "weapon_sniper_scout_spawn":
				clip_max = 15;ammo_max = Convars.GetFloat("ammo_sniperrifle_max");break;
			case "weapon_sniper_military":case "weapon_sniper_military_spawn":
				clip_max = 30;ammo_max = Convars.GetFloat("ammo_sniperrifle_max");break;
			case "weapon_sniper_awp":case "weapon_sniper_awp_spawn":
				clip_max = 20;ammo_max = Convars.GetFloat("ammo_sniperrifle_max");break;
			case "weapon_pumpshotgun":case "weapon_shotgun_chrome":case "weapon_pumpshotgun_spawn":case "weapon_shotgun_chrome_spawn":
				clip_max = 8;ammo_max = Convars.GetFloat("ammo_shotgun_max");break;
			case "weapon_autoshotgun":case "weapon_shotgun_spas":case "weapon_autoshotgun_spawn":case "weapon_shotgun_spas_spawn":
				clip_max = 10;ammo_max = Convars.GetFloat("ammo_autoshotgun_max");break;
		}
		local clip_after = (clip_max*clip_p/100).tointeger();local ammo_after = (ammo_max*ammo_p/100).tointeger();

		return [clip_after, ammo_after];
	}
}