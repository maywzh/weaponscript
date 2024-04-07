Msg("[INFO]Damage Display Mod Loading...!\n");
const filestring = "idd/lang_setting.txt";
local dfl = FileToString(filestring);
if(dfl == null)
{
	StringToFile(filestring,"0");
}else 
{
	dfl = dfl.tointeger();
}
function OnGameEvent_player_activate(params)
{
    local tname = GetPlayerFromUserID(params.userid);
	if(!IsPlayerABot(tname) && tname.GetZombieType() == 9)
	{
		tname.__KeyValueFromString("targetname","player"+UniqueString());
		EntFire(tname.GetName(),"runscriptfile","dis_base_lib");
		EntFire(tname.GetName(),"runscriptcode","RegisterFunc()");
		if(dfl == 0)ClientPrint(tname,3,"默认语言：中文/Defalut:Chinese");
		else ClientPrint(tname,3,"Defalut Lang: English/默认语言：英文");
		ClientPrint(tname,3,"\x03"+"["+"\x01"+"提示"+"\x03"+"]"+"\x04"+"显示伤害Mod支持两种语言，0 = 中文，1 = 英语，输入"+"\x03"+" !cl 语言代码 "+"\x04"+"来切换！");
		ClientPrint(tname,3,"\x03"+"["+"\x01"+"Tip"+"\x03"+"]"+"\x04"+"Damage Display Mod Support two languages，0 = Chinese，1 = English，Type"+"\x03"+" !cl LangNumber "+"\x04"+"Change It！");
	}
    
}
function OnGameEvent_player_disconnect(params)
{
	
    local tname = GetPlayerFromUserID(params.userid).GetName();
	if(!IsPlayerABot(GetPlayerFromUserID(params.userid)) && GetPlayerFromUserID(params.userid).GetZombieType() == 9)
    EntFire(tname,"runscriptcode","DestoryHandle()");
}
local maxLen = 50;
//for SI

function OnGameEvent_player_hurt(params)
{
    //Msg("123");
    local victim = GetPlayerFromUserID(params.userid);
    local attacker = GetPlayerFromUserID(params.attacker);
    if(IsPlayerABot(attacker)||victim.IsSurvivor())return;
    if(!victim.IsDead()&&!victim.IsDying()&&!victim.IsIncapacitated())
    {
        ShowHpBar(params.health,NetProps.GetPropInt(victim,"m_iMaxHealth"),attacker,0,victim.GetPlayerName());
    }
}
::deathdmg <- -1;

function OnGameEvent_player_say(params)
{
	local front_s = split(params.text," ");
	local playerhandle = GetPlayerFromUserID(params.userid);
	if(front_s[0] == "!cl")
	{
		switch(front_s[1])
		{
			case "0" :
			{
				playerhandle.GetScriptScope().CMyLang(0);ClientPrint(playerhandle,3,"[OK!]已将您的语言设置为中文！");break;
			}
			case "1" :
			{
				playerhandle.GetScriptScope().CMyLang(1);ClientPrint(playerhandle,3,"[OK!]Your Correct Language:English！");break;
			}
			default :
			{
				ClientPrint(playerhandle,3,"[ERROR]无效的语言代码/Invalid Lang Number");
			}
		}
	}
	if(front_s[0] == "!setdfl" && playerhandle == GetListenServerHost())
	{
		if(front_s[1] == "0" || front_s[1] == "1")
		{
			StringToFile(filestring,front_s[1]);
			ClientPrint(playerhandle,3,"[OK!]重新载入地图后生效！/It will work on the new Map loaded!");
		}else ClientPrint(playerhandle,3,"[ERROR]无效的语言代码/Invalid Lang Number");
	}
}
//for witch and ci
function OnGameEvent_infected_hurt(params)
{
    local victim = Ent(params.entityid);
    local attacker = GetPlayerFromUserID(params.attacker);
    if(IsPlayerABot(attacker) || attacker == null)return;
    local nowHp = NetProps.GetPropInt(victim,"m_iHealth");
    local maxHp = NetProps.GetPropInt(victim,"m_iMaxHealth");
    if(nowHp-params.amount <= 0)deathdmg = params.amount;
    if(victim.GetClassname() == "witch")
    {
        ShowHpBar(nowHp,maxHp,attacker,0,"witch");
    }else if(victim.GetClassname() == "infected" && nowHp > 0)
    {
		//print("at"+attacker+"\n");
        EntFire(attacker.GetName(),"runscriptcode",format("SetArray(%d,%d)",params.amount,0));
    }
}
//for all zombies
function OnGameEvent_player_death(params)
{
    local victim;
    if(params.victimname == "Infected" || params.victimname == "Witch")
    {victim = Ent(params.entityid);}
    else
    {victim =GetPlayerFromUserID(params.userid);}
    local attacker = GetPlayerFromUserID(params.attacker);
    if(IsPlayerABot(attacker) || (victim.IsPlayer()&&victim.GetZombieType()==9))return;
    local isheadshot = params.headshot;
    switch(params.victimname)
    {
        case "Infected" :
        {
            if(!isheadshot)
            //localplayer.SetArray(deathdmg,FL_IF_DEAD);
            EntFire(attacker.GetName(),"runscriptcode",format("SetArray(%d,%d)",deathdmg,2));
            else
            EntFire(attacker.GetName(),"runscriptcode",format("SetArray(%d,%d)",deathdmg,1));
            break;
        }
        default :
        {
            if(!isheadshot)
            ShowHpBar(-1,100,attacker,0,params.victimname);
            else
            ShowHpBar(-1,100,attacker,isheadshot,params.victimname);
            break;
        }
    }
}
function ShowHpBar(nowHp,maxHp,clientWho,isheadshot,theName="unknown")
{   
    
    //Msg(isheadshot);
	
    if(!maxHp)return;
    if(nowHp<=0)
    {
        if(isheadshot == 1)
        {
			local langhs = clientWho.GetScriptScope().ReturnLangHeadshot();
            ClientPrint(clientWho,4,format("【%s!】%s",langhs,theName));
        }
        else
        {
			local langks = clientWho.GetScriptScope().ReturnLangKilled();
            ClientPrint(clientWho,4,format("【%s!】%s",langks,theName));
        }
        return;
    }
    local prencent = ((nowHp.tofloat()/maxHp.tofloat())).tofloat();
    local nowHpsLen = ceil(prencent * maxLen);
    local dmgLen = ceil((1-prencent).tofloat()*maxLen);
    //Msg(prencent);
    local strNow="";
    local strDmg="";
    for(local i = 0 ;i <nowHpsLen;i++)strNow+="#";
    for(local i = 0 ;i <dmgLen;i++)strDmg+="=";
    local strT = (strNow.tostring()+strDmg.tostring()).tostring();
    ClientPrint(clientWho,4,format("HP: |-%s-|  [%d / %d]  %s\n",strT,nowHp,maxHp,theName));
}
