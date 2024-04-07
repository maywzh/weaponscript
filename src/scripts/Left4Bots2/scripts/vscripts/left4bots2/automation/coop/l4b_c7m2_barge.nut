Msg("Including " + ::Left4Bots.BaseModeName + "/l4b_c7m2_barge automation script...\n");

::Left4Bots.Automation.step <- 0;
::Left4Bots.Automation.checkpointleft <- false;

::Left4Bots.Automation.OnConcept <- function(who, subject, concept, query)
{
	//::Left4Bots.Logger.Debug("Automation.OnConcept - " + concept + " - who: " + who + " - subject: " + subject);
	
	switch (concept)
	{
		case "SurvivorLeavingInitialCheckpoint":
			// !!! This also triggers when a survivor is defibbed later in the game !!!
			if (::Left4Bots.Automation.checkpointleft)
				return;
			::Left4Bots.Automation.checkpointleft = true;
		
			// *** TASK 2. Wait for the first survivor to leave the start saferoom, then start leading
			
			::Left4Bots.Automation.DoLead("bots");
			break;

		case "SurvivorBotReachedCheckpoint":
			// *** TASK 3. Saferoom reached. Remove all the task and let the given orders (lead) complete
			
			CurrentTasks.clear();
			break;
	}
}

::Left4Bots.Automation.OnFlow <- function(prevFlowPercent, curFlowPercent)
{
	//::Left4Bots.Logger.Debug("Automation.OnFlow(" + prevFlowPercent + " -> " + curFlowPercent + ")");
	
	switch(::Left4Bots.Automation.step)
	{
		case 0:
			// *** TASK 1. Heal while in the start saferoom
			
			::Left4Bots.Automation.DoHealInSaferoom();
			::Left4Bots.Automation.step++;
			break;
	}
}

::Left4Bots.Automation.Events.OnGameEvent_round_start <- function (params)
{
	printl("::Left4Bots.Automation.Events.OnGameEvent_round_start");
	
	// What is this ladder for? There is another one for the infected next to this and this one doesn't seem to be usable by the survivors anyway. It only f*** the flow up
	local area = NavMesh.GetNavAreaByID(103491);
	if (area && area.IsValid())
	{
		local name = "whythereisaladderhere_" + area.GetID();
		if (Entities.FindByName(null, name) == null)
			::Left4Utils.SpawnNavBlocker(name, area.GetCenter(), "-5 -5 -5", "5 5 5", 2);
	}
}
