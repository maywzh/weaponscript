printl("ultrakill-like parrying")

ChCh_Parrying <-
{
ShovingPlayerData = {}

Settings = 
{
    //Parried_Sprite = 1
    Parried_Sound = 1
    Parry_Molotovs = 1
    Molotov_Explode = 1
    Parry_Pipes = 1
    Pipe_Fire = 1
    Parry_Bile = 1
    Parry_Spit = 1
    Spit_Explode = 1
    Parry_Grenade_launcher = 1
    Parry_Rocks = 1
}

function ParseSettings()
{
    local SettingsFileName = "parrying/Settings.cfg"
    local file = FileToString(SettingsFileName)

    local tData;
    local function SerializeSettings() {
        local sData = "{"
        foreach (key, val in Settings) {
            if (type(val) == "string") {
                val = "\"" + val + "\""
            } else if (type(val) == "array") {
                local newValue = "["
                for (local i = 0; i < val.len(); i++) {
                    if (type(val[i]) == "string") {
                        newValue += "\"" + val[i] + "\""
                    } else {
                        newValue += val[i].tostring()
                    }
                    if (i < val.len() - 1) {
                        newValue += ", "
                    }
                }
                newValue += "]"
                val = newValue
            }
            sData += "\n\t" + key + " = " + val
        }
        sData += "\n}"
        StringToFile(SettingsFileName, sData)
    }
    if (tData = file){
        try {
            tData = compilestring("return " + tData)()
            local hasMissingKey = false
            foreach (key, val in Settings){
                if (key in tData){
                    Settings[key] = tData[key]
                }
                else if (!hasMissingKey){
                    hasMissingKey = true 
                }
            }
            if (hasMissingKey)
            { SerializeSettings() }
        }
        catch (error) {
            SerializeSettings()
        }
    }
    else{
        SerializeSettings();
    }
    
}

function GetParriedEntsFrom(pos,x_ext,y_ext,z_ext)
{
    local goodents = ["molotov_projectile","pipe_bomb_projectile","vomitjar_projectile","spitter_projectile","grenade_launcher_projectile","tank_rock"]

    local gottenents = []

    foreach(thing in goodents)
    {
        for (local ent; ent = Entities.FindByClassname(ent, thing); )
        {
            local entpos = ent.GetOrigin()

            if(abs(entpos.x) <= abs(pos.x + x_ext) || abs(entpos.x) <= abs(pos.x - x_ext))
            {
                if(abs(entpos.y) <= abs(pos.y + y_ext) || abs(entpos.y) <= abs(pos.y - y_ext))
                {
                    if(abs(entpos.z) <= abs(pos.z + z_ext) || abs(entpos.z) <= abs(pos.z - z_ext))
                    {
                        gottenents.append(ent)
                    }
                }
            }
            
        }
    }

    return gottenents
}

function OleMateShoved(who,pos,ang)
{
    local gottenents = GetParriedEntsFrom(pos,64,64,96)
    if(gottenents.len() > 0)
    {
        foreach(thing in gottenents)
        {
            switch(thing.GetClassname())
            {
                case "molotov_projectile":
                    if(Settings.Parry_Molotovs >= 1)
                    {
                        ParryGrenade(thing,who,pos,ang,1)
                        //if(Settings.Parried_Sprite >= 1)
                        //{
                            //AttachSpriteTo(thing,who)
                        //}
                    }
                    break
                case "pipe_bomb_projectile":
                    if(Settings.Parry_Pipes >= 1)
                    {
                        ParryGrenade(thing,who,pos,ang,1)
                        //if(Settings.Parried_Sprite >= 1)
                        //{
                            //AttachSpriteTo(thing,who)
                        //}
                    }
                    break
                case "vomitjar_projectile":
                    if(Settings.Parry_Bile >= 1)
                    {
                        ParryGrenade(thing,who,pos,ang,2)
                        //if(Settings.Parried_Sprite >= 1)
                        //{
                            //AttachSpriteTo(thing,who)
                        //}
                    }
                    break
                case "spitter_projectile":
                    if(Settings.Parry_Spit >= 1)
                    {
                        ParryGrenade(thing,who,pos,ang,1)
                        //if(Settings.Parried_Sprite >= 1)
                        //{
                            //AttachSpriteTo(thing,who)
                        //}
                    }
                    break
                case "grenade_launcher_projectile":
                    if(Settings.Parry_Grenade_launcher >= 1)
                    {
                        ParryGrenade(thing,who,pos,ang,2)
                        //if(Settings.Parried_Sprite >= 1)
                        //{
                            //AttachSpriteTo(thing,who)
                        //}
                    }
                    break
                case "tank_rock":
                    if(Settings.Parry_Rocks >= 1)
                    {
                        ParryGrenade(thing,who,pos,ang,1)
                        //if(Settings.Parried_Sprite >= 1)
                        //{
                            //AttachSpriteTo(thing,who)
                        //}
                    }
                    break
            }
        }
    }

    //shovetrigger.Kill()
}

function ParryGrenade(molly,who,pos,ang,speed)
{
    local mollyspeed = molly.GetVelocity()
    NetProps.SetPropEntity(molly, "m_hThrower", who)

    molly.SetVelocity(ang.Forward().Scale(mollyspeed.Length()).Scale(speed))
    molly.SetContext("ChCh_WasParried","1",-1)

    if(Settings.Parried_Sound >= 1)
    {
        EmitSoundOnClient("GolfClub.ImpactWorld", who)
    }
}

//function AttachSpriteTo(what,who)
//{
//    local clr = "0 0 0"
//    local character = ResponseCriteria.GetValue(who, "who").tolower()
//
//    switch(character)
//    {
//        case "gambler":
//            clr = "64 100 166"
//            break;
//        case "producer":
//            clr = "168 71 96"
//            break;
//        case "coach":
//            clr = "112 75 125"
//            break;
//        case "mechanic":
//            clr = "223 200 143"
//            break;
//        case "namvet":
//            clr = "71 117 56"
//            break;
//        case "teengirl":
//            clr = "174 91 91"
//            break;
//        case "manager":
//            clr = "255 255 255"
//            break;
//        case "biker":
//            clr = "130 147 148"
//            break;
//    }
//
//    local sprite = SpawnEntityFromTable("env_sprite", {origin = what.GetOrigin(), framerate = 10, GlowProxySize = 2, model = "sprites/glow01.spr", scale = 1, rendermode = 9, rendercolor = clr, renderamt = 255, HDRColorScale = 1, spawnflags = 1})
//    sprite.ValidateScriptScope()
//
//    NetProps.SetPropEntity(sprite,"m_hAttachedToEntity",what)
//    NetProps.SetPropEntity(sprite,"moveparent",what)
//
//    sprite.SetContext("ChCh_SpriteAttached", what.GetEntityIndex().tostring(),-1)
//}

function CheckIfShoving()
{
    local player = null
    while(player = Entities.FindByClassname(player, "player"))
    {
        if(player.IsSurvivor() && !player.IsDead() && !player.IsIncapacitated() && !player.IsHangingFromLedge())
        {
            if(ShovingPlayerData.rawin(player))
            {
                local prevshove = ShovingPlayerData.rawget(player)
                local newshove = NetProps.GetPropFloat(player, "m_flNextShoveTime")
    
                ShovingPlayerData.rawset(player, NetProps.GetPropFloat(player, "m_flNextShoveTime"))

                if(newshove != prevshove)
                {
                    OleMateShoved(player,player.GetOrigin(),player.EyeAngles())
                }
            }
            else
            {
                ShovingPlayerData.rawset(player, NetProps.GetPropFloat(player, "m_flNextShoveTime"))
            }
        }
    }

    //for (local sprite; sprite = Entities.FindByClassname(sprite, "env_sprite"); )
    //{
    //    local attach = ResponseCriteria.GetValue(sprite, "ChCh_SpriteAttached")

    //    if(attach != "")
    //    {
    //        if(!EntIndexToHScript(ResponseCriteria.GetValue(sprite, "ChCh_SpriteAttached").tointeger()))
    //        {
    //            sprite.Kill()
    //        }
    //    }
    //}
}

function GetGrenadeFrom(pos)
{
    for (local ent; ent = Entities.FindByClassnameWithin(ent, "molotov_projectile",pos,4); )
    {
       return ent
    }
    for (local ent; ent = Entities.FindByClassnameWithin(ent, "pipe_bomb_projectile",pos,4); )
    {
       return ent
    }
    for (local ent; ent = Entities.FindByClassnameWithin(ent, "vomitjar_projectile",pos,4); )
    {
       return ent
    }
    for (local ent; ent = Entities.FindByClassnameWithin(ent, "grenade_launcher_projectile",pos,4); )
    {
       return ent
    }
}

function SpawnExplosionAtFrom(who,at,rad,dam)
{
    local kaboom = SpawnEntityFromTable("env_explosion", {origin = at, spawnflags = 1, iMagnitude = 0, iRadiusOverride = rad, rendermode = 5})
    kaboom.ValidateScriptScope()
    SpawnEntityFromTable("info_particle_system", { origin = at, effect_name = "weapon_grenadelauncher", start_active = 1, flag_as_weather = 0})
    local boomnum = RandomInt(1,3).tostring()
    EmitAmbientSoundOn("ambient/explosions/explode_" + boomnum + ".wav", 1.0, 120, RandomInt(95,105), kaboom)
    EmitAmbientSoundOn("ambient/explosions/explode_" + boomnum + ".wav", 1.0, 120, RandomInt(95,105), kaboom)

    for (local ent; ent = Entities.FindByClassnameWithin(ent, "prop*",at,rad); )
    {
        ent.TakeDamage(dam, -2147483648, who)
    }
    for (local ent; ent = Entities.FindByClassnameWithin(ent, "func*",at,rad); )
    {
        ent.TakeDamage(dam, -2147483648, who)
    }
    for (local ent; ent = Entities.FindByClassnameWithin(ent, "player",at,rad); )
    {
        if(ent.IsSurvivor())
        {
            ent.TakeDamage(dam / 24, -2147483648, who)
        }
        else
        {
            ent.TakeDamage(dam, -2147483648, who)
        }
    }
    for (local ent; ent = Entities.FindByClassnameWithin(ent, "infected",at,rad); )
    {
        ent.TakeDamage(dam, -2147483648, who)
    }
    for (local ent; ent = Entities.FindByClassnameWithin(ent, "witch",at,rad); )
    {
        ent.TakeDamage(dam, -2147483648, who)
    }
}

function SpawnFireAt(who,at)
{
    DropFire(at + Vector(0,0,1))

    for (local ent; ent = Entities.FindByClassnameWithin(ent, "molotov_projectile",at,32); )
    {
        NetProps.SetPropEntity(ent, "m_hThrower", who)
    }
}

function OnGameEvent_round_start(params) 
{
    if(!IsSoundPrecached("ambient/explosions/explode_1.wav"))
    {
        PrecacheSound("ambient/explosions/explode_1.wav")
    }
    if(!IsSoundPrecached("ambient/explosions/explode_2.wav"))
    {
        PrecacheSound("ambient/explosions/explode_2.wav")
    }
    if(!IsSoundPrecached("ambient/explosions/explode_3.wav"))
    {
        PrecacheSound("ambient/explosions/explode_3.wav")
    }
    Entities.First().PrecacheScriptSound("GolfClub.ImpactWorld")
    SpawnEntityFromTable("logic_timer", {RefireTime = 0.01, OnTimer = "!self,runscriptcode,DirectorScript.ChCh_Parrying.CheckIfShoving()"})
}

function OnGameEvent_hegrenade_detonate(params) 
{
    if("x" in params && "y" in params && "z" in params && "userid" in params)
    {
        if(params.userid)
        {
            local type = GetGrenadeFrom(Vector(params.x,params.y,params.z))
            local thrower = GetPlayerFromUserID(params.userid)
    
            if(type.GetClassname() == "molotov_projectile" && Settings.Molotov_Explode >= 1)
            {
                if(ResponseCriteria.GetValue(type, "ChCh_WasParried") == "1")
                {
                    SpawnExplosionAtFrom(thrower,Vector(params.x,params.y,params.z),150,250)
                }
            }
            else if(type.GetClassname() == "pipe_bomb_projectile" && Settings.Pipe_Fire >= 1)
            {
                if(ResponseCriteria.GetValue(type, "ChCh_WasParried") == "1")
                {
                    SpawnFireAt(thrower,Vector(params.x,params.y,params.z))
                }
            }
        }
    }
}

function OnGameEvent_spit_burst(params) 
{
    if(params.subject && Settings.Spit_Explode >= 1)
    {
        local spit = Entities.FindByClassnameWithin(null, "spitter_projectile",EntIndexToHScript(params.subject).GetOrigin(),4)

        if(ResponseCriteria.GetValue(spit, "ChCh_WasParried") == "1")
        {
            SpawnExplosionAtFrom(null,spit.GetOrigin(),150,250)
        }
    }
}
}

__CollectEventCallbacks(ChCh_Parrying, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);
ChCh_Parrying.ParseSettings()