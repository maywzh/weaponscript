//作者：求生的兔
//已知bug:霰弹枪会导致看不到当前子弹数，显示为0，备用弹匣正常显示，只是显示bug，子弹正常扣除，正常换弹，仅显示bug！
::Nicks <-[];       //存储玩家句柄的数组，句柄（官网这么说的，也就是玩家实体），这个句柄能定位到储存的特定玩家
::Weapons <-[];     //储存玩家的武器，如果玩家第一次存后拿着小手枪获取存的武器（即没有主武器但是存了一把）会把这个数组替换为weapon_none
//储存的是武器实体的名字
::fAmmo <-[];       //储存的武器当前弹药
::sAmmo <-[];       //储存武器的备用弹匣弹药
::Times_ <-[];      //判定用，判定是不是第一次存
::pWeapon <-        //遍历用，用于对比存进去的武器是否在下面的数组内
    [
        "weapon_autoshotgun","weapon_hunting_rifle","weapon_pumpshotgun","weapon_rifle_ak47","weapon_rifle_desert","weapon_rifle_m60",
        "weapon_rifle_sg552","weapon_rifle","weapon_shotgun_chrome","weapon_grenade_launcher","weapon_shotgun_spas","weapon_smg_mp5",
        "weapon_smg_silenced","weapon_smg","weapon_sniper_awp","weapon_sniper_military","weapon_sniper_scout"
    ];
::Upgard <-[];      //储存的升级效果，镭射激光，高爆，燃烧等没有回标记为0
::uAmmo <-[];       //储存的特殊子弹数量
::dbg <- 1;
	if(Entities.FindByName(null,"doubleweapon_timer")==null){
    SpawnEntityFromTable("logic_timer", {targetname = "doubleweapon_timer",vscripts = "doubleweapons",RefireTime = 0.15, OnTimer = "!caller,runscriptcode,PlayerRunCmds()"});}

function ArrayGetNum(array_,handle)//从数组内获取当前玩家句柄的编号，返回编号
{
    local p;
    for(local i =0;i<array_.len();i++)
    {
        if(array_[i] == handle)
        {
	        p = i;
            return p;
            break;
        }
    }
}
function OnGameEvent_player_say(params)
{
    if(dbg == 1)//only for dbg mode;
    {
        if(params.text == "!get")
        {
        for(local i =0;i<Nicks.len();i++)
        {
            Msg("第"+i+"号:句柄:"+Nicks[i]+",武器:"+Weapons[i]+",子弹1:"+fAmmo[i]+",子弹2:"+sAmmo[i]+",用:"+Times_[i]+",升级:"+Upgard[i]+",特字:"+uAmmo[i]+"\n");
        }
        }
    }

}
function OnGameEvent_player_connect(params)//玩家加入事件，当有新玩家加入则进行给新玩家创建数组。
{
    CreateNickArray();
    ::printlang(" 今日技巧: 按住E+鼠标右键可以选择第二主武器 ")
}
function OnGameEvent_bot_player_replace(params)
{
    CreateNickArray();
}
function OnGameEvent_player_disconnect(params)//离开事件，删除离开玩家的数组。
{
    DeleteNickArray(GetPlayerFromUserID(params.userid));
}
function DeleteNickArray(ent)//删除数组的主函数
{
    local n = ArrayGetNum(Nicks,ent);
    if(n != null)
    {
        ::Nicks.remove(n);
        ::Weapons.remove(n);
        ::fAmmo.remove(n);
        ::sAmmo.remove(n);
        ::Times_.remove(n);
        ::Upgard.remove(n);
        ::uAmmo.remove(n);
        Msg("deleted");
    }

}
function CreateNickArray()//创建数组的主函数
{
    local ent;
    while(ent = Entities.FindByClassname(ent,"player"))//遍历全部玩家
    {
        if(IsPlayerABot(ent) == false && ent.GetZombieType() == 9)//玩家不是电脑人，且是生还者
        {//创建数组
            if(Nicks.len() == 0)//肉数组内没东西，也就是第一次创建，增加玩家句柄进去。append语句就是给数组增加内容
            {
                ::Nicks.append(ent);
                ::Weapons.append("weapon_none");
                ::fAmmo.append(-1);
                ::sAmmo.append(-1);
                ::Times_.append(0);
                ::Upgard.append(0);
                ::uAmmo.append(-1);
                //Msg("1");
            }else if(Nicks.len() > 0)//数组内有东西
            {
                local n =ArrayGetNum(Nicks,ent);
                if(n == null)//且这个实体不在数组内，为此实体创建，在则跳过。
                {
                    ::Nicks.append(ent);
                    ::Weapons.append("weapon_none");
                    ::fAmmo.append(-1);
                    ::sAmmo.append(-1);
                    ::Times_.append(0);
                    ::Upgard.append(0);
                    ::uAmmo.append(-1);
                    //Msg("2");
                }
            }
        }
    }
}
::GetPlayerWeapon <- function(ent,slot)//获取玩家的武器槽内的武器，不存在返回null，存在返回武器实体句柄。
{
	local htable ={};
	GetInvTable(ent,htable);
	slot="slot"+slot;
	if(htable.rawin(slot))
	return htable.rawget(slot);
	else
	return null;
}
function PlayerRunCmds()
{
    local ent;
    //for(local i=0;i<Nicks.len();i++)//遍历循环
    //{
        while(ent = Entities.FindByClassname(ent,"player"))//遍历所有玩家
        {
            //if(GetCharacterDisplayName(ent) == "Nick")
            //{
                if(IsPlayerABot(ent) == false && ent.IsDying() == false)//玩家不是电脑，没死
                {
                    local button = ent.GetButtonMask();//获取按下的按钮

                    local n =ArrayGetNum(Nicks,ent);//获取这个玩家的数组编号
                    if(button == 2080 || button == 2088)//按钮是E+右键且这个实体在数组内。
                    {
                        if(Nicks.find(ent) != null)
                        {
                             local nowWeapon = GetPlayerWeapon(ent,0);//获得当前武器的classname;
                                if(nowWeapon!=null && Times_[n] == 0)//是第一次存武器且classname是主武器
                                {
                                    SaveMyWeapon(ent,n);//存武器
                                    //Msg("1");
                                    GetPlayerWeapon(ent,0).Kill();//删除武器
                                }else if(GetPlayerWeapon(ent,0) != null || GetPlayerWeapon(ent,0) == null)
                                {
                                    if(Times_[n] == 1 && Weapons[n] != "weapon_none")//非第一次存武器且已经存了武器
                                    {
                                        if(GetPlayerWeapon(ent,0) !=null)//有主武器
                                        {
                                            local temp_u = (NetProps.GetPropInt(GetPlayerWeapon(ent,0),"m_upgradeBitVec")).tointeger();
                                            local temp_w = GetPlayerWeapon(ent,0).GetClassname().tostring();
                                            local temp_f = (NetProps.GetPropInt(GetPlayerWeapon(ent,0),"m_iClip1")).tointeger();
                                            local temp_s = (NetProps.GetPropIntArray(ent,"m_iAmmo",NetProps.GetPropInt(GetPlayerWeapon(ent,0),"m_iPrimaryAmmoType"))).tointeger();
                                            local temp_ua = (NetProps.GetPropInt(GetPlayerWeapon(ent,0),"m_nUpgradedPrimaryAmmoLoaded")).tointeger();
                                            //w代表武器名，f代表当前弹匣数量，s代表备用弹匣数量
                                            GetPlayerWeapon(ent,0).Kill();//删除武器
                                            GiveWeaponFromInv(ent,n);//给之前存入的武器
                                            if(temp_ua <= 0)
                                            SaveMyWeapon(ent,n,temp_w,temp_f,temp_s,temp_u,0,true);//存武器
                                            if(temp_ua > 0)
                                            SaveMyWeapon(ent,n,temp_w,temp_f,temp_s,temp_u,temp_ua,true);//存武器

                                        }else if(GetPlayerWeapon(ent,0) == null)
                                        {
                                            local temp_ww = "weapon_none";
                                            //Msg(Weapons[n]);
                                            GiveWeaponFromInv(ent,n);
                                            SaveMyWeapon(ent,n,temp_ww,-1,-1,0,0,true);
                                        }
                                    }else if(Times_[n]==1 && Weapons[n] == "weapon_none")
                                    {
                                        if(GetPlayerWeapon(ent,0) !=null)
                                        {
                                            SaveMyWeapon(ent,n);
                                            GetPlayerWeapon(ent,0).Kill();
                                        }

                                    }
                                }
                        }


                    }
                }
            //}
        }
    //}
}
function GiveWeaponFromInv(ent,num)
{   local tp_string = Weapons[num].tostring();
    //Msg(tp_string);
    if(Weapons[num].tostring() != "weapon_none")
    {
        if(tp_string != "weapon_smg")
        {
            ent.GiveItem("weapon_smg");
            GetPlayerWeapon(ent,0).Kill();
            ent.GiveItem(tp_string);
            //if(Upgard[num] != 0)
            //{
	            NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_iClip1",0);
                NetProps.SetPropIntArray(ent,"m_iAmmo",sAmmo[num],NetProps.GetPropInt(GetPlayerWeapon(ent,0),"m_iPrimaryAmmoType"));
                if(Upgard[num] != 0 && Upgard[num] != 4)
                {
                    if(fAmmo[num]==0)
                    {
                        NetProps.SetPropIntArray(ent,"m_iAmmo",sAmmo[num]-uAmmo[num],NetProps.GetPropInt(GetPlayerWeapon(ent,0),"m_iPrimaryAmmoType"));
                        NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_iClip1",uAmmo[num]);
                        NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_upgradeBitVec",Upgard[num]);
                        NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_nUpgradedPrimaryAmmoLoaded",uAmmo[num]);
                    }else
                    {
                        NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_iClip1",uAmmo[num]);
                        NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_upgradeBitVec",Upgard[num]);
                        NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_nUpgradedPrimaryAmmoLoaded",uAmmo[num]);
                    }

                }else if(Upgard[num] == 4)
                {
                    NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_upgradeBitVec",Upgard[num]);
                    NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_iClip1",fAmmo[num]);
                }else if(Upgard[num] == 0)
                {
                    NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_iClip1",fAmmo[num]);
                }
        }else if(tp_string == "weapon_smg")
        {
            ent.GiveItem("weapon_smg_silenced");
            GetPlayerWeapon(ent,0).Kill();
            ent.GiveItem(tp_string);
	            NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_iClip1",0);
                NetProps.SetPropIntArray(ent,"m_iAmmo",sAmmo[num],NetProps.GetPropInt(GetPlayerWeapon(ent,0),"m_iPrimaryAmmoType"));
                if(Upgard[num] != 0 && Upgard[num] != 4)
                {
                    if(fAmmo[num]==0)
                    {
                        NetProps.SetPropIntArray(ent,"m_iAmmo",sAmmo[num]-uAmmo[num],NetProps.GetPropInt(GetPlayerWeapon(ent,0),"m_iPrimaryAmmoType"));
                        NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_iClip1",uAmmo[num]);
                        NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_upgradeBitVec",Upgard[num]);
                        NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_nUpgradedPrimaryAmmoLoaded",uAmmo[num]);
                    }else
                    {
                        NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_iClip1",uAmmo[num]);
                        NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_upgradeBitVec",Upgard[num]);
                        NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_nUpgradedPrimaryAmmoLoaded",uAmmo[num]);
                    }

                }else if(Upgard[num] == 4)
                {
                    NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_upgradeBitVec",Upgard[num]);
                    NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_iClip1",fAmmo[num]);
                }else if(Upgard[num] == 0)
                {
                    NetProps.SetPropInt(GetPlayerWeapon(ent,0),"m_iClip1",fAmmo[num]);
                }
        }

    }
}
function SaveMyWeapon(ent,num,tpw=null,tpf=null,tps=null,tpu=null,tpum=null,tpr = false)
{
    local nowWeapon = GetPlayerWeapon(ent,0).GetClassname().tostring();
    //local tests = IsPrimaryWeapon(nowWeapon);
    if(Times_[num] == 0)
    ::Times_[num] = 1;
    if(tpr == false)
    {
            ::Weapons[num] = nowWeapon;
            ::fAmmo[num] = (NetProps.GetPropInt(GetPlayerWeapon(ent,0),"m_iClip1")).tointeger();
            ::sAmmo[num] = (NetProps.GetPropIntArray(ent,"m_iAmmo",NetProps.GetPropInt(GetPlayerWeapon(ent,0),"m_iPrimaryAmmoType"))).tointeger();
            ::Upgard[num] = (NetProps.GetPropInt(GetPlayerWeapon(ent,0),"m_upgradeBitVec")).tointeger();
            local tp_ua =NetProps.GetPropInt(GetPlayerWeapon(ent,0),"m_nUpgradedPrimaryAmmoLoaded").tointeger();
            if(tp_ua <= 0)
            ::uAmmo[num] = 0;
            if(tp_ua >0)
            ::uAmmo[num] = tp_ua;
    }else if(tpr == true)
    {
        ::Weapons[num] =tpw;
        ::fAmmo[num] =tpf;
        ::sAmmo[num] = tps;
        ::Upgard[num] = tpu;
        ::uAmmo[num] = tpum;
    }

}