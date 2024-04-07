::mp_gamemode <- Convars.GetStr("mp_gamemode").tolower();
if(::mp_gamemode != "coop" && ::mp_gamemode != "realism" && ::mp_gamemode != "versus")return;

//IncludeScript("VSLib");
Convars.SetValue("sv_consistency", 0);
Convars.SetValue("sv_pure_kick_clients", 0);

if (!("MANACAT" in getroottable()))
{
	::MANACAT <-
	{
	}
}

if(!("hardmode" in ::MANACAT)){
	::MANACAT.hardmode <- {
		check = false
		ver = "08/14/2023"
	}
	::MANACAT.slot0 <- function(ent){
		local msg = Convars.GetClientConvarValue("cl_language", ent.GetEntityIndex());
		switch(msg){
			case "korean":case "koreana":	msg = "택티컬 트레이닝";	break;
			case "japanese":				msg = "タクティカルトレーニング";	break;
			case "spanish":					msg = "Tactical Training";	break;
			default:						msg = "Tactical Training";	break;
		}
		ClientPrint( ent, 5, "\x02 - "+msg+" \x01 v"+::MANACAT.hardmode.ver);
	};
}

printl( "<MANACAT> Hard Mode Loaded. v"+::MANACAT.hardmode.ver);

::hdmdState <- {
	lv = 0
	lv_allow = 0

	introskip = false //1챕터에서 인트로를 스킵할 것인가(처음 1회는 인트로 스킵 없음)
	start = false //시작지점에서 출발했는지
	regular = false //하드모드 난이도에 들어갔는지
	finale = false //최종전을 진행중인지
	incap = false //무력화 상황인지
	gameDif = "normal"
	admin = ""
	
	ammo = 0 //0 = 증량 | 1 = 기본값
	pistol = 0 //0 = 제한없음 | 1 = 매그넘 금지
	shotgun = 0 //0 = 제한없음 | 1 = 1차무기만
	rifle = 0 //0 = 제한없음 | 1 = 1차무기만
	sniper = 0 //0 = 제한없음 | 1 = 스카웃만

	escape_route = [] //탈출경로 내비게이션 매쉬, [0] = flow [1] = nav mesh [2] = GetCenter
//	spawnCheckpointItem = false //맵 전환시 넘어온 아이템이 1회 이상 변환되었는지?

	gamemode = 0//0 = 기본, 1 = 헌터모드
}

::hardmodeVars <- {
	startTime = 0
	chkhard = 0 //0이면 아직 하드모드 진입 안한 것, 1이면 진입한 것, 100이면 게임 종료(탈출)

	hordeRes = 1000

	updateTime = 0
	//tank_order = 0 //탱크 스폰 차례 (대전)(특좀처럼 스폰시키고 싶을 때 ConvertZombieClass)
	//tank_current = 0 //현재까지 스폰되었던 탱크 수 (대전)(특좀처럼 스폰시키고 싶을 때 ConvertZombieClass)

	incapCount = 0 //생존자 무력화 횟수

	debug = 0 // 1이면 게임상황 보임

	lang = 0 //0 = en | 1 = kr | 2 = jp
	msgShow = 0 //0 = show | 1 = no show
	msg = ""
	firstmsg = 0 //1챕터 처음 시작하고 뜰 메시지
	hpShow = 0 //0 = all show | 1 = tank & witch | 2 = no show
	dmg = 0 //0 = normal | 1 = fast
	ffset = 0 //팀킬

	survList = []
	playerList = []

	//이하 집계
	//czkill = 0

	sessionData = {}
	introData = {}//세션당 인트로 최초 1회를 보았는지 저장함
	//맵 전환시 변환된 아이템 좌표
	itemData = {}
	pistolData = {}
	shotgunData = {}
	rifleData = {}
	sniperData = {}
	weaponData = {} //_spawn이 아닌 낱개 무기를 포괄함
}

::hdmdUpdate1 <- function(params){
	::hdmdSurvFunc.groundCheck();
	::setAggressiveSpecials();
}

::hdmdUpdate3 <- function(params){
	if(::hdmdSIVars.boomerRes < 1000)::hdmdSIVars.boomerRes+=4;
	if(::hardmodeVars.hordeRes < 1000)::hardmodeVars.hordeRes+=6;

	/* //디버그
	hud_positioning();
	//*/
	::hdmdCIFunc.common_zombie();
	::hdmdSIFunc.special_zombie();
	::hdmdTankFunc.tank_zombie();
	::hardmodeVars.updateTime = Time();

	local someplayer;

	::tank_gen();
	//printl("타임"+Time() + "  인트로 "+Director.GetCommonInfectedCount());
}

IncludeScript("manacat_hardmode/survivor");
IncludeScript("manacat_hardmode/item");
IncludeScript("manacat_hardmode/common_infected");
IncludeScript("manacat_hardmode/special_infected");
IncludeScript("manacat_hardmode/hardmode_introduce");
IncludeScript("manacat_hardmode/cvar");
IncludeScript("manacat_hardmode/hardmode_lang");
IncludeScript("manacat_hardmode/hardmode_showHP");

IncludeScript("manacat_hardmode/tank");
IncludeScript("manacat_hardmode/witch");
IncludeScript("manacat_hardmode/hardmode_damage");
IncludeScript("manacat_hardmode/hardmode_saveload");
//IncludeScript("manacat_hardmode/classChanger");
IncludeScript("manacat_hardmode/introskip");

IncludeScript("manacat_hardmode/manacatTimer");
if (!("manacatTimers" in getroottable())){
	IncludeScript("manacat/manacatTimer");
}

IncludeScript("manacat_hardmode/info");
if (!("manacatInfo" in getroottable())){
	IncludeScript("manacat/info");
}

::hardmodeFunc<-{
	function start(params){
		if(!::hdmdState.regular){
			::hdmdState.regular = true;
			::hardmodeFunc.toHardmodeSet();
		}
	}

	function countSurv(userid = 0){
		if(userid == 0){//초기 추가
			local _player = null;
			while (_player = Entities.FindByClassname(_player, "player")){
				if (_player.IsValid())if(_player.IsSurvivor() == true){
					local _pmodel = _player.GetModelName();
					local len = ::hardmodeVars.survList.len();
					local _pid = _player.GetPlayerUserId();
					for(local i=0;i<len;i++){
						if(::hardmodeVars.survList[i] == _pmodel){
							for(local j=0;j<len;j++)if(::hardmodeVars.playerList[j] == _pid)::hardmodeVars.playerList[j] = 0;
							if(IsPlayerABot(_player) == false)::hardmodeVars.playerList[i] = _pid;
							return;
						}
					}
					::hardmodeVars.survList.append(_pmodel);	::hardmodeVars.playerList.append(0);
					if(IsPlayerABot(_player) == false)::hardmodeVars.playerList[len] = _pid;
				}
			}
		}else{//특정유저만 생존자표에 넣을 때
			local _player = GetPlayerFromUserID(userid); local _pmodel = _player.GetModelName();
			local len = ::hardmodeVars.survList.len();
			if(_player.IsSurvivor() == true){
				if(_pmodel == "models/infected/hunter.mdl" || _pmodel == "models/infected/hunter_l4d1.mdl")return;
				for(local i=0;i<len;i++){
					if(::hardmodeVars.survList[i] == _pmodel){
						for(local j=0;j<len;j++)if(::hardmodeVars.playerList[j] == userid)::hardmodeVars.playerList[j] = 0;
						if(IsPlayerABot(_player) == false)::hardmodeVars.playerList[i] = userid;
						return;
					}
				}
				::hardmodeVars.survList.append(_pmodel);	::hardmodeVars.playerList.append(0);
				if(IsPlayerABot(_player) == false)::hardmodeVars.playerList[len] = userid;
			}
		}
	}

	function OnGameEvent_difficulty_changed(params){
		::hdmdState.gameDif = Convars.GetStr("z_difficulty").tolower();
	}

	function OnGameEvent_round_start_post_nav(params){
		::hdmdState.gameDif = Convars.GetStr("z_difficulty").tolower();
		::hdmdState.introskip = false;
		RestoreTable("hdmd", ::hardmodeVars.sessionData);
		local gametime = Director.GetTotalElapsedMissionTime();
		if(::hardmodeVars.sessionData.len() == 0 || ("gametime" in ::hardmodeVars.sessionData && ::hardmodeVars.sessionData["gametime"] > gametime)){
			::hardmodeVars.sessionData["lv"] <- 0;
			::hardmodeVars.sessionData["mapname"] <- "-";
			::hardmodeVars.sessionData["gamecount"] <- 1;
			::hardmodeVars.sessionData["count_fail"] <- 0;
			for(local i = 0; i <= 7; i++)
				::hardmodeVars.sessionData["count_fail_lv"+i] <- 0;
			::hardmodeVars.sessionData["count_death"] <- 0;
			::hdmdState.lv = ::hdmdOptionVars.lv;
		}else{
			::hdmdState.lv = ::hardmodeVars.sessionData["lv"];
		}
		::hardmodeVars.sessionData["gametime"] <- gametime;
		SaveTable("hdmd", ::hardmodeVars.sessionData);
		::loadset();
		::hdmdOption.levelAdjust(::hdmdState.lv);
		::hdmdTankFunc.waterManage();
		//라운드 시작 전

		::hardmodeVars.startTime = Time()+10;
		toHardmodeSet();

		::firstset();

		::hdmdSurvFunc.first_aid_kit();

		::manacatAddTimerByName("hdmd1", 1, true, ::hdmdUpdate1);
		::manacatAddTimerByName("hdmd3", 3, true, ::hdmdUpdate3);
		if(Time().tointeger() == 1){
			::hardmodeVars.firstmsg = 1;
		}

		countSurv();
		::hardmodeFunc.weaponDensity();
		
		//DirectorScript.GetDirectorOptions().cm_ProhibitBosses <- true;
		//DirectorScript.GetDirectorOptions().ProhibitBosses <- true;
		DirectorScript.GetDirectorOptions().DisallowThreatType <- 8; //안전구역에서 나갈때 탱크 플로우 위치가 102면 null로 전환하여 금지 해제
	}

	function OnGameEvent_round_end(params){
		local bot = 0;
		local SearchPlayer = null;	local gamemover = true;
		while (SearchPlayer = Entities.FindByClassname(SearchPlayer, "player")){
			if(SearchPlayer.IsSurvivor()){
				if(IsPlayerABot(SearchPlayer))bot++;
				if(!SearchPlayer.IsDead() && !SearchPlayer.IsDying() && !SearchPlayer.IsIncapacitated())
					gamemover = false;
			}
		}
		if(bot >= 2 && gamemover)::startmsgkr({ force = 0 });
		if(gamemover && ::hdmdState.lv != 1){
			RestoreTable("hdmd", ::hardmodeVars.sessionData);
			::hardmodeVars.sessionData["gamecount"]++;

			if(::hdmdSurvVars.humanCount > 2){
				::hardmodeVars.sessionData["count_fail"]++;
				for(local i = ::hdmdState.lv; i <= 7; i++){
					::hardmodeVars.sessionData["count_fail_lv"+i]++;
				}
			/*	for(local i = 0; i <= 7; i++){
					print(::hardmodeVars.sessionData["count_fail_lv"+i]);
				}
				printl(" ");//*/
				::hardmodeVars.sessionData["mapname"] <- Director.GetMapName();

				::printlang("\x01   Failure Count : "+::hardmodeVars.sessionData["count_fail"],
							"\x01   실패 횟수 : "+::hardmodeVars.sessionData["count_fail"],
							"\x01   失敗回数 : "+::hardmodeVars.sessionData["count_fail"],
							"\x01   Recuento de fallas : "+::hardmodeVars.sessionData["count_fail"],
							-3);

				::hdmdOption.levelAdjust(::hdmdState.lv);
				::hardmodeVars.sessionData["lv"] <- ::hdmdState.lv;
			}
			::hardmodeVars.sessionData["gametime"] <- Director.GetTotalElapsedMissionTime();
			SaveTable("hdmd", ::hardmodeVars.sessionData);
		}
	}

	function OnGameEvent_map_transition(params){
		::hardmodeVars.sessionData["gametime"] <- Director.GetTotalElapsedMissionTime();
		SaveTable("hdmd", ::hardmodeVars.sessionData);
		SaveTable("hdmd_item", ::hardmodeVars.itemData);
		SaveTable("hdmd_pistol", ::hardmodeVars.pistolData);
		SaveTable("hdmd_shotgun", ::hardmodeVars.shotgunData);
		SaveTable("hdmd_rifle", ::hardmodeVars.rifleData);
		SaveTable("hdmd_sniper", ::hardmodeVars.sniperData);
		::hdmdItemFunc.save_weapon();
	}

	function standCheck(ent, tolerance=60){
		local startpos = ent.GetOrigin();
		local endpos = Vector(startpos.x, startpos.y, startpos.z+100);
		local targetNorm = Vector(endpos.x, endpos.y, endpos.z);
		targetNorm.x -= startpos.x;	targetNorm.y -= startpos.y;	targetNorm.z -= startpos.z;
		targetNorm.x = targetNorm.x/targetNorm.Norm();
		targetNorm.y = targetNorm.y/targetNorm.Norm();
		targetNorm.z = targetNorm.z/targetNorm.Norm();

		if(180/PI*acos(ent.GetAngles().Up().Dot(targetNorm)) < tolerance){
			return true;
		}
		return false;
	}

	function OnGameEvent_player_say(params){
		local _player = GetPlayerFromUserID(params.userid);
		local _pName = _player.GetPlayerName();
		local _chat = params.text.tolower();
		_chat = split(_chat," ");
	
		///*//개발중 확인용
		switch(_chat[0]){
			case "!startmsg" : case "!설명" :
				IncludeScript("manacat_hardmode/hardmode_introduce");
				if(::mp_gamemode == "versus") ::manacatAddTimer(0.1, false, ::versusmsg, { tgp = null });
				else ::manacatAddTimer(0.1, false, ::startmsg2, { });
			break;
		//	case "!s" : case "!spec" : case "!관전" :
		//		::spectate(_player);
		//	break;
		//	case "!join" : case "!참여" : case "!참가" :
		//		::jointeam2(_player);
		//	break;
			case "!end" : case "!끝" :	saveset("killall", _player);	break;
			case "!tankplz" :
				printl("탱크 소환");
				ZSpawn( { type = 8, pos = null, ang = QAngle(0,0,0) } );
			break;
			case "!logchk" :
				if(::hardmodeVars.debug == 0){
					printl(Time() + " - - - - - - - - - - - - - - - - - - - - - - - - - -<log_chk> ON");
					::hardmodeVars.debug = 1;
					/*//디버그
					::log_hud.Show();
					::log2_hud.Show();
					::log3_hud.Show();
					//*/
				}else{
					printl(Time() + " - - - - - - - - - - - - - - - - - - - - - - - - - -<log_chk> OFF");
					::hardmodeVars.debug = 0;
					/*//디버그
					::log_hud.Hide();
					::log2_hud.Hide();
					::log3_hud.Hide();
					//*/
				}
			break;
			case "!t" :
				::hdmdItemVars.weaponData = [];
				local len = ::hdmdItemVars.weaponData.len();
				for(local i = 0; i < len; i++)				printl(::hdmdItemVars.weaponData[i]);
				for(local i = 0; i < 100; i++){
					if("weapon"+i in ::hardmodeVars.weaponData)	printl(::hardmodeVars.weaponData["weapon"+i]);
					if("weapon_owner"+i in ::hardmodeVars.weaponData)	printl(::hardmodeVars.weaponData["weapon_owner"+i]);
				}
			break;
			case "!tt_admin" :
				::load_admin();
				if(::hdmdState.admin == ""){
					if(_chat.len() <= 1){
						local code = "";
						for(local i = 0; i < 4; i++){
							for(local j = 0; j < 4; j++){
								code += RandomInt(0,9).tostring();
							}
							if(i != 3)code += "-";
						}
						StringToFile("hardmode/admin.txt", code);
						
						::printlang("\x01   The admin code was generated in \x03"+"admin.txt\x01"+" in the EMS directory.",
									"\x01   관리자 코드를 EMS 디렉토리에 있는 \x03"+"admin.txt\x01"+"에 생성하였습니다.",
									"\x01   管理者コードをEMSディレクトリにある\x03"+"admin.txt\x01"+"に生成しました。",
									"\x01   El admin código fue generado en \x03"+"admin.txt\x01"+" el directorio EMS.",
									-3);
						::printlang("\x01   Please check the file and enter the admin code.",
									"\x01   파일을 확인 후 관리자 코드를 입력해주십시오.",
									"\x01   ファイルを確認後、管理者コードを入力してください。",
									"\x01   Por favor, verifique el archivo y entre el admin código.",
									-3);
						::printlang("\x01   ex) !tt_admin 0000-0000-0000-0000",
									"\x01   예) !tt_admin 0000-0000-0000-0000",
									"\x01   例) !tt_admin 0000-0000-0000-0000",
									"\x01   ex) !tt_admin 0000-0000-0000-0000",
									-3);
					}else{
						local code = FileToString("hardmode/admin.txt");
						if(code == _chat[1]){
							StringToFile("hardmode/admin.txt", _player.GetNetworkIDString());
							::hdmdState.admin = _player.GetNetworkIDString();
							::printlang("\x01   Administrator settings are complete.",
										"\x01   관리자 설정이 완료되었습니다.",
										"\x01   管理者の設定が完了しました。",
										"\x01   La configuración del administrador está completa.",
										-3);
						}else{
							::printlang("\x01   Admin code does not match.",
										"\x01   관리자 코드가 일치하지 않습니다.",
										"\x01   管理者コードが一致しません。",
										"\x01   El admin codigo no coincide.",
										-3);
						}
					}
				}else{
					::printlang("\x01   Administrator is already set up.",
								"\x01   이미 관리자가 설정되어있습니다.",
								"\x01   既に管理者が設定されています。",
								"\x01   Ya esta establecido el administrador.",
								-3);
					::printlang("\x01   To reset the administrator,\n   remove the\x03 admin.txt\x01 file from the EMS directory.",
								"\x01   관리자를 재설정하시려면,\n   EMS 디렉토리에 있는\x03 admin.txt\x01 파일을 제거해주세요.",
								"\x01   管理者を再設定するには、\n   EMSディレクトリにある\x03"+"admin.txt\x01"+"ファイルを削除してください。",
								"\x01   Para resetar al administrador,\n   jubilar al\x03 admin.txt\x01 archivo del directorio EMS.",
								-3);
				}
			break;
			case "!msg" :
				if(::hardmodeVars.msgShow == 0){
					saveset("msgHide", _player);
				}else{
					saveset("msgShow", _player);
				}
			break;
			case "!msg" :
				if(::hardmodeVars.msgShow == 0){
					saveset("msgHide", _player);
				}else{
					saveset("msgShow", _player);
				}
			break;
			case "!ammo" :
				if(::hdmdState.ammo == 0)	saveset("ammo_1", _player);
				else						saveset("ammo_0", _player);
			break;
			case "!pistol" :
				if(::hdmdState.pistol == 0)		saveset("pistol_1", _player);
				else							saveset("pistol_0", _player);
				::hdmdItemFunc.weapon_pistol();
			break;
			case "!shotgun" :
				if(::hdmdState.shotgun == 0)	saveset("shotgun_1", _player);
				else							saveset("shotgun_0", _player);
				::hdmdItemFunc.weapon_shotgun();
			break;
			case "!rifle" :
				if(::hdmdState.rifle == 0)		saveset("rifle_1", _player);
				else							saveset("rifle_0", _player);
				::hdmdItemFunc.weapon_rifle();
			break;
			case "!sniper" :
				if(::hdmdState.sniper == 0)		saveset("sniper_1", _player);
				else							saveset("sniper_0", _player);
				::hdmdItemFunc.weapon_sniper();
			break;
			case "!weapon" :
				if(::hdmdState.pistol == 0 && ::hdmdState.shotgun == 0 && ::hdmdState.rifle == 0 && ::hdmdState.sniper == 0)
						saveset("allWeapon_1", _player);
				else	saveset("allWeapon_0", _player);
				::hdmdItemFunc.weapon_pistol();
				::hdmdItemFunc.weapon_shotgun();
				::hdmdItemFunc.weapon_rifle();
				::hdmdItemFunc.weapon_sniper();
			break;
			case "!hp" :
				if(::hardmodeVars.hpShow == 0){
					saveset("hpShow", _player);
				}else if(::hardmodeVars.hpShow == 1){
					saveset("hpHide", _player);
				}else if(::hardmodeVars.hpShow == 2){
					saveset("hpShowAll", _player);
				}
			break;
			case "!dmg" :
				if(::hardmodeVars.dmg == 0){
					saveset("dmg_detailed", _player);
				}else if(::hardmodeVars.dmg == 1){
					saveset("dmg_normal", _player);
				}
			break;
			case "!lv" :	saveset("lv", _player);		break;
			case "!lv1" :	saveset("lv1", _player);	break;
			case "!lv2" :	saveset("lv2", _player);	break;
			case "!lv3" :	saveset("lv3", _player);	break;
			case "!lv4" :	saveset("lv4", _player);	break;
			case "!lv5" :	saveset("lv5", _player);	break;
			case "!lv6" :	saveset("lv6", _player);	break;
			case "!lv7" :	saveset("lv7", _player);	break;
			case "!gm" :
				if(_chat.len() == 1){
					saveset("mode", _player);
				}else if(_chat[1] == "coop" || _chat[1] == "normal"){
					saveset("coop", _player);
				}else if(_chat[1] == "hunter"){
					saveset("hunter", _player);
				}else{
					saveset("mode", _player);
				}
			break;
		}
	}

	function OnGameEvent_finale_vehicle_leaving(params){
		if(::hardmodeVars.chkhard != 100){
			::hardmodeVars.chkhard = 100;
			::printlang("\x01"+"Thank you for playing \x03"+"TACTICAL TRAINING\x01.",
						"\x03택티컬 트레이닝\x01을 플레이해주셔서 감사합니다.",
						"\x03戦術トレーニング\x01をプレイしてくださってありがとうございます。",
						"\x01"+"Gracias por jugar \x03"+"TACTICAL TRAINING\x01.",
						-3);
			::manacatAddTimer(3.0, false, ::startmsgkr, { force = 1 });
			::hardmodeVars.msgShow = 1;
		}
	}

	function OnGameEvent_finale_start(params){
		::hdmdState.finale = true;
		toFinaleSet();
		::hardmodeFunc.changeD();
		//printl(DirectorScript.GetDirectorOptions().A_CustomFinale1 + "   " + DirectorScript.GetDirectorOptions().A_CustomFinaleValue1);
		
		/*
		printl(DirectorScript.GetDirectorOptions().B_CustomFinale_StageCount);
		printl(DirectorScript.GetDirectorOptions().A_CustomFinale_StageCount);
		printl(DirectorScript.GetDirectorOptions().A_CustomFinale1 + "   " + DirectorScript.GetDirectorOptions().A_CustomFinaleValue1);
		printl(DirectorScript.GetDirectorOptions().A_CustomFinale2 + "   " + DirectorScript.GetDirectorOptions().A_CustomFinaleValue2);
		printl(DirectorScript.GetDirectorOptions().A_CustomFinale3 + "   " + DirectorScript.GetDirectorOptions().A_CustomFinaleValue3);
		printl(DirectorScript.GetDirectorOptions().A_CustomFinale4 + "   " + DirectorScript.GetDirectorOptions().A_CustomFinaleValue4);
		printl(DirectorScript.GetDirectorOptions().A_CustomFinale5 + "   " + DirectorScript.GetDirectorOptions().A_CustomFinaleValue5);
		printl(DirectorScript.GetDirectorOptions().A_CustomFinale6 + "   " + DirectorScript.GetDirectorOptions().A_CustomFinaleValue6);
		printl(DirectorScript.GetDirectorOptions().A_CustomFinale7 + "   " + DirectorScript.GetDirectorOptions().A_CustomFinaleValue7);
		printl(DirectorScript.GetDirectorOptions().A_CustomFinale8 + "   " + DirectorScript.GetDirectorOptions().A_CustomFinaleValue8);
		*/
		
		//printl(DirectorScript.GetDirectorOptions().B_CustomFinale_StageCount);
	}

	function changeD(params = {}){
		::hdmdSurvFunc.teamAnalysis();

		::hdmdSurvFunc.first_aid_kit();
		::hdmdSurvFunc.ammo();
		local currentlevel = ::hdmdState.lv;
		if(currentlevel > 5)currentlevel = 5;

		if(::mp_gamemode == "coop"){
			if(::hdmdSurvVars.teamPower <= 2){
				Convars.SetValue("sv_disable_glow_faritems", 0);
			}else{
				Convars.SetValue("sv_disable_glow_faritems", 1);
			}
		}
		if(!Director.IsTankInPlay()){
			if(::hdmdState.finale){
				::hardmodeFunc.toFinaleSet();
			}else{
				::hardmodeFunc.toHardmodeSet();
			}
		}
	}

	function toHardmodeSet(){
		//if(::hardmodeVars.ladderspeed == false && ::hdmdState.lv > 3)::manacatAddTimer(0.1, false, ::ladderspeed, { });
		local cp = ::hdmdSurvVars.playerCount;

		local tankaggro = Director.IsTankInPlay();

		if(::hdmdState.start && Time() >= ::hardmodeVars.startTime.tointeger() + 25){
			if(::mp_gamemode == "coop"){
				if(cp <= 2){
					Convars.SetValue("director_convert_pills", 1);
					Convars.SetValue("survivor_revive_health", 35);
				}else{
					Convars.SetValue("director_convert_pills", 0);
					Convars.SetValue("survivor_revive_health", 30);
				}
			}else if(::mp_gamemode == "realism"){
				Convars.SetValue("director_convert_pills", 0);
				if(cp <= 2){
					Convars.SetValue("survivor_revive_health", 40);
				}else{
					Convars.SetValue("survivor_revive_health", 35);
				}
			}
			::hdmdSurvFunc.burn_factor();
		}else{
			if(!::hdmdState.start){
				Convars.SetValue("first_aid_heal_percent", 0.9);
				Convars.SetValue("first_aid_kit_use_duration", 3);
			}
			
			//if(Convars.GetStr("mp_gamemode") == "coop"){
				Convars.SetValue("survivor_revive_health", 30);
				Convars.SetValue("director_convert_pills", 0);
			//}else if(Convars.GetStr("mp_gamemode") == "realism"){
			//	Convars.SetValue("survivor_revive_health", 30);
			//	Convars.SetValue("director_convert_pills", 0);
			//}

			::hdmdCIFunc.common_zombie();
			::hdmdSurvFunc.burn_factor_ez();
		}
	}

	function toFinaleSet(){
		//DirectorScript.GetDirectorOptions().cm_ProhibitBosses <- false;
		//DirectorScript.GetDirectorOptions().ProhibitBosses <- false;
		DirectorScript.GetDirectorOptions().DisallowThreatType <- null;

		//printl("피날레 분석");
		//local doubleTankFinale = false;
		local findTank = 0;
		if(::hdmdState.lv > 6)findTank = 1;
		for(local i = 1; i < 100; i++){
			try{
				//printl("탱크" + DirectorScript.GetDirectorOptions()["A_CustomFinale"+i]);
				if(DirectorScript.GetDirectorOptions()["A_CustomFinale"+i] == 1){
					if(::hdmdState.lv > 5 && DirectorScript.GetDirectorOptions()["A_CustomFinaleValue"+i] == 1){
						DirectorScript.GetDirectorOptions()["TankLimit"] <- 4;
						if(findTank != 0)DirectorScript.GetDirectorOptions()["A_CustomFinaleValue"+i] <- 2.1; //그냥 2여도 되지만 0.1은 내가 바꿨다는 구분을 위해 붙임
					}else if(::hdmdState.lv <= 5 && DirectorScript.GetDirectorOptions()["A_CustomFinaleValue"+i] == 2.1){
						DirectorScript.GetDirectorOptions()["A_CustomFinaleValue"+i] <- 1;
					}
					findTank++;
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
		/*
		if(doubleTankFinale == true){
			DirectorScript.GetDirectorOptions()["TankLimit"] <- 2;
			Convars.SetValue("z_tank_health", 3500);
		}else{
			DirectorScript.GetDirectorOptions()["TankLimit"] <- 1;
			Convars.SetValue("z_tank_health", 4000);
		}*/

		if(::hdmdSurvVars.playerCount > 3){
			//SessionOptions.cm_MaxSpecials <- 3;
			//SessionOptions.MaxSpecials <- 3;
			if(::hdmdState.lv <= 5){
				DirectorScript.GetDirectorOptions().cm_MaxSpecials <- 3;
				DirectorScript.GetDirectorOptions().MaxSpecials <- 3;
			}else if(::hdmdState.lv == 6){
				DirectorScript.GetDirectorOptions().cm_MaxSpecials <- 4;
				DirectorScript.GetDirectorOptions().MaxSpecials <- 4;
			}else{
				DirectorScript.GetDirectorOptions().cm_MaxSpecials <- 5;
				DirectorScript.GetDirectorOptions().MaxSpecials <- 5;
			}
		}
		Convars.SetValue("z_wandering_density", 0.05);

		Convars.SetValue("director_convert_pills", 0);
		::hdmdCIFunc.common_zombie();
		::hdmdSurvFunc.burn_factor();
	}

	function weaponDensity(){
		Convars.SetValue("z_gun_swing_coop_max_penalty", 11);
		Convars.SetValue("z_gun_swing_coop_min_penalty", 8);

		Convars.SetValue("director_melee_weapon_density", 25.92);
		Convars.SetValue("director_pistol_density", -1);
		Convars.SetValue("director_ammo_density", -1);

		Convars.SetValue("director_molotov_density", 25.92);
		Convars.SetValue("director_pipe_bomb_density", 12.96);
		Convars.SetValue("director_vomitjar_density", 3.24);

		Convars.SetValue("director_super_weapon_density", -1);
		Convars.SetValue("director_upgradepack_density", -1);
		Convars.SetValue("director_propane_tank_density", -1);
		Convars.SetValue("director_gas_can_density", 25.92);

		Convars.SetValue("director_pain_pill_density", 25.92);
		Convars.SetValue("director_adrenaline_density", 3.24);
		Convars.SetValue("director_defibrillator_density", 3.24);

		Convars.SetValue("director_item_cluster_range", 20);//was 50
	}

	/*//일반 좀비가 눈에 보이는 곳에 나타나는지 테스트
	function OnGameEvent_player_jump(params)
	{
		::SpawnZombiesNearSurv(5);
	}
	*/
}

::CanTraceToLocation <- function(ent, finishPos, traceMask = 131083)
{
	local begin = ent.GetOrigin();
	if(ent.GetClassname() == "player")begin = ent.EyePosition();
	local finish = finishPos;
	
	local m_trace = { start = begin, end = finish, ignore = ent, mask = traceMask };
	TraceLine(m_trace);
	
	if (m_trace.pos.x == finish.x && m_trace.pos.y == finish.y && m_trace.pos.z == finish.z)
		return true;
	
	return false;
}

::ZSpawner <- function(params){
	if(::mp_gamemode == "versus" && ztype != 10)return;
	local ztype = params["ztype"];
	local pos = null;
	if("zsound" in params && params.zsound == "mob")Director.PlayMegaMobWarningSounds();
	if(ztype == 10)pos = Vector(0,0,0);
	ZSpawn( { type = ztype, pos = pos, ang = QAngle(0,0,0) } );
	//printl("spawn "+ztype);
	if(ztype == 8)::hardmodeFunc.toHardmodeSet();
	return;
}

/*
::SpawnZombiesNearSurv <- function(zN = 1){
	if(zN.tointeger() == 0)return;
	::manacatAddTimer(0.1, false, ::SpawnZombiesNearSurv2, { zN2 = zN.tointeger() });
	return;
}

::SpawnZombiesNearSurv2 <- function(params){
	local zN2 = params["zN2"];
	zN2--;
	::SpawnZombieNearSurv();
	::SpawnZombiesNearSurv(zN2);
	return;
}
*/

__CollectEventCallbacks(::hardmodeFunc, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);