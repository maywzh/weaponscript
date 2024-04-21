Msg("Activating Restore Incap Crawling Anim script\n");

incapCrawlAnimFix <-
{
	thinkEnt = null,
	mdlIdxIncaps = {},
	mdlIdxCrawls = {},
	
	function PrecacheIncap(client, mdlIdx)
	{
		if (!(mdlIdx in mdlIdxIncaps))
		{
			mdlIdxIncaps[mdlIdx] <- [];
			local crawlAnim = client.LookupSequence("ACT_IDLE_INCAP");
			if (crawlAnim != -1)
				mdlIdxIncaps[mdlIdx].append(crawlAnim);
			crawlAnim = client.LookupSequence("ACT_IDLE_INCAP_PISTOL");
			if (crawlAnim != -1)
				mdlIdxIncaps[mdlIdx].append(crawlAnim);
			crawlAnim = client.LookupSequence("ACT_IDLE_INCAP_ELITES");
			if (crawlAnim != -1)
				mdlIdxIncaps[mdlIdx].append(crawlAnim);
			
			if (!(0 in mdlIdxIncaps))
				mdlIdxIncaps[mdlIdx] == null;
		}
	}
	
	function PrecacheCrawl(client, mdlIdx)
	{
		if (!(mdlIdx in mdlIdxCrawls))
		{
			local crawlAnim = client.LookupSequence("ACT_TERROR_INCAP_CRAWL");
			if (crawlAnim == -1)
			{
				mdlIdxCrawls[mdlIdx] <- null;
				return;
			}
			
			mdlIdxCrawls[mdlIdx] <- [
				crawlAnim,
				client.LookupActivity("ACT_TERROR_INCAP_CRAWL"),
				client.GetSequenceDuration(crawlAnim),
			];
		}
	}
	
	function ToggleThink(boolean = null)
	{
		if (boolean == null)
		{
			if (thinkEnt != null && thinkEnt.IsValid())
				boolean = false;
			else
				boolean = true;
		}
		
		switch (boolean)
		{
		case true:
			thinkEnt = SpawnEntityFromTable("info_teleport_destination", {});
			if (!thinkEnt.ValidateScriptScope())
			{
				thinkEnt.Kill();
				thinkEnt = null;
				return;
			}
			local entScope = thinkEnt.GetScriptScope();
			entScope.IncappedClients <- [];
			entScope.Slot5Used <- [];
			entScope.StopAnim <- function(client, mdlIdx = null)
			{
				if (mdlIdx == null)
					mdlIdx = NetProps.GetPropInt(client, "m_nModelIndex");
				
				incapCrawlAnimFix.PrecacheCrawl(client, mdlIdx);
				if (incapCrawlAnimFix.mdlIdxCrawls[mdlIdx] == null)
					return;
				
				if (NetProps.GetPropIntArray(client, "m_NetGestureSequence", 5) == incapCrawlAnimFix.mdlIdxCrawls[mdlIdx][0])
				{
					NetProps.SetPropIntArray(client, "m_NetGestureSequence", -1, 5);
					NetProps.SetPropIntArray(client, "m_NetGestureActivity", -1, 5);
					NetProps.SetPropFloatArray(client, "m_NetGestureStartTime", -1, 5);
				}
				if (NetProps.GetPropIntArray(client, "m_NetGestureSequence", 6) == incapCrawlAnimFix.mdlIdxCrawls[mdlIdx][0])
				{
					NetProps.SetPropIntArray(client, "m_NetGestureSequence", -1, 6);
					NetProps.SetPropIntArray(client, "m_NetGestureActivity", -1, 6);
					NetProps.SetPropFloatArray(client, "m_NetGestureStartTime", -1, 6);
				}
			}
			
			entScope.ToggleToArray <- function(client, boolean = true)
			{
				switch (boolean)
				{
				case true:
					if (IncappedClients.find(client) == null)
						IncappedClients.append(client);
					break;
				default:
					local clientLoc = IncappedClients.find(client);
					if (clientLoc != null)
					{
						IncappedClients.remove(clientLoc);
						local Slot5UsedLoc = Slot5Used.find(client);
						if (Slot5UsedLoc != null)
							Slot5Used.remove(Slot5UsedLoc);
						
						this.StopAnim(client);
						
						if (!(0 in IncappedClients))
							incapCrawlAnimFix.ToggleThink(false);
					}
					break;
				}
			}
			
			entScope.IterateIncaps <- function()
			{
				local cVarEnabled = Convars.GetFloat("survivor_allow_crawling");
				if (cVarEnabled != 0)
				{
					if (!(0 in IncappedClients))
					{
						incapCrawlAnimFix.ToggleThink(false);
						return 1.0;
					}
					for (local i = 0; i < IncappedClients.len(); i++)
					{
						local client = IncappedClients[i];
						//printl("Found "+client+" in IncappedClients array");
						if ( client == null || !client.IsValid() )
						{
							IncappedClients.remove(i);
							i = i - 1;
							continue;
						}
						
						local mdlIdx = NetProps.GetPropInt(client, "m_nModelIndex");
						incapCrawlAnimFix.PrecacheCrawl(client, mdlIdx);
						if (incapCrawlAnimFix.mdlIdxCrawls[mdlIdx] == null)
						{
							IncappedClients.remove(i);
							i = i - 1;
							continue;
						}
						incapCrawlAnimFix.PrecacheIncap(client, mdlIdx);
						if (incapCrawlAnimFix.mdlIdxIncaps[mdlIdx] == null)
						{
							IncappedClients.remove(i);
							i = i - 1;
							continue;
						}
						
						local hasIncapAnim = false;
						local clSequence = client.GetSequence();
						for (local i = 0; i < incapCrawlAnimFix.mdlIdxIncaps[mdlIdx].len(); i++)
						{
							if (incapCrawlAnimFix.mdlIdxIncaps[mdlIdx][i] == clSequence)
							{
								hasIncapAnim = true;
								break;
							}
						}
						
						local buttons = client.GetButtonMask();
						if ((buttons & DirectorScript.IN_FORWARD) && !(buttons & DirectorScript.IN_BACK) && hasIncapAnim)
						{
							//printl(client+" is crawling");
							local time = Time();
							
							local Slot5UsedLoc = Slot5Used.find(client);
							local arraySlot = null;
							
							if ((!(NetProps.GetPropIntArray(client, "m_NetGestureSequence", 6) == incapCrawlAnimFix.mdlIdxCrawls[mdlIdx][0]) || 
							(NetProps.GetPropFloatArray(client, "m_NetGestureStartTime", 6) + incapCrawlAnimFix.mdlIdxCrawls[mdlIdx][2] - 0.3 <= time)) && 
							Slot5UsedLoc == null)
								arraySlot = 5;
							else if (!(NetProps.GetPropIntArray(client, "m_NetGestureSequence", 5) == incapCrawlAnimFix.mdlIdxCrawls[mdlIdx][0]) || 
							(NetProps.GetPropFloatArray(client, "m_NetGestureStartTime", 5) + incapCrawlAnimFix.mdlIdxCrawls[mdlIdx][2] - 0.3 <= time))
								arraySlot = 6;
							
							if (arraySlot == null) continue;
							local gestureTime = NetProps.GetPropFloatArray(client, "m_NetGestureStartTime", arraySlot);
							
							if (gestureTime + incapCrawlAnimFix.mdlIdxCrawls[mdlIdx][2] - 0.1 <= time)
							{
								//printl("arraySlot "+arraySlot+" is used");
								NetProps.SetPropIntArray(client, "m_NetGestureSequence", incapCrawlAnimFix.mdlIdxCrawls[mdlIdx][0], arraySlot);
								NetProps.SetPropIntArray(client, "m_NetGestureActivity", incapCrawlAnimFix.mdlIdxCrawls[mdlIdx][1], arraySlot);
								NetProps.SetPropFloatArray(client, "m_NetGestureStartTime", time, arraySlot);
								
								if (Slot5UsedLoc == null)
									Slot5Used.append(client);
								else
									Slot5Used.remove(Slot5UsedLoc);
							}
						}
						else
							this.StopAnim(client, mdlIdx);
					}
					return 0.1;
				}
				//printl("Game has no crawling, using low think mode");
				return 1.0;
			}
			AddThinkToEnt(thinkEnt, "IterateIncaps");
			break;
		default:
			if (thinkEnt != null && thinkEnt.IsValid())
			{
				thinkEnt.Kill();
				thinkEnt = null;
			}
			break;
		}
	}
	
	function OnGameEvent_player_incapacitated( params )
	{
		if ( !("userid" in params) ) return;
		local client = GetPlayerFromUserID( params["userid"] );
		if ( client == null || !client.IsValid() ) return;
		
		if ( thinkEnt == null || !thinkEnt.IsValid() )
			ToggleThink(true);
		
		if ( thinkEnt != null && thinkEnt.IsValid() )
		{
			local entScope = thinkEnt.GetScriptScope();
			entScope.ToggleToArray(client, true);
		}
	}
	
	function OnGameEvent_revive_success( params )
	{RemoveFromThinkArray(params, "subject");}
	function OnGameEvent_player_death( params )
	{RemoveFromThinkArray(params);}
	
	function RemoveFromThinkArray( params, paramStr = "userid" )
	{
		if ( !(paramStr in params) ) return;
		local client = GetPlayerFromUserID( params[paramStr] );
		if ( client == null || !client.IsValid() ) return;
		
		if ( thinkEnt == null || !thinkEnt.IsValid() )
			ToggleThink(true);
		
		if ( thinkEnt != null && thinkEnt.IsValid() )
		{
			local entScope = thinkEnt.GetScriptScope();
			entScope.ToggleToArray(client, false);
		}
	}
	
	function DoReplace(oldPlyId, newPlyId)
	{
		if ( thinkEnt == null || !thinkEnt.IsValid() ) return;
		
		local oldPly = GetPlayerFromUserID(oldPlyId);
		if (oldPly == null || !oldPly.IsValid()) return;
		local newPly = GetPlayerFromUserID(newPlyId);
		if (newPly == null || !newPly.IsValid() || !newPly.IsSurvivor()) return;
		
		local entScope = thinkEnt.GetScriptScope();
		
		local oldPlyLoc = entScope.IncappedClients.find(oldPly);
		if (oldPlyLoc != null)
		{
			entScope.IncappedClients[oldPlyLoc] = newPly;
		}
	}
	
	function OnGameEvent_player_bot_replace(params)
	{
		if (!("player" in params) || !("bot" in params)) return;
		DoReplace(params["player"], params["bot"]);
	}
	
	function OnGameEvent_bot_player_replace(params)
	{
		if (!("player" in params) || !("bot" in params)) return;
		DoReplace(params["bot"], params["player"]);
	}
}

__CollectEventCallbacks(incapCrawlAnimFix, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)