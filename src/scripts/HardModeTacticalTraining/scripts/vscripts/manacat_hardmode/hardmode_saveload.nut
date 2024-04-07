::hdmdOptionVars<-{
	lv = 0	//세이브파일에서 로드한 레벨, 직접 영향은 없음 (직접 영향은 ::hdmdState.lv)
}

::hdmdOption<-{
	function admin_check(player){
		if(player.GetNetworkIDString() == ::hdmdState.admin){
			return true;
		}else{
			return false;
		}
	}

	function hostname(){
		local hostname = Convars.GetStr("hostname");
		local gmode = "coop";
		if(::hdmdState.gamemode == 1)gmode = "hunter";
		if(hostname.find("Tactical Training") == null){
			Convars.SetValue("hostname", Convars.GetStr("hostname") + "\ngamemode: Tactical Training " + gmode + " Lv" + ::hdmdState.lv);
		}else{
			Convars.SetValue("hostname", GetListenServerHost().GetPlayerName() + "\ngamemode: Tactical Training " + gmode + " Lv" + ::hdmdState.lv);
		}
	}

	function gmodeSet(mode){
		if(mode == -1){
			switch(::hdmdState.gamemode){
				case 0:
					::printlang("\x01   Current game is in\x03 Normal Training mode\x01.",
								"\x01   현재 게임은 \x03일반 트레이닝 모드\x01입니다.",
								"\x01   現在のゲームは\x03通常トレーニングモード\x01です。",
								"\x01   El juego actual está en\x03 Normal Training mode\x01.",
								-3);
				break;
				case 1:
					::printlang("\x01   Current game is in\x03 Hunter Hunting Training mode\x01.",
								"\x01   현재 게임은 \x03헌터 헌팅 트레이닝 모드\x01입니다.",
								"\x01   現在のゲームは\x03ハンターハンティングトレーニングモード\x01です。",
								"\x01   El juego actual está en\x03 Hunting Training mode\x01.",
								-3);
				break;
			}
			return;
		}
		if(mode == ::hdmdState.gamemode){
			::printlang("\x01   Same as current game mode.",
						"\x01   현재 게임 모드와 같습니다.",
						"\x01   現在のゲームモードと同じです。",
						"\x01   Es igual que la modo juego actual.",
						-3);
			return;
		}
		if(::hdmdState.start){
			::printlang("\x01   Can't change the difficulty level after leaving the safe zone.",
						"\x01   안전구역을 떠난 이후에는 난이도 등급을 변경할 수 없습니다.",
						"\x01   安全区域を離れた後は難易度の等級を変更することはできません。",
						"\x01   No puedo cambiar el dificultad nivel después de salir de la zona segura.",
						-3);
			return;
		}
		if(mode == 0){
			::printlang("\x01   Change to\x03 Normal Training mode\x01.",
						"\x01   \x03일반 트레이닝\x01으로 변경합니다.",
						"\x01   \x03通常トレーニング\x01に変更します。",
						"\x01   Cambie al\x03 Normal Training mode\x01.",
						-3);
		}else if(mode == 1){
			::printlang("\x01   Change to\x03 Hunting Training mode\x01.",
						"\x01   \x03헌터 헌팅 트레이닝\x01으로 변경합니다.",
						"\x01   \x03ハンターハンティングトレーニング\x01に変更します。",
						"\x01   Cambia al\x03 Hunting Training mode\x01.",
						-3);
		}
		StringToFile("hardmode/gamemode.txt", mode.tostring());
		::hdmdOption.hostname();
	}

	function levelSet(lv){
		if(lv == ::hdmdState.lv){
			::printlang("\x01   Same as current difficulty.",
						"\x01   현재 난이도와 같습니다.",
						"\x01   現在の難易度と同じです。",
						"\x01   Es igual que la dificultad actual.",
						-3);
			return;
		}
		if(::hdmdState.start){
			::printlang("\x01   Can't change the difficulty level after leaving the safe zone.",
						"\x01   안전구역을 떠난 이후에는 난이도 등급을 변경할 수 없습니다.",
						"\x01   安全区域を離れた後は難易度の等級を変更することはできません。",
						"\x01   No puedo cambiar el dificultad nivel después de salir de la zona segura.",
						-3);
			return;
		}
		local criteria = 5;
		if(lv >= 6)criteria = 3;
		if(::hardmodeVars.sessionData["count_fail_lv"+lv] >= criteria){
			::printlang("\x01   Can't challenge \x03Level "+lv+"\x01 difficulty in this game\n \x01  because team failed too many rounds.",
						"\x01   너무 많은 라운드를 실패했기 때문에\n \x01  이번 게임에서는 \x03"+lv+"등급\x01 난이도에 도전할 수 없습니다.",
						"\x01   あまりにも多くのラウンドが失敗したため、\n \x01  今回のゲームでは\x03"+lv+"等級\x01難易度に挑戦できません。",
						"\x01   No se puede desafiar el dificultad\x03 Nivel "+lv+"\x01 en este juego porque\n \x01  el equipo falló en demasiadas rondas.",
						-3);
			return;
		}else{
			::printlang("\x01   Set the difficulty to \x03Level "+lv+"\x01. ( "+::hdmdState.lv+" → "+lv+" )",
						"\x01   게임 난이도를\x03 "+lv+"등급\x01으로 설정합니다. ( "+::hdmdState.lv+" → "+lv+" )",
						"\x01   ゲーム難易度を\x03"+lv+"等級\x01に設定します。( "+::hdmdState.lv+" → "+lv+" )",
						"\x01   Cambiar la dificultad al\x03 Nivel "+lv+"\x01. ( "+::hdmdState.lv+" → "+lv+" )",
						-3);
			StringToFile("hardmode/lv.txt", lv.tostring());
			
			if(lv==7)::hdmdItemFunc.kit2pills();
			::hdmdOption.levelAdjust(lv);

			DirectorScript.GetDirectorOptions().A_CustomFinale_StageCount <- 1;
			DirectorScript.GetDirectorOptions().A_CustomFinale1 <- 8;
			DirectorScript.GetDirectorOptions().A_CustomFinaleValue1 <- 0.0;
			
			local ent = null;
			if (ent = Entities.FindByClassname(ent, "info_director")){
				if(ent.IsValid())
					DoEntFire("!self", "ScriptedPanicEvent", "", 0.0, null, ent);
			}
			::hardmodeVars.sessionData["lv"] <- ::hdmdState.lv;
			SaveTable("hdmd", ::hardmodeVars.sessionData);
			::hdmdOption.hostname();
		}
	}

	function levelAllow(){
		::hdmdState.lv_allow = 1;
		for(local i = 1; i <= 7; i++){
			local allowN = 5;	if(i >= 6)allowN = 3;
			if(::hardmodeVars.sessionData["count_fail_lv"+i] < allowN && ::hdmdState.lv_allow <= i){
				::hdmdState.lv_allow = i;
			}
		}
		
	/*	::printlang("\x01   .",
					"\x01   "+::hdmdState.lv_allow+"등급까지 허용됨.",
					"\x01   。",
					"\x01   .",
					-3);	//*/
	}

	function levelAdjust(lv){
	/*	::printlang("\x01   .",
					"\x01   등급 조절 시도.",
					"\x01   。",
					"\x01   .",
					-3);	//*/
		if(::hdmdState.lv_allow < lv){
			::hdmdSurvFunc.countPlayer();
			if(::hdmdState.lv != ::hdmdState.lv_allow && ::hdmdSurvVars.humanCount > 1){
				::printlang("\x01   The difficulty level has been demoted. ( "+::hardmodeVars.sessionData["lv"]+" → "+::hdmdState.lv_allow+" )",
							"\x01   난이도 등급이 강등 조정되었습니다. ( "+::hardmodeVars.sessionData["lv"]+" → "+::hdmdState.lv_allow+" )",
							"\x01   難易度の等級が降格調整されました。( "+::hardmodeVars.sessionData["lv"]+" → "+::hdmdState.lv_allow+" )",
							"\x01   El nivel de dificultad ha sido degradado.( "+::hardmodeVars.sessionData["lv"]+" → "+::hdmdState.lv_allow+" )",
							-3);
				::hdmdState.lv = ::hdmdState.lv_allow;
			}
		}else{
			::hdmdState.lv = lv;
		}
	}
}

::saveset <- function(setv, admin){
	if(!::hdmdOption.admin_check(admin)){
		admin = split(admin.GetNetworkIDString(),":");
		admin = admin[0]+"_"+admin[1]+"_"+admin[2];
		switch(setv){
			case "lv" :
				local allowN = 5;	if(::hdmdState.lv >= 6)allowN = 3;
				local count = "(";
				if(hdmdState.lv == 1)count = "";//count += ::hardmodeVars.sessionData["count_fail_lv"+::hdmdState.lv]+") ";
				else count += ::hardmodeVars.sessionData["count_fail_lv"+::hdmdState.lv]+"/"+allowN+") ";

				if(::hdmdOptionVars.lv == ::hdmdState.lv || ::hdmdState.lv == 1){
					::printlang("\x01   The current level of difficulty is\x03 Level "+::hdmdOptionVars.lv+"\x01"+". "+count,
								"\x01   현재 난이도는\x03 "+::hdmdOptionVars.lv+"등급\x01입니다. "+count,
								"\x01   今の難易度は\x03 "+::hdmdOptionVars.lv+"等級\x01です。"+count,
								"\x01   La dificultad actual es\x03 Nivel "+::hdmdOptionVars.lv+"\x01"+". "+count,
								-3);
				}else{
					local lv = ::hdmdOptionVars.lv - ::hdmdState.lv;
					::printlang("\x01   The current level of difficulty is\x03 Level "+::hdmdState.lv+"\x01"+". "+count+"(Level "+lv+" Downgrade)",
								"\x01   현재 난이도는\x03 "+::hdmdState.lv+"등급\x01입니다. "+count+"("+lv+"등급 강등)",
								"\x01   今の難易度は\x03 "+::hdmdState.lv+"等級\x01です。 "+count+"("+lv+"等級 降格)",
								"\x01   La dificultad actual es\x03 Nivel "+::hdmdState.lv+"\x01"+". "+count+"(Rebaja de Nivel "+lv+")",
								-3);
				}
				break;
			case "mode" :
				::hdmdOption.gmodeSet(-1);
			break;
			default :
				::printlang("\x01   Only the host can change hard mode setting.",
							"\x01   호스트만 하드모드 설정을 변경할 수 있습니다.",
							"\x01   ホストのみハードモード設定を変更できます。",
							"\x01   Solo el anfritión de la sala puede cambiar la configuración de Hard Mode.",
							-3);
				break;
		}
	}else{
		switch(setv){
			case "killall" :
				local ent = null;
				while (ent = Entities.FindByClassname(ent, "player")){
					if(ent.IsValid())if(ent.IsSurvivor()){
						ent.TakeDamage(100, 128, ent);
					}
				}
			return;
			case "lv" :
				local allowN = 5;	if(::hdmdState.lv >= 6)allowN = 3;
				local count = "(";
				if(hdmdState.lv == 1)count = "";//count += ::hardmodeVars.sessionData["count_fail_lv"+::hdmdState.lv]+") ";
				else count += ::hardmodeVars.sessionData["count_fail_lv"+::hdmdState.lv]+"/"+allowN+") ";

				if(::hdmdOptionVars.lv == ::hdmdState.lv || ::hdmdState.lv == 1){
					::printlang("\x01   The current level of difficulty is\x03 Level "+::hdmdOptionVars.lv+"\x01"+". "+count,
								"\x01   현재 난이도는\x03 "+::hdmdOptionVars.lv+"등급\x01입니다. "+count,
								"\x01   今の難易度は\x03 "+::hdmdOptionVars.lv+"等級\x01です。"+count,
								"\x01   La dificultad actual es\x03 Nivel "+::hdmdOptionVars.lv+"\x01"+". "+count,
								-3);
				}else{
					printl(::hdmdOptionVars.lv);
					printl(::hdmdState.lv);
					local lv = ::hdmdOptionVars.lv - ::hdmdState.lv;
					::printlang("\x01   The current level of difficulty is\x03 Level "+::hdmdState.lv+"\x01"+". "+count+"(Level "+lv+" Downgrade)",
								"\x01   현재 난이도는\x03 "+::hdmdState.lv+"등급\x01입니다. "+count+"("+lv+"등급 강등)",
								"\x01   今の難易度は\x03 "+::hdmdState.lv+"等級\x01です。 "+count+"("+lv+"等級 降格)",
								"\x01   La dificultad actual es\x03 Nivel "+::hdmdState.lv+"\x01"+". "+count+"(Rebaja de Nivel "+lv+")",
								-3);
				}
			break;
			case "lv1" :
				::hdmdOption.levelSet(1);
			break;
			case "lv2" :
				::hdmdOption.levelSet(2);
			break;
			case "lv3" :
				::hdmdOption.levelSet(3);
			break;
			case "lv4" :
				::hdmdOption.levelSet(4);
			break;
			case "lv5" :
				::hdmdOption.levelSet(5);
			break;
			case "lv6" :
				::hdmdOption.levelSet(6);
			break;
			case "lv7" :
				::hdmdOption.levelSet(7);
			break;
			case "mode" :
				::hdmdOption.gmodeSet(-1);
			break;
			case "coop" :
				::hdmdOption.gmodeSet(0);
			break;
			case "hunter" :
				::hdmdOption.gmodeSet(1);
			break;
			case "msgShow" :
				StringToFile("hardmode/msg.txt", "0");
				::printlang("\x01   Display game info messages.",
							"\x01   게임 정보 메시지를 표시합니다.",
							"\x01   ゲーム情報メッセージを表示します。",
							"\x01   Mostrar mensajes de información sobre la partida.",
							-3);
			break;
			case "msgHide" :
				::printlang("\x01   Don't display game info messages.",
							"\x01   게임 정보 메시지를 표시하지 않습니다.",
							"\x01   ゲーム情報メッセージを表示しません。",
							"\x01   No mostrar mensajes de información sobre la partida.",
							-3);
				::printlang("\x01   Enter '\x03!msg\x01' again in the chat to display game info messages.",
							"\x01   다시 '\x03!msg\x01'를 입력하시면 게임 정보 메시지를 표시합니다.",
							"\x01   もう一度 「\x03!msg\x01」を入力すると、ゲーム情報メッセージが表示されます。",
							"\x01   Escribe '!msg' de nuevo en el chat para\n   mostrar mensajes de información sobre la partida.",
							-3);
				StringToFile("hardmode/msg.txt", "1");
			break;
			case "hpShowAll" :
				StringToFile("hardmode/hpm.txt", "0");
				::printlang("\x01   Display the HP of all special infected.",
							"\x01   모든 특수 감염자의 HP를 표시합니다.",
							"\x01   すべての特殊感染者のHPを表示します。",
							"\x01   Mostrar la vida de todos los infectados especiales.",
							-3);
			break;
			case "hpShow" :
				StringToFile("hardmode/hpm.txt", "1");
				::printlang("\x01   Display the HP of Tanks and Witches.",
							"\x01   탱크와 윗치의 HP를 표시합니다.",
							"\x01   タンクとウィッチのHPを表示します。",
							"\x01   Mostrar la vida de los Tanks y Witches.",
							-3);
			break;
			case "hpHide" :
				StringToFile("hardmode/hpm.txt", "2");
				::printlang("\x01   Don't display the HP of all infected.",
							"\x01   모든 감염자의 HP를 표시하지 않습니다.",
							"\x01   すべての感染者のHPを表示しません。",
							"\x01   No mostrar la vida de los infectados especiales.",
							-3);
			break;
			case "dmg_normal" :
				StringToFile("hardmode/capdmg.txt", "0");
				::printlang("\x01   Set capture damage to normal.",
							"\x01   포획 피해량을 보통으로 설정합니다.",
							"\x01   捕獲ダメージを通常に設定します。",
							"\x01   Establezca el daño de captura en normal.",
							-3);
			break;
			case "dmg_detailed" :
				StringToFile("hardmode/capdmg.txt", "1");
				::printlang("\x01   Set capture damage to detailed.",
							"\x01   포획 피해량을 정밀하게 설정합니다.",
							"\x01   捕獲ダメージを精密に設定します。",
							"\x01   Establezca el daño de captura en detallado.",
							-3);
			break;
			case "ammo_0" :
				StringToFile("hardmode/ammo.txt", "0");
				::printlang("\x01   Set ammo capacity to default.",
							"\x01   탄약 보유량을 기본 설정합니다.",
							"\x01   弾薬の保有量を基本設定します。",
							"\x01   Establece la capacidad de municion por defecto.",
							-3);
			break;
			case "ammo_1" :
				StringToFile("hardmode/ammo.txt", "1");
				::printlang("\x01   Set ammo capacity to extra.",
							"\x01   탄약 보유량을 증량 설정합니다.",
							"\x01   弾薬の保有量を増量設定します。",
							"\x01   Establezca la capacidad de municion en extra.",
							-3);
			break;
			case "pistol_0" :
				StringToFile("hardmode/weapon/pistol.txt", "0");
				::printlang("\x01   Allow magnum pistols.",
							"\x01   매그넘 권총을 허용합니다.",
							"\x01   マグナムピストルを許可します。",
							"\x01   Permitir pistolas magnum.",
							-3);
			break;
			case "pistol_1" :
				StringToFile("hardmode/weapon/pistol.txt", "1");
				::printlang("\x01   Prohibit magnum pistols.",
							"\x01   매그넘 권총을 금지합니다.",
							"\x01   マグナムピストルを禁止します。",
							"\x01   Prohibir las pistolas magnum.",
							-3);
			break;
			case "shotgun_0" :
				StringToFile("hardmode/weapon/shotgun.txt", "0");
				::printlang("\x01   Allow Tier 2 shotguns.",
							"\x01   2차 산탄총을 허용합니다.",
							"\x01   ティア２ショットガンを許可します。",
							"\x01   Permitir escopetas de Tier 2.",
							-3);
			break;
			case "shotgun_1" :
				StringToFile("hardmode/weapon/shotgun.txt", "1");
				::printlang("\x01   Prohibit Tier 2 shotguns.",
							"\x01   2차 산탄총을 금지합니다.",
							"\x01   ティア２ショットガンを禁止します。",
							"\x01   Prohibir las escopetas de Tier 2.",
							-3);
			break;
			case "rifle_0" :
				StringToFile("hardmode/weapon/rifle.txt", "0");
				::printlang("\x01   Allow Tier 2 assault rifles.",
							"\x01   2차 돌격소총을 허용합니다.",
							"\x01   ティア２アサルトライフルを許可します。",
							"\x01   Permitir rifles de asalto de Tier 2.",
							-3);
			break;
			case "rifle_1" :
				StringToFile("hardmode/weapon/rifle.txt", "1");
				::printlang("\x01   Prohibit Tier 2 assault rifles.",
							"\x01   2차 돌격소총을 금지합니다.",
							"\x01   ティア２アサルトライフルを禁止します。",
							"\x01   Prohibir los rifles de asalto de Tier 2.",
							-3);
			break;
			case "sniper_0" :
				StringToFile("hardmode/weapon/sniper.txt", "0");
				::printlang("\x01   Allow Tier 2 sniper rifles.",
							"\x01   2차 저격소총을 허용합니다.",
							"\x01   ティア２スナイパーライフルを許可します。",
							"\x01   Permitir rifles de francotirador de Tier 2.",
							-3);
			break;
			case "sniper_1" :
				StringToFile("hardmode/weapon/sniper.txt", "1");
				::printlang("\x01   Prohibit Tier 2 sniper rifles.",
							"\x01   2차 저격소총을 금지합니다.",
							"\x01   ティア２スナイパーライフルを禁止します。",
							"\x01   Prohibir los rifles de francotirador de Tier 2.",
							-3);
			break;
			case "allWeapon_0" :
				StringToFile("hardmode/weapon/pistol.txt", "0");
				StringToFile("hardmode/weapon/shotgun.txt", "0");
				StringToFile("hardmode/weapon/rifle.txt", "0");
				StringToFile("hardmode/weapon/sniper.txt", "0");
				::printlang("\x01   Allow every Tier 2 weapons.",
							"\x01   2차 무기를 모두 허용합니다.",
							"\x01   ティア2武器を全て許可します。",
							"\x01   Permitir todas las Tier 2 armas.",
							-3);
			break;
			case "allWeapon_1" :
				StringToFile("hardmode/weapon/pistol.txt", "1");
				StringToFile("hardmode/weapon/shotgun.txt", "1");
				StringToFile("hardmode/weapon/rifle.txt", "1");
				StringToFile("hardmode/weapon/sniper.txt", "1");
				::printlang("\x01   Prohibit every Tier 2 weapons.",
							"\x01   2차 무기를 모두 금지합니다.",
							"\x01   ティア2武器を全て禁止します。",
							"\x01   Prohibir todas las Tier 2 armas.",
							-3);
			break;
		}
	}
	::loadset();
}

::loadset <- function(){
	::load_admin();

	::hardmodeVars.lang = FileToString("hardmode/lang.txt");
	if(::hardmodeVars.lang == null)::hardmodeVars.lang = 0;
	else ::hardmodeVars.lang = ::hardmodeVars.lang.tointeger();
	if(::hardmodeVars.lang >= 4 || ::hardmodeVars.lang < 0)::hardmodeVars.lang = 0;
	
	::hardmodeVars.msgShow = FileToString("hardmode/msg.txt");
	if(::hardmodeVars.msgShow == null)::hardmodeVars.msgShow = 0;
	else ::hardmodeVars.msgShow = ::hardmodeVars.msgShow.tointeger();
	if(::hardmodeVars.msgShow >= 2 || ::hardmodeVars.msgShow < 0)::hardmodeVars.msgShow = 0;

	::hardmodeVars.hpShow = FileToString("hardmode/hpm.txt");
	if(::hardmodeVars.hpShow == null)::hardmodeVars.hpShow = 2;
	else ::hardmodeVars.hpShow = ::hardmodeVars.hpShow.tointeger();
	if(::hardmodeVars.hpShow >= 3 || ::hardmodeVars.hpShow < 0)::hardmodeVars.hpShow = 2;
	
	::hardmodeVars.dmg = FileToString("hardmode/capdmg.txt");
	if(::hardmodeVars.dmg == null)::hardmodeVars.dmg = 0;
	else ::hardmodeVars.dmg = ::hardmodeVars.dmg.tointeger();
	if(::hardmodeVars.dmg >= 2 || ::hardmodeVars.dmg < 0)::hardmodeVars.dmg = 0;

	if(::hardmodeVars.dmg == 0){
		Convars.SetValue("z_jockey_ride_damage_interval", 1.0);
		Convars.SetValue("tongue_choke_damage_interval", 1.0);
		Convars.SetValue("z_pounce_damage_delay", 1.0);
			Convars.SetValue("pain_pills_health_value",50);
			Convars.SetValue("adrenaline_health_buffer",25);
	}else{
		Convars.SetValue("z_jockey_ride_damage_interval", 0.25);
		Convars.SetValue("tongue_choke_damage_interval", 0.25);
		Convars.SetValue("z_pounce_damage_delay", 0.5);
			Convars.SetValue("pain_pills_health_value",2);
			Convars.SetValue("adrenaline_health_buffer",1);
	}

	::hardmodeVars.ffset = FileToString("friendlyfire/set.txt");
	if(::hardmodeVars.ffset == null)::hardmodeVars.ffset = 0;
	else ::hardmodeVars.ffset = ::hardmodeVars.ffset.tointeger();
	if(::hardmodeVars.ffset >= 3 || ::hardmodeVars.ffset < 0)::hardmodeVars.ffset = 0;

	::hdmdOptionVars.lv = FileToString("hardmode/lv.txt");
	if(::hdmdOptionVars.lv == null)::hdmdOptionVars.lv = 4;
	else ::hdmdOptionVars.lv = ::hdmdOptionVars.lv.tointeger();
	if(::hdmdOptionVars.lv >= 8 || ::hdmdOptionVars.lv < 1)::hdmdOptionVars.lv = 4;

	if(::hdmdState.lv == 0)::hdmdState.lv = ::hdmdOptionVars.lv;
	::hdmdOption.levelAllow();
	
	::hdmdState.gamemode = FileToString("hardmode/gamemode.txt");
	if(::hdmdState.gamemode == null)::hdmdState.gamemode = 0;
	else ::hdmdState.gamemode = ::hdmdState.gamemode.tointeger();
	if(::hdmdState.gamemode >= 2 || ::hdmdState.gamemode < 0)::hdmdState.gamemode = 0;

	::hdmdState.ammo = FileToString("hardmode/ammo.txt");
	if(::hdmdState.ammo == null)::hdmdState.ammo = 1;
	else ::hdmdState.ammo = ::hdmdState.ammo.tointeger();
	if(::hdmdState.ammo >= 2 || ::hdmdState.ammo < 0)::hdmdState.ammo = 1;
	::hdmdSurvFunc.ammo();

	::hdmdState.pistol = FileToString("hardmode/weapon/pistol.txt");
	if(::hdmdState.pistol == null)::hdmdState.pistol = 0;
	else ::hdmdState.pistol = ::hdmdState.pistol.tointeger();
	if(::hdmdState.pistol >= 2 || ::hdmdState.pistol < 0)::hdmdState.pistol = 0;
	
	::hdmdState.shotgun = FileToString("hardmode/weapon/shotgun.txt");
	if(::hdmdState.shotgun == null)::hdmdState.shotgun = 0;
	else ::hdmdState.shotgun = ::hdmdState.shotgun.tointeger();
	if(::hdmdState.shotgun >= 2 || ::hdmdState.shotgun < 0)::hdmdState.shotgun = 0;

	::hdmdState.rifle = FileToString("hardmode/weapon/rifle.txt");
	if(::hdmdState.rifle == null)::hdmdState.rifle = 0;
	else ::hdmdState.rifle = ::hdmdState.rifle.tointeger();
	if(::hdmdState.rifle >= 2 || ::hdmdState.rifle < 0)::hdmdState.rifle = 0;

	::hdmdState.sniper = FileToString("hardmode/weapon/sniper.txt");
	if(::hdmdState.sniper == null)::hdmdState.sniper = 0;
	else ::hdmdState.sniper = ::hdmdState.sniper.tointeger();
	if(::hdmdState.sniper >= 2 || ::hdmdState.sniper < 0)::hdmdState.sniper = 0;

	::hdmdOption.hostname();
}

::load_admin <- function(){
	::hdmdState.admin = FileToString("hardmode/admin.txt");
	if(::hdmdState.admin == null || ::hdmdState.admin.find(":") == null)::hdmdState.admin = "";
}