"Resource/UI/dropdown_tvgammahint.res"
{
	"PnlBackground"
	{
		"ControlName"			"Panel"
		"fieldName"				"PnlBackground"
		"xpos"					"0"
		"ypos"					"0"
		"zpos"					"-1"
		"wide"					"100"
		"tall"					"190"  [$RUSSIAN]
		"tall"					"140"  [!$RUSSIAN]
		"visible"				"1"
		"enabled"				"1"
		"paintbackground"		"1"
		"paintborder"			"1"
	}
	"Background1"
	{
		"ControlName"		"EditablePanel"
		"fieldName"			"Background1"
		"xpos"					"0"
		"ypos"					"0"
		"zpos"					"0"
		"wide"					"100"
		"tall"					"190"  [$RUSSIAN]
		"tall"					"140"  [!$RUSSIAN]
		"visible"				"1"
		"enabled"				"1"
		"bgcolor_override"	"0 0 0 255"
		"PaintBackgroundType"	"1"
	}
	"Info"
	{
		"ControlName"		"Label"
		"fieldName"		"Info"
		"xpos"			"2"
		"ypos"			"2"//themlabelsypos
		"wide"			"98"
		"tall"			"150" [$RUSSIAN]
		"tall"			"94" [!$RUSSIAN]
		"autoResize"	"0"
		"pinCorner"		"0"
		"visible"		"1"
		"enabled"		"1"
		"textAlignment"			"north-west"
		"wrap"					"1"
		"Font"					"defaultverysmall"
		"tabPosition"	"0"
		"labelText"				"仅在off/on（关闭/打开）和全屏模式下工作。仅在需要额外亮度时启用，否则使用上面的正常伽马滑块。"  
		"fgcolor_override"		"255 255 255 255"//desc_color
		//"bgcolor_override"		"0 0 255 200"
		"zpos"					"1"
	}
}
