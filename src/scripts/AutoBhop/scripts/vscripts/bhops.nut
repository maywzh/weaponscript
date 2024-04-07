//AutoBhop plugin by PCI-GAMING,AutoBhop script by Okcf,and aps,but them script seems doesnt work?
//Msg("bhhooo!");
if (!Entities.FindByName(null, "jumper123")) {SpawnEntityFromTable("logic_timer",{targetname="jumper123",RefireTime = 0.01 , OnTimer = "!caller,runscriptcode,bhop_think()"});}
::on <- 1;
::ent <- null;
::bhop_think <-function()
{
    while(ent = Entities.FindByClassname(ent,"player"))
    {
        if(!ent.IsDead() && !ent.IsDying() && ent.IsSurvivor())
        {
            //if(ent.GetButtonMask() & 2)
            //{
                local bt = NetProps.GetPropInt(ent,"m_afButtonDisabled");
                if(NetProps.GetPropInt(ent,"m_hGroundEntity") == -1)
                {
                    if(NetProps.GetPropInt(ent,"movetype") != 9)
                    {
                        NetProps.SetPropInt(ent,"m_afButtonDisabled",(bt|2));
                        continue;
                    }
                }
                NetProps.SetPropInt(ent, "m_afButtonDisabled",(bt&~2));
            //}
        }
    }
}
function OnGameEvent_player_say(params)
{
    if(params.text == "!bhop")
    {
        on=!on;
        
		//Msg(on+"\n")
        if(on == false)
        {
            ClientPrint(null,3,format("\x03"+"["+"\x04"+"AutoBhopMod"+"\x03"+"]"+"\x01"+"Off"));
            EntFire("jumper123","disable");
        }else
        {
            ClientPrint(null,3,format("\x03"+"["+"\x04"+"AutoBhopMod"+"\x03"+"]"+"\x01"+"On"));
            EntFire("jumper123","enable");
        }
    }
    
}