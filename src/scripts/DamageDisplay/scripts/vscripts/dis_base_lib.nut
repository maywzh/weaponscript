local defaultLang = FileToString("idd/lang_setting.txt").tointeger();//Chinese = 0,English = 1.
::rootlang_killed <- ["击杀","Killed"];
::rootlang_headshot <- ["爆头","HeadShot"];
local PlayerHandle = null;
local PlayerLoopName = null;
local PlayerRelayHandle = null;
local DisBuf = [" "," "," "," "];
const max = 4;
const FL_IF_ALIVE = 0;
const FL_IF_HEADSHOT = 1;
const FL_IF_DEAD = 2;
RelayTable <-
{
    StartDisabled = false
}
//dbg()
function show()
{
	Say(null,"is:"+PlayerHandle,false);
}
function CMyLang(code)
{
	defaultLang = code;
}
function ReturnLangKilled()
{
	return rootlang_killed[defaultLang];
}
function ReturnLangHeadshot()
{
	return rootlang_headshot[defaultLang];
}
function RegisterFunc()
{
    PlayerHandle = self;
    //PlayerHandle.__KeyValueFromString("targetname","player"+UniqueString());
    PlayerRelayHandle = SpawnEntityFromTable("logic_relay",RelayTable);
	PlayerRelayHandle.__KeyValueFromString("targetname","dis_relay"+UniqueString());
    PlayerLoopName = PlayerRelayHandle.GetName();
	EntFire(PlayerLoopName,"addoutput",format("onuser1 %s:runscriptcode:CallRelayFunc():0:-1",PlayerHandle.GetName()));
    Msg("[INFO]"+PlayerHandle+" Registered\n");
}
function CallRelayFunc()
{
	//Msg("Call CallRelayFunc()!\n");
    for(local i = max-1;i >= 0;i--)
    {
            DisBuf[i] = " ";
    }
}
function AcceptIO(delay)
{
	//Msg("Call AcceptIO()!\n");
    EntFire(PlayerLoopName,"fireuser1","",delay);
}
function CancelIO()
{
	//Msg("Call CancelIO()!\n");
    EntFire(PlayerLoopName,"CancelPending");
}
function SetArray(dmg,flags)
{
	//Msg("Call SetArray()!\n");
    for(local i = max-1;i >= 1;i--)
        {
            DisBuf[i] = DisBuf[i-1];
        }
        switch(flags)
        {
            case FL_IF_ALIVE :
            {
                DisBuf[0] = format("-%dHP",dmg);
                break;
            }
            case FL_IF_DEAD :
            {
                DisBuf[0] = format("-%dHP 【%s!】",dmg,rootlang_killed[defaultLang]);
                break;
            }
            case FL_IF_HEADSHOT :
            {
                DisBuf[0] = format("-%dHP 【%s!】",dmg,rootlang_headshot[defaultLang]);
                break;
            }
            default :
            {
                DisBuf[0] = " ";
            }
        }
		//Msg(PlayerHandle+"\n");
        ClientPrint(PlayerHandle,4,format("%s\n%s\n%s\n%s\n",DisBuf[0],DisBuf[1],DisBuf[2],DisBuf[3]));
        if(PlayerRelayHandle != null &&PlayerRelayHandle.IsValid())CancelIO();
        AcceptIO(2.5);
}
function DestoryHandle()
{
    if(PlayerRelayHandle.IsValid() && PlayerRelayHandle != null)
    {
        PlayerHandle.Kill();
        //Msg("[INFO]"+PlayerTargetName+" Destoried\n");
    }
}