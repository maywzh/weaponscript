::manacatInfo<-{
	function OnGameEvent_player_connect(params){
		if(params.networkid != "BOT"){
			local p = null;
			while (p = Entities.FindByClassname(p, "player")){
				if(p != null && p.IsValid()){
					local msg = Convars.GetClientConvarValue("cl_language", p.GetEntityIndex());
					switch(msg){
						case "korean":case "koreana":	msg = params["name"]+" 님이 게임에 참가하고 있습니다.";	break;
						case "japanese":				msg = "プレイヤー "+params["name"]+" がゲームに参加しています";	break;
						case "spanish":					msg = "El jugador "+params["name"]+" se está uniendo a la partida";	break;
						default:						msg = "Player "+params["name"]+" is joining the game";	break;
					}
					ClientPrint(p, 5, "\x01"+msg);
				}
			}
		}
	}

	function OnGameEvent_player_say(params){
		local player = GetPlayerFromUserID(params.userid);
		local chat = params.text.tolower();
		chat = split(chat," ");
		switch(chat[0]){
			case "!addon" : case "!add-on" :
				local msg = Convars.GetClientConvarValue("cl_language", player.GetEntityIndex());
				switch(msg){
					case "korean":case "koreana":	msg = "이 세션에 적용된 애드온 목록입니다.";	break;
					case "japanese":				msg = "このセッションに適用されたアドオンのリストです。";	break;
					case "spanish":					msg = "Lista de add-ons aplicados a esta sesión.";	break;
					default:						msg = "List of add-ons applied to this session.";	break;
				}
				ClientPrint(player, 5, "\x03"+msg);
				local slotn = 0;
				for(local i = 0; i < 99; i++){
					if(("slot"+i) in ::MANACAT){
						::MANACAT["slot"+i](player);
						slotn++;
					}
				}
			break;
		}
	}
}

__CollectEventCallbacks(::manacatInfo, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);