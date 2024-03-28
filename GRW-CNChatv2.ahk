#Requires AutoHotkey v2.0
;强制使用键盘钩子来实现热键
#UseHook true
;版本号
toolVersion := "v2.3"
;设置速度最快的WinTitle匹配模式
SetTitleMatchMode 3
SetTitleMatchMode "Fast"
;配置文件名
profilesName := "游戏无缝输入中文v2配置.ini"
;配置文件[main]段各项名称
mainConfigName := "main"
selectGameName := "选择游戏"
maxWaitTimeName := "最大等待响应时间"
chatMaxLengthName := "输入框最大字符数"
maxRandomTimeName := "延时最大值"
;配置文件游戏配置段各项名称
gameExeName := "运行程序"
inputKeyName := "开始输入"
sendMethodName := "发送文本方式"
minDelayName := "最小操作延时"
maxDelayName := "最大操作延时"
minPressName := "最小键击延时"
maxPressName := "最大键击延时"
chatPosXName := "输入框X"
chatPosYName := "输入框Y"
chatPosWName := "输入框W"
;一些控件名称
isMoveEditName := "调整输入框位置大小"
delayTimeName := "操作延时"
pressTimeName := "键击延时"
; isFullscreenName := "兼容全屏"
;实验性兼容全屏模式
; isFullscreen := 0
;聊天窗口句柄
chatGuiHwnd := 0
;游戏窗口句柄
gameHwnd := 0
;是否开启“输入框调整模式”
isMoveEdit := 0
;输入框高度
chatGuiH := 26.0
;输入框关闭按钮宽度
chatGuiCloseW := 20
;游戏配置项名称最大字符数
gameNameMaxLength := 50
;延时最小值
minRandomTime := 10
;延时最大值
maxRandomTime := 1000
;输入框允许输入的最大字符数
chatMaxLength := 88
;输入框索引名称
chatEditName := "gmxrchatedit"
;输入框关闭按钮索引名称
chatCloseName := "gmxrchatclose"
;Enter、Esc、Tab热键标准名称
enterKeyName := "Enter"
escKeyName := "Esc"
tabKeyName := "Tab"
;发送文本所有方式及对应说明
sendMethodArr := ["ControlSendText", "Send{ASC nnnnn}", "SendText", "PostMessage", "CopyPaste"]
sendMethodNameArr := ["发送字符到游戏窗口", "模拟{Alt + GBK编码}发送", "发送字符到已激活窗口", "发送字符到消息队列", "模拟复制粘贴"]
;存储所有已启用的热键
hotkeysArr := []
;主界面宽、高
myGuiW := 330
myGuiH := 280
;主界面水平边距、垂直边距
myGuiMarginX :=8
myGuiMarginY := 8

;读取并校验配置文件对应的内容
readCheckCfgData()
;创建主界面
myGui := Gui("-Resize -MaximizeBox", "游戏无缝输入中文" toolVersion)
myGui.SetFont(, "SimSun(宋体)")
myGui.MarginX := myGuiMarginX
myGui.MarginY := myGuiMarginY
;创建控件
creatMyGuiControl()
;显示主界面
myGui.Show("xCenter yCenter w" myGuiW "h" myGuiH)
;强制刷新控件的值
reloadControlValue(true)
;添加控件事件
addMyGuiControlEvent()
;当鼠标移动到特定的控件上时显示相关帮助，有需求时再加
; OnMessage(0x200, On_WM_MOUSEMOVE)

;托盘右键菜单定制
A_TrayMenu.Delete()
A_TrayMenu.Add("打开", clickOpen)
A_TrayMenu.Add("重新加载", clickReload)
A_TrayMenu.Add("退出", clickExit)
A_TrayMenu.ClickCount := 1
A_TrayMenu.Default := "打开"
A_IconTip := "游戏无缝输入中文" toolVersion

;启动声明
declarationMsgBox()

;创建主界面上的控件
creatMyGuiControl()
{
	;选择游戏、添加、删除
	selectGameBoxH := 60	;选择游戏矩形框高度
	deleteGameCtrlW := 40	;删除按钮宽度
	ddlCtrlMarginTop := 16	;选择游戏控件顶部边距
	myGui.AddGroupBox("Section w" myGuiW - myGuiMarginX * 2 " h" selectGameBoxH, selectGameName)
	selectGameCtrlW := myGuiW - myGuiMarginX * 6 - deleteGameCtrlW * 2
	global selectGameCtrl := myGui.AddDropDownList("xp+" myGuiMarginX " yp+" ddlCtrlMarginTop " w" selectGameCtrlW)
	global exeNameCtrl := myGui.AddText("xp r1 cRed wp y+2")
	global addGameCtrl := myGui.AddButton("x+" myGuiMarginX " y" myGuiMarginY + ddlCtrlMarginTop " w" deleteGameCtrlW " h" selectGameBoxH - ddlCtrlMarginTop - myGuiMarginY, "添加")
	global deleteGameCtrl := myGui.AddButton("yp wp hp x+" myGuiMarginX, "删除")
	;发送文本方式、键击延时、操作延时
	delayTimeCtrlW := 60	;操作延时按钮宽度
	sendMethodBoxH := 60	;发送文本方式矩形框高度
	sendMethodCtrlW := myGuiW - myGuiMarginX * 6 - delayTimeCtrlW * 2
	myGui.AddGroupBox("Section xs ys+" selectGameBoxH + myGuiMarginY " w" myGuiW - myGuiMarginX * 2 " h" sendMethodBoxH, sendMethodName)
	global sendMethodCtrl := myGui.AddDropDownList("xp+" myGuiMarginX " yp+" ddlCtrlMarginTop " w" sendMethodCtrlW, sendMethodArr)
	global sendMethodNameCtrl := myGui.AddText("xp r1 cRed wp y+2", sendMethodNameArr[1])
	global pressTimeCtrl := myGui.AddButton("x+" myGuiMarginX " ys+" ddlCtrlMarginTop " w" delayTimeCtrlW " h" sendMethodBoxH - ddlCtrlMarginTop - myGuiMarginY)
	global delayTimeCtrl := myGui.AddButton("yp wp hp x+" myGuiMarginX)
	;启动、输入框调整模式、关于、说明
	aboutCtrlH := 46	;关于按钮高度
	aboutCtrlW := 24	;关于按钮宽度
	inputKeyBoxH := myGuiH - selectGameBoxH - sendMethodBoxH - myGuiMarginY * 4
	inputKeyBoxW := myGuiW - sendMethodCtrlW - myGuiMarginX * 4
	startBoxW := sendMethodCtrlW+myGuiMarginX
	myGui.AddGroupBox("Section xs ys+" sendMethodBoxH + myGuiMarginY " w" startBoxW " h" inputKeyBoxH, "")
	global startCtrl := myGui.AddButton("xp+" myGuiMarginX " yp+" ddlCtrlMarginTop " w" startBoxW - myGuiMarginX * 3 - aboutCtrlW " h" inputKeyBoxH - ddlCtrlMarginTop - myGuiMarginY, "启动")
	startCtrl.SetFont("s24 cDefault")
	global aboutCtrl := myGui.AddButton("x+" myGuiMarginX " yp w" aboutCtrlW " h" aboutCtrlH, "关`n`n于")
	global readmeCtrl := myGui.AddButton("xp ys+" inputKeyBoxH-myGuiMarginY-aboutCtrlH " w" aboutCtrlW " h" aboutCtrlH, "说`n`n明")
	global isMoveEditCtrl := myGui.AddCheckbox("ys-6 w132 h20 Checked0 xs+" myGuiMarginX, isMoveEditName)
	;添加自定义属性，存储启动按钮的启停状态
	startCtrl.btnStatus := false
	;兼容全屏模式下的中文输入，会触发诸多BUG，无力解决，计划取消
	;global isFullscreenCtrl := myGui.AddCheckbox("yp w66 h20 Checked0 x+" myGuiMarginX, isFullscreenName)
	;按键配置
	textCtrlMarginY := 4	;按键配置每行文本之间的垂直间距
	inputKeyCtrlW := 50		;开始输入控件宽度
	inputKeyCtrlH := 20		;开始输入控件高度
	leftKeyNameW := 60		;左侧按键配置名宽度
	keyNameW := (inputKeyBoxW - myGuiMarginX * 3) - leftKeyNameW
	keyNameH := (inputKeyBoxH - ddlCtrlMarginTop - inputKeyCtrlH - textCtrlMarginY * 4) / 3.0
	myGui.AddGroupBox("Section ys xs+" myGuiMarginY * 2 + sendMethodCtrlW " w" inputKeyBoxW " h" inputKeyBoxH, inputKeyName)
	global inputKeyCtrl := myGui.AddHotkey("Limit254 xp+" myGuiMarginX " yp+" ddlCtrlMarginTop " w" inputKeyCtrlW " h" inputKeyCtrlH)
	global isEnterKeyCtrl := myGui.AddCheckbox("Checked0 x+" myGuiMarginX " yp w" inputKeyBoxW-myGuiMarginX*3-inputKeyCtrlW " h" inputKeyCtrlH, enterKeyName)
	myGui.AddText("+0x200 xs+" myGuiMarginX " y+" textCtrlMarginY " w" leftKeyNameW " h" keyNameH, "发送文本：")
	myGui.AddText("+0x200 x+" myGuiMarginX " yp w" keyNameW " hp", enterKeyName)
	myGui.AddText("+0x200 xs+" myGuiMarginX " y+" textCtrlMarginY " w" leftKeyNameW " hp", "取消输入：")
	myGui.AddText("+0x200 x+" myGuiMarginX " yp w" keyNameW " hp", escKeyName)
	myGui.AddText("+0x200 xs+" myGuiMarginX " y+" textCtrlMarginY " w" leftKeyNameW " hp", "切换频道：")
	myGui.AddText("+0x200 x+" myGuiMarginX " yp w" keyNameW " hp", tabKeyName)
	;设置每个控件的提示，有需求时再加
	; selectGameCtrl.ToolTip := "选择已存储及内置的游戏配置项"
	; addGameCtrl.ToolTip := "添加游戏配置项：`n依次输入“游戏名称”及“游戏窗口对应的程序完整名称”"
	; sendMethodCtrl.ToolTip := "每个游戏适用的发送方式不一样：`n针对不同游戏可依次调试出最佳方式"
	; delayTimeCtrl.ToolTip := "设置工具模拟按键的保持时间：`n每个游戏接受程度不一样，择机调试出最佳延时"
	; pressTimeCtrl.ToolTip := "设置工具模拟按键操作前的延时：`n每个游戏接受程度不一样，择机调试出最佳延时"
	; isMoveEditCtrl.ToolTip := "如果勾选后再启动：`n游戏内可自由调整输入框位置及宽度"
	; startCtrl.ToolTip := "确保游戏为“无边框”或“窗口化”模式，启动之后才可正常使用`n暂不兼容游戏全屏模式"
	; inputKeyCtrl.ToolTip := "配置开始输入的按键：`n需与游戏内的按键配置一致"
	; isEnterKeyCtrl.ToolTip := "勾选后即配置“开始聊天”按键为Enter(回车)键"
}
;添加控件触发事件
addMyGuiControlEvent()
{
	;添加控件事件
	selectGameCtrl.OnEvent("Change", selectGame_Change)
	addGameCtrl.OnEvent("Click", addGame_Click)
	deleteGameCtrl.OnEvent("Click", deleteGame_Click)
	isMoveEditCtrl.OnEvent("Click", isMoveEdit_Click)
	inputKeyCtrl.OnEvent("Change", inputKey_Change)
	isEnterKeyCtrl.OnEvent("Click", isEnterKey_Click)
	; isFullscreenCtrl.OnEvent("Click", isFullscreen_Click)
	sendMethodCtrl.OnEvent("Change", sendMethod_Change)
	delayTimeCtrl.OnEvent("Click", delayTime_Click)
	pressTimeCtrl.OnEvent("Click", pressTime_Click)
	startCtrl.OnEvent("Click", start_Click)
	aboutCtrl.OnEvent("Click", clickAbout)
	readmeCtrl.OnEvent("Click", clickReadme)
	;主界面关闭触发事件
	myGui.OnEvent("Close", myGui_Close)
}
;控件提示显示，有需求时再加
/*
On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd)
{
    static PrevHwnd := 0
    if (Hwnd != PrevHwnd)
    {
        Text := "", ToolTip() ; 关闭之前的工具提示.
        CurrControl := GuiCtrlFromHwnd(Hwnd)
        if CurrControl
        {
            if !CurrControl.HasProp("ToolTip")
                return ; 此控件没有工具提示.
            Text := CurrControl.ToolTip
            SetTimer () => ToolTip(Text), -1000
            SetTimer () => ToolTip(), -4000 ; 移除工具提示.
        }
        PrevHwnd := Hwnd
    }
}
*/
;写入配置文件
writeCfg(Value, Filename, Section, Key)
{
	if !FileExist(profilesName)
		defaultGameCfg()
	IniWrite(Value, Filename, Section, Key)
}
;主界面点击关闭按钮的处理
myGui_Close(thisGui)
{
	myGui.Opt("+OwnDialogs")
	result := warningMsgBox("确定退出？", "退出", "OKCancel Icon! Default2")
	if result = "OK"
		clickExit
	else
		return true
}
;选择游戏改变
selectGame_Change(GuiCtrlObj, Info)
{
	game := GuiCtrlObj.Text
	writeCfg(game, profilesName, mainConfigName, selectGameName)
	readCheckCfgData(game)
	reloadControlValue()
}
;添加游戏
addGame_Click(GuiCtrlObj, Info)
{
	myGui.Opt("+OwnDialogs")
	myGui.GetPos(&myGuiX, &myGuiY)
	inputBoxW := 200	;弹出的输入框宽度
	inputBoxH := 110	;弹出的输入框高度
	inputBoxX := myGuiX + (myGuiW - inputBoxW) / 2
	inputBoxY := myGuiY + (myGuiH - inputBoxH) / 2
	addGameNameBox := InputBox("输入游戏配置项名称`n不超过" gameNameMaxLength "个字符", "游戏配置项名称", "x" inputBoxX " y" inputBoxY " w" inputBoxW " h" inputBoxH)
	if addGameNameBox.Result != "OK"
		return
	addName := addGameNameBox.Value
	if !addName
		return
	if StrLen(addName) > gameNameMaxLength
	{
		warningMsgBox("配置项名称不能超过" gameNameMaxLength "个字符", "输入值错误！")
		return
	}
	if addName = mainConfigName
	{
		warningMsgBox("配置项名称不能为：" mainConfigName, "输入值错误！")
		return
	}
	for value in gameNameArr
	{
		if addName = value
		{
			warningMsgBox("配置项名称不能与现有的重复", "输入值错误！")
			return
		}
	}
	myGui.Opt("+OwnDialogs")
	addGameExeBox := InputBox("输入游戏窗口运行时对应的完整程序名(******.exe)", "游戏完整程序名", "x" inputBoxX " y" inputBoxY " w" inputBoxW " h" inputBoxH)
	if addGameExeBox.Result != "OK"
		return
	addExe := addGameExeBox.Value
	if !addExe
	{
		warningMsgBox("完整程序名不能为空", "输入值错误！")
		return
	}
	subExeStr := SubStr(addExe, -4, 4)
	if (subExeStr != ".exe")
	{
		warningMsgBox("完整程序名必须包含 .exe 后缀`n" addExe " 不符合", "输入值错误！")
		return
	}
	writeCfg(addExe, profilesName, addName, gameExeName)
	readCheckCfgData(addName)
	reloadControlValue(true)
}
;删除游戏
deleteGame_Click(GuiCtrlObj, Info)
{
	deleteGame := selectGameCtrl.Text
	myGui.Opt("+OwnDialogs")
	result := warningMsgBox("是否要删除此游戏的配置？`n" deleteGame "（" exeNameCtrl.Text "）", "删除游戏配置", "OKCancel Icon! Default2")
	if result != "OK"
		return
	;切换到下一个游戏配置项
	oldValue := selectGameCtrl.Value
	selectGameCtrl.Delete(oldValue)
	newValue := oldValue - 1
	if newValue < 1
		newValue := 1
	selectGameCtrl.Value := newValue
	game := selectGameCtrl.Text
	writeCfg(game, profilesName, mainConfigName, selectGameName)
	;删除对应的游戏配置文件
	deleteGameCfg := IniRead(profilesName, deleteGame, , "")
	if deleteGameCfg
		IniDelete(profilesName, deleteGame)
	else
		warningMsgBox("配置文件中无此游戏配置", "删除配置出错！")
	;重新读取数据并强制刷新控件显示
	readCheckCfgData(game)
	reloadControlValue(true)
}
;发送文本方式改变
sendMethod_Change(GuiCtrlObj, Info)
{
	methodValue := GuiCtrlObj.Value
	if methodValue && IsInteger(methodValue)
	{
		global sendMethod := Integer(methodValue)
		sendMethodNameCtrl.Text := sendMethodNameArr[sendMethod]
		writeCfg(sendMethod, profilesName, selectGame, sendMethodName)
	}
}
;键击随机延时改变
pressTime_Click(GuiCtrlObj, Info)
{
	myGui.Opt("+OwnDialogs")
	myGui.GetPos(&myGuiX, &myGuiY)
	inputBoxW := 180
	inputBoxH := 90
	inputBoxX := myGuiX + (myGuiW - inputBoxW) / 2
	inputBoxY := myGuiY + (myGuiH - inputBoxH) / 2
	minValueBox := InputBox("键击延时的最小值(毫秒)", "必须为10的倍数的整数", "x" inputBoxX " y" inputBoxY " w" inputBoxW " h" inputBoxH, minPressTime)
	if minValueBox.Result = "OK"
	{
		minValue := minValueBox.Value
		if !minValue
			return
		if !IsInteger(minValue)
		{
			warningMsgBox("请输入整数数字", "输入值错误！")
			return
		}
		if Mod(minValue, 10)
		{
			warningMsgBox("请输入10的倍数的整数数字！比如100,110,120", "输入值错误！")
			return
		}
		minValue := Integer(minValue)
		if minValue > 1000
		{
			warningMsgBox("输入值不能超过1000 ！", "输入值错误！")
			return
		}
		myGui.Opt("+OwnDialogs")
		maxValueBox := InputBox("键击延时的最大值(毫秒)", "必须为10的倍数的整数", "x" inputBoxX " y" inputBoxY " w" inputBoxW " h" inputBoxH, maxPressTime)
		if maxValueBox.Result = "OK"
		{
			maxValue := maxValueBox.Value
			if !maxValue
				return
			if !IsInteger(maxValue)
			{
				warningMsgBox("请输入整数数字！", "输入值错误！")
				return
			}
			if Mod(maxValue, 10)
			{
				warningMsgBox("请输入10的倍数的整数数字！比如200,210,220", "输入值错误！")
				return
			}
			maxValue := Integer(maxValue)
			if maxValue > 1000
			{
				warningMsgBox("输入值不能超过1000 ！", "输入值错误！")
				return
			}
			pressTime_Change(minValue, maxValue)
			writeCfg(minPressTime, profilesName, selectGame, minPressName)
			writeCfg(maxPressTime, profilesName, selectGame, maxPressName)
		}
	}
}
;操作随机延时改变
delayTime_Click(GuiCtrlObj, Info)
{
	myGui.Opt("+OwnDialogs")
	myGui.GetPos(&myGuiX, &myGuiY)
	inputBoxW := 180
	inputBoxH := 90
	inputBoxX := myGuiX + (myGuiW - inputBoxW) / 2
	inputBoxY := myGuiY + (myGuiH - inputBoxH) / 2
	minValueBox := InputBox("操作延时的最小值(毫秒)", "必须为10的倍数的整数", "x" inputBoxX " y" inputBoxY " w" inputBoxW " h" inputBoxH, minDelayTime)
	if minValueBox.Result = "OK"
	{
		minValue := minValueBox.Value
		if !minValue
			return
		if !IsInteger(minValue)
		{
			warningMsgBox("请输入整数数字！", "输入值错误！")
			return
		}
		if Mod(minValue, 10)
		{
			warningMsgBox("请输入10的倍数的整数数字！比如100,110,120", "输入值错误！")
			return
		}
		minValue := Integer(minValue)
		if minValue > maxRandomTime
		{
			warningMsgBox("输入值不能超过 " maxRandomTime " ！", "输入值错误！")
			return
		}
		myGui.Opt("+OwnDialogs")
		maxValueBox := InputBox("操作延时的最大值(毫秒)", "必须为10的倍数的整数", "x" inputBoxX " y" inputBoxY " w" inputBoxW " h" inputBoxH, maxDelayTime)
		if maxValueBox.Result = "OK"
		{
			maxValue := maxValueBox.Value
			if !maxValue
				return
			if !IsInteger(maxValue)
			{
				warningMsgBox("请输入整数数字！", "输入值错误！")
				return
			}
			if Mod(maxValue, 10)
			{
				warningMsgBox("请输入10的倍数的整数数字！比如100,110,120", "输入值错误！")
				return
			}
			maxValue := Integer(maxValue)
			if maxValue > maxRandomTime
			{
				warningMsgBox("输入值不能超过 " maxRandomTime " ！", "输入值错误！")
				return
			}
			delayTime_Change(minValue, maxValue)
			writeCfg(minDelayTime, profilesName, selectGame, minDelayName)
			writeCfg(maxDelayTime, profilesName, selectGame, maxDelayName)
		}
	}
}
;操作延时改变，同步按钮显示
delayTime_Change(minTime, maxTime)
{
	if maxTime < minTime
		maxTime := minTime
	global minDelayTime := minTime
	global maxDelayTime := maxTime
	delayTimeCtrl.Text := delayTimeName "`n" minTime "-" maxTime
}
;键击延时改变，同步按钮显示
pressTime_Change(minTime, maxTime)
{
	if maxTime < minTime
		maxTime := minTime
	global minPressTime := minTime
	global maxPressTime := maxTime
	pressTimeCtrl.Text := pressTimeName "`n" minTime "-" maxTime
}
;“调整输入框位置大小”勾选与取消处理
isMoveEdit_Click(GuiCtrlObj, Info)
{
	ctrlValue := GuiCtrlObj.Value
	if ctrlValue = -1
		return
	global isMoveEdit := ctrlValue
}
/*
;兼容全屏开启与关闭处理，处理起来有诸多BUG，暂时取消
isFullscreen_Click(GuiCtrlObj, Info)
{
	ctrlValue := GuiCtrlObj.Value
	if ctrlValue = -1
		return
	global isFullscreen := ctrlValue
}
*/
;开始输入按键改变
inputKey_Change(GuiCtrlObj, Info)
{
	inputKeyValue := GetKeyName(GuiCtrlObj.Value)
	;排除一些无效触发事件，及排除设置大小写键
	if (!inputKeyValue) or (inputKeyValue = "CapsLock")
	{
		inputKeyCtrl.Value := inputKey
		return
	}
	global inputKey := inputKeyValue
	writeCfg(inputKeyValue, profilesName, selectGame, inputKeyName)
}
;“Enter”控件勾选与取消处理
isEnterKey_Click(GuiCtrlObj, Info)
{
	ctrlValue := GuiCtrlObj.Value
	if ctrlValue = -1
		return
	if ctrlValue
	{
		inputKeyCtrl.Enabled := false
		enterKey := enterKeyName
		if enterKey = inputKey
			return
		inputKeyCtrl.Value := enterKey
		global inputKey := enterKey
		writeCfg(enterKey, profilesName, selectGame, inputKeyName)
	}else
		inputKeyCtrl.Enabled := true
}
;启动按钮点击事件处理
start_Click(GuiCtrlObj, Info)
{
	buttonStatus := GuiCtrlObj.btnStatus
	if buttonStatus
		stopTool()
	else
		startTool()
}
;启动
startTool()
{
	;临时禁用启动按钮
	startCtrl.Enabled := false
	;禁用可编辑控件
	selectGameCtrl.Enabled := false
	addGameCtrl.Enabled := false
	deleteGameCtrl.Enabled := false
	inputKeyCtrl.Enabled := false
	sendMethodCtrl.Enabled := false
	delayTimeCtrl.Enabled := false
	pressTimeCtrl.Enabled := false
	isMoveEditCtrl.Enabled := false
	isEnterKeyCtrl.Enabled := false
	; isFullscreenCtrl.Enabled := false
	;启用热键
	inputKeyValue := GetKeyName(inputKey)
	;只有输入键不是Enter才开启输入热键，防止与发送热键重复
	if (inputKeyValue != enterKeyName)
	{
		inputKeyValue := "~" inputKeyValue
		Hotkey(inputKeyValue, inputKeyCallback, "On")
		;存储开始输入的热键
		hotkeysArr.Push(inputKeyValue)
	}
	enterHotkey := "~" enterKeyName
	escHotkey := "~" escKeyName
	tabHotkey := "~" tabKeyName
	Hotkey(enterHotkey, sendKeyCallback, "On")
	Hotkey(escHotkey, escKeyCallback, "On")
	Hotkey(tabHotkey, tabKeyCallback, "On")
	;存储其他热键
	hotkeysArr.Push(enterHotkey, escHotkey, tabHotkey)
	;延时更新按钮状态
	SetTimer(enableStopBtn, -1000)
	enableStopBtn()
	{
		startCtrl.btnStatus := true
		startCtrl.Text := "停止"
		startCtrl.Opt("+BackgroundRed")
		startCtrl.Enabled := true
	}
}
;停止
stopTool()
{
	;禁用所有已开启的热键
	for hotkeyName in hotkeysArr
	{
		Hotkey(hotkeyName, "Off")
	}
	global hotkeysArr := []
	;销毁聊天窗口
	chatGui_Destroy()
	global gameHwnd := 0	
	;临时禁用启动按钮
	startCtrl.Enabled := false
	;延时更新按钮状态
	SetTimer(enableStartBtn, -1000)
	enableStartBtn()
	{
		;启用可编辑控件
		selectGameCtrl.Enabled := true
		addGameCtrl.Enabled := true
		if isDefaultGame(selectGame)
			deleteGameCtrl.Enabled := false
		else
			deleteGameCtrl.Enabled := true
		if isEnterKeyCtrl.Value = 1
			inputKeyCtrl.Enabled := false
		else
			inputKeyCtrl.Enabled := true
		sendMethodCtrl.Enabled := true
		delayTimeCtrl.Enabled := true
		pressTimeCtrl.Enabled := true
		isMoveEditCtrl.Enabled := true
		isEnterKeyCtrl.Enabled := true
		; isFullscreenCtrl.Enabled := true
		startCtrl.btnStatus := false
		startCtrl.Text := "启动"
		startCtrl.Opt("+BackgroundDefault")
		startCtrl.Enabled := true
	}
}
;开始输入
inputKeyCallback(hotkeyName)
{
	if !WinActive("ahk_exe" processName)
		return
	if chatGuiHwnd && GuiFromHwnd(chatGuiHwnd)
	{
		WinActivate(chatGuiHwnd)
		return
	}
	keyName := LTrim(hotkeyName, "~")
	KeyWait keyName
	Sleep Random(minDelayTime, maxDelayTime)
	global gameHwnd := WinExist()
	WinGetClientPos &grwX, &grwY, &grwW, &grwH
	; WinGetPosEx(gameHwnd, &grwX, &grwY, &grwW, &grwH)
	if chatPosW > grwW
		chatW := grwW
	else
		chatW := chatPosW
	if chatPosX < grwX
		chatX := grwX
	else if chatPosX > (grwX + grwW - chatW)
		chatX := grwX + grwW - chatW
	else
		chatX := chatPosX
	if chatPosY < grwY
		chatY := grwY
	else if chatPosY > (grwY + grwH - chatGuiH)
		chatY := grwY + grwH - chatGuiH
	else
		chatY := chatPosY

	if isMoveEdit
	{
		;已开启输入框调整模式
		;聊天框标题
		chatGuiTitle := "鼠标按此拖动、鼠标移动至左右边框调整长度"
		;+E0x80000选项禁用边框阴影，待验证
		chatGui := Gui("+ToolWindow +Caption +Resize -SysMenu +Border +AlwaysOnTop -DPIScale +MinSizex" chatGuiH " +MaxSizex" chatGuiH, chatGuiTitle)
	}else
	{
		;未开启输入框调整模式
		chatGui := Gui("+ToolWindow -Caption -Resize -SysMenu +Border +AlwaysOnTop -DPIScale", "")
	}
	; fontSize := chatGuiH // 2
	chatGui.SetFont("bold s12", "SimHei(黑体)")
	chatGui.BackColor := "Black"
	chatGui.MarginX := 0
	chatGui.MarginY := 0
	global chatGuiHwnd := chatGui.Hwnd
	;+WantTab 使得 Tab 键击产生制表符而不是导航到下一个控件。此选项问题待解决
	chatEdit := chatGui.AddEdit("x0 y0 cWhite BackgroundBlack -Tabstop -WantTab w" chatW-chatGuiCloseW " h" chatGuiH " Limit" chatMaxLength " v" chatEditName)
	chatClose := chatGui.AddText("x+0 y0 -Tabstop +Center cWhite +BackgroundRed +0x200 w" chatGuiCloseW " h" chatGuiH " v" chatCloseName, "X")
	chatGui.Show("x" chatX " y" chatY " w" chatW " h" chatGuiH)
	;设置键盘焦点到输入框
	chatEdit.Focus()
	;输入框添加相应事件处理
	chatGui.OnEvent("Size", chatGui_Size)
	chatClose.OnEvent("Click", chatGui_Close)
	; if isFullscreen
	; {
	; 	;实验性兼容全屏模式方法：让chatGui成为游戏的子窗口，有些游戏会一直闪烁
	; 	;启用兼容全屏模式后，可能会导致发送文本响应较为滞后
	; 	chatGui.Opt("+Owner" gameHwnd)
	; 	if WinWaitNotActive("ahk_id" chatGuiHwnd, , maxwaitTime)
	; 	{
	; 		if chatGuiHwnd && gameHwnd && WinExist()
	; 			WinActivate
	; 	}
	; }
}
;聊天窗口大小改变
chatGui_Size(GuiObj, MinMax, Width, Height)
{
	if (MinMax = -1)
		return
	if !isMoveEdit
		return
	if !GuiObj
		return
	chatEdit := GuiObj[chatEditName]
	chatClose := GuiObj[chatCloseName]
	if chatEdit
		chatEdit.Move(, , Width-chatGuiCloseW, Height)
	if chatClose
		chatClose.Move(Width-chatGuiCloseW, 0, , Height)
}
;主动点击聊天框的关闭按钮
chatGui_Close(GuiCtrlObj, Info)
{
	chatGui_Destroy(GuiCtrlObj.Gui)
}
;发送文本
sendKeyCallback(hotkeyName)
{
	;处理当开始输入键与发送按键同为Enter时的情况
	if (inputKey = enterKeyName)
	{
		if (!chatGuiHwnd) && WinActive("ahk_exe" processName)
		{
			;当游戏激活时，按下Enter执行开始输入事件
			enterHotKey := "~" enterKeyName
			inputKeyCallback(enterHotKey)
			return
		}
	}
	if !chatGuiHwnd
		return
	if !gameHwnd
		return
	if !WinActive("ahk_id" chatGuiHwnd)
		return
	chatGui := GuiFromHwnd(WinExist())
	chatEdit := chatGui[chatEditName]
	;兼容在中文输入状态下按Enter键直接输入英文
	oldChatText := chatEdit.Value
	KeyWait enterKeyName
	chatText := chatEdit.Value
	if chatText != oldChatText
		return
	chatGui_Destroy(chatGui)
	if !WinExist(gameHwnd)
		return
	;默认编辑控件上获取的文本就是UTF-16编码
	; chatText := getUTF8Str(chatText)
	SetKeyDelay(Random(minDelayTime, maxDelayTime), Random(minPressTime, maxPressTime))
	if (sendMethod = 2)
	{
		;Alt+nnnnn小键盘方法
		WinActivate
		if WinWaitActive(, , maxwaitTime)
		{
			loop Parse chatText
			{
				ascCode := getGBKCode(A_LoopField)
				keyName := "{ASC " ascCode "}"
				SendEvent keyName
			}
			SetKeyDelay(Random(minDelayTime, maxDelayTime), Random(minPressTime, maxPressTime))
			SendEvent "{Enter}"
			global gameHwnd := 0
		}
	}else if (sendMethod = 3)
	{
		;SendText 方法
		WinActivate
		SendText chatText
		if WinWaitActive(, , maxwaitTime)
		{
			SetKeyDelay(Random(minDelayTime, maxDelayTime), Random(minPressTime, maxPressTime))
			SendEvent "{Enter}"
			global gameHwnd := 0
		}
	}else if (sendMethod = 4)
	{
		;PostMessage 方法
		WinActivate
		waitTime := Random(minDelayTime, maxDelayTime)
		loop Parse chatText
		{
			PostMessage(WM_CHAR := 0x102, ord(A_LoopField))
			Sleep waitTime
		}
		if WinWaitActive(, , maxwaitTime)
		{
			SetKeyDelay(Random(minDelayTime, maxDelayTime), Random(minPressTime, maxPressTime))
			SendEvent "{Enter}"
			global gameHwnd := 0
		}
	}else if (sendMethod = 5)
	{
		;复制粘贴方法
		WinActivate
		if WinWaitActive(, , maxwaitTime)
		{
			;保存原有剪贴板内容，避免粘贴后无法恢复
			clipSaved := ClipboardAll()
			A_Clipboard := chatText
			ClipWait(maxwaitTime)
			SendEvent "^v"
			SetKeyDelay(Random(minDelayTime, maxDelayTime), Random(minPressTime, maxPressTime))
			SendEvent "{Enter}"
			;发送完，恢复原有剪贴板内容
			A_Clipboard := clipSaved
			global gameHwnd := 0
		}
	}else
	{
		;ControlSendText 方法
		WinActivate
		ControlSend chatText
		if WinWaitActive(, , maxwaitTime)
		{
			SetKeyDelay(Random(minDelayTime, maxDelayTime), Random(minPressTime, maxPressTime))
			SendEvent "{Enter}"
			global gameHwnd := 0
		}
	}
}
;获取单个字符的GBK编码
getGBKCode(str)
{
	encoding := "CP936"
	size := StrPut(str, encoding)	; 计算所需的缓冲区大小
	buf := Buffer(size)	; 分配缓冲区
	StrPut(str, buf, encoding)	; 将字符串转换为GBK并存储在缓冲区中
	gbkCode := (NumGet(buf, 0, "UChar") << 8) + NumGet(buf, 1, "UChar")	; 计算GBK编码的十进制值
	return gbkCode
}
/*
;AutoHotkey v2版从编辑控件上收集的字符串默认为UTF-16编码
;字符串转GBK
getGBKStr(str)
{
	encoding := "CP936"
	size := StrPut(str, encoding)
	buf := Buffer(size)
	StrPut(str, buf, encoding)
	gbkStr := StrGet(buf, encoding)  ; 从缓冲区获取GBK编码的字符串
	return gbkStr
}
;字符串转UTF-8
getUTF8Str(str)
{
	encoding := "UTF-8"
	size := StrPut(str, encoding)
	buf := Buffer(size)
	StrPut(str, buf, encoding)
	utf8Str := StrGet(buf, encoding)  ; 从缓冲区获取UTF-8编码的字符串
	return utf8Str
}
*/
;切换频道
tabKeyCallback(hotkeyName)
{
	if !chatGuiHwnd
		return
	if !gameHwnd
		return
	if !WinActive("ahk_id" chatGuiHwnd)
		return
	KeyWait tabKeyName
	if !WinExist(gameHwnd)
		return
	WinActivate()
	if WinWaitActive(, , maxwaitTime)
	{
		SetKeyDelay(Random(minDelayTime, maxDelayTime), Random(minPressTime, maxPressTime))
		SendEvent "{Tab}"
		KeyWait("Tab", "L T" maxwaitTime)
		if !WinExist(chatGuiHwnd)
			return
		WinActivate()
		;主动设置键盘焦点到输入框上，暂时不需要
		; if WinWaitActive(, , maxwaitTime)
		; {
		; 	chatGui := GuiFromHwnd(chatGuiHwnd)
		; 	if chatGui
		; 		ControlFocus(chatGui[chatEditName])
		; }
		;去除因添加+WantTab选项导致输入框多出来的制表符
		;此种方式处理效果不佳，再想更好的办法
		; chatGui := GuiFromHwnd(WinExist())
		; chatEdit := chatGui[chatEditName]
		; ControlSend("{Backspace}", chatEdit)
	}
}
;取消输入
escKeyCallback(hotkeyName)
{
	if !chatGuiHwnd
		return
	if !WinExist("ahk_id" chatGuiHwnd)
		return
	KeyWait escKeyName
	chatGuiActive := WinActive(chatGuiHwnd)
	if chatGuiActive && WinExist(gameHwnd)
	{
		WinActivate()
		if WinWaitActive(, , maxwaitTime)
		{
			SetKeyDelay(Random(minDelayTime, maxDelayTime), Random(minPressTime, maxPressTime))
			SendEvent "{Esc}"
			global gameHwnd := 0
		}
	}
	chatGui_Destroy()
}
;销毁聊天窗口
chatGui_Destroy(GuiObj?)
{
	if IsSet(GuiObj) && IsObject(GuiObj)
	{
		chatGui := GuiObj
	}else
	{
		if !chatGuiHwnd
			return
		chatGui := GuiFromHwnd(chatGuiHwnd)
		if !chatGui
		{
			global chatGuiHwnd := 0
			return
		}
	}
	if isMoveEdit
	{
		;勾选调整输入框位置大小时，在销毁前保存输入框的X、Y、W的数据
		chatGui.GetPos(&chatX, &chatY, &chatW, &chatH)
		chatGui.GetClientPos(&clientX, &clientY, &clientW, &clientH)
		global chatPosX := chatX
		global chatPosY := chatY
		global chatPosW := clientW
		writeCfg(chatPosX, profilesName, selectGame, chatPosXName)
		writeCfg(chatPosY, profilesName, selectGame, chatPosYName)
		writeCfg(chatPosW, profilesName, selectGame, chatPosWName)
	}
	chatGui.Destroy()
	global chatGuiHwnd := 0
}
;配置文件数据读取并校验
readCheckCfgData(section?)
{
	gameArr := []
	readGame := ""
	gameExe := ""
	;文件不存在时创建默认配置文件
	if !FileExist(profilesName)
		defaultGameCfg()
	if IsSet(section)
	{
		;当主动传入段名时，优先读取该段
		gameArr := creatCfgGameArr(IniRead(profilesName))
		if section
		{
			readGame := section
			gameExe := IniRead(profilesName, section, gameExeName, "")
			if !gameExe
				cfgErrMsgBox(profilesName "：`n[" readGame "]`n" gameExeName "=`n值为空！")
		}else
		{
			;段名为空时，默认选择第一个游戏
			if gameArr.Length
			{
				readGame := gameArr[1]
				IniWrite(readGame, profilesName, mainConfigName, selectGameName)
				gameExe := IniRead(profilesName, readGame, gameExeName)
			}else
			{
				;配置文件中没有游戏配置项时，删除无效配置文件并创建默认配置文件
				FileDelete(profilesName)
				defaultGameCfg()
				gameArr := creatCfgGameArr(IniRead(profilesName))
				readGame := gameArr[1]
				gameExe := IniRead(profilesName, selectGame, gameExeName)
			}
		}	
	}else
	{
		;当未主动传入段名时
		gameArr := creatCfgGameArr(IniRead(profilesName))
		if gameArr.Length
		{
			readGame := IniRead(profilesName, mainConfigName, selectGameName, "")
			if !readGame
			{
				readGame := gameArr[1]
				IniWrite(readGame, profilesName, mainConfigName, selectGameName)
			}
		}else
		{
			;配置文件中没有游戏配置项时，删除无效配置文件并创建默认配置文件
			FileDelete(profilesName)
			defaultGameCfg()
			gameArr := creatCfgGameArr(IniRead(profilesName))
			readGame := gameArr[1]
		}
		gameExe := IniRead(profilesName, readGame, gameExeName, "")
		if !gameExe
			cfgErrMsgBox(profilesName "：`n[" readGame "]`n" gameExeName "=`n值为空！")
	}
	;读取配置文件的所有游戏名、当前选择的游戏及对应的运行程序名称
	global gameNameArr := gameArr
	global selectGame := readGame
	global processName := gameExe
	;隐性配置项
	;读取并校验配置文件的“最大等待响应时间”配置项
	readMaxWaitTime := IniRead(profilesName, mainConfigName, maxWaitTimeName, "2.5")
	if !IsNumber(readMaxWaitTime)
		cfgErrMsgBox(profilesName "：`n[" mainConfigName "]`n" maxWaitTimeName "=" readMaxWaitTime "`n对应的值不是数字！")
	readMaxWaitTime := Float(readMaxWaitTime)
	if readMaxWaitTime < 0.01
		readMaxWaitTime := 0.01
	else if readMaxWaitTime > 10
		readMaxWaitTime := 10
	global maxwaitTime := readMaxWaitTime
	;读取并校验配置文件的“输入框最大字符数”配置项
	readChatMaxLength := IniRead(profilesName, mainConfigName, chatMaxLengthName, "88")
	if !IsInteger(readChatMaxLength)
		cfgErrMsgBox(profilesName "：`n[" mainConfigName "]`n" chatMaxLengthName "=" readChatMaxLength "`n对应的值不是整数！")
	readChatMaxLength := Integer(readChatMaxLength)
	if readChatMaxLength < 40
		readChatMaxLength := 40
	else if readChatMaxLength > 200
		readChatMaxLength := 200
	global chatMaxLength := readChatMaxLength
	;读取并校验配置文件的“延时最大值”配置项
	readMaxRandomTime := IniRead(profilesName, mainConfigName, maxRandomTimeName, "1000")
	if !IsInteger(readMaxRandomTime)
		cfgErrMsgBox(profilesName "：`n[" mainConfigName "]`n" maxRandomTimeName "=" readMaxRandomTime "`n对应的值不是整数!")
	readMaxRandomTime := Integer(readMaxRandomTime)
	if readMaxRandomTime < minRandomTime
		readMaxRandomTime := minRandomTime
	global maxRandomTime := readMaxRandomTime

	;读取并校验当前选择游戏的“开始输入”配置项
	readKey := IniRead(profilesName, readGame, inputKeyName, "t")
	gameKey := GetKeyName(readKey)
	if (!gameKey) or (gameKey = "CapsLock")
		cfgErrMsgBox(profilesName "：`n[" readGame "]`n" inputKeyName "=" readKey "`n对应的按键配置不支持！")
	global inputKey := gameKey
	;读取并校验当前选择游戏的“发送文本方式”配置项
	readMethod := IniRead(profilesName, readGame, sendMethodName, "1")
	if !IsInteger(readMethod)
		cfgErrMsgBox(profilesName "：`n[" readGame "]`n" sendMethodName "=" readMethod "`n对应的值必须是(1~" sendMethodArr.Length "的整数)！")
	readMethod := Integer(readMethod)
	if readMethod > sendMethodArr.Length
		readMethod := 1
	global sendMethod := readMethod
	;读取并校验当前选择游戏的“最小、最大操作延时”配置项
	readMinDelay := IniRead(profilesName, readGame, minDelayName, "10")
	if !IsInteger(readMinDelay)
		cfgErrMsgBox(profilesName "：`n[" selectGame "]`n" minDelayName "=" readMinDelay "`n对应的值必须是10的倍数的整数！")
	readMinDelay := Integer(readMinDelay)
	if readMinDelay < minRandomTime
		readMinDelay := minRandomTime
	else if readMinDelay > maxRandomTime
		readMinDelay := maxRandomTime
	global minDelayTime := readMinDelay
	readMaxDelay := IniRead(profilesName, readGame, maxDelayName, "100")
	if !IsInteger(readMaxDelay)
		cfgErrMsgBox(profilesName "：`n[" selectGame "]`n" maxDelayName "=" readMaxDelay "`n对应的值必须是10的倍数的整数！")
	readMaxDelay := Integer(readMaxDelay)
	if readMaxDelay < minRandomTime
		readMaxDelay := minRandomTime
	else if readMaxDelay > maxRandomTime
		readMaxDelay := maxRandomTime
	global maxDelayTime := readMaxDelay
	;读取并校验当前选择游戏的“最小、最大键击延时”配置项
	readMinPress := IniRead(profilesName, readGame, minPressName, "10")
	if !IsInteger(readMinPress)
		cfgErrMsgBox(profilesName "：`n[" selectGame "]`n" minPressName "=" readMinPress "`n对应的值必须是10的倍数的整数！")
	readMinPress := Integer(readMinPress)
	if readMinPress < minRandomTime
		readMinPress := minRandomTime
	else if readMinPress > maxRandomTime
		readMinPress := maxRandomTime
	global minPressTime := readMinPress
	readMaxPress := IniRead(profilesName, readGame, maxPressName, "100")
	if !IsInteger(readMaxPress)
		cfgErrMsgBox(profilesName "：`n[" selectGame "]`n" maxPressName "=" readMaxPress "`n对应的值必须是10的倍数的整数！")
	readMaxPress := Integer(readMaxPress)
	if readMaxPress < minRandomTime
		readMaxPress := minRandomTime
	else if readMaxPress > maxRandomTime
		readMaxPress := maxRandomTime
	global maxPressTime := readMaxPress
	;读取并校验当前选择游戏的“输入框X、Y、W”配置项
	readPosX := IniRead(profilesName, readGame, chatPosXName, String(A_ScreenWidth*0.8))
	if !IsNumber(readPosX)
		cfgErrMsgBox(profilesName "：`n[" selectGame "]`n" chatPosXName "=" readPosX "`n对应的值不是数字！")
	readPosX := Float(readPosX)
	global chatPosX := readPosX
	readPosY := IniRead(profilesName, readGame, chatPosYName, String(A_ScreenHeight*0.6))
	if !IsNumber(readPosY)
		cfgErrMsgBox(profilesName "：`n[" selectGame "]`n" chatPosYName "=" readPosY "`n对应的值不是数字！")
	readPosY := Float(readPosY)
	global chatPosY := readPosY
	readPosW := IniRead(profilesName, readGame, chatPosWName, String(A_ScreenWidth*0.18))
	if !IsNumber(readPosW)
		cfgErrMsgBox(profilesName "：`n[" selectGame "]`n" chatPosWName "=" readPosW "`n对应的值不是数字！")
	readPosW := Float(readPosW)
	global chatPosW := readPosW
}
;刷新控件显示
reloadControlValue(isForce?)
{
	if IsSet(isForce) && isForce
	{
		selectGameCtrl.Delete()
		selectGameCtrl.Add(gameNameArr)
	}
	selectGameCtrl.Text := selectGame
	;内置的游戏配置项则禁用删除按钮
	if isDefaultGame(selectGame)
		deleteGameCtrl.Enabled := false
	else
		deleteGameCtrl.Enabled := true
	exeNameCtrl.Text := processName
	inputKeyCtrl.Value := inputKey
	if inputKey = enterKeyName
	{
		isEnterKeyCtrl.Value := 1
		inputKeyCtrl.Enabled := false
	}else
	{
		isEnterKeyCtrl.Value := 0
		inputKeyCtrl.Enabled := true
	}
	sendMethodCtrl.Choose(sendMethod)
	sendMethodNameCtrl.Text := sendMethodNameArr[sendMethod]
	delayTime_Change(minDelayTime, maxDelayTime)
	pressTime_Change(minPressTime, maxPressTime)
}
;过滤生成游戏名字数组
creatCfgGameArr(sectionStr)
{
	if !sectionStr
		return Array()
	sectionArr := StrSplit(sectionStr, "`n")
	sectionIndex := sectionArr.Length
	loop sectionIndex
	{
		;过滤配置文件中所有的[main]配置段
		section := sectionArr[sectionIndex]
		if (section = mainConfigName)
			sectionArr.RemoveAt(sectionIndex)
		sectionIndex := sectionIndex - 1
		if sectionIndex < 1
			break
	}
	return sectionArr
}
;普通的警告样式弹窗
warningMsgBox(text?, title?, options?)
{
	if IsSet(myGui)
	{
		myGui.GetPos(&myGuiX, &myGuiY)
		msgBoxX := myGuiX + 50
		msgBoxY := myGuiY + 50
		res := MsgBoxAt(msgBoxX, msgBoxY, text ?? unset, title ?? "警告！", options ?? "Icon!")
	}else
		res := MsgBox(text ?? unset, title ?? "警告！", options ?? "Icon!")
	return res ?? ""
}
;配置文件出错样式弹窗
cfgErrMsgBox(text?)
{
	if IsSet(myGui)
	{
		myGui.GetPos(&myGuiX, &myGuiY)
		msgBoxX := myGuiX + 50
		msgBoxY := myGuiY + 50
		MsgBoxAt(msgBoxX, msgBoxY, text ?? "配置文件出错！", "配置文件出错！", "Iconx")
	}else
		MsgBox(text ?? "配置文件出错！", "配置文件出错！", "Iconx")
	ExitApp
}
;声明样式弹窗
declarationMsgBox()
{
	declarationName := "启动声明"
	isShow := IniRead(profilesName, mainConfigName, declarationName, "")
	if !isShow
		return
	text := "游戏无缝输入中文" toolVersion "
	(
	
	GameXueRen 制作

	此工具不涉及游戏文件及内存修改，
	仅模拟按键操作和使用win系统API实现全流程自动化。

	对于使用此工具，支持游戏输入中文可能导致的后果，
	完全取决于游戏厂商的判定，请自行取舍。
	此工具及作者不承担任何责任！

	此工具开源且永久免费！禁止贩卖出售！
	https://github.com/GameXueRen/GRW-CNChat
	游戏交流群：299177445 (游击战王牌大队)

	点击 “中止” 退出。
	点击 “重试” 接受声明并继续。
	点击 “忽略” 接受声明且不再提示 。
	)"
	titie := "作者声明！"
	options := "AbortRetryIgnore Icon! Default2"
	if IsSet(myGui)
	{
		myGui.GetPos(&myGuiX, &myGuiY)
		myGui.Opt("+OwnDialogs")
		res := MsgBoxAt(myGuiX, myGuiY, text, titie, options)
	} else
		res := MsgBox(text, titie, options)
	if res = "Abort"
		ExitApp
	else if res = "Ignore"
		IniWrite("0", profilesName, mainConfigName, declarationName)
	else
		return
}
;打开显示主界面
clickOpen(*)
{
	if IsSet(myGui)
		myGui.Show
}
;重新加载
clickReload(*)
{
	Reload
}
;退出
clickExit(*)
{
	;如果工具在启用状态，退出之前保存输入框位置
	if IsSet(startCtrl) && startCtrl.btnStatus
		stopTool()
	ExitApp
}
;支持自定义弹出坐标的MsgBox
MsgBoxAt(x, y, text?, title?, options?)
{
    if hHook := DllCall("SetWindowsHookExW", "int", 5, "ptr", cb := CallbackCreate(CBTProc), "ptr", 0, "uint", DllCall("GetCurrentThreadId", "uint"), "ptr") {
        res := MsgBox(text ?? unset, title ?? unset, options ?? unset)
        if hHook
            DllCall("UnhookWindowsHookEx", "ptr", hHook)
    }
    CallbackFree(cb)
    return res ?? ""
    CBTProc(nCode, wParam, lParam) {
        if nCode == 3 && WinGetClass(wParam) == "#32770" {
            DllCall("UnhookWindowsHookEx", "ptr", hHook)
            hHook := 0
            pCreateStruct := NumGet(lParam, "ptr")
            NumPut("int", x, pCreateStruct, 44)
            NumPut("int", y, pCreateStruct, 40)
        }
        return DllCall("CallNextHookEx", "ptr", 0, "int", nCode, "ptr", wParam, "ptr", lParam)
    }
}
/*
;获取更精准的窗口位置大小信息
WinGetPosEx(hwnd, &x?, &y?, &w?, &h?) 
{
	; 使用DwmGetWindowAttribute获取窗口的扩展帧边界
    if !DllCall("dwmapi\DwmGetWindowAttribute", "ptr", hwnd, "uint", 9, "ptr", rect := Buffer(16), "uint", 16) 
	{
        x := NumGet(rect, "int")
        y := NumGet(rect, 4, "int")
        w := NumGet(rect, 8, "int") - x
        h := NumGet(rect, 12, "int") - y
        return true
    }else 
	{
        ; 如果DwmGetWindowAttribute调用失败，回退到使用WinGetPos
		WinGetPos(&x, &y, &w, &h, "ahk_id" hwnd)
        return false
    }
}
*/
;判定是否为内置的游戏配置项
isDefaultGame(game)
{
	defaultGame := ["幽灵行动：荒野", "幽灵行动：断点", "幽灵行动：断点-vulkan", "彩虹六号：围攻", "彩虹六号：围攻-vulkan"]
	for value in defaultGame
	{
		if  (game = value)
			return true
	}
	return false
}
;创建默认配置文件及内置游戏配置项
defaultGameCfg()
{
	FileAppend "
	(
		[main]
		选择游戏=幽灵行动：荒野
		最大等待响应时间=2.5
		输入框最大字符数=88
		延时最大值=1000
		启动声明=1

		[幽灵行动：荒野]
		运行程序=GRW.exe
		开始输入=t
		发送文本方式=1
		最小操作延时=10
		最大操作延时=100
		最小键击延时=10
		最大键击延时=100
		输入框X=1552
		输入框Y=674
		输入框W=344

		[幽灵行动：断点]
		运行程序=GRB.exe
		开始输入=Enter
		发送文本方式=5
		最小操作延时=10
		最大操作延时=100
		最小键击延时=10
		最大键击延时=100
		输入框X=1420
		输入框Y=696
		输入框W=384

		[幽灵行动：断点-vulkan]
		运行程序=GRB_vulkan.exe
		开始输入=Enter
		发送文本方式=5
		最小操作延时=10
		最大操作延时=100
		最小键击延时=10
		最大键击延时=100
		输入框X=1420
		输入框Y=696
		输入框W=384

		[彩虹六号：围攻]
		运行程序=RainbowSix.exe
		开始输入=y
		发送文本方式=2
		最小操作延时=10
		最大操作延时=100
		最小键击延时=10
		最大键击延时=100
		输入框X=1382	
		输入框Y=778
		输入框W=288

		[彩虹六号：围攻-vulkan]
		运行程序=RainbowSix_Vulkan.exe
		开始输入=y
		发送文本方式=2
		最小操作延时=10
		最大操作延时=100
		最小键击延时=10
		最大键击延时=100
		输入框X=1382
		输入框Y=778
		输入框W=288
	)", profilesName, "CP0"
}
;关于
clickAbout(*)
{
	MsgBox "游戏无缝输入中文" toolVersion "
	(
	
	GameXueRen 制作
	此工具开源且永久免费！禁止贩卖出售！
	https://github.com/GameXueRen/GRW-CNChat
	游戏交流群：299177445 (游击战王牌大队)

	更新记录：
	公测版v1（2024/03/05）：
	首次发布，支持荒野无缝中文输入。
	公测版v1.1（2024/03/07）：
	改进打开聊天时的响应方式，方便观看聊天记录。
	公测版v1.2.1（2024/03/10）：
	兼容中文输入状态下按下Enter键导入英文，而不是直接发送；
	兼容win自带的微软拼音输入法，解决导入中文乱码；
	改善模拟按键及导入文本方式，更可靠。
	公测版v1.2.3（2024/03/13）：
	解决游戏内输入框在某些情况下不同步打开的BUG。
	公测版v2.0（2024/03/19）：
	大改版，提供自定义按键、参数微调功能，及适配更多游戏。
	公测版v2.1（2024/03/21）：
	支持开始输入按键设置为Enter，新增2种发送方式，兼容更多游戏。
	公测版v2.2（2024/03/23）：
	修复已知BUG，重新设计界面布局。
	正式版v2.3（2024/03/25）：
	修复已知BUG，正式发布！
	)", "关于"
}
;使用说明
clickReadme(*)
{
	MsgBox "
	(
	1、进入游戏画面，并确保为“无边框模式”或“窗口化”。
	此工具暂时不兼容游戏“全屏模式”下的中文输入。

	2、工具界面选项介绍。
	选择游戏：可选择已存储在配置文件中及工具内置的游戏配置项。
	添加：可添加游戏配置项，依次输入“游戏名称”及“游戏窗口对应的程序完整名称”。

	发送文本方式：不同游戏，可调试不同的“发送文本方式”来兼容。

	键击延时：此为工具模拟按键按下的保持时间，默认为10~100毫秒之间随机。
	对于一些游戏，太低的键击延时将导致模拟按键不生效。
	如果出现概率性无法联动打开游戏内输入框，或者发送漏字的情况，可适当调高此参数来调试。

	操作延时：此为工具模拟按键操作前的延时，默认为10~100毫秒之间随机。
	对于一些游戏，太低的操作延时将导致多个连续的模拟按键动作不生效。
	教高的操作延时会让工具的开启输入、发送文本、取消输入动作较为迟滞。

	调整输入框位置大小：勾选后，在游戏内可随意拖动输入框位置及调整宽度，工具同时会记住位置。

	开始输入：配置开始聊天的按键，且须与游戏内的开始聊天按键配置一致。
	额外Enter勾选框：勾选后，即配置开始输入按键为“Enter”。

	3、在游戏内，正常按“开始输入”按键聊天，按“回车”发送，按“Esc”取消聊天。无缝中文输入。
	请确保游戏内“文本聊天”按键设置与工具的一致。

	常见问题1：发送中文后，游戏内显示乱码问号。
	解决办法：进入win系统设置->时间和语言->语言->首选语言->中文(简体，中国)，
	在该语言选项下删除“美式键盘”即可解决。
	如需额外配置“美式键盘”，请在首选语言->添加语言->“英语(美国)”语言选项下添加。
	或者更换中文输入法，并首先切换到中文输入法，再启动进入游戏。
	)", "使用说明"
}