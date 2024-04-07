::startmsg <- function(params){
	if(Director.GetMapName().find("m1") != null && ::hardmodeVars.firstmsg == 1){
		::hardmodeVars.firstmsg = 2;
		::printlang("\x03TACTICAL TRAINING",
					"\x03전술 트레이닝",
					"\x03戦術トレーニング",
					"\x03TACTICAL TRAINING",
					-1);
		if(::mp_gamemode == "versus"){
			::manacatAddTimer(4.0, false, ::versusmsg, { force = 0 });
		}else{
			::manacatAddTimer(2.0, false, ::startmsgkr, { force = 0 });
			::manacatAddTimer(5.0, false, ::startmsg2, { });
		}
	}
}
::startmsgkr <- function(params){
	local force = params["force"];
	if(force == 0){
		force = -1;
	}else{
		force = -3;
	}
	::printlang("   If It just feels so difficult, but there is no one to be with you,\n   Come to \x04Hard Mode User Group\x01 and try it together.",
				"   너무 어렵게만 느껴지는데 이 어려움을 같이 극복할 사람이 없다면,\n   \x04하드 모드 유저 그룹\x01에 오셔서 함께 도전해보세요.",
				"   とても難しく感じるが、一緒にやる人がいなければ、\n   \x04Hard Mode User Group\x01に来て、一緒に挑戦してみてください。",
				"",
				force);
	::printlang("   Steam Group : https://steamcommunity.com/groups/hard-mode \n   Steam Chats :\x03 https://s.team/chat/APiTRcso",
				"   스팀 그룹페이지 : https://steamcommunity.com/groups/hard-mode \n   스팀 그룹채팅방 :\x03 https://s.team/chat/APiTRcso",
				"   Steam Group : https://steamcommunity.com/groups/hard-mode \n   Steam Chats :\x03 https://s.team/chat/APiTRcso",
				"",
				force);
}
::startmsg2 <- function(params){
	if(::hardmodeVars.msgShow == 0){
		switch(::hardmodeVars.lang){
			case 0:
				ClientPrint( null, 5, "\x04[ Language Setting :\x01 English\x04 ]");
				ClientPrint( null, 5, "\x01   표시 언어를 한국어로 바꾸시려면\n   채팅창에 '\x03!kr\x01'을 입력하세요.");
				ClientPrint( null, 5, "\x01   表示言語を日本語に変えるには、\n   チャットに「\x03!jp\x01」と入力してください。");
				ClientPrint( null, 5, "\x01   Para cambiar el idioma del mod a Espanol,\n   escribe '\x03!es\x01' en el chat.");
			break;
			case 1:
				ClientPrint( null, 5, "\x04[ 언어설정 :\x01 한국어\x04 ]");
				ClientPrint( null, 5, "\x01   To change the display language to English,\n   type '\x03!en\x01' in the chat.");
				ClientPrint( null, 5, "\x01   表示言語を日本語に変えるには、\n   チャットに「\x03!jp\x01」と入力してください。");
				ClientPrint( null, 5, "\x01   Para cambiar el idioma del mod a Espanol,\n   escribe '\x03!es\x01' en el chat.");
			break;
			case 2:
				ClientPrint( null, 5, "\x04[ 言語設定 :\x01 日本語\x04 ]");
				ClientPrint( null, 5, "\x01   To change the display language to English,\n   type '\x03!en\x01' in the chat.");
				ClientPrint( null, 5, "\x01   표시 언어를 한국어로 바꾸시려면\n   채팅창에 '\x03!kr\x01'을 입력하세요.");
				ClientPrint( null, 5, "\x01   Para cambiar el idioma del mod a Espanol,\n   escribe '\x03!es\x01' en el chat.");
			break;
			case 3:
				ClientPrint( null, 5, "\x04[ Configuracion de idioma :\x01 Espanol\x04 ]");
				ClientPrint( null, 5, "\x01   To change the display language to English,\n   type '\x03!en\x01' in the chat.");
				ClientPrint( null, 5, "\x01   표시 언어를 한국어로 바꾸시려면\n   채팅창에 '\x03!kr\x01'을 입력하세요.");
				ClientPrint( null, 5, "\x01   表示言語を日本語に変えるには、\n   チャットに「\x03!jp\x01」と入力してください。");
			break;
		}
		::manacatAddTimer(7.0, false, ::startmsg2_5, { });
	}
}
::startmsg2_5 <- function(params){
	::printlang("\x04[ Difficulty :\x01 Level "+::hdmdState.lv+"\x04 ]",
				"\x04[ 난이도 :\x01 "+::hdmdState.lv+" 등급\x04 ]",
				"\x04[ 難易度 :\x01 "+::hdmdState.lv+" 等級\x04 ]",
				"\x04[ Dificultad :\x01 Nivel "+::hdmdState.lv+"\x04 ]",
				-1);
	::printlang("\x01   The higher the number of level, the more difficult the difficulty.",
				"\x01   등급의 숫자가 높을수록 난이도가 어려워집니다.",
				"\x01   等級の数値が高いほど難易度が難しくなります。",
				"\x01   Cuanto más alto sea el número del nivel, más difícil será la dificultad.",
				-1);
	::printlang("\x01   If you want to change difficulty, type '\x03!lv1 ~ !lv7\x01' in the chat.",
				"\x01   난이도를 바꾸고 싶으시면 채팅창에 '\x03!lv1 ~ !lv7\x01'를 입력하세요.",
				"\x01   難易度を変えたい場合は、\n   チャットに「\x03!lv1 ~ !lv7\x01」を入力してください。",
				"\x01   Si quieres cambiar la dificultad, escribe '\x03!lv1 ~ !lv7\x01' en el chat.",
				-1);
	::manacatAddTimer(7.0, false, ::startmsg3, { });
}
::startmsg3 <- function(params){
	::printlang("\x04[ Game Info Message ]",
				"\x04[ 게임 정보 메시지 ]",
				"\x04[ ゲーム情報メッセージ ]",
				"\x04[ Mensaje de información sobre la partida ]",
				-1);
	::printlang("\x01   If you want to hide game info messages, type '\x03!msg\x01' in the chat.",
				"\x01   게임 정보 메시지를 숨기고 싶으시면 채팅창에 '\x03!msg\x01'를 입력하세요.",
				"\x01   ゲーム情報メッセージを非表示にしたい場合は、\n   チャットに「\x03!msg\x01」を入力してください。",
				"\x01   Si quieres esconder los mensajes de información sobre la partida,\n   escribe '!msg' en el chat.",
				-1);
	::manacatAddTimer(5.0, false, ::startmsg4, { });
}
::startmsg4 <- function(params){
	local statEn = "";
	local statKr = "";
	local statJp = "";
	local statEs = "";
	::loadset();
	if(::hardmodeVars.hpShow == 0){
		statEn = "Show all special infected";
		statKr = "특수 감염자 모두 표시";
		statJp = "すべて表示";
		statEs = "Mostrar todos los infectados especiales";
	}else if(::hardmodeVars.hpShow == 1){
		statEn = "Show only Tanks & Witches";
		statKr = "탱크 & 윗치 표시";
		statJp = "タンクとウィッチだけ表示";
		statEs = "Mostrar solo los Tanks y Witches";
	}else{
		statEn = "Don't show";
		statKr = "표시하지 않음";
		statJp = "表示しない";
		statEs = "No mostrar";
	}
	::printlang("\x04[ Special Infected HP Gauge :\x01 "+statEn+"\x04 ]",
				"\x04[ 특수 감염자 HP 게이지 :\x01 "+statKr+"\x04 ]",
				"\x04[ 特殊感染者HPゲージ :\x01 "+statJp+"\x04 ]",
				"\x04[ Mostrar HP de un infectado especial :\x01 "+statEs+"\x04 ]",
				-1);
	::printlang("\x01   If you want to change the HP gauge display option,\n   type '\x03!hp\x01' in the chat.",
				"\x01   HP 게이지 표시 설정을 바꾸고 싶으시면 채팅창에 '\x03!hp\x01'를 입력하세요.",
				"\x01   HPゲージの表示設定を変更したい場合は、\n   チャットに「\x03!hp\x01」を入力してください。",
				"\x01   Si quieres cambiar la opción del indicador\n   de la vida de un infectado especial, escribe '!hp' en el chat.",
				-1);
	::manacatAddTimer(5.0, false, ::startmsg4_5, { });
}
::startmsg4_5 <- function(params){
	local statEn = "";
	local statKr = "";
	local statJp = "";
	local statEs = "";
	::loadset();
	if(::hardmodeVars.dmg == 0){
		statEn = "Normal";
		statKr = "보통";
		statJp = "通常";
		statEs = "normal";
	}else if(::hardmodeVars.dmg == 1){
		statEn = "Detailed";
		statKr = "정밀";
		statJp = "精密";
		statEs = "Detallado";
	}
	::printlang("\x04[ Capture Damage :\x01 "+statEn+"\x04 ]",
				"\x04[ 포획 피해 :\x01 "+statKr+"\x04 ]",
				"\x04[ 捕獲ダメージ :\x01 "+statJp+"\x04 ]",
				"\x04[ Captura dano :\x01 "+statEs+"\x04 ]",
				-1);
	::printlang("\x01   If you want to change the capture damage setting,\n   type '\x03!dmg\x01' in the chat.",
				"\x01   포획 피해 설정을 바꾸고 싶으시면 채팅창에 '\x03!dmg\x01'를 입력하세요.",
				"\x01   捕獲ダメージ設定を変更したい場合は、\n   チャットに「\x03!dmg\x01」を入力してください。",
				"\x01   Si desea cambiar la configuracion de captura dano,\n   escriba '\x03!dmg\x01' en el chat.",
				-1);
	::manacatAddTimer(5.0, false, ::startmsg5, { });
}
::startmsg5 <- function(params){
	if("ffReflector" in ::MANACAT){
		local statEn = "";
		local statKr = "";
		local statJp = "";
		local statEs = "";
		::loadset();
		if(::hardmodeVars.ffset == 0){
			statEn = "ON";
			statKr = "켜짐";
			statJp = "オン";
			statEs = "ACTIVADO";
		}else if(::hardmodeVars.ffset == 1){
			statEn = "OFF";
			statKr = "꺼짐";
			statJp = "オフ";
			statEs = "DESACTIVADO";
		}
		::printlang("\x04[ Friendly Fire Reflector :\x01 "+statEn+"\x04 ]",
					"\x04[ 아군공격 반사 :\x01 "+statKr+"\x04 ]",
					"\x04[ 同士討ち反射 :\x01 "+statJp+"\x04 ]",
					"\x04[ Fuego amigo reflectante : \x01 "+statEs+"\x04 ]",
					-1);
		::printlang("\x01   If you want to turn on/off the friendly fire reflector,\n   type '\x03!ffon\x01' or '\x03!ffoff\x01' in the chat.",
					"\x01   게임의 아군공격 반사를 켜거나 끄시려면\n   채팅창에 '\x03!ffon\x01' 또는 '\x03!ffoff\x01'를 입력하세요.",
					"\x01   ゲームの同士討ち反射設定を変更したい場合は、\n   チャットに「\x03!ffon\x01」か「\x03!ffoff\x01」を入力してください。",
					"\x01   Si quieres activar o desactivar el fuego amigo reflectante,\n   escribe '!ffon' o '!ffoff' en el chat.",
					-1);
	}
}