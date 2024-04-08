ChCh_TankWalkerKit <-
{
function OnGameEvent_tank_killed( params )
{
    if("userid" in params)
    {
        if(params.userid)
        {
            local tank = GetPlayerFromUserID(params.userid)
            if(tank.GetModelName() == "models/infected/hulk.mdl")
            {
                local kit = tank.FindBodygroupByName("medkit")
    
                tank.SetBodygroup(kit, 1)
    
                //local kitbone = tank.LookupBone("pack_jiggle") didnt spawn where it should
                local kitbone = tank.LookupBone("ValveBiped.Bip01_L_Thigh")
    
                SpawnEntityFromTable("weapon_first_aid_kit", {origin = tank.GetBoneOrigin(kitbone) + Vector(0,0,12), angles = tank.GetBoneAngles(kitbone).ToKVString()})
            }
        }
    }
}
}

__CollectEventCallbacks(ChCh_TankWalkerKit, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);