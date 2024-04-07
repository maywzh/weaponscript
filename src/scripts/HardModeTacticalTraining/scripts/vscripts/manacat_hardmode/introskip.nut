::introFunc<-
{
	function IntroSkip(params){
		local IntroMap = (Entities.FindByName( null, "lcs_intro" ) || Entities.FindByName( null, "fade_intro" ) || Entities.FindByName( null, "intro_lr" ));
	//	printl("인트로맵 여부 : "+IntroMap);
		switch(Director.GetMapName()){
			case "c1m1_hotel":
				EntFire("sound_chopperleave","Kill"); //Specific intro sounds.
				EntFire("rescue_chopper","Kill"); //Specific models of rescue vehicles.
				EntFire("lcs_intro","Kill"); //Remove survivor voices during intro.
				EntFire("fade_intro","Kill"); //Remove entity of fade control.
				EntFire("director","FinishIntro",null,0.1); //Stop survivor animations during intro.
				EntFire("director","ReleaseSurvivorPositions",null,0.1); //Teleport to start points+unfreezing.
				EntFire("point_viewcontrol_survivor","Kill"); //Remove intro cameras.
			break;
			case "c2m1_highway":
				EntFire("lcs_intro","Kill");
				EntFire("fade_intro","Kill");
				EntFire("director","FinishIntro",null,0.1);
				EntFire("director","ReleaseSurvivorPositions",null,0.1);
				EntFire("point_viewcontrol_survivor","Kill");
			break;
			case "c3m1_plankcountry":
				EntFire("lcs_intro","Kill");
				EntFire("fade_intro","Kill");
				EntFire("director","ReleaseSurvivorPositions",null,0.1);
				EntFire("point_viewcontrol_survivor","Kill");
			break;
			case "c4m1_milltown_a":
				EntFire("PugTug","Kill");
				EntFire("@skybox_PugTug","Kill");
				EntFire("lcs_intro","Kill");
				EntFire("fade_intro","Kill");
				EntFire("@director","FinishIntro",null,0.1);
				EntFire("@director","ReleaseSurvivorPositions",null,0.1);
				EntFire("point_viewcontrol_survivor","Kill");
			break;
			case "c5m1_waterfront":
				EntFire("orator","Kill");
				EntFire("tug_boat_intro","Kill");
				EntFire("@skybox_tug_boat_intro","Kill");
				EntFire("fade_intro","Kill");
				EntFire("director","FinishIntro",null,0.1);
				EntFire("director","ReleaseSurvivorPositions",null,0.1);
				EntFire("point_viewcontrol_survivor","Kill");
			break;
			case "c6m1_riverbank":
				/*Prohibit "relay_intro_start" forcing a FireConceptToAny input.
				P.S.: Usually we avoid using such methods,
				but only this time... Made sure,that DirectorOptions loads properly.*/

				EntFire("@director","FinishIntro");
				EntFire("@director","AddOutput","targetname director_temp");
				EntFire("director_temp","AddOutput","targetname @director",0.1);
				EntFire("fade_intro","Kill");
				EntFire("point_viewcontrol_survivor","Kill");
			break;
			case "c7m1_docks":
				EntFire("intro_train_steam1","Kill");
				EntFire("intro_train_steam2","Kill");
				EntFire("intro_train_steam3","Kill");
				EntFire("train","AddOutput","origin 13168.001,2768.000,50.000");
				EntFire("infected_chase","Kill");
				EntFire("infected_spawner","Kill");
				EntFire("fade_outro_1","Kill");
				EntFire("fade_outro_4","Kill");
				EntFire("director","ReleaseSurvivorPositions",null,0.1);
				EntFire("point_viewcontrol_survivor","Kill");
			break;
			case "c8m1_apartment":
				EntFire("lcs_intro_survivors","Kill");
				EntFire("tarp_sound","Kill");
				EntFire("tarp_animated","Kill");
				EntFire("ghostAnim","Kill");
				EntFire("sound_chopper","Kill");
				EntFire("helicopter_speaker","Kill");
				EntFire("helicopter_animated","Kill");
				EntFire("fade_intro","Kill");
				EntFire("director","FinishIntro",null,0.3);
				EntFire("director","ReleaseSurvivorPositions",null,0.3);
				EntFire("camera_intro_airplane","Kill");
			break;
			case "c9m1_alleys":
				EntFire("lcs_intro","Kill");
				EntFire("fade_intro","Kill");
				EntFire("@director","FinishIntro",null,0.1);
				EntFire("@director","ReleaseSurvivorPositions",null,0.1);
				EntFire("point_viewcontrol_survivor","Kill");
			break;
			case "c10m1_caves":
				EntFire("lcs_intro","Kill");
				EntFire("fade_intro","Kill");
				EntFire("director","FinishIntro",null,0.3);
				EntFire("director","ReleaseSurvivorPositions",null,0.3);
				EntFire("point_viewcontrol_survivor","Kill");
			break;
			case "c11m1_greenhouse":
				EntFire("light_hanging03","AddOutput","targetname ");
				EntFire("light_hanging02","AddOutput","targetname ");
				EntFire("light_hanging01","AddOutput","targetname ");
				EntFire("greenhouse_panel02","Kill");
				EntFire("greenhouse_panel01","Kill");
				EntFire("greenhouse_particles","Kill");
				EntFire("sound_airplane_intro","Kill");
				EntFire("airplane_animated_intro","Kill");
				EntFire("lcs_intro_airport_01","Kill");
				EntFire("fade_intro","Kill");
				EntFire("director","FinishIntro",null,0.3);
				EntFire("director","ReleaseSurvivorPositions",null,0.3);
				EntFire("point_viewcontrol_survivor","Kill");
			break;
			case "c12m1_hilltop":
				EntFire("lcs_intro","Kill");
				EntFire("fade_intro","Kill");
				EntFire("director","FinishIntro",null,0.3);
				EntFire("director","ReleaseSurvivorPositions",null,0.3);
				EntFire("point_viewcontrol_survivor","Kill");
			break;
			case "c13m1_alpinecreek":
				EntFire("gamesound","PlaySound");
				EntFire("lcs_intro","Kill");
				EntFire("scene_relay","Kill");
				EntFire("b_Signboard01","Kill");
				EntFire("fade_intro","Kill");
				EntFire("director","FinishIntro",null,0.1);
				EntFire("director","ReleaseSurvivorPositions",null,0.1);
				EntFire("point_viewcontrol_survivor","Kill");
			break;
			default:
				if(IntroMap != null){
					local a = [];
					local ent = null;
					while (ent = Entities.FindByName(ent, "relay_intro_setup")){
						if (ent.IsValid())DoEntFire("!self", "Kill", "", 0, null, ent);
					}

					local b = [];
					local ent = null;
					while (ent = Entities.FindByName(ent, "relay_intro_start")){
						if (ent.IsValid()){
							DoEntFire("!self", "AddOutput", "OnTrigger camera_intro:Disable::0:-1", 0, null, ent);
							DoEntFire("!self", "AddOutput", "OnTrigger relay_intro_finished:Trigger::1:-1", 0, null, ent);
							DoEntFire("!self", "Trigger", "", 0, null, ent);
						}
					}
				}
			break;
		}
	}
}

__CollectEventCallbacks(::showhpFunc, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);