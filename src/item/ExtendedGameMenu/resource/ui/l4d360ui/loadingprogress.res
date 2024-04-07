"Resource/UI/Downloads.res"
{
	"LoadingProgress"
	{	
		"ControlName"			"Frame"
		"fieldName"				"LoadingProgress"
		"xpos"					"0"
		"ypos"					"0"
		"wide"					"f0"
		"tall"					"f0"
		"autoResize"			"0"
		"pinCorner"				"0"
		"visible"				"1"
		"enabled"				"1"
		"tabPosition"			"0"
	}
	"ProTotalProgress"
	{
		"ControlName"			"ContinuousProgressBar"
		"fieldName"				"ProTotalProgress"
		"xpos"					"c238"	[$WIN32WIDE]
		"xpos"					"r158"	[!$WIN32WIDE]
		"ypos"					"r45"
		"wide"					"135"
		"tall"					"33" 
		"zpos"					"5"
		"autoResize"			"0"
		"pinCorner"				"0"
		"visible"				"1"
		"enabled"				"1"
		"tabPosition"			"0"
		"usetitlesafe"		"1"
	}
	
	// "WorkingAnim"
	// {
		// "visible"				"0"
		// "enabled"				"0"

	// }
	
	"WorkingAnim"
	{
		"ControlName"			"ImagePanel"
		"fieldName"				"WorkingAnim"
		"xpos"					"0"
		"ypos"					"40"
		"zpos"					"6"
		"wide"					"40"
		"tall"					"40"
		"visible"				"1"
		"enabled"				"1"
		"tabPosition"			"0"
		"scaleImage"			"1"
		"image"					"common/l4d_spinner"
		"frame"					"0"
	}	
	
	"LoadingText"
	{
		"ControlName"			"Label"
		"fieldName"				"LoadingText"
		"xpos"					"c173"	[$WIN32WIDE]
		"xpos"					"r223"	[!$WIN32WIDE]
		"ypos"					"r55"
		"zpos"					"5"
		"wide"					"200"
		"tall"					"20"
		"autoResize"			"1"
		"pinCorner"				"0"
		"visible"				"1"
		"enabled"				"1"
		"tabPosition"			"0"
		"Font"					"DefaultBold"
		"labelText"				"#L4D360UI_Loading"
		"textAlignment"			"east"
		"usetitlesafe"			"1"
		//loadingprogress_text_color_special_event
	}	
	
	"BGImage"
	{
		"ControlName"		"ImagePanel"
		"fieldName"			"BGImage"
		"xpos"				"0"
		"ypos"				"0"
		"wide"				"f0"
		"tall"				"f0"
		"zpos"				"2"
		"scaleImage"		"1"
		"visible"			"0"
		"enabled"			"1"
	}
	
	"Poster"
	{
		"ControlName"		"ImagePanel"
		"fieldName"			"Poster"
		"xpos"				"c-240"
		"ypos"				"0"
		"wide"				"480"
		"tall"				"f0"
		"zpos"				"3"
		"scaleImage"		"1"
		"visible"			"0"
		"enabled"			"1"
		// APS: THESE ARE NOW DYNAMIC - DON"T PUT A DEFAULT IMAGE HERE!
		"image"				""
	}
	
	"LocalizedCampaignName"
	{
		"ControlName"				"Label"
		"fieldName"				"LocalizedCampaignName"
		"xpos"					"c-374"	[$WIN32WIDE]
		"xpos"					"22"	[!$WIN32WIDE]
		"ypos"					"0"		
		"zpos"					"5"
		"wide"					"f0"
		"tall"					"20"
		"pinCorner"				"0"
		"visible"				"1"
		"enabled"				"1"
		"tabPosition"				"0"
		"Font"					"DefaultLarge"
		"labelText"				""
		"textAlignment"				"south-west"
		"noshortcutsyntax"			"1"
		"usetitlesafe"				"1"
		//loadingprogress_text_color_special_event
	}
	
	"LocalizedCampaignTagline"
	{
		"ControlName"				"Label"
		"fieldName"				"LocalizedCampaignTagline"
		//Urik: tagline' xpos seems to be code-linked to LocalizedCampaignName xpos
		"xpos"					"0"	[$WIN32WIDE]
		"xpos"					"0"	[!$WIN32WIDE]
		"ypos"					"0"
		"zpos"					"5"
		"wide"					"f0"
		"tall"					"20"
		"pinCorner"				"0"
		"visible"				"1"
		"enabled"				"1"
		"tabPosition"				"0"
		"Font"					"DefaultMedium"
		"labelText"				""
		"textAlignment"				"north-west"
		"noshortcutsyntax"			"1"
		"pin_to_sibling"			"LocalizedCampaignName"
		"pin_corner_to_sibling"			"0"	
		"pin_to_sibling_corner"			"2"
		//loadingprogress_text_color_special_event
	}
	
	
	"GameModeLabel"
	{
		"ControlName"				"Label"
		"fieldName"				"GameModeLabel"
		"xpos"					"c-374"	[$WIN32WIDE]
		"xpos"					"22"	[!$WIN32WIDE]
		"ypos"					"r55"
		"zpos"					"5"
		"wide"					"f0"
		"tall"					"20"
		"autoResize"				"1"
		"pinCorner"				"0"
		"visible"				"0"
		"enabled"				"1"
		"tabPosition"				"0"
		"Font"					"DefaultLarge"
		"textAlignment"				"north-west"
		"noshortcutsyntax"			"1"
		"usetitlesafe"				"1"
		//loadingprogress_text_color_special_event
	}	
	
	"StarringLabel"
	{
		"ControlName"				"Label"
		"fieldName"				"StarringLabel"
		"xpos"					"c-374"	[$WIN32WIDE]
		"xpos"					"22"	[!$WIN32WIDE]
		"ypos"					"r39"
		"zpos"					"5"
		"wide"					"50"
		"tall"					"16"
		"autoResize"				"1"
		"pinCorner"				"0"
		"visible"				"0"
		"enabled"				"1"
		"tabPosition"				"0"
		"Font"					"DefaultMedium"
		"textAlignment"				"north-west"
		"labelText"				"#L4D360UI_Loading_Starring"
		"noshortcutsyntax"			"1"
		"usetitlesafe"				"1"
		"auto_wide_tocontents"			"1"
		//loadingprogress_text_color_special_event
	}	
	"PlayerNames"
	{
		"ControlName"				"Label"
		"fieldName"				"PlayerNames"
		"xpos"					"0"
		"ypos"					"0"
		"zpos"					"5"
		"wide"					"475" 
		"tall"					"32"
		"wrap"					"1"
		"autoResize"				"1"
		"pinCorner"				"0"
		"visible"				"0"
		"enabled"				"1"
		"tabPosition"				"0"
		"Font"					"DefaultMedium"
		"textAlignment"				"north-west"
		"labelText"				""
		"noshortcutsyntax"			"1"
		"pin_to_sibling"			"StarringLabel"
		"pin_corner_to_sibling"			"0"	
		"pin_to_sibling_corner"			"1"	
		//loadingprogress_text_color_special_event
	}	
	
	"CampaignFooter"
	{
		"ControlName"		"EditablePanel"
		"fieldName"		"CampaignFooter"
		"xpos"			"0"
		"ypos"			"r60"
		"wide"			"f0"
		"tall"			"200"
		"autoResize"		"0"
		"pinCorner"		"0"
		"visible"		"0"
		"enabled"		"1"
		"textAlignment"		"west"
		"dulltext"		"0"
		"brighttext"		"1"
		"bgcolor_override"	"0 0 0 175"
		"usetitlesafe"		"1"
	}
}