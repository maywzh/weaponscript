::firstset <- function(){
	/*
	Convars.SetValue("z_common_limit", 0);
	Convars.SetValue("z_hunter_limit", 0);
	Convars.SetValue("z_jockey_limit", 0);
	Convars.SetValue("z_smoker_limit", 0);
	Convars.SetValue("z_charger_limit", 0);
	Convars.SetValue("z_boomer_limit", 0);
	Convars.SetValue("z_spitter_limit", 0);
	Convars.SetValue("sb_move", 0);
	//*/

	Convars.SetValue("vs_max_team_switches", 99);	
	Convars.SetValue("z_spawn_safety_range", 150);
	Convars.SetValue("versus_force_start_time", 9999);
	Convars.SetValue("sv_disable_glow_survivors", 0);
	Convars.SetValue("sv_disable_glow_faritems", 1);
	Convars.SetValue("sb_friend_immobilized_reaction_time_normal", 0);
	Convars.SetValue("sb_friend_immobilized_reaction_time_hard", 0);
	Convars.SetValue("sb_friend_immobilized_reaction_time_expert", 0);
	Convars.SetValue("sb_friend_immobilized_reaction_time_vs", 0);
	Convars.SetValue("director_convert_pills", 0);

	Convars.SetValue("z_vomit_interval", 10);
	Convars.SetValue("sb_temp_health_consider_factor", 1);
	Convars.SetValue("rescue_min_dead_time", 60);
	Convars.SetValue("z_ghost_speed", 700);

	if(Convars.GetStr("mp_gamemode") == "realism"){
		Convars.SetValue("sv_disable_glow_survivors", 1);
		Convars.SetValue("sv_rescue_disabled", 1);
		Convars.SetValue("z_non_head_damage_factor_multiplier", 0.5);
		Convars.SetValue("z_head_damage_causes_wounds", 1);
		Convars.SetValue("z_use_next_difficulty_damage_factor", 1);
		Convars.SetValue("z_witch_always_kills", 1);
		Convars.SetValue("z_witch_allow_change_victim", 1);
	}else if(Convars.GetStr("mp_gamemode") == "versus"){
		Convars.SetValue("z_spit_interval", 15);
		Convars.SetValue("z_vomit_interval", 18);
		Convars.SetValue("z_exploding_health", 80);
	}
}