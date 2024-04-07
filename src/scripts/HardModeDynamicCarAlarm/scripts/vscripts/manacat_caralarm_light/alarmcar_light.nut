carLight <-
{
	//-------------------------------------------------------
	// Required Interface functions
	//-------------------------------------------------------
	function GetPrecacheList()
	{
		local precacheModels =
		[
		//	EntityGroup.SpawnTables.Level_caralarm_glass1_off,
		]
		return precacheModels
	}

	//-------------------------------------------------------
	function GetSpawnList()
	{
		local spawnEnts =
		[
			EntityGroup.SpawnTables.custom_alarm_timer
			EntityGroup.SpawnTables.custom_alarm_light
			EntityGroup.SpawnTables.custom_alarm_light2
		]
		return spawnEnts
	}

	//-------------------------------------------------------
	function GetEntityGroup()
	{
		return EntityGroup
	}

	//-------------------------------------------------------
	// Table of entities that make up this group
	//-------------------------------------------------------
	EntityGroup =
	{
		SpawnTables =
		{
			custom_alarm_timer = 
			{
				SpawnInfo =
				{
					classname = "logic_timer"
					targetname = "manacat_alarm_timer"
					RefireTime = ".75"
					StartDisabled = "1"
					UseRandomTime = "0"
					connections =
					{
						OnTimer =
						{
							cmd1 ="manacat_alarm_lightturnOn00-1"
							cmd2 ="manacat_alarm_lightturnOff00.5-1"
						//	cmd4 ="alarm_flash_darkalpha2550.2-1"
						//	cmd5 ="alarm_flash_darkalpha00.4-1"
						}
					}
				}
			}
			custom_alarm_light = 
			{
				SpawnInfo =
				{
					classname = "light_dynamic"
					targetname = "manacat_alarm_light"
					distance = "220"
					brightness = "3"
					_light = "225 217 220 10"
                    origin = Vector(117, 0, 36)
				}
			}
			custom_alarm_light2 = 
			{
				SpawnInfo =
				{
					classname = "light_dynamic"
					targetname = "manacat_alarm_light"
					distance = "220"
					brightness = "3"
					_light = "255 13 19 10"
                    origin = Vector(-117, 0, 36)
				}
			}
		} // SpawnTables
	} // EntityGroup
}

RegisterEntityGroup( "carLight", carLight )