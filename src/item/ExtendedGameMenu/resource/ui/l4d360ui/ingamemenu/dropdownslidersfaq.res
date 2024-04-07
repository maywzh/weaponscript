"Resource/UI/DropDownSlidersFAQ.res"
{
	"PnlBackground"
	{
		"ControlName"			"Panel"
		"fieldName"				"PnlBackground"
		"xpos"					"0"
		"ypos"					"0"
		"zpos"					"-1"
		"wide"					"320"
		"tall"					"340"
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
		"wide"					"320"
		"tall"					"340"
		"visible"				"1"
		"enabled"				"1"
		"bgcolor_override"	"0 0 0 255"
		"PaintBackgroundType"	"1"
	}
	"Info"
	{
		"ControlName"		"Label"
		"fieldName"		"Info"
		"xpos"			"6"
		"ypos"			"2"//themlabelsypos
		"wide"			"308"
		"tall"			"220"
		"autoResize"	"0"
		"pinCorner"		"0"
		"visible"		"1"
		"enabled"		"1"
		"textAlignment"			"north-west"
		"wrap"					"1"
		"Font"					"BlogPostText"
		"tabPosition"	"0"
		"labelText"				"Слайдеры в развертывающихся меню можно двигать мышкой и стрелками влево-вправо. Настройка активна, пока не отпустите левую кнопку (даже если слайдер уже не отображается). Используйте только стрелки для активации слайдера инструктора по игре! Для большинства слайдеров был установлен шаг одного нажатия стрелки 25-50, кроме net_graph и FOV, где шаг 1ед. Слайдеры не масштабируются корректно, так что в зависимости от разрешения монитора возможен бардак. Изначально было настроено на 1920x1080." [$RUSSIAN]
		"labelText"				"你可以拖动弹出式菜单滑块，只要你不放开鼠标左键，即使它们不再画图。或者，您可以使用键盘箭头或控制器上的D-pad。游戏指导员滑块是非常小车-使用箭头而不是鼠标。滑块的箭头键增量已设置为在几次单击中有效地更改最小最大值，但用于网络图和视野的位置滑块除外，它们以较小的增量工作以允许更精确的设置。无法实现任何按钮，因此滑块是唯一的选择。滑块不能缩放，所以根据屏幕分辨率的不同，它们会或多或少地错位。最初调整为1920x1080" [!$RUSSIAN]
		"fgcolor_override"		"255 255 255 255"//desc_color
		//"bgcolor_override"		"0 0 255 200"
		"zpos"					"1"
	}
}
