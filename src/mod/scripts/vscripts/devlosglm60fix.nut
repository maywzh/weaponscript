printl("Loaded DevlosGLM60Fix")
printl("By Solved/Devlos aka Timonenluca")

DevlosGLM60Fix <- {}

function DevlosGLM60FixCFG()
{
    //HostSteamID [Chat Commands]
    if(FileToString("DevlosGLM60Fix/cfg/ServerHost/HostSteamID.txt") == null)
    {
        StringToFile("DevlosGLM60Fix/cfg/ServerHost/HostSteamID.txt" , "SteamID_Here")
    }
    else if(FileToString("DevlosGLM60Fix/cfg/ServerHost/HostSteamID.txt") != null)
    {
        printl("DevlosGLM60Fix: SteamIDHost File Generated!")
    }
    //M60_Clip2 CFG
    if(FileToString("DevlosGLM60Fix/cfg/M60_Clip2.txt") == null)
    {
        StringToFile("DevlosGLM60Fix/cfg/M60_Clip2.txt", "0")
    }
    else if(FileToString("DevlosGLM60Fix/cfg/M60_Clip2.txt") != null)
    {
        Convars.SetValue("ammo_M60_max", FileToString("DevlosGLM60Fix/cfg/M60_Clip2.txt"))
    }
    
    //M60_Clip2 CFG
    if(FileToString("DevlosGLM60Fix/cfg/M60_Clip2.txt") == null)
    {
        StringToFile("DevlosGLM60Fix/cfg/M60_Clip2.txt", "0")
    }
    else if(FileToString("DevlosGLM60Fix/cfg/M60_Clip2.txt") != null)
    {
        Convars.SetValue("ammo_M60_max", FileToString("DevlosGLM60Fix/cfg/M60_Clip2.txt"))
    }

    //GL_Clip2 CFG
    if(FileToString("DevlosGLM60Fix/cfg/GL_Clip2.txt") == null)
    {
        StringToFile("DevlosGLM60Fix/cfg/GL_Clip2.txt", "30")
    }
    else if(FileToString("DevlosGLM60Fix/cfg/GL_Clip2.txt") != null)
    {
        Convars.SetValue("ammo_grenadelauncher_max", FileToString("DevlosGLM60Fix/cfg/GL_Clip2.txt"))
    }

    //GL_Reload_Enable CFG 
    if(FileToString("DevlosGLM60Fix/cfg/reload/GL_Reload_Enable.txt") == null)
    {
        StringToFile("DevlosGLM60Fix/cfg/reload/GL_Reload_Enable.txt", "true")
    }
    else if(FileToString("DevlosGLM60Fix/cfg/reload/GL_Reload_Enable.txt") != null)
    {
        if(FileToString("DevlosGLM60Fix/cfg/reload/GL_Reload_Enable.txt").tolower() != "true")
        {
            if(FileToString("DevlosGLM60Fix/cfg/reload/GL_Reload_Enable.txt").tolower() != "false")
            {
                StringToFile("DevlosGLM60Fix/cfg/reload/GL_Reload_Enable.txt", "true")
            }
        }
        else if(FileToString("DevlosGLM60Fix/cfg/reload/GL_Reload_Enable.txt").tolower() != "false")
        {
            if(FileToString("DevlosGLM60Fix/cfg/reload/GL_Reload_Enable.txt").tolower() != "true")
            {
                StringToFile("DevlosGLM60Fix/cfg/reload/GL_Reload_Enable.txt", "true")
            }
        }
    }

    //M60_Reload_Enable CFG 
    if(FileToString("DevlosGLM60Fix/cfg/reload/M60_Reload_Enable.txt") == null)
    {
        StringToFile("DevlosGLM60Fix/cfg/reload/M60_Reload_Enable.txt", "true")
    }
    else if(FileToString("DevlosGLM60Fix/cfg/reload/M60_Reload_Enable.txt") != null)
    {
        if(FileToString("DevlosGLM60Fix/cfg/reload/M60_Reload_Enable.txt").tolower() != "true")
        {
            if(FileToString("DevlosGLM60Fix/cfg/reload/M60_Reload_Enable.txt").tolower() != "false")
            {
                StringToFile("DevlosGLM60Fix/cfg/reload/M60_Reload_Enable.txt", "true")
            }
        }
        else if(FileToString("DevlosGLM60Fix/cfg/reload/M60_Reload_Enable.txt").tolower() != "false")
        {
            if(FileToString("DevlosGLM60Fix/cfg/reload/M60_Reload_Enable.txt").tolower() != "true")
            {
                StringToFile("DevlosGLM60Fix/cfg/reload/M60_Reload_Enable.txt", "true")
            }
        }
    }

    //M60_Drop_Enable CFG 
    if(FileToString("DevlosGLM60Fix/cfg/drop/M60_Drop_Enable.txt") == null)
    {
        StringToFile("DevlosGLM60Fix/cfg/drop/M60_Drop_Enable.txt", "true")
    }
    else if(FileToString("DevlosGLM60Fix/cfg/drop/M60_Drop_Enable.txt") != null)
    {
        if(FileToString("DevlosGLM60Fix/cfg/drop/M60_Drop_Enable.txt").tolower() != "true")
        {
            if(FileToString("DevlosGLM60Fix/cfg/drop/M60_Drop_Enable.txt").tolower() != "false")
            {
                StringToFile("DevlosGLM60Fix/cfg/drop/M60_Drop_Enable.txt", "true")
            }
        }
        else if(FileToString("DevlosGLM60Fix/cfg/drop/M60_Drop_Enable.txt").tolower() != "false")
        {
            if(FileToString("DevlosGLM60Fix/cfg/drop/M60_Drop_Enable.txt").tolower() != "true")
            {
                StringToFile("DevlosGLM60Fix/cfg/drop/M60_Drop_Enable.txt", "true")
            }
        }
    }
}

DevlosGLM60FixCFG() //Run CFG Check

::DevlosGLM60FixCFGValues <- { //global table to fetch file data
    HostSteamID = null
    GL_Reload_Enable = null
    M60_Reload_Enable = null
    M60_Drop_Enable = null

}

function DevlosApplyGLM60FixCFGValues()
{
    ::DevlosGLM60FixCFGValues.HostSteamID = FileToString("DevlosGLM60Fix/cfg/ServerHost/HostSteamID.txt")
    ::DevlosGLM60FixCFGValues.GL_Reload_Enable = FileToString("DevlosGLM60Fix/cfg/reload/GL_Reload_Enable.txt")
    ::DevlosGLM60FixCFGValues.M60_Reload_Enable = FileToString("DevlosGLM60Fix/cfg/reload/M60_Reload_Enable.txt")
    ::DevlosGLM60FixCFGValues.M60_Drop_Enable = FileToString("DevlosGLM60Fix/cfg/drop/M60_Drop_Enable.txt")

    printl("Host_SteamID: " + DevlosGLM60FixCFGValues.HostSteamID)
    printl("GL_Reload_Enable: " + DevlosGLM60FixCFGValues.GL_Reload_Enable)
    printl("M60_Reload_Enable: " + DevlosGLM60FixCFGValues.M60_Reload_Enable)
    printl("M60_Drop_Enable: " + DevlosGLM60FixCFGValues.M60_Drop_Enable)
}

DevlosApplyGLM60FixCFGValues() //CFG Apply Values to Table

DevlosGLM60Fix.OnGameEvent_player_use <- function ( params )
{

    local Player = GetPlayerFromUserID( params.userid );
    local entity = params.targetid;

    function FindAIndex()
    {    
        for(local ent = null; ( ent = Entities.FindByClassname( ent , "weapon_ammo_spawn" ) ) != null; )
        {
            if(ent != null && ent.IsValid()) 
            {
                yield ent;
            }
        }
    }

    if(Player != null && Player.IsValid())
    {

        local invTable = {}

        GetInvTable(Player, invTable)

        if("slot0" in invTable)
        {
            local AWeapon = invTable.slot0
            local AweaponClass = invTable.slot0.GetClassname()

            local ammocvar = {weapon_rifle_m60 = "ammo_m60_max" , weapon_grenade_launcher = "ammo_grenadelauncher_max"}
            local ammoType = NetProps.GetPropInt(AWeapon , "m_iPrimaryAmmoType");
            local ammo = NetProps.GetPropIntArray(Player , "m_iAmmo", ammoType);

            if(AWeapon != null && AWeapon.IsValid())
            {
                foreach(AIndex in FindAIndex())
                {
                    if(AIndex.GetEntityIndex() == entity)
                    {
                        if(AweaponClass == "weapon_grenade_launcher")
                        {
                            if(::DevlosGLM60FixCFGValues.GL_Reload_Enable.tolower() == "true")
                            {            
                                local GL_reservemax = Convars.GetFloat(ammocvar[AweaponClass]);
            
                                if(GL_reservemax != ammo)
                                {
                                    //printl("Player: " + Player + "\n" + "Weapon: " + AweaponClass)
                                    Player.GiveAmmo(GL_reservemax)
                                }
                            }
                        }
                        else if(AweaponClass == "weapon_rifle_m60") // Prevent Refill spamming , Check Clip1()
                        {
                            if(::DevlosGLM60FixCFGValues.M60_Reload_Enable.tolower() == "true")
                            {
                                if(IsPlayerABot(Player))
                                {
                                    NetProps.SetPropInt(AWeapon,"m_iClip1", AWeapon.GetMaxClip1());
                                }
                                else if(!IsPlayerABot(Player))
                                {
                                    local M60_reservemax = Convars.GetFloat(ammocvar[AweaponClass]) + (AWeapon.GetMaxClip1() - AWeapon.Clip1());
                                    NetProps.SetPropIntArray(Player , "m_iAmmo",  M60_reservemax , ammoType);
                                    EmitSoundOnClient("BaseCombatCharacter.AmmoPickup", Player)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


DevlosGLM60Fix.OnGameEvent_weapon_fire <- function ( params ) // Reliable Optimized event to check below ammo count for Clip1()
{
    local Player = GetPlayerFromUserID( params.userid );
    local AWeapon = Player.GetActiveWeapon()
    local WeaponName = params.weapon

    if(Player != null && Player.IsValid())
    {
        if(AWeapon != null && AWeapon.IsValid() && WeaponName == "rifle_m60")
        {
            if(AWeapon.Clip1() <= 2)
            {
                if(::DevlosGLM60FixCFGValues.M60_Drop_Enable.tolower() == "true")
                {
                    switch(NetProps.GetPropInt(AWeapon, "m_upgradeBitVec"))
                    {
                        case 4:
                        {
                            NetProps.SetPropInt(AWeapon, "m_upgradeBitVec" , 4)
                        }
                        case 5:
                        {
                            NetProps.SetPropInt(AWeapon, "m_upgradeBitVec" , 4)
                        }
                        case 6:
                        {
                            NetProps.SetPropInt(AWeapon, "m_upgradeBitVec" , 4)
                        }
                    }
                    
                    NetProps.SetPropInt(AWeapon, "m_nUpgradedPrimaryAmmoLoaded" , 0);
                    NetProps.SetPropEntity(AWeapon,"m_iClip1", 0);

                    //NetProps.SetPropInt(Player , "m_afButtonForced", 8192)
                    //DoEntFire("!self", "RunScriptCode", @"NetProps.SetPropInt(self , ""m_afButtonForced"" , NetProps.GetPropInt(self , ""m_afButtonForced"") & ~8192)" , 0.1, null, Player);
                }
            }
        }
    }
} 

DevlosGLM60Fix.OnGameEvent_weapon_reload <- function ( params ) // Fix 1 bullet dissappearing on reload due to "m_iclip1" trick
{
    local Player = GetPlayerFromUserID( params.userid );
    local AWeapon = Player.GetActiveWeapon()
    local AWeaponClass = Player.GetActiveWeapon().GetClassname()
    local Manual = params.manual

    if(Player != null && Player.IsValid())
    {
        if(AWeapon != null && AWeapon.IsValid() && AWeapon.Clip1() <= 2 && Convars.GetStr("ammo_M60_max") != "0" &&  Manual == true && AWeaponClass == "weapon_rifle_m60")
        {
            local ammoType = NetProps.GetPropInt(AWeapon , "m_iPrimaryAmmoType");
            local ammo = NetProps.GetPropIntArray(Player , "m_iAmmo", ammoType);

            NetProps.SetPropIntArray(Player , "m_iAmmo",  ammo + 1 , ammoType);
        }
    }
}

DevlosGLM60Fix.OnGameEvent_player_say <- function ( params )
{
    //printl("Text")
    local Player = GetPlayerFromUserID( params.userid );
    local text = ( params.text );

    if (Player != null && Player.IsValid())
    {
        if(GetListenServerHost() == Player || Player.GetNetworkIDString() == ::DevlosGLM60FixCFGValues.HostSteamID)
        {
            if(text != null && text != -1 && text != "")
            {
                text = text.tolower()
                local Command = split(strip(text) , " ");

                switch (Command[0])
                {
                    case "!d_glm60fix_m60_clip2":
                    {
                        try
                        {
                            Command[1].tointeger()
                        }
                        catch (error)
                        {
                            ClientPrint(Player , 3 , "\x01" + "ERROR! Not a Integer! Current Value: "  + "\x04" + FileToString("DevlosGLM60Fix/cfg/M60_Clip2.txt"))
                            break;
                        }

                        if(Command.len() <= 1 || Command.len() >= 3){
                        ClientPrint(Player , 3 , "\x01" + "Usage: !d_glm60fix_m60_clip2" + "\x03" + "[Number]")
                        ClientPrint(Player , 3 , "\x01" + "Current Value: " + "\x04" + FileToString("DevlosGLM60Fix/cfg/M60_Clip2.txt"))
                        break;
                        }
                        else if(Command.len() == 2){
                        StringToFile("DevlosGLM60Fix/cfg/M60_Clip2.txt", Command[1])
                        ClientPrint(Player , 3 , "\x01" + "M60 Clip2 Changed to: " + "\x04" + Command[1])
                        break;
                        }
                    }
                    case "!d_glm60fix_gl_clip2":
                    {
                        try
                        {
                            Command[1].tointeger()
                        }
                        catch (error)
                        {
                            ClientPrint(Player , 3 , "\x01" + "ERROR! Not a Integer! Current Value: "  + "\x04" + FileToString("DevlosGLM60Fix/cfg/GL_Clip2.txt"))
                            break;
                        }

                        if(Command.len() <= 1 || Command.len() >= 3){
                        ClientPrint(Player , 3 , "\x01" + "Usage: !d_glm60fix_gl_clip2" + "\x03" + "[Number]")
                        ClientPrint(Player , 3 , "\x01" + "Current Value: " + "\x04" + FileToString("DevlosGLM60Fix/cfg/GL_Clip2.txt"))
                        break;
                        }
                        else if(Command.len() == 2){
                        StringToFile("DevlosGLM60Fix/cfg/GL_Clip2.txt", Command[1])
                        ClientPrint(Player , 3 , "\x01" + "GL Clip2 Changed to: " + "\x04" + Command[1])
                        break;
                        }
                    }
                    case "!d_glm60fix_gl_rl":
                    {
                        if(Command.len() <= 1 || Command.len() >= 3)
                        {
                            ClientPrint(Player , 3 , "\x01" + "Usage: !d_glm60fix_gl_rl" + "\x03" + "[true/false]")
                            ClientPrint(Player , 3 , "\x01" + "Current Value: " + "\x04" + DevlosGLM60FixCFGValues.GL_Reload_Enable)
                            break;
                        }
                        else if(Command.len() == 2)
                        {
                            if(Command[1] == "true" || Command[1] == "false")
                            {
                                StringToFile("DevlosGLM60Fix/cfg/reload/GL_Reload_Enable.txt", Command[1])
                                ClientPrint(Player , 3 , "\x01" + "GL Reload Changed to: " + "\x04" + Command[1])
                                break;
                            }
                            else
                            {
                                ClientPrint(Player , 3 , "\x01" + "Usage: !d_glm60fix_gl_rl" + "\x03" + "[true/false]")
                                ClientPrint(Player , 3 , "\x01" + "Current Value: " + "\x04" + DevlosGLM60FixCFGValues.GL_Reload_Enable)
                                break;   
                            }
                        }
                    }
                    case "!d_glm60fix_m60_rl":
                    {
                        if(Command.len() <= 1 || Command.len() >= 3)
                        {
                            ClientPrint(Player , 3 , "\x01" + "Usage: !d_glm60fix_m60_rl" + "\x03" + "[true/false]")
                            ClientPrint(Player , 3 , "\x01" + "Current Value: " + "\x04" + DevlosGLM60FixCFGValues.M60_Reload_Enable)
                            break;
                        }
                        else if(Command.len() == 2)
                        {
                            if(Command[1] == "true" || Command[1] == "false")
                            {
                                StringToFile("DevlosGLM60Fix/cfg/reload/M60_Reload_Enable.txt", Command[1])
                                ClientPrint(Player , 3 , "\x01" + "M60 Reload Changed to: " + "\x04" + Command[1])
                                break;
                            }
                            else
                            {
                                ClientPrint(Player , 3 , "\x01" + "Usage: !d_glm60fix_m60_rl" + "\x03" + "[true/false]")
                                ClientPrint(Player , 3 , "\x01" + "Current Value: " + "\x04" + DevlosGLM60FixCFGValues.M60_Reload_Enable)
                                break;   
                            }
                        }
                    }
                    case "!d_glm60fix_m60_drop":
                    {
                        if(Command.len() <= 1 || Command.len() >= 3)
                        {
                            ClientPrint(Player , 3 , "\x01" + "Usage: !d_glm60fix_m60_drop" + "\x03" + "[true/false]")
                            ClientPrint(Player , 3 , "\x01" + "Current Value: " + "\x04" + DevlosGLM60FixCFGValues.M60_Drop_Enable)
                            break;
                        }
                        else if(Command.len() == 2)
                        {
                            if(Command[1] == "true" || Command[1] == "false")
                            {
                                StringToFile("DevlosGLM60Fix/cfg/drop/M60_Drop_Enable.txt", Command[1])
                                ClientPrint(Player , 3 , "\x01" + "M60 Drop Changed to: " + "\x04" + Command[1])
                                break;
                            }
                            else
                            {
                                ClientPrint(Player , 3 , "\x01" + "Usage: !d_glm60fix_m60_drop" + "\x03" + "[true/false]")
                                ClientPrint(Player , 3 , "\x01" + "Current Value: " + "\x04" + DevlosGLM60FixCFGValues.M60_Drop_Enable)
                                break;   
                            }
                        }
                    }
                }
            }
        }
    }
}

__CollectGameEventCallbacks(DevlosGLM60Fix)