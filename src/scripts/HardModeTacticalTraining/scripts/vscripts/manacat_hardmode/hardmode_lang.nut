::dprint <- function(textlog, texttype = 0, tg = 5, tgplayer = null){
	local ignSet = false;
	if(tg > 10){
		tg -= 10;
		ignSet = true;
	}
	if((::hardmodeVars.msgShow == 0 && Director.GetGameMode() != "versus") || ignSet == true){
		if(texttype == 0)		ClientPrint( tgplayer, tg, "Hardmode: \x01"+textlog);
		else if(texttype == 1)	ClientPrint( tgplayer, tg, "\x01"+textlog);
		else if(texttype == 2)	ClientPrint( tgplayer, tg, textlog);
	}
	return;
}

::printlang <- function(enm, krm, jpm, esm, level = 0, tgplayer = null){
	local msg = "";
	switch(::hardmodeVars.lang){
		case 0:	msg = enm;	break;
		case 1:	msg = krm;	break;
		case 2:	msg = jpm;	break;
		case 3:	msg = esm;	break;
	}
	//if(::hardmodeVars.msg != msg){
		::hardmodeVars.msg = msg;
		if(tgplayer == null){
			local entplayer = null;
			while (entplayer = Entities.FindByClassname(entplayer, "player")){
				if(entplayer.IsValid()){
					if(/*entplayer.IsSurvivor() &&*/ !IsPlayerABot(entplayer)){
						tgplayer = Convars.GetClientConvarValue("cl_language", entplayer.GetEntityIndex())
						switch(tgplayer){
							case "korean":case "koreana":	msg = krm;	break;
							case "japanese":				msg = jpm;	break;
							case "spanish":					msg = esm;	break;
							default:						msg = enm;	break;
						}
						if(level >= 0)::dprint(msg, 0, 5, entplayer);
						else if(level == -1)::dprint(msg, 1, 5, entplayer);
						else if(level == -2)::dprint(msg, 2, 14, entplayer);
						else if(level == -3)::dprint(msg, 1, 15, entplayer);//msgshow를 무시하고 출력
					}
				}
			}
		}else{
			if(IsPlayerABot(tgplayer) || !tgplayer.IsValid())return;
			local playerset = Convars.GetClientConvarValue("cl_language", tgplayer.GetEntityIndex())
			switch(playerset){
				case "korean":case "koreana":	msg = krm;	break;
				case "japanese":				msg = jpm;	break;
				case "spanish":					msg = esm;	break;
				default:						msg = enm;	break;
			}
			if(level >= 0)::dprint(msg, 0, 5, tgplayer);
			else if(level == -1)::dprint(msg, 1, 5, tgplayer);
			else if(level == -2)::dprint(msg, 2, 14, tgplayer);
			else if(level == -3)::dprint(msg, 1, 15, tgplayer);
		}
	//}
}
/*
::changeDcall <- function(enm = "", krm = "", jpm = "", esm = ""){
	local msg = "";
	switch(::hardmodeVars.lang){
		case 0:	msg = enm;	break;
		case 1:	msg = krm;	break;
		case 2:	msg = jpm;	break;
		case 3:	msg = esm;	break;
	}
	if(::hardmodeVars.msg != msg){
		::hardmodeVars.msg = msg;
		if(msg != ""){
			//::dprint("\x04"+txtlog);
			::printlang("\x04<Difficulty reset> ("+enm+")",
						"\x04<난이도 재설정> ("+krm+")",
						"\x04<難易度の再設定> ("+jpm+")",
						"\x04<Dificultad reajustada> ("+esm+")",
						1);	
		}else{
			::printlang("\x04<Difficulty reset>",
						"\x04<난이도 재설정>",
						"\x04<難易度の再設定>",
						"\x04<Dificultad reajustada>",
						1);	
		}
		::hardmodeFunc.changeD();
	}
}*/