::hdmdCIFunc<-{
	function common_zombie(){
		::hdmdCIFunc.z_common_limit();
		::hdmdCIFunc.z_background_limit();
		::hdmdCIFunc.z_common_spec();
		::hdmdCIFunc.hit_incap_factor();
		::hdmdCIFunc.common_zombie_interval();
		::hdmdCIFunc.z_door_pound_damage();
	}

	function z_common_limit(){
		local z_limit = 0;
		local z_den = 0;
		local mob_max = 30;	local mob_min = 10;

		if(::hardmodeVars.chkhard != 0){
			if(::hdmdState.gameDif == "impossible"){	z_den += 0.01;	}
			else if(::hdmdState.gameDif == "hard"){		z_den += 0.01;	}
			else if(::hdmdState.gameDif == "normal"){		}
			else{											}

			if(::mp_gamemode == "coop"){
				z_limit += 5;
				if(::hdmdSurvVars.teamPower <= 2){
					if(!Director.IsTankInPlay()){
						mob_max += 10;	mob_min += 5;
					}else{
						mob_max += 5;	mob_min += 5;
					}
				}else{
					if(!Director.IsTankInPlay()){
						mob_max += 15;	mob_min += 15;
					}else{
						mob_max += 5;	mob_min += 5;
					}
				}
			}else if(::mp_gamemode == "realism"){
				if(::hdmdSurvVars.teamPower <= 2){
					if(!Director.IsTankInPlay()){
						mob_max += 5;	mob_min += 2;
					}
				}else{
					if(!Director.IsTankInPlay()){
						mob_max += 10;	mob_min += 10;
					}
				}
			}
			if		(::hdmdSurvVars.teamPower > 3)z_limit += 10
			else if	(::hdmdSurvVars.teamPower > 2)z_limit += 5;
		}
		

	//	if(::hdmdState.lv < 5)z_int *= ::hdmdState.lv/5;

		z_limit = 30+z_limit-(4-::hdmdSurvVars.teamPower);
		if(z_limit < 30)z_limit = 30;

		//소수 인원으로 플레이할수록 적은 좀비를 상대
		z_limit -= (4-::hdmdSurvVars.playerCount)*4;
		if(::hdmdSurvVars.playerCount == 1)			z_limit -= 7;
		else if(::hdmdSurvVars.playerCount == 2)	z_limit -= 3;
		if(Director.IsTankInPlay())z_limit -= (4-::hdmdSurvVars.teamPower);
		if(::hdmdState.gamemode == 1){
			z_limit /= 4;
			if(z_limit < 8)z_limit = 8;
		}
		Convars.SetValue("z_common_limit", z_limit);

		mob_max -= (4-::hdmdSurvVars.playerCount)*5;
		mob_min -= (4-::hdmdSurvVars.playerCount)*3;
		if(::hdmdSurvVars.playerCount == 1){
			if(mob_max < 18)mob_max = 18;
			if(mob_min < 8)mob_min = 8;
		}else if(::hdmdSurvVars.playerCount == 2){
			if(mob_max < 25)mob_max = 25;
			if(mob_min < 10)mob_min = 10;
		}else{
			if(mob_max < 30)mob_max = 30;
			if(mob_min < 10)mob_min = 10;
		}
		if(::hdmdState.gamemode == 1){mob_max /= 4;mob_min /= 4;}
		Convars.SetValue("z_mob_spawn_max_size", mob_max);	Convars.SetValue("z_mob_spawn_min_size", mob_min);

		if(::hdmdState.lv >= 7){
			if(::hdmdState.gamemode == 0){
				if(z_den < 0)z_den = 0;
				Convars.SetValue("z_wandering_density", 0.04+z_den); //was 0.03
			}else if(::hdmdState.gamemode == 1){
				Convars.SetValue("z_wandering_density", 0.02);
			}
		}
	}

	function z_background_limit(){
		local z_blimit = 0;

		switch(::hdmdState.gameDif){
			case "easy":	z_blimit += 10;	break;
			case "normal":	z_blimit += 5;	break;
			case "hard":	z_blimit += 2;	break;
			//case "impossible":
		}

		if(::mp_gamemode == "coop"){
			z_blimit += 25;
		}else if(::mp_gamemode == "realism"){
			z_blimit += 15;
		}

		//키트를 많이 가지고 있을 수록 많은 좀비를 상대
		z_blimit += ::hdmdSurvVars.kitCount*2;
		
		if(::hdmdState.incap)			z_blimit -= 15;
		if(Director.IsTankInPlay())		z_blimit -= 15;

		if(::hdmdSurvVars.playerCount <= 1)			z_blimit -= 15;
		else if(::hdmdSurvVars.playerCount <= 2)	z_blimit -= 8;

		if(::hdmdState.finale){
			if(!Director.IsTankInPlay()){
				if(::hdmdSurvVars.playerCount <= 2)			z_blimit -= 10;
				else if(::hdmdSurvVars.playerCount <= 3)	z_blimit -= 5;
			}
		}

		//소수 인원으로 플레이할수록 적은 좀비를 상대
		z_blimit -= (4-::hdmdSurvVars.playerCount)*3;
		if(::hdmdSurvVars.playerCount == 1)z_blimit -= 4;

		if(z_blimit < 0)z_blimit = 0;
		if(::hdmdState.gamemode == 1)z_blimit /= 4;
		Convars.SetValue("z_background_limit", 20+z_blimit);
	}

	function z_common_spec(){
		local hp = 50;
		local speed = 250;
		local attack = 1;
		local behind = 0.5;

		if(::hdmdSurvVars.playerCount == 1){
			hp = 40;
		}else{
			if(::hardmodeVars.chkhard != 0){
				behind = 0.6;
				speed = 255;

				if(::mp_gamemode == "coop"){
					hp = 60;
					if(::hdmdSurvVars.teamPower <= 2){
						attack = 1;
						behind = 0.5;
					}else{
						if(::hdmdState.incap)	attack = 1;
						else					attack = 0.9;
					}
				}else if(::mp_gamemode == "realism"){
					hp = 50;
					if(::hdmdSurvVars.teamPower <= 2){
						attack = 1;
						behind = 0.5;
					}else{
						if(::hdmdState.incap)	attack = 1;
						else					attack = 0.9;
					}
				}
				if(::hdmdState.incap){
					hp = 50;
					speed = 250;
				}
				if(::hdmdSurvVars.teamPower <= 2)speed = 250;
			}
			if(Director.IsTankInPlay()){
				behind = 0.5;
				hp = 50;
				speed = 250;
			}
			if(::hdmdState.finale){
				behind = 0.5;
				hp = 50;
			}
			
			Convars.SetValue("z_hear_gunfire_range", 200+(350*(::hdmdSurvVars.teamPower-1)));
			Convars.SetValue("z_hear_runner_far_range", 750+(125*(::hdmdSurvVars.teamPower-1)));
			Convars.SetValue("z_hear_runner_near_range", 500+(75*(::hdmdSurvVars.teamPower-1)));
			
			//소수 인원으로 플레이할수록 체력이 적어짐
			hp -= (4-::hdmdSurvVars.playerCount)*2;
			if(hp < 50)hp = 50;
		}
		if(::hdmdState.gamemode == 1)hp = 20;
		Convars.SetValue("z_health", hp);
		Convars.SetValue("z_speed", speed);
		Convars.SetValue("z_attack_interval", attack);
		Convars.SetValue("z_hit_from_behind_factor", behind);
	}

	function common_zombie_interval(){
		local z_int = 0;

		if(::hardmodeVars.chkhard != 0){
			if(::hdmdSurvVars.teamPower <= 1)		z_int = 3;
			else if(::hdmdSurvVars.teamPower <= 2)	z_int = 5;
			else if(::hdmdSurvVars.teamPower <= 3)	z_int = 6;
			else									z_int = 7;
		}
		if(Director.IsTankInPlay())z_int = 0;

		if(::hdmdState.lv < 5)z_int *= ::hdmdState.lv/5;
		
		Convars.SetValue("z_mob_spawn_max_interval_easy", 240-(z_int*17));	Convars.SetValue("z_mob_spawn_max_interval_normal", 180-(z_int*7));
		Convars.SetValue("z_mob_spawn_max_interval_hard", 180-(z_int*5));	Convars.SetValue("z_mob_spawn_max_interval_expert", 180-(z_int*4));

		Convars.SetValue("z_mob_spawn_min_interval_easy", 120-(z_int*8));	Convars.SetValue("z_mob_spawn_min_interval_normal", 90-(z_int*4));
		Convars.SetValue("z_mob_spawn_min_interval_hard", 90-(z_int*3));	Convars.SetValue("z_mob_spawn_min_interval_expert", 90-(z_int*2));

		local maxinterval;	local mininterval;
		if(::hdmdState.lv < 7){	maxinterval = 900-(z_int*40)+100-(::hdmdSurvVars.teamPower*25);	mininterval = 420-(z_int*20)+200-(::hdmdSurvVars.teamPower*50);	}
		else{							maxinterval = 900-(z_int*100)+100-(::hdmdSurvVars.teamPower*25);	mininterval = 420-(z_int*50)+200-(::hdmdSurvVars.teamPower*50);	}
		if(maxinterval > 900)maxinterval = 900;	if(mininterval > 420)mininterval = 420;
		Convars.SetValue("z_mega_mob_spawn_max_interval", maxinterval);	//printl(maxinterval);
		Convars.SetValue("z_mega_mob_spawn_min_interval", mininterval);	//printl(mininterval);
	}

	function z_door_pound_damage(){//default : 200
		local z_door = 200;
		if(::hardmodeVars.chkhard != 0){
			if(::hdmdSurvVars.teamPower <= 1)		z_door = 200;
			else if(::hdmdSurvVars.teamPower <= 2)	z_door = 290;
			else if(::hdmdSurvVars.teamPower <= 3)	z_door = 320;
			else									z_door = 380;
		}
		if(Director.IsTankInPlay())z_door = 200;
		Convars.SetValue("z_door_pound_damage", z_door);
	}

	function hit_incap_factor(){
		if(::hdmdSurvVars.teamPower <= 1.5 || ::hdmdState.finale){
			Convars.SetValue("z_hit_incap_factor_easy", 0.3);	Convars.SetValue("z_hit_incap_factor_normal", 1.0);
			Convars.SetValue("z_hit_incap_factor_hard", 1.0);	Convars.SetValue("z_hit_incap_factor_expert", 1.0);
		}else if(Director.IsTankInPlay()){
			Convars.SetValue("z_hit_incap_factor_easy", 0.4);	Convars.SetValue("z_hit_incap_factor_normal", 1.0);
			Convars.SetValue("z_hit_incap_factor_hard", 1.0);	Convars.SetValue("z_hit_incap_factor_expert", 1.0);
		}else{
			Convars.SetValue("z_hit_incap_factor_easy", 0.5);	Convars.SetValue("z_hit_incap_factor_normal", 1.0);
			Convars.SetValue("z_hit_incap_factor_hard", 1.1);	Convars.SetValue("z_hit_incap_factor_expert", 1.2);
		}
	}

	function OnGameEvent_player_death(params){
		if(::hdmdState.gamemode == 1){
			if(params.victimname == "Infected"){
				local killer = GetPlayerFromUserID(params.attacker);
				::hdmdSurvFunc.hp_bonus(killer, 2, 30);
			}else if(params.victimname == "Witch"){
				local killer = GetPlayerFromUserID(params.attacker);
				::hdmdSurvFunc.hp_bonus(killer, 30, 65);
			}
		}
	}
}

__CollectEventCallbacks(::hdmdCIFunc, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);