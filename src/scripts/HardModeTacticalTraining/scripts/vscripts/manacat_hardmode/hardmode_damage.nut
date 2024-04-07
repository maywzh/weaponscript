::AllowTakeDamage <- function (damageTable){
/*	local attacker = damageTable.Attacker;
	local attackerModel = attacker.GetModelName();
	local victim = damageTable.Victim;

	try{
		if(victim.GetZombieType() == 9 && damageTable.Inflictor.GetClassname() == "weapon_tank_claw"){
			if(::hdmdState.lv > 3){
				//printl("attacker "+damageTable.Attacker);		printl("Victim "+damageTable.Victim);		printl("Inflictor "+damageTable.Inflictor);
				//printl("DamageDone "+damageTable.DamageDone);		printl("DamageType "+damageTable.DamageType);		printl("Weapon "+damageTable.Weapon);
				if(victim.GetHealth()+victim.GetHealthBuffer() <= damageTable.DamageDone)	::manacatAddTimer(0.1, false, ::flyincap, { player = victim, atker = attacker });
				else	return true;
				return false;
			}
		}
	}catch(e){
	}
	
	if(damageTable.Inflictor.GetClassname() == "infected"){
		damageTable.DamageDone = damageTable.DamageDone * (::hardmodeVars.dmgscale - ::hardmodeVars.dmgscale_team);
	}else if(attackerModel.find("hunter") != null){
		local gameDif = Convars.GetStr("z_difficulty").tolower();
		if(damageTable.DamageDone == 40 || (damageTable.DamageDone == 20 && gameDif == "hard")
		//|| (damageTable.DamageDone == 10 && (gameDif == "normal" || gameDif == "easy"))
		){
			damageTable.DamageDone = damageTable.DamageDone * (::hardmodeVars.dmgscale - ::hardmodeVars.dmgscale_team);
		}
	}else if(attackerModel.find("jockey") != null || attackerModel.find("smoker") != null || attackerModel.find("spitter") != null || attackerModel.find("boomer") != null || attackerModel.find("charger") != null){
		damageTable.DamageDone = damageTable.DamageDone * (1.0-::hardmodeVars.dmgscale_team);
	}

	return true;
*/

	local attacker = damageTable.Attacker;	local attackerClass = null;
	if("GetClassname" in attacker)attackerClass = attacker.GetClassname();
	local victim = damageTable.Victim;		local victimClass = null;
	if("GetClassname" in victim)victimClass = victim.GetClassname();
	local damageNerf = 0;	//특좀 대상 피해 조절용
	if(attackerClass == null || victimClass == null)return true;
	local InflictorClass = damageTable.Inflictor.GetClassname();

	if(NetProps.GetPropInt( attacker, "m_iTeamNum" ) == 4){
		if((victim.GetClassname() != "infected" || (victim.GetClassname() == "infected" && damageTable.DamageType != -2130706430)) && damageTable.DamageDone > 5)damageTable.DamageDone = 5;
	}

	//printl("attacker "+damageTable.Attacker);		printl("Victim "+damageTable.Victim);		printl("Inflictor "+damageTable.Inflictor);
	//printl("DamageDone "+damageTable.DamageDone);		printl("DamageType "+damageTable.DamageType);		printl("Weapon "+damageTable.Weapon);

	try{
		if(victimClass == "player"){
			local ztype = victim.GetZombieType();

			//생존자가 입는 피해
			if(ztype == 9){
				if(!::hdmdState.start && damageTable.DamageDone < 5000 && damageTable.Victim != damageTable.Attacker)return false;
				damageTable.DamageDone = ::hdmdDMGFunc.damageFix(attacker, victim, attackerClass, victimClass, damageTable);

				switch(InflictorClass){
					case "weapon_tank_claw" :
						//탱크 펀치를 맞았을 때 체공 후 무력화
						if(victim.GetHealth()+victim.GetHealthBuffer() <= damageTable.DamageDone && !victim.IsIncapacitated() && !victim.IsHangingFromLedge())	::manacatAddTimer(0.1, false, ::flyincap, { player = victim, atker = attacker });
						else	return true;
						return false;
					case "insect_swarm" :
						return true;
					default :
				}
				
				if(::hdmdState.gamemode == 0){
					local aztype = damageTable.Attacker.GetZombieType();
					//포획 피해량 정밀 설정시 자키의 살 찢는 효과음이 너무 시끄러우므로
					if(::hardmodeVars.dmg != 0){
						if(attackerClass == "player" && aztype == 5 && victim.IsDominatedBySpecialInfected() && victim.GetSpecialInfectedDominatingMe() == attacker){
							local len = ::hdmdSIVars.jockey_jump.len();
							for(local i = 0; i < len; i++){
								if(::hdmdSIVars.jockey_jump[i][0] == attacker){
									if(::hdmdSIVars.jockey_jump[i][1]+0.95 > Time()){
										damageTable.DamageType = 1048576;
									}else{
										::hdmdSIVars.jockey_jump[i][1] = Time();
									}
									break;
								}
							}
						}
					}
					//불타는 특좀으로부터의 화상 피해 (3등급 난이도부터)
					if(attackerClass == "player" && attacker.IsOnFire() && damageTable.DamageType == 128 && ::hdmdState.lv >= 3){
						local len = ::hdmdSIVars.fireList.len();
						for(local i = 0; i < len; i++){
							if(::hdmdSIVars.fireList[i][0] == damageTable.Attacker && ::hdmdSIVars.fireList[i][1] >= 1){
								damageTable.DamageType = 136;//128+8
								::hdmdSIVars.fireList[i][1] = 0;
								switch(aztype){
									case 1:case 2:case 4:case 5://스모커 부머 스피터 자키
										damageTable.DamageDone += 1;
									break;
									case 3://헌터 - 급습은 데미지타입 1
										if(damageTable.DamageDone == 6)damageTable.DamageDone += 1;
										else damageTable.DamageDone += 2;
									break;
									case 6://차저
										damageTable.DamageDone += 2;
									break;
								}
							}
						}
					}
				}else if(::hdmdState.gamemode == 1){
					//헌터한테 잡혔을 때 30 피해 이상 받았으면 더이상 피해 안받는 것으로 함
					if(attackerClass == "player" && victim.IsDominatedBySpecialInfected() && victim.GetSpecialInfectedDominatingMe() == attacker && damageTable.Attacker.GetZombieType() == 3){
						local len = ::hdmdSIVars.hunter_pounce.len();
						for(local i = 0; i < len; i++){
							if(::hdmdSIVars.hunter_pounce[i][0] == attacker){
								if(::hdmdSIVars.hunter_pounce[i][2] >= 30)return false;
								::hdmdSIVars.hunter_pounce[i][2] += damageTable.DamageDone;
								if(::hdmdSIVars.hunter_pounce[i][2] >= 30){
									damageTable.DamageDone -= ::hdmdSIVars.hunter_pounce[i][2]-30;
									::hdmdSIVars.hunter_pounce[i][2] = 30;
								}//printl(::hdmdSIVars.hunter_pounce[i][1]+"  "+::hdmdSIVars.hunter_pounce[i][2]);
								return true;
							}
						}
					}
				}
			}else if(ztype == 8){
				if((InflictorClass == "prop_physics" || InflictorClass == "prop_physics_multiplayer" || InflictorClass == "prop_car_alarm")){
					return false;
				}else if(::hdmdState.lv >= 4){
					if(InflictorClass == "grenade_launcher_projectile"){
						if(damageTable.DamageDone > 125){
							local dmg = damageTable.DamageDone - 125;
							dmg /= 4;
							damageTable.DamageDone = 125 + dmg;
						}
					}else{
						if(InflictorClass == "prop_minigun"){
							damageTable.DamageDone = 5;
						}else if(InflictorClass == "prop_minigun_l4d1"){
							damageTable.DamageDone = 4;
						}
						local activity = victim.GetSequenceActivityName(victim.GetSequence());
						if(activity == "ACT_TANK_OVERHEAD_THROW" || activity == "ACT_TERROR_RAGE_AT_KNOCKDOWN"){
							damageTable.DamageDone -= damageTable.DamageDone/2;
						}else if(activity == "ACT_CLIMB_UP" || activity == "ACT_CLIMB_DOWN" || activity == "ACT_CLIMB_DISMOUNT"
							|| activity == "ACT_TERROR_CLIMB_36_FROM_STAND" || activity == "ACT_TERROR_CLIMB_38_FROM_STAND" || activity == "ACT_TERROR_CLIMB_50_FROM_STAND" || activity == "ACT_TERROR_CLIMB_70_FROM_STAND"
							|| activity == "ACT_TERROR_CLIMB_115_FROM_STAND" || activity == "ACT_TERROR_CLIMB_130_FROM_STAND" || activity == "ACT_TERROR_CLIMB_150_FROM_STAND" || activity == "ACT_TERROR_CLIMB_166_FROM_STAND"){
							damageTable.DamageDone -= damageTable.DamageDone/4;
						}
						local dist = (attacker.GetOrigin() - victim.GetOrigin()).Length();
						if(dist > 350){
							dist -= 350;
							if(dist > 500)dist = 500;
							damageTable.DamageDone -= (damageTable.DamageDone/200)*(100/(500/dist));
						}
					}
					
					if(victim.IsOnFire())damageTable.DamageDone -= 6;
					//printl(damageTable.DamageDone);
				}
				damageNerf = 70;
			}else if(ztype == 3 && ::hdmdState.gamemode == 1){//헌터모드에서 헌터
				if(IsPlayerABot(attacker) && attacker.IsSurvivor()){
					damageTable.DamageDone *= 0.75;
				}
			}else if(ztype == 6){
				if(NetProps.GetPropIntArray( victim, "m_nSequence", 0) == 5){
					damageTable.DamageDone *= 2.942;//66% 피해감소를 원상복구
				}
			}else{
				if(InflictorClass == "entityflame"){
					local len = ::hdmdSIVars.fireList.len();
					local find = false;
				//	printl(damageTable.Victim+" 화상 추가");
					for(local i = 0; i < len; i++){
						if(::hdmdSIVars.fireList[i][0] == damageTable.Victim){
							::hdmdSIVars.fireList[i][1] += 0.3;
							find = true;
						}
					}
					if(!find){
						::hdmdSIVars.fireList.append([damageTable.Victim, 1]);
					}
				}
				damageNerf = 200;
			}
		}/*else if(victimClass == "witch"){
			damageNerf = 70;
		}*/else if(victimClass == "infected"){
			if(attackerClass == "player"){
				local ztype = attacker.GetZombieType();
				if(ztype != 9 && ztype != 8){
					if(ztype == 6)damageTable.DamageDone = 25;//차저
					else damageTable.DamageDone = 17;
					return true;
				}
			}
		}else if((victimClass == "prop_physics" || victimClass == "prop_physics_multiplayer" || victimClass == "prop_car_alarm") && NetProps.GetPropInt(victim, "m_hasTankGlow") && NetProps.GetPropInt(victim, "m_breakableType") != 2 && InflictorClass == "weapon_tank_claw"){
			return false;
		}else if(victimClass == "prop_door_rotating_checkpoint" && attackerClass == "witch" && NetProps.GetPropInt( victim, "m_eDoorState" ) == 0){
			if(::hdmdTankVars.door_pound_time <= Time()){
				local back = attacker.GetOrigin() + attacker.GetAngles().Forward().Scale(-40);
				::hdmdTankFunc.door_open_try({chkpdoor = victim, back = back, openerPos = attacker.GetOrigin(), opener = attacker, tank = false});
			}
		}

		/*
		//특좀 대상 피해 조정
		if(damageNerf != 0){
			local weapon = damageTable.Weapon.GetClassname();
			switch(weapon){
				case "weapon_autoshotgun" : case "weapon_shotgun_spas" :
					damageTable.DamageDone = (damageTable.DamageDone/5)*3.5;
				break;
				case "weapon_hunting_rifle" : case "weapon_sniper_military" :
					if(damageTable.DamageDone < damageNerf)damageTable.DamageDone = (damageTable.DamageDone/5)*4;	//헤드샷은 유지
				break;
				case "weapon_smg" : case "weapon_rifle_m60" :
					damageTable.DamageDone += 4;
				break;
				case "weapon_smg_mp5" :
					damageTable.DamageDone += 1;
				break;
				case "weapon_rifle" :
					damageTable.DamageDone -= 2;
				break;
				case "weapon_rifle_desert" :
					damageTable.DamageDone -= 8;
				break;
				case "weapon_rifle_ak47" :
					damageTable.DamageDone -= 13;
				break;
				case "weapon_sniper_awp" :
					damageTable.DamageDone += 85;
				break;
				case "weapon_sniper_scout" :
					damageTable.DamageDone += 75;
				break;
				case "weapon_chainsaw" :
					damageTable.DamageDone -= 40;
				break;
			}
		}//*/
	}catch(e){
	//	printl(e);
	}

	return true;
}

::flyincap <- function(params){
	if (params.player.IsIncapacitated() || params.player.IsHangingFromLedge()) return;
	params.player.TakeDamage(params.player.GetHealth()+params.player.GetHealthBuffer(), 128, params.atker);
}

::hdmdDMGFunc <- {
	function damageFix(attacker, victim, attackerClass, victimClass, damageTable){

		if((damageTable.DamageType&8)==8 && victim.IsIncapacitated() && damageTable.DamageDone > 1)return 1;
		if(attackerClass == "witch"){
			if(::hdmdSurvVars.playerCount == 1 && !victim.IsIncapacitated()){
				local dmg = (victim.GetHealth() + victim.GetHealthBuffer())-1;
			//	EmitSoundOnClient("WitchZombie.ShredVictim", victim);
				if(dmg < 1)dmg = 1;
				return dmg;
			}
		}else if(attackerClass == "infected"){
			local dmg = 0;
			if(::hdmdState.gamemode == 0){
				if(::hdmdSurvFunc.allInDanger()+3 >= Time()){
					if(victim.IsIncapacitated()){
						if(::hdmdSurvVars.playerCount <= 2)	return 5;
						if(::hdmdSurvVars.playerCount == 3)	return 8;
						else								return 10;
					}
					if(::hdmdState.gameDif == "easy" || ::hdmdState.gameDif == "normal"){
						if(::hdmdSurvVars.playerCount <= 2)			dmg = 2;
						else										dmg = 3;//was 2
						if(::hdmdState.lv >= 7)					dmg += 1;
					}else if(::hdmdState.gameDif == "hard"){
						if(::hdmdSurvVars.playerCount == 1)			dmg = 3;
						else if(::hdmdSurvVars.playerCount == 2)	dmg = 4;
						else										dmg = 5;
						if(::hdmdState.lv >= 7)					dmg += 2;
					}else if(::hdmdState.gameDif == "impossible"){
						if(::hdmdSurvVars.playerCount == 1){
																	dmg = 4;
							if(::hdmdState.lv >= 7)				dmg += 2;
						}else if(::hdmdSurvVars.playerCount == 2){
							if(::hdmdSurvVars.teamPower <= 2)		dmg = 4;
							else									dmg = 5;
							if(::hdmdState.lv >= 7)				dmg += 3;
						}else if(::hdmdSurvVars.playerCount == 3){
							if(::hdmdSurvVars.teamPower <= 2)		dmg = 4;
							else if(::hdmdSurvVars.teamPower <= 3)	dmg = 5;
							else									dmg = 6;
							if(::hdmdState.lv >= 7)				dmg += 3;
						}else{
							if(::hdmdSurvVars.teamPower <= 2)		dmg = 5;
							else if(::hdmdSurvVars.teamPower <= 3)	dmg = 6;
							else									dmg = 8;
							if(::hdmdState.lv >= 7)				dmg += 4;
						}
					}
				}else{
					return 12;
				}
			}else if(::hdmdState.gamemode == 1){
				if(victim.IsIncapacitated()){
					if(::hdmdSurvVars.playerCount <= 2)	return 1;
					if(::hdmdSurvVars.playerCount == 3)	return 2;
					else								return 3;
				}
				if(::hdmdState.gameDif == "easy" || ::hdmdState.gameDif == "normal" || ::hdmdState.gameDif == "hard"){
					if(::hdmdSurvVars.playerCount <= 2)			dmg = 1;
					else										dmg = 2;//was 2
				}else if(::hdmdState.gameDif == "impossible"){
					if(::hdmdSurvVars.playerCount <= 2)			dmg = 2;
					else										dmg = 3;
				}
			}
			local z = victim.GetSpecialInfectedDominatingMe();
			if(z != null){
				if("GetZombieType" in z && z.GetZombieType() != 1){
					if(::hdmdSurvVars.playerCount == 1)			dmg -= 4;
					else if(::hdmdSurvVars.playerCount == 2)	dmg -= 3;
					else if(::hdmdSurvVars.playerCount == 3)	dmg -= 2;
					else										dmg -= 1;
				}else{
					if(::hdmdSurvVars.playerCount == 1)			dmg -= 2;
					else if(::hdmdSurvVars.playerCount == 2)	dmg -= 1;
				}
			}
			if(IsPlayerABot(victim))dmg -= dmg/3;
			if(dmg < 1)dmg = 1;
			return dmg;
		}
		switch(attacker.GetZombieType()){
			case 1://스모커
				if(damageTable.DamageType == 1048576 && (damageTable.DamageDone == 1.1 || damageTable.DamageDone == 3.1)){
					if(victim.GetVelocity().Length() > 35)
							return damageTable.DamageDone-0.1;  //끌려가는 동안 지속 피해
					else	return 0;							//다 끌려간 이후에는 피해 없음
				}else if(victim.IsDominatedBySpecialInfected() && victim.GetSpecialInfectedDominatingMe() == attacker){//질식
					if(::hardmodeVars.dmg == 0){
						if(::hdmdState.gameDif == "easy" || ::hdmdState.gameDif == "normal"){
							if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 30;
							if(::hdmdSurvVars.teamPower <= 1)	return 4;
							if(::hdmdSurvVars.teamPower <= 2)	return 5;
							if(::hdmdSurvVars.teamPower <= 3)	return 6;
																return 8;
						}
						if(::hdmdState.gameDif == "hard"){
							if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 30;
							if(::hdmdSurvVars.teamPower <= 1)	return 5;
							if(::hdmdSurvVars.teamPower <= 2)	return 6;
							if(::hdmdSurvVars.teamPower <= 3)	return 8;
																return 10;
						}
						if(::hdmdState.gameDif == "impossible"){
							if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 30;
							if(::hdmdSurvVars.teamPower <= 1)	return 6;
							if(::hdmdSurvVars.teamPower <= 2)	return 8;
							if(::hdmdSurvVars.teamPower <= 3)	return 10;
																return 12;//was 30
						}
					}else{
						if(::hdmdState.gameDif == "easy" || ::hdmdState.gameDif == "normal"){
							if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 7;
							if(::hdmdSurvVars.teamPower <= 1)	return 1;
																return 2;
						}
						if(::hdmdState.gameDif == "hard"){
							if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 7;
							if(::hdmdSurvVars.teamPower <= 3)	return 2;
																return 3;
						}
						if(::hdmdState.gameDif == "impossible"){
							if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 7;
							if(::hdmdSurvVars.teamPower <= 2)	return 2;
																return 3;//was 30
						}
					}
				}else{//평타
					if(::hdmdState.gameDif == "easy")		return 2;//was 1
					if(::hdmdState.gameDif == "normal")		return 2;
					if(::hdmdState.gameDif == "hard"){
						if(::hdmdSurvVars.teamPower <= 1)	return 4;
															return 5;
					}
					if(::hdmdState.gameDif == "impossible"){
						if(::hdmdSurvVars.teamPower <= 1)	return 4;
						if(::hdmdSurvVars.teamPower <= 2)	return 5;
						if(::hdmdSurvVars.teamPower <= 2.5)	return 6;
															return 8;
					}
				}
			case 2://부머
			case 4://스피터
				//스피터 침 피해가 빨리 들어오도록 함 (4등급 난이도부터)
				if(damageTable.Inflictor.GetClassname() == "insect_swarm"){
					if(::hdmdState.lv >= 4 && !IsPlayerABot(victim)){
						if(damageTable.DamageDone < 0.3)return 0;
						if(damageTable.DamageDone < 1 && !victim.IsIncapacitated())return 1;
					}
					return damageTable.DamageDone;
				}
				//평타
				if(::hdmdState.gameDif == "easy")		return 2;//was 1
				if(::hdmdState.gameDif == "normal")		return 2;
				if(::hdmdState.gameDif == "hard"){
					if(::hdmdSurvVars.teamPower <= 1)	return 4;
														return 5;
				}
				if(::hdmdState.gameDif == "impossible"){
					if(::hdmdSurvVars.teamPower <= 1)	return 4;
					if(::hdmdSurvVars.teamPower <= 2)	return 5;
					if(::hdmdSurvVars.teamPower <= 2.5)	return 6;
														return 8;
				}
			case 3://헌터
				if(damageTable.DamageType == 129)return damageTable.DamageDone;
				if(::hdmdState.gameDif == "easy" || ::hdmdState.gameDif == "normal"){
					if(::hdmdState.gamemode == 0){
						if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 6;
						if(damageTable.DamageDone == 10)	return 5;	//평타
															return 6;	//급습
					}else if(::hdmdState.gamemode == 1){
						if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 2;
						if(damageTable.DamageDone == 10)	return 1;	//평타
															return 2;	//급습
					}
				}else if(::hdmdState.gameDif == "hard"){
					if(::hdmdState.gamemode == 0){
						//평타
						if(damageTable.DamageDone == 20){
							if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 8;
							if(::hdmdSurvVars.teamPower <= 1)	return 5;
							if(::hdmdSurvVars.teamPower <= 2)	return 6;
							if(::hdmdSurvVars.teamPower <= 2.5)	return 7;
																return 8;
						}
						//급습
							if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 8;
						if(::hdmdSurvVars.teamPower <= 1)	return 5;
						if(::hdmdSurvVars.teamPower <= 2)	return 6;
						if(::hdmdSurvVars.teamPower <= 2.5)	return 7;
															return 8;
					}else if(::hdmdState.gamemode == 1){
						//평타
						if(damageTable.DamageDone == 20){
							if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 6;
							if(::hdmdSurvVars.teamPower <= 1)	return 1;
							if(::hdmdSurvVars.teamPower <= 2)	return 2;
							if(::hdmdSurvVars.teamPower <= 2.5)	return 3;
																return 4;
						}
						//급습
							if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 8;
						if(::hdmdSurvVars.teamPower <= 2)	return 3;
						if(::hdmdSurvVars.teamPower <= 2.5)	return 4;
															return 5;
					}
				}else if(::hdmdState.gameDif == "impossible"){
					if(::hdmdState.gamemode == 0){
						//평타
						if(damageTable.DamageDone == 40){
							if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 15;
							if(::hdmdSurvVars.teamPower <= 1)	return 6;
							if(::hdmdSurvVars.teamPower <= 2)	return 7;
							if(::hdmdSurvVars.teamPower <= 2.5)	return 8;
																return 10;
						}
						//급습
							if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 15;
						if(::hdmdSurvVars.teamPower <= 1)	return 5;
						if(::hdmdSurvVars.teamPower <= 2)	return 6;
						if(::hdmdSurvVars.teamPower <= 2.5)	return 8;
															return 10;
					}else if(::hdmdState.gamemode == 1){
						//평타
						if(damageTable.DamageDone == 40){
							if(::hdmdSurvVars.teamPower <= 1)	return 1;
							if(::hdmdSurvVars.teamPower <= 2)	return 2;
							if(::hdmdSurvVars.teamPower <= 2.5)	return 3;
																return 4;
						}
						//급습
						if(::hdmdSurvVars.teamPower <= 2)	return 3;
						if(::hdmdSurvVars.teamPower <= 2.5)	return 4;
															return 5;
					}
				}
			case 5://자키
				if(::hdmdState.gameDif == "easy" || ::hdmdState.gameDif == "normal"){
					if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 4;
					if(damageTable.DamageDone == 1
					|| damageTable.DamageDone == 2)	return 2;	//평타

					if(::hardmodeVars.dmg == 0)		return 4;	//도약
					else							return 1;
				}else if(::hdmdState.gameDif == "hard"){
					//평타
					if(damageTable.DamageDone == 5){
						if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 12;
						if(::hdmdSurvVars.teamPower <= 1)	return 3;
						if(::hdmdSurvVars.teamPower <= 2)	return 4;
						if(::hdmdSurvVars.teamPower <= 2.5)	return 5;
															return 7;//was 5
					}
					//도약
					if(::hardmodeVars.dmg == 0){
						if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 12;
						if(::hdmdSurvVars.teamPower <= 2)	return 4;
						if(::hdmdSurvVars.teamPower <= 3)	return 5;
															return 7;
					}else{
						if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 4;
						if(::hdmdSurvVars.teamPower <= 2)	return 1;
															return 2;
					}
				}else if(::hdmdState.gameDif == "impossible"){
					//평타
					if(damageTable.DamageDone == 20){
						if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 12;
						if(::hdmdSurvVars.teamPower <= 1)	return 4;
						if(::hdmdSurvVars.teamPower <= 2)	return 5;
						if(::hdmdSurvVars.teamPower <= 2.5)	return 6;
															return 8;//was 20
					}
					//도약
					if(::hardmodeVars.dmg == 0){
						if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 12;
						if(::hdmdSurvVars.teamPower <= 2)	return 5;
						if(::hdmdSurvVars.teamPower <= 3)	return 6;
															return 8;
					}else{
						if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 4;
						if(::hdmdSurvVars.teamPower <= 2)	return 1;
															return 2;
					}
				}
			case 6://차저
				if(!attacker.IsImmobilized()){//평타
					if(damageTable.DamageDone <= 3){
						return damageTable.DamageDone;//충격파
					}else{
						if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 20;
						if(::hdmdState.gameDif == "easy")			return 5;//was 10
						if(::hdmdState.gameDif == "normal")			return 10;
						if(::hdmdState.gameDif == "hard"
						|| ::hdmdState.gameDif == "impossible"){
							if(::hdmdSurvVars.teamPower <= 1.5)		return 10;
							if(::hdmdSurvVars.teamPower <= 2.5)		return 12;
																	return 15;//was 20
						}
					}
				}else if(damageTable.DamageDone > 4){//강타
					if(::hdmdSurvFunc.allInDanger()+3 < Time())		return 20;
					if(::hdmdSurvVars.teamPower <= 1.5)		return 10;
					if(::hdmdSurvVars.teamPower <= 2.5)		return 12;
															return 15;
				}
			case 8://탱크
				local dmg = damageTable.DamageDone;	local dmg_origin = damageTable.DamageDone;
			//	printl("조정전 : "+dmg);
				local attackClass = damageTable.Inflictor.GetClassname();
				if(attackClass == "prop_physics" || attackClass == "prop_physics_multiplayer" || attackClass == "prop_car_alarm"){
					if(::hdmdSurvVars.playerCount == 1)dmg *= 0.3;
					else if(::hdmdSurvVars.playerCount == 2)dmg *= 0.6;
					return dmg;
				}
				if(::hdmdSurvVars.playerCount == 1 && damageTable.DamageDone > 20)dmg = 20;
				else if(::hdmdSurvVars.playerCount == 2 && damageTable.DamageDone > 24)dmg = 24;
				else if(::hdmdSurvVars.playerCount == 3 && damageTable.DamageDone > 30)dmg = 30;
				else if(::hdmdSurvVars.playerCount == 4 && damageTable.DamageDone > 36)dmg = 36;
				else if(::hdmdSurvVars.playerCount == 5 && damageTable.DamageDone > 42)dmg = 42;
				else if(::hdmdSurvVars.playerCount == 6 && damageTable.DamageDone > 46)dmg = 46;
				else if(::hdmdSurvVars.playerCount >= 7 && damageTable.DamageDone > 50)dmg = 50;
				if(::hdmdSurvVars.playerCount == 1 && dmg < 20)dmg = 20;
				else if(::hdmdSurvVars.playerCount != 1 && dmg < 24)dmg = 24;
				if(damageTable.DamageType == 129)dmg /= 2;
				if(::hdmdTankVars.tanks >= 2)dmg -= dmg/3;
				if(IsPlayerABot(victim))dmg -= dmg/3;
			//	printl("조정후 : "+dmg);

				local tankOrigin = attacker.GetOrigin();
				local tankPunch = attacker.GetActiveWeapon();
				if(victim.IsIncapacitated()){
					for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
						if(!::hdmdSurvVars.playerList[i][1].IsValid() || ::hdmdSurvVars.playerList[i][1].IsDead() || ::hdmdSurvVars.playerList[i][1].IsDying() || ::hdmdSurvVars.playerList[i][1].IsIncapacitated() || ::hdmdSurvVars.playerList[i][1].IsDominatedBySpecialInfected())continue;
						local dist = (::hdmdSurvVars.playerList[i][1].GetOrigin() - tankOrigin).Length();
						if(dist <= 120){
						//	::hdmdSurvVars.playerList[i][1].Stagger(tankOrigin);
							::hdmdTankFunc.tank_punch_knockback(attacker, ::hdmdSurvVars.playerList[i][1], 0);
							::hdmdSurvVars.playerList[i][1].TakeDamageEx(tankPunch, attacker, tankPunch, tankOrigin, tankOrigin, 100, 129);
						}
					}
					if(::hdmdState.gameDif == "easy" || ::hdmdState.gameDif == "normal")
																return 35;//was 75
					if(::hdmdState.gameDif == "hard")			return 45;
					if(::hdmdState.gameDif == "impossible"){
						if(::hdmdSurvVars.playerCount == 2)		return 45;
																return 55;
					}
				}else{
					if(damageTable.Inflictor.GetClassname() == "weapon_tank_claw"){
						if(damageTable.DamageType != 129){
							for(local i = 0; i < ::hdmdSurvVars.playerCount; i++){
								if(!::hdmdSurvVars.playerList[i][1].IsValid() || ::hdmdSurvVars.playerList[i][1].IsDead() || ::hdmdSurvVars.playerList[i][1].IsDying() || ::hdmdSurvVars.playerList[i][1].IsIncapacitated() || ::hdmdSurvVars.playerList[i][1].IsDominatedBySpecialInfected())continue;
								if(::hdmdSurvVars.playerList[i][1] == victim)continue;
								local dist = (::hdmdSurvVars.playerList[i][1].GetOrigin() - tankOrigin).Length();			//탱크와의 거리
								local dist2 = (::hdmdSurvVars.playerList[i][1].GetOrigin() - victim.GetOrigin()).Length();	//피해자와의 거리
								if(dist <= 120 && dist2 <= 80){
									::hdmdTankFunc.tank_punch_knockback(attacker, ::hdmdSurvVars.playerList[i][1], 1);
									::hdmdSurvVars.playerList[i][1].TakeDamageEx(tankPunch, attacker, tankPunch, tankOrigin, tankOrigin, dmg_origin, 129);
								}
							}
						}else{
							dmg *= 2;
						}
					}
				}
				return dmg;
		}
		return damageTable.DamageDone;
	}
}