﻿#Requires AutoHotkey v2.0
;版本号
toolVersion := "v2.4.4"
;设置速度最快的WinTitle匹配模式
SetTitleMatchMode 3
SetTitleMatchMode "Fast"
;配置文件名
profilesName := "游戏无缝输入中文v2配置.ini"
;配置文件[main]段各项名称
mainConfigName := "main"
selectGameName := "选择游戏"
maxWaitTimeName := "maxWaitTime"
chatMaxLengthName := "chatMaxLength"
chatMaxFontSizeName := "chatMaxFontSize"
isShowTipName := "isShowTip"
;配置文件游戏配置段各项名称
gameExeName := "运行程序"
inputKeyName := "开始输入"
sendMethodName := "发送文本方式"
isFixCNErrName := "修复中文乱码"
minDelayName := "最小操作延时"
maxDelayName := "最大操作延时"
minPressName := "最小键击延时"
maxPressName := "最大键击延时"
chatPosXName := "输入框X"
chatPosYName := "输入框Y"
chatPosWName := "输入框W"
chatFontSizeName := "输入框字体尺寸"
isShowAdminRunName := "isShowAdminRun"
;聊天框
chatGui := 0
chatEditName := "gmxrEdit"
;是否开启“输入框调整模式”
isMoveEdit := 0
;输入框字体最小和最大尺寸
chatMinFontSize := 10
chatMaxFontSize := 60
;延时最小值
minRandomTime := 10
;延时最大值
maxRandomTime := 1000
;输入框允许输入的最大字符数
chatMaxLength := 88
;Enter、Esc、Tab热键标准名称
enterKeyName := "Enter"
escKeyName := "Esc"
tabKeyName := "Tab"
;主界面宽、高
myGuiW := 330
myGuiH := 280

;调试
; ListLines()

;读取并校验配置文件对应的内容
readCheckMainCfgData()
;创建主界面
myGui := Gui("-Resize -MaximizeBox", "游戏无缝输入中文" toolVersion)
;创建控件
creatMyGuiControl()
;显示主界面
myGui.Show("Center w" myGuiW "h" myGuiH)
;添加控件提示
addMyGuiControlTip()
;添加控件事件
addMyGuiControlEvent()
;刷新选择游戏控件显示
refreshSelectGameCtrl()

;托盘右键菜单定制
A_TrayMenu.Delete()
A_TrayMenu.Add("打开", clickOpen(*) => myGui.Show())
A_TrayMenu.Add("重新加载", clickReload)
A_TrayMenu.Add("退出", clickExit)
A_TrayMenu.ClickCount := 1
A_TrayMenu.Default := "打开"
A_IconTip := "游戏无缝输入中文" toolVersion

;启动声明
declarationMsgBox()
;设置主界面输入焦点
setMyGuiFocus()

;创建主界面上的控件
creatMyGuiControl()
{
	;主界面水平边距、垂直边距
	myGuiMarginX := 8
	myGuiMarginY := 8
	myGui.MarginX := myGuiMarginX
	myGui.MarginY := myGuiMarginY
	;选择游戏、添加、删除
	selectGameBoxH := 60	;选择游戏矩形框高度
	deleteGameCtrlW := 40	;删除按钮宽度
	ddlCtrlMarginTop := 16	;选择游戏控件顶部边距
	myGui.AddGroupBox("Section w" myGuiW - myGuiMarginX * 2 " h" selectGameBoxH, selectGameName)
	selectGameCtrlW := myGuiW - myGuiMarginX * 6 - deleteGameCtrlW * 2
	global selectGameCtrl := myGui.AddDropDownList("xp+" myGuiMarginX " yp+" ddlCtrlMarginTop " w" selectGameCtrlW)
	global exeNameCtrl := myGui.AddText("+0x200 xp r1 cRed wp y+2")
	global addGameCtrl := myGui.AddButton("x+" myGuiMarginX " y" myGuiMarginY + ddlCtrlMarginTop " w" deleteGameCtrlW " h" selectGameBoxH - ddlCtrlMarginTop - myGuiMarginY, "添加")
	global deleteGameCtrl := myGui.AddButton("yp wp hp x+" myGuiMarginX, "删除")
	;发送文本方式、键击延时、操作延时
	delayTimeCtrlW := 60	;操作延时按钮宽度
	sendMethodBoxH := 60	;发送文本方式矩形框高度
	sendMethodCtrlW := myGuiW - myGuiMarginX * 6 - delayTimeCtrlW * 2
	myGui.AddGroupBox("Section xs ys+" selectGameBoxH + myGuiMarginY " w" myGuiW - myGuiMarginX * 2 " h" sendMethodBoxH, sendMethodName)
	;发送文本所有方式
	sendMethodArr := ["ControlSendText", "Send{ASC nnnnn}", "SendText", "PostMessage", "CopyPaste"]
	global sendMethodCtrl := myGui.AddDropDownList("xp+" myGuiMarginX " yp+" ddlCtrlMarginTop " w" sendMethodCtrlW, sendMethodArr)
	global sendMethodNameCtrl := myGui.AddText("+0x200 xp r1 cRed wp y+2")
	global pressTimeCtrl := myGui.AddButton("x+" myGuiMarginX " ys+" ddlCtrlMarginTop " w" delayTimeCtrlW " h" sendMethodBoxH - ddlCtrlMarginTop - myGuiMarginY)
	global delayTimeCtrl := myGui.AddButton("yp wp hp x+" myGuiMarginX)
	;启动、输入框调整模式、关于、说明
	aboutCtrlH := 46	;关于按钮高度
	aboutCtrlW := 26	;关于按钮宽度
	inputKeyBoxH := myGuiH - selectGameBoxH - sendMethodBoxH - myGuiMarginY * 4
	inputKeyBoxW := myGuiW - sendMethodCtrlW - myGuiMarginX * 4
	startBoxW := sendMethodCtrlW+myGuiMarginX
	myGui.AddGroupBox("Section xs ys+" sendMethodBoxH + myGuiMarginY " w" startBoxW " h" inputKeyBoxH, "")
	global startCtrl := myGui.AddButton("xp+" myGuiMarginX " yp+" ddlCtrlMarginTop " w" startBoxW - myGuiMarginX * 3 - aboutCtrlW " h" inputKeyBoxH - ddlCtrlMarginTop - myGuiMarginY, "启动")
	startCtrl.SetFont("s24")
	global settingsCtrl := myGui.AddButton("x+" myGuiMarginX " yp w" aboutCtrlW " h" aboutCtrlH, "设`n`n置")
	global aboutCtrl := myGui.AddButton("xp ys+" inputKeyBoxH-myGuiMarginY-aboutCtrlH " w" aboutCtrlW " h" aboutCtrlH, "关`n`n于")
	global manualSendCtrl := myGui.AddButton("x+-62 ys-8 w62 h22", "手动发送")
	global isMoveEditCtrl := myGui.AddCheckbox("ys-6 w80 h20 Checked0 xs+" myGuiMarginX, "调整输入框")
	;添加自定义属性，存储启动按钮的启停状态
	startCtrl.btnStatus := false
	;按键配置
	textCtrlMarginY := 4	;按键配置每行文本之间的垂直间距
	inputKeyCtrlW := 50		;开始输入控件宽度
	inputKeyCtrlH := 20		;开始输入控件高度
	leftKeyNameW := 60		;左侧按键配置名宽度
	keyNameW := (inputKeyBoxW - myGuiMarginX * 3) - leftKeyNameW
	keyNameH := (inputKeyBoxH - ddlCtrlMarginTop - inputKeyCtrlH*2 - textCtrlMarginY * 5) / 3.0
	myGui.AddGroupBox("Section ys xs+" myGuiMarginY * 2 + sendMethodCtrlW " w" inputKeyBoxW " h" inputKeyBoxH, inputKeyName)
	global inputKeyCtrl := myGui.AddHotkey("Limit254 xp+" myGuiMarginX " yp+" ddlCtrlMarginTop " w" inputKeyCtrlW " h" inputKeyCtrlH)
	global isEnterKeyCtrl := myGui.AddCheckbox("Checked0 x+" myGuiMarginX " yp w" inputKeyBoxW-myGuiMarginX*3-inputKeyCtrlW " h" inputKeyCtrlH, enterKeyName)
	global isFixCNErrCtrl := myGui.AddCheckbox("Checked0 xs+" myGuiMarginX " y+" textCtrlMarginY " w" inputKeyBoxW-myGuiMarginX*2 " h" inputKeyCtrlH, "修复中文???乱码")
	myGui.AddText("+0x200 xs+" myGuiMarginX " y+" textCtrlMarginY " w" leftKeyNameW " h" keyNameH, "发送文本：")
	myGui.AddText("+0x200 x+" myGuiMarginX " yp w" keyNameW " hp", enterKeyName)
	myGui.AddText("+0x200 xs+" myGuiMarginX " y+" textCtrlMarginY " w" leftKeyNameW " hp", "取消输入：")
	myGui.AddText("+0x200 x+" myGuiMarginX " yp w" keyNameW " hp", escKeyName)
	myGui.AddText("+0x200 xs+" myGuiMarginX " y+" textCtrlMarginY " w" leftKeyNameW " hp", "切换频道：")
	myGui.AddText("+0x200 x+" myGuiMarginX " yp w" keyNameW " hp", tabKeyName)
	global toolLinkCtrl := myGui.AddLink("right w94 x" myGuiW-myGuiMarginX-94 " y" myGuiMarginY, '开源:<a href="https://github.com/GameXueRen/GRW-CNChat">GRW-CNChat</a>')
}
;添加控件触发事件
addMyGuiControlEvent()
{
	;添加控件事件
	selectGameCtrl.OnEvent("Change", selectGame_Change)
	addGameCtrl.OnEvent("Click", addGame_Click)
	deleteGameCtrl.OnEvent("Click", deleteGame_Click)
	isMoveEditCtrl.OnEvent("Click", isMoveEdit_Click)
	manualSendCtrl.OnEvent("Click", manualSend_Click)
	inputKeyCtrl.OnEvent("Change", inputKey_Change)
	isEnterKeyCtrl.OnEvent("Click", isEnterKey_Click)
	isFixCNErrCtrl.OnEvent("Click", isFixCNErr_Click)
	sendMethodCtrl.OnEvent("Change", sendMethod_Change)
	delayTimeCtrl.OnEvent("Click", delayTime_Click)
	pressTimeCtrl.OnEvent("Click", pressTime_Click)
	startCtrl.OnEvent("Click", start_Click)
	aboutCtrl.OnEvent("Click", clickAbout)
	settingsCtrl.OnEvent("Click", openSettingsGui)
	;主界面关闭触发事件
	myGui.OnEvent("Close", myGui_Close)
}
;添加控件提示
addMyGuiControlTip()
{
	ControlAddTip(addGameCtrl, "添加新的游戏支持")
	ControlAddTip(deleteGameCtrl, "删除当前游戏配置项")
	ControlAddTip(sendMethodCtrl, "不同游戏适用的发送方式不一样`n可选择不同方式进行调试")
	ControlAddTip(pressTimeCtrl, "设置工具模拟按键操作的延时：`n不同游戏适用的延时不一样`n可设置适当延时进行调试`n延时设置范围：" minRandomTime "~" maxRandomTime)
	ControlAddTip(delayTimeCtrl, "设置工具模拟窗口操作的延时：`n不同游戏适用的延时不一样`n可设置适当延时进行调试`n延时设置范围：" minRandomTime "~" maxRandomTime)
	ControlAddTip(isMoveEditCtrl, "勾选后支持调整输入框位置及宽高`n并保存到下次显示")
	ControlAddTip(startCtrl, "确保游戏为“无边框”或“窗口化”模式`n启动之后才可正常使用")
	ControlAddTip(inputKeyCtrl, "配置开始输入的按键：`n需与游戏内的按键配置一致`n才可同步打开游戏内聊天框")
	ControlAddTip(isEnterKeyCtrl, "勾选后即配置：`n“开始输入”按键为“Enter”键")
	ControlAddTip(manualSendCtrl, "手动输入文字并发送到：`n对应窗口内的“输入光标处”`n适用一些非聊天场景")
	ControlAddTip(toolLinkCtrl, "https://github.com/GameXueRen/GRW-CNChat")
	ControlAddTip(isFixCNErrCtrl, "勾选后即尝试修复发送中文时`n显示为 ??? 类似乱码的问题")
	ControlAddTip(settingsCtrl, "打开更多设置")
	ControlAddTip(aboutCtrl, "常见问题`n更新记录")
	GuiSetTipDelayTime(myGui, 800)
	GuiSetTipEnabled(myGui, isShowTip)
}
;设置GUI
openSettingsGui(*)
{
	setMyGuiFocus()
	myGui.GetPos(&myGuiX, &myGuiY)
	settingsGuiW := 166
	settingsGuiH := 214
	settingsGuiX := Integer(myGuiX + (myGuiW - settingsGuiW) / 2)
	settingsGuiY := Integer(myGuiY + (myGuiH - settingsGuiH) / 2)
	settingsGui := Gui("-Resize -MinimizeBox +Owner" myGui.Hwnd, "更多设置")
	settingsGui.MarginX := 8
	settingsGui.MarginY := 6
	settingsGui.AddCheckbox("xm ym h20 Checked" isShowAdminRun " v" isShowAdminRunName, "显示以管理员运行建议")
	settingsGui.AddCheckbox("xp hp Checked" isShowTip " v" isShowTipName, "显示帮助(鼠标悬停显示)")
	editCtrlW := 50
	settingsGui.AddText("+0x200 r1", "等待窗口响应最长时间：")
	settingsGui.AddEdit("Section y+2 r1 +Limit4 w" editCtrlW " v" maxWaitTimeName, maxwaitTime)
	settingsGui.AddText("+0x200 x+4 hp", "秒 (1 - 60)")
	settingsGui.AddText("+0x200 xs r1", "输入框的最大字符数：")
	settingsGui.AddEdit("Section y+2 r1 +Number +Limit3 w" editCtrlW " v" chatMaxLengthName, chatMaxLength)
	settingsGui.AddText("+0x200 x+4 hp", "个 (88 - 880)")
	settingsGui.AddText("+0x200 xs r1", "输入框的最大字体尺寸：")
	settingsGui.AddEdit("Section y+2 r1 +Number +Limit2 w" editCtrlW " v" chatMaxFontSizeName, chatMaxFontSize)
	settingsGui.AddText("+0x200 x+4 hp", "磅 (10 - 72)")
	savesettingsW := 80
	saveSettingsXS := Round((settingsGuiW-savesettingsW-settingsGui.MarginX*2)/2)
	saveSettingsCtrl := settingsGui.AddButton("h30 Center xs+" saveSettingsXS " w" savesettingsW, "保存设置")

	settingsGui.Show("x" settingsGuiX " y" settingsGuiY " w" settingsGuiW "h" settingsGuiH)
	settingsGui.OnEvent("Close", (*) => myGui.Opt("-Disabled"))
	saveSettingsCtrl.OnEvent("Click", saveSettings_Click)
	myGui.Opt("+Disabled")
}
;保存设置
saveSettings_Click(GuiCtrlObj, info)
{
	settingsData := GuiCtrlObj.Gui.Submit(false)
	for ctrlName, ctrlValue in settingsData.OwnProps()
	{
		if (ctrlName = isShowTipName)
		{
			if (ctrlValue != isShowTip)
			{
				global isShowTip := ctrlValue
				writeCfg(ctrlValue, mainConfigName, ctrlName)
				GuiSetTipEnabled(myGui, isShowTip)
			}
		}else if (ctrlName = isShowAdminRunName)
		{
			if (ctrlValue != isShowAdminRun)
			{
				global isShowAdminRun := ctrlValue
				writeCfg(ctrlValue, mainConfigName, ctrlName)
			}
		}else if (ctrlName = maxWaitTimeName)
		{
			if (ctrlValue != maxwaitTime) && IsNumber(ctrlValue)
			{
				ctrlValue := Round(Number(ctrlValue), 1)
				if ctrlValue < 1
					ctrlValue := 1
				else if ctrlValue > 60
					ctrlValue := 60
				global maxwaitTime := ctrlValue
				writeCfg(ctrlValue, mainConfigName, ctrlName)
			}
		} else if (ctrlName = chatMaxLengthName)
		{
			if (ctrlValue != chatMaxLength) && IsNumber(ctrlValue)
			{
				ctrlValue := Round(Number(ctrlValue), 0)
				if ctrlValue < 88
					ctrlValue := 88
				else if ctrlValue > 880
					ctrlValue := 880
				global chatMaxLength := ctrlValue
				writeCfg(ctrlValue, mainConfigName, ctrlName)
			}
		} else if (ctrlName = chatMaxFontSizeName)
		{
			if (ctrlValue != chatMaxFontSize) && IsNumber(ctrlValue)
			{
				ctrlValue := Round(Number(ctrlValue), 0)
				if ctrlValue < chatMinFontSize
					ctrlValue := chatMinFontSize
				else if ctrlValue > 72
					ctrlValue := 72
				global chatMaxFontSize := ctrlValue
				writeCfg(ctrlValue, mainConfigName, ctrlName)
			}
		}
	}
	myGui.Opt("-Disabled")
	GuiCtrlObj.Gui.Destroy()
}
;读取配置文件
readCfg(Section?, Key?, Default := "")
{
	return IniRead(profilesName, Section ?? unset, Key ?? unset, Default)
}
;写入配置文件
writeCfg(Value, Section, Key)
{
	if FileExist(profilesName)
	{
		IniWrite(Value, profilesName, Section, Key)
	}else
	{
		;配置文件不存在时，创建默认配置文件、保存当前所有参数
		defaultGameCfg()
		IniWrite(selectGame, profilesName, mainConfigName, selectGameName)
		IniWrite(processName, profilesName, selectGame, gameExeName)
		IniWrite(inputKey, profilesName, selectGame, inputKeyName)
		IniWrite(sendMethod, profilesName, selectGame, sendMethodName)
		IniWrite(minDelayTime, profilesName, selectGame, minDelayName)
		IniWrite(maxDelayTime, profilesName, selectGame, maxDelayName)
		IniWrite(minPressTime, profilesName, selectGame, minPressName)
		IniWrite(maxPressTime, profilesName, selectGame, maxPressName)
		IniWrite(chatPosX, profilesName, selectGame, chatPosXName)
		IniWrite(chatPosY, profilesName, selectGame, chatPosYName)
		IniWrite(chatPosW, profilesName, selectGame, chatPosWName)
		IniWrite(chatFontSize, profilesName, selectGame, chatFontSizeName)
		IniWrite(isFixCNErr, profilesName, selectGame, isFixCNErrName)
		IniWrite(Value, profilesName, Section, Key)
		readCheckMainCfgData()
		refreshSelectGameCtrl()
	}
}
;主界面点击关闭按钮的处理
myGui_Close(thisGui)
{
	myGui.Opt("+OwnDialogs")
	result := warningMsgBox("确定退出？", "退出", "OKCancel Icon! Default2")
	if result = "OK"
	{
		clickExit()
	}else
		return true
}
;选择游戏改变
selectGame_Change(GuiCtrlObj, Info)
{
	game := GuiCtrlObj.Text
	if game != selectGame
	{
		global selectGame := game
		writeCfg(game, mainConfigName, selectGameName)
	}
	readCheckGameCfgData(game)
	refreshOtherCtrl()
}
;添加游戏
addGame_Click(GuiCtrlObj, Info)
{
	setMyGuiFocus()
	myGui.Opt("+OwnDialogs")
	myGui.GetPos(&myGuiX, &myGuiY)
	inputBoxW := 200	;弹出的输入框宽度
	inputBoxH := 110	;弹出的输入框高度
	inputBoxX := Integer(myGuiX + (myGuiW - inputBoxW) / 2)
	inputBoxY := Integer(myGuiY + (myGuiH - inputBoxH) / 2)
	;游戏配置项名称最大字符数
	gameNameMaxLength := 50
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
	writeCfg(addExe, addName, gameExeName)
	gameNameArr.Push(addName)
	selectGameCtrl.Add([addName])
	ControlChooseIndex(gameNameArr.Length, selectGameCtrl, myGui)
}
;删除游戏
deleteGame_Click(GuiCtrlObj, Info)
{
	setMyGuiFocus()
	deleteGame := selectGameCtrl.Text
	myGui.Opt("+OwnDialogs")
	result := warningMsgBox("是否要删除此游戏的配置？`n" deleteGame "`n( " exeNameCtrl.Text " )", "删除游戏配置", "OKCancel Icon! Default2")
	if result != "OK"
		return
	if gameNameArr.Length < 2
	{
		;简单限制，保证工具加载数据显示不出错
		warningMsgBox("无法删除`n至少需保留一个游戏配置项！", "删除配置出错！")
		return
	}
	;删除对应的游戏配置文件
	deleteGameCfg := readCfg(deleteGame)
	if deleteGameCfg
		IniDelete(profilesName, deleteGame)
	else
		warningMsgBox("配置文件中无此游戏配置", "删除配置出错！")
	;切换到下一个游戏配置项
	oldValue := selectGameCtrl.Value
	gameNameArr.RemoveAt(oldValue)
	newValue := oldValue - 1
	if newValue < 1
	{
		newValue := 1
	}
	selectGameCtrl.Delete()
	selectGameCtrl.Add(gameNameArr)
	ControlChooseIndex(newValue, selectGameCtrl, myGui)
}
;发送文本方式改变
sendMethod_Change(GuiCtrlObj, Info)
{
	methodValue := GuiCtrlObj.Value
	if methodValue = 1
		methodName := "发送字符到游戏窗口"
	else if methodValue = 2
		methodName := "模拟{Alt + GBK编码}发送"
	else if methodValue = 3
		methodName := "发送字符到已激活窗口"
	else if methodValue = 4
		methodName := "发送字符到消息队列"
	else if methodValue = 5
		methodName := "模拟复制粘贴"
	else
		methodName := ""
	sendMethodNameCtrl.Text := methodName
	if (methodValue != sendMethod) && methodName
	{
		global sendMethod := Integer(methodValue)
		writeCfg(sendMethod, selectGame, sendMethodName)
	}
}
;键击随机延时改变
pressTime_Click(GuiCtrlObj, Info)
{
	setMyGuiFocus()
	myGui.Opt("+OwnDialogs")
	myGui.GetPos(&myGuiX, &myGuiY)
	inputBoxW := 180
	inputBoxH := 90
	inputBoxX := Integer(myGuiX + (myGuiW - inputBoxW) / 2)
	inputBoxY := Integer(myGuiY + (myGuiH - inputBoxH) / 2)
	minValueBox := InputBox("键击延时的最小值(毫秒)", "必须为正整数", "x" inputBoxX " y" inputBoxY " w" inputBoxW " h" inputBoxH, minPressTime)
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
		minValue := Integer(minValue)
		if minValue > maxRandomTime
		{
			warningMsgBox("输入值不能超过" maxRandomTime " ！", "输入值错误！")
			return
		}
		myGui.Opt("+OwnDialogs")
		maxValueBox := InputBox("键击延时的最大值(毫秒)", "必须为正整数", "x" inputBoxX " y" inputBoxY " w" inputBoxW " h" inputBoxH, maxPressTime)
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
			maxValue := Integer(maxValue)
			if maxValue > maxRandomTime
			{
				warningMsgBox("输入值不能超过" maxRandomTime " ！", "输入值错误！")
				return
			}
			pressTime_Change(minValue, maxValue)
		}
	}
}
;操作随机延时改变
delayTime_Click(GuiCtrlObj, Info)
{
	setMyGuiFocus()
	myGui.Opt("+OwnDialogs")
	myGui.GetPos(&myGuiX, &myGuiY)
	inputBoxW := 180
	inputBoxH := 90
	inputBoxX := Integer(myGuiX + (myGuiW - inputBoxW) / 2)
	inputBoxY := Integer(myGuiY + (myGuiH - inputBoxH) / 2)
	minValueBox := InputBox("操作延时的最小值(毫秒)", "必须为正整数", "x" inputBoxX " y" inputBoxY " w" inputBoxW " h" inputBoxH, minDelayTime)
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
		minValue := Integer(minValue)
		if minValue > maxRandomTime
		{
			warningMsgBox("输入值不能超过 " maxRandomTime " ！", "输入值错误！")
			return
		}
		myGui.Opt("+OwnDialogs")
		maxValueBox := InputBox("操作延时的最大值(毫秒)", "必须为正整数", "x" inputBoxX " y" inputBoxY " w" inputBoxW " h" inputBoxH, maxDelayTime)
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
			maxValue := Integer(maxValue)
			if maxValue > maxRandomTime
			{
				warningMsgBox("输入值不能超过 " maxRandomTime " ！", "输入值错误！")
				return
			}
			delayTime_Change(minValue, maxValue)
		}
	}
}
;操作延时改变，同步按钮显示
delayTime_Change(minTime, maxTime)
{
	if maxTime < minTime
		maxTime := minTime
	if minTime != minDelayTime
	{
		global minDelayTime := minTime
		writeCfg(minDelayTime, selectGame, minDelayName)
	}
	if maxTime != maxDelayTime
	{
		global maxDelayTime := maxTime
		writeCfg(maxDelayTime, selectGame, maxDelayName)
	}
	delayTimeCtrl.Text := "操作延时`n" minTime "-" maxTime
}
;键击延时改变，同步按钮显示
pressTime_Change(minTime, maxTime)
{
	if maxTime < minTime
		maxTime := minTime
	if minTime != minPressTime
	{
		global minPressTime := minTime
		writeCfg(minPressTime, selectGame, minPressName)
	}
	if maxTime != maxPressTime
	{
		global maxPressTime := maxTime
		writeCfg(maxPressTime, selectGame, maxPressName)
	}
	pressTimeCtrl.Text := "键击延时`n" minTime "-" maxTime
}
;“调整输入框位置大小”勾选与取消处理
isMoveEdit_Click(GuiCtrlObj, Info)
{
	ctrlValue := GuiCtrlObj.Value
	global isMoveEdit := ctrlValue
	if !chatGui
		return
	GuiCtrlObj.Enabled := false
	if ctrlValue
	{
		chatGui.Opt("+Caption +Resize")
	}else
	{
		saveChatGuiPos()
		chatGui.Opt("-Caption -Resize")
	}
	if (WinGetMinMax(chatGui) != -1)
	{
		chatGui.Show("Restore AutoSize")
	}
	;允许调整窗口大小后，必须在输入框显示后，再次设置窗口最小及最大尺寸，才会及时生效
	if ctrlValue
	{
		chatGui.Opt("+MinSize60x" getEditAutoHeight(chatMinFontSize) " +MaxSize" A_ScreenWidth "x" getEditAutoHeight(chatMaxFontSize))
	}
	SetTimer((*)=> GuiCtrlObj.Enabled := true, -1000)
}
;“手动发送”点击事件
manualSend_Click(GuiCtrlObj, Info)
{
	setMyGuiFocus()
	checkIsAdminRun()
	myGui.Opt("+OwnDialogs")
	myGui.GetPos(&myGuiX, &myGuiY)
	inputBoxW := myGuiW-32
	inputBoxH := 126
	inputBoxX := Integer(myGuiX + (myGuiW - inputBoxW) / 2)
	inputBoxY := Integer(myGuiY + (myGuiH - inputBoxH) / 2)
	manualSendBox := InputBox("此处输入文字，点击确定即发送到`n" processName "`n窗口内的输入光标处", "手动发送文字到游戏窗口", "x" inputBoxX " y" inputBoxY " w" inputBoxW " h" inputBoxH)
	if manualSendBox.Result = "OK"
	{
		chatText := manualSendBox.Value
		if !chatText
			return
		if !WinExist("ahk_exe" processName)
		{
			warningMsgBox(processName "`n窗口不存在！")
			return
		}
		setRandomKeyDelay()
		WinActivate()
		if !WinWaitActive(, , maxwaitTime)
			return
		switchCNIME(true)
		switch sendMethod
		{
			case 2:
				loop Parse chatText
				{
					ascCode := getGBKCode(A_LoopField)
					keyName := "{ASC " ascCode "}"
					SendEvent keyName
				}
			case 3:
				SendText chatText
			case 4:
				waitTime := getRandomPressTime()
				loop Parse chatText
				{
					PostMessage(WM_CHAR := 0x102, ord(A_LoopField))
					Sleep waitTime
				}
			case 5:
				clipSaved := ClipboardAll()
				A_Clipboard := chatText
				ClipWait(maxwaitTime)
				SendEvent "^v"
				A_Clipboard := clipSaved
				clipSaved := ""
			default:
				ControlSendText chatText
		}
		switchCNIME(false)
	}
}
;开始输入按键改变
inputKey_Change(GuiCtrlObj, Info)
{
	inputKeyValue := GetKeyName(GuiCtrlObj.Value)
	;排除一些无效触发事件，及排除设置大小写键
	if (!inputKeyValue) or (inputKeyValue = "CapsLock")
	{
		GuiCtrlObj.Value := inputKey
		return
	}
	if inputKeyValue != inputKey
	{
		global inputKey := inputKeyValue
		writeCfg(inputKeyValue, selectGame, inputKeyName)
	}
}
;“Enter”控件勾选与取消处理
isEnterKey_Click(GuiCtrlObj, Info)
{
	setMyGuiFocus()
	ctrlValue := GuiCtrlObj.Value
	if ctrlValue
	{
		inputKeyCtrl.Enabled := false
		inputKeyCtrl.Value := enterKeyName
		if inputKey != enterKeyName
		{
			global inputKey := enterKeyName
			writeCfg(enterKeyName, selectGame, inputKeyName)
		}
	}else
		inputKeyCtrl.Enabled := true
}
;修复中文???乱码控件事件
isFixCNErr_Click(GuiCtrlObj, Info)
{
	setMyGuiFocus()
	ctrlValue := GuiCtrlObj.Value
	if isFixCNErr != ctrlValue
	{
		global isFixCNErr := ctrlValue
		writeCfg(ctrlValue, selectGame, isFixCNErrName)
	}
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
	checkIsAdminRun()
	setRandomKeyDelay()
	;临时禁用启动按钮
	startCtrl.Enabled := false
	;禁用可编辑控件
	selectGameCtrl.Enabled := false
	addGameCtrl.Enabled := false
	deleteGameCtrl.Enabled := false
	inputKeyCtrl.Enabled := false
	isMoveEditCtrl.Enabled := false
	isEnterKeyCtrl.Enabled := false
	startCtrl.btnStatus := true
	changeChatGui(0)
	;延时更新按钮状态
	SetTimer(enableStopBtn, -1000)
	enableStopBtn()
	{
		startCtrl.Text := "停止"
		startCtrl.Opt("+BackgroundRed")
		startCtrl.Enabled := true
		isMoveEditCtrl.Enabled := true
		setMyGuiFocus(true)
	}
}
;停止
stopTool()
{
	;临时禁用启动按钮
	startCtrl.Enabled := false
	isMoveEditCtrl.Enabled := false
	startCtrl.btnStatus := false
	changeChatGui(-1)
	;延时更新按钮状态
	SetTimer(enableStartBtn, -1000)
	enableStartBtn()
	{
		;启用可编辑控件
		selectGameCtrl.Enabled := true
		addGameCtrl.Enabled := true
		deleteGameCtrl.Enabled := true
		if isEnterKeyCtrl.Value = 1
			inputKeyCtrl.Enabled := false
		else
			inputKeyCtrl.Enabled := true
		isMoveEditCtrl.Enabled := true
		isEnterKeyCtrl.Enabled := true
		startCtrl.Text := "启动"
		startCtrl.Opt("+BackgroundDefault")
		startCtrl.Enabled := true
		setMyGuiFocus(false)
	}
}
;保存输入框位置大小
saveChatGuiPos()
{
	if !chatGui
		return
	if (WinGetMinMax(chatGui) = -1)
		return
	chatGui.GetPos(&chatX, &chatY)
	chatGui.GetClientPos(, , &clientW, &clientH)
	fontSize := getEditAutoFontSize(clientH)
	if chatPosX != chatX
	{
		global chatPosX := chatX
		writeCfg(chatX, selectGame, chatPosXName)
	}
	if chatPosY != chatY
	{
		global chatPosY := chatY
		writeCfg(chatY, selectGame, chatPosYName)
	}
	if chatPosW != clientW
	{
		global chatPosW := clientW
		writeCfg(clientW, selectGame, chatPosWName)
	}
	if chatFontSize != fontSize
	{
		global chatFontSize := fontSize
		writeCfg(fontSize, selectGame, chatFontSizeName)
	}
}
;显示、隐藏或销毁输入框
changeChatGui(state := -1)
{
	if state = -1
	{
		changeHotkeys(state)
		if chatGui
		{
			if isMoveEdit
			{
				saveChatGuiPos()
			}
			chatGui.Destroy()
			global chatGui := 0
		}
		return
	}
	if !chatGui
	{
		screenWidth := A_ScreenWidth
		screenHeight := A_ScreenHeight
		chatH := getEditAutoHeight(chatFontSize)
		if chatPosW > screenWidth
			chatW := screenWidth
		else
			chatW := chatPosW
		if chatPosX < 0
			chatX := 0
		else if chatPosX > (screenWidth - chatW)
			chatX := screenWidth - chatW
		else
			chatX := chatPosX
		if chatPosY < 0
			chatY := 0
		else if chatPosY > (screenHeight - chatH)
			chatY := screenHeight - chatH
		else
			chatY := chatPosY
		chatGuiTitle := "鼠标按此拖动、鼠标靠至左右上下边框调整宽高"
		if isMoveEdit
		{
			;已开启输入框调整模式
			chatGuiMinH := getEditAutoHeight(chatMinFontSize)
			chatGuiMaxH := getEditAutoHeight(chatMaxFontSize)
			global chatGui := Gui("+ToolWindow -SysMenu +Border +Caption +Resize +AlwaysOnTop +MinSize60x" chatGuiMinH " +MaxSize" A_ScreenWidth "x" chatGuiMaxH, chatGuiTitle)
		} else
		{
			global chatGui := Gui("+ToolWindow -SysMenu +Border -Caption -Resize +AlwaysOnTop", chatGuiTitle)
		}
		chatGui.SetFont("bold s" chatFontSize)
		chatGui.BackColor := "Black"
		chatGui.MarginX := 0
		chatGui.MarginY := 0
		chatGui.AddEdit("x0 y0 cWhite BackgroundBlack r1 Disabled1 w" chatW - 20 " h" chatH " Limit" chatMaxLength " v" chatEditName)
		chatClose := chatGui.AddText("yp +Center cWhite +BackgroundRed +0x200 vgmxrClose w20 h" chatH, "X")
		chatClose.SetFont("s12")
		chatGui.Show("Hide AutoSize x" chatX " y" chatY)
		chatClose.OnEvent("Click", chatClose_Click(GuiCtrlObj, *) => changeChatGui(0))
		chatGui.OnEvent("Size", chatGui_Size)
	}
	if state = 0
	{
		changeHotkeys(state)
		chatGui[chatEditName].Text := ""
		chatGui[chatEditName].Enabled := false
		if isMoveEdit
		{
			saveChatGuiPos()
		}
		; 需要先最小化，再隐藏，否则窗口最小化后会残留显示标题栏
		chatGui.Show("Minimize")
		chatGui.Hide()
	} else if state = 1
	{
		Sleep getRandomDelayTime()
		chatGui.Show("Restore AutoSize")
		; 允许调整窗口大小后，必须在输入框显示后，再次设置窗口最小及最大尺寸，才会及时生效
		if isMoveEdit
		{
			chatGui.Opt("+MinSize60x" getEditAutoHeight(chatMinFontSize) " +MaxSize" A_ScreenWidth "x" getEditAutoHeight(chatMaxFontSize))
		}
		chatGui[chatEditName].Enabled := true
		chatGui[chatEditName].Focus()
		changeHotkeys(state)
	}
}
;相关热键控制
changeHotkeys(state)
{
	if state = 0
	{
		;启用开始输入热键及禁用其他热键
		if (inputKey = enterKeyName)
		{
			Hotkey("~" enterKeyName, enterInputKeyCallback, "On")
		}else
		{
			static oldInputkey := inputKey
			if oldInputkey != inputKey
			{
				;防止上次的开始输入热键未被及时禁用,导致启用多个开始输入热键
				Hotkey("~" oldInputkey " Up", inputKeyCallback, "Off")
				oldInputkey := inputKey
			}
			Hotkey("~" inputKey " Up", inputKeyCallback, "On")
			Hotkey("~" enterKeyName, sendKeyCallback, "Off")
		}
		Hotkey("~" escKeyName " Up", escKeyCallback, "Off")
		Hotkey("~" tabKeyName " Up", tabKeyCallback, "Off")
	}else if state = 1
	{
		;禁用开始输入热键及启用其他热键
		if (inputKey = enterKeyName)
		{
			Hotkey("~" enterKeyName, enterInputKeyCallback, "On")
		}else
		{
			Hotkey("~" inputKey " Up", inputKeyCallback, "Off")
			Hotkey("~" enterKeyName, sendKeyCallback, "On")
		}
		Hotkey("~" escKeyName " Up", escKeyCallback, "On")
		Hotkey("~" tabKeyName " Up", tabKeyCallback, "On")
	}else if state = -1
	{
		;禁用所有热键
		if (inputKey = enterKeyName)
		{
			Hotkey("~" enterKeyName, enterInputKeyCallback, "Off")
		}else
		{
			Hotkey("~" inputKey " Up", inputKeyCallback, "Off")
			Hotkey("~" enterKeyName, sendKeyCallback, "Off")
		}
		Hotkey("~" escKeyName " Up", escKeyCallback, "Off")
		Hotkey("~" tabKeyName " Up", tabKeyCallback, "Off")
	}
}
;当开始输入为Enter时的处理
enterInputKeyCallback(hotkeyName)
{
	if chatGui && WinActive(chatGui)
	{
		sendKeyCallback(hotkeyName)
		return
	}
	KeyWait LTrim(hotkeyName, "~")
	inputKeyCallback(hotkeyName)
}
;开始输入
inputKeyCallback(hotkeyName)
{
	Critical
	if !WinActive("ahk_exe" processName)
		return
	changeChatGui(1)
}
;获取输入框最佳匹配高度
getEditAutoHeight(fontSize)
{
	autoHeight := Round(fontSize * A_ScreenDPI / 72.0 + 8.0)
	if autoHeight < 1
		autoHeight := 1
	return autoHeight
}
;获取输入框最佳匹配字体尺寸
getEditAutoFontSize(height)
{
	autoFontSize := Round((height - 8.0) * 72.0 / A_ScreenDPI)
	if autoFontSize < chatMinFontSize
		autoFontSize := chatMinFontSize
	else if autoFontSize > 72
		autoFontSize := 72
	return autoFontSize
}
;聊天窗口大小改变
chatGui_Size(GuiObj, MinMax, Width, Height)
{
	if (MinMax = -1)
		return
	if !isMoveEdit
		return
	chatEdit := GuiObj[chatEditName]
	chatClose := GuiObj["gmxrClose"]
	fontSize := getEditAutoFontSize(Height)
	chatEdit.SetFont("s" fontSize)
	chatEdit.Move(, , Width - 20, Height)
	chatClose.Move(Width - 20, , , Height)
	chatEdit.Redraw()
	chatClose.Redraw()
}
;发送文本
sendKeyCallback(hotkeyName)
{
	Critical
	if !chatGui
		return
	if !WinActive(chatGui)
		return
	chatEdit := chatGui[chatEditName]
	;兼容在中文输入状态下按Enter键直接输入英文
	oldChatText := chatEdit.Value
	KeyWait LTrim(hotkeyName, "~")
	chatText := chatEdit.Value
	if chatText != oldChatText
		return
	changeChatGui(0)
	if !WinExist("ahk_exe" processName)
		return
	WinActivate()
	switch sendMethod
	{
		case 2:
			;Alt+nnnnn小键盘方法
			if WinWaitActive(, , maxwaitTime)
			{
				switchCNIME(true)
				loop Parse chatText
				{
					ascCode := getGBKCode(A_LoopField)
					keyName := "{ASC " ascCode "}"
					SendEvent keyName
				}
				setRandomKeyDelay()
				SendEvent "{Enter}"
			}
		case 3:
			;SendText 方法
			if WinWaitActive(, , maxwaitTime)
			{
				switchCNIME(true)
				SendText chatText
				setRandomKeyDelay()
				SendEvent "{Enter}"
			}
		case 4:
			;PostMessage 方法
			switchCNIME(true)
			waitTime := getRandomPressTime()
			loop Parse chatText
			{
				PostMessage(WM_CHAR := 0x102, ord(A_LoopField))
				Sleep waitTime
			}
			if WinWaitActive(, , maxwaitTime)
			{
				setRandomKeyDelay()
				SendEvent "{Enter}"
			}
		case 5:
			;复制粘贴方法
			if WinWaitActive(, , maxwaitTime)
			{
				switchCNIME(true)
				;保存原有剪贴板内容，避免粘贴后无法恢复
				clipSaved := ClipboardAll()
				A_Clipboard := chatText
				ClipWait(maxwaitTime)
				SendEvent "^v"
				setRandomKeyDelay()
				SendEvent "{Enter}"
				;发送完，恢复原有剪贴板内容
				A_Clipboard := clipSaved
				clipSaved := "" ;释放内存
			}
		default:
			;ControlSendText 方法
			switchCNIME(true)
    		ControlSendText chatText
			if WinWaitActive(, , maxwaitTime)
			{
				setRandomKeyDelay()
				SendEvent "{Enter}"
			}
	}
	switchCNIME(false)
}
;切换中文输入法或恢复原输入法
;IME的ID:"zh",134481924 "jp",68224017 "en",67699721
switchCNIME(isSwitchCN := false)
{
	if !isFixCNErr
		return
	static inputLocaleID := -1
	if isSwitchCN
	{
		;切换为中文输入法 0x8040804=134481924
		try
		{
			threadID := DllCall("GetWindowThreadProcessId", "UInt", WinExist("A"), "UInt", 0)
			localeID := DllCall("GetKeyboardLayout", "UInt", threadID, "UInt")
			if localeID != 134481924
			{
				PostMessage(0x50, 0, 134481924, , "A")
				inputLocaleID := localeID
				Sleep getRandomDelayTime()
			}
		}
	} else
	{
		if inputLocaleID = -1
			return
		;切换为英文输入法  美式键盘0x40904090=67699721
		;恢复原输入法
		try
		{
			PostMessage(0x50, 0, inputLocaleID, , "A")
		}
		inputLocaleID := -1
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
	Critical
	if !chatGui
		return
	if !WinActive(chatGui)
		return
	if !WinExist("ahk_exe" processName)
		return
	WinActivate()
	if WinWaitActive(, , maxwaitTime)
	{
		setRandomKeyDelay()
		SendEvent "{Tab}"
		KeyWait("Tab", "L T" maxwaitTime)
		if !chatGui
			return
		;解决因模拟按下Tab键导致输入框文本被全选的问题
		chatGui[chatEditName].GetPos(, , &chatEditW)
		ControlClick(chatGui[chatEditName], chatGui, , , , "x" chatEditW)
		WinActivate(chatGui)
	}
}
;取消输入
escKeyCallback(hotkeyName)
{
	Critical
	if !chatGui
		return
	chatGuiActive := WinActive(chatGui)
	changeChatGui(0)
	if chatGuiActive && WinExist("ahk_exe" processName)
	{
		WinActivate()
		if WinWaitActive(, , maxwaitTime)
		{
			setRandomKeyDelay()
			SendEvent "{Esc}"
		}
	}
}
;读取并校验Main配置项数据
readCheckMainCfgData()
{
	if FileExist(profilesName)
	{
		gameArr := creatCfgGameArr(readCfg())
		if gameArr.Length
		{
			readGame := readCfg(mainConfigName, selectGameName)
			if !readGame
			{
				readGame := gameArr[1]
				IniWrite(readGame, profilesName, mainConfigName, selectGameName)
			}
		}else
		{
			;配置文件中没有游戏配置项时，删除无效配置文件并创建默认配置文件
			FileDelete(profilesName)
			gameArr := defaultGameCfg()
			readGame := gameArr[1]
		}
	}else
	{
		;文件不存在时创建默认配置文件
		gameArr := defaultGameCfg()
		readGame := gameArr[1]
	}
	global gameNameArr := gameArr, selectGame := readGame
	;隐性配置项
	;读取并校验配置文件的“最大等待响应时间”配置项
	maxWaitTimeName := "最大等待响应时间"
	readMaxWaitTime := readCfg(mainConfigName, maxWaitTimeName, "5")
	if !IsNumber(readMaxWaitTime)
		cfgErrMsgBox(profilesName "：`n[" mainConfigName "]`n" maxWaitTimeName "=" readMaxWaitTime "`n对应的值不是数字！")
	readMaxWaitTime := Round(readMaxWaitTime, 1)
	if readMaxWaitTime < 1
		readMaxWaitTime := 1
	else if readMaxWaitTime > 60
		readMaxWaitTime := 60
	global maxwaitTime := readMaxWaitTime
	;读取并校验配置文件的“输入框最大字符数”配置项
	chatMaxLengthName := "输入框最大字符数"
	readChatMaxLength := readCfg(mainConfigName, chatMaxLengthName, "88")
	if !IsInteger(readChatMaxLength)
		cfgErrMsgBox(profilesName "：`n[" mainConfigName "]`n" chatMaxLengthName "=" readChatMaxLength "`n对应的值不是整数！")
	readChatMaxLength := Integer(readChatMaxLength)
	if readChatMaxLength < 88
		readChatMaxLength := 88
	else if readChatMaxLength > 880
		readChatMaxLength := 880
	global chatMaxLength := readChatMaxLength
	;读取并校验配置文件的“延时最大值”配置项
	maxRandomTimeName := "延时最大值"
	readMaxRandomTime := readCfg(mainConfigName, maxRandomTimeName, "1000")
	if !IsInteger(readMaxRandomTime)
		cfgErrMsgBox(profilesName "：`n[" mainConfigName "]`n" maxRandomTimeName "=" readMaxRandomTime "`n对应的值不是整数!")
	readMaxRandomTime := Integer(readMaxRandomTime)
	if readMaxRandomTime < minRandomTime
		readMaxRandomTime := minRandomTime
	global maxRandomTime := readMaxRandomTime
	;输入框的最大字体尺寸
	readChatMaxFontSize := readCfg(mainConfigName, chatMaxFontSizeName, "60")
	if !IsInteger(readChatMaxFontSize)
		cfgErrMsgBox(profilesName "：`n[" mainConfigName "]`n" chatMaxFontSizeName "=" readChatMaxFontSize "`n对应的值不是整数!")
	readChatMaxFontSize := Integer(readChatMaxFontSize)
	if readChatMaxFontSize < chatMinFontSize
		readChatMaxFontSize := chatMinFontSize
	else if readChatMaxFontSize > 99
		readChatMaxFontSize := 99
	global chatMaxFontSize := readChatMaxFontSize
	;是否显示帮助提示
	readShowTip := readCfg(mainConfigName, isShowTipName, "1")
	if (readShowTip != "0") && (readShowTip != "1")
		cfgErrMsgBox(profilesName "：`n[" mainConfigName "]`n" isShowTipName "=" readShowTip "`n对应的值必须是0或1！")
	global isShowTip := Integer(readShowTip)
	;是否显示以管理员身份运行建议
	readShowAdminRun := readCfg(mainConfigName, isShowAdminRunName, "1")
	if (readShowAdminRun != "0") && (readShowAdminRun != "1")
		cfgErrMsgBox(profilesName "：`n[" mainConfigName "]`n" isShowAdminRunName "=" readShowAdminRun "`n对应的值必须是0或1！")
	global isShowAdminRun := Integer(readShowAdminRun)
}
;读取并校验游戏配置项数据
readCheckGameCfgData(readGame)
{
	gameExe := readCfg(readGame, gameExeName)
	if !gameExe
	{
		gameSectionData := IniRead(profilesName, readGame, , "")
		if !gameSectionData
			cfgErrMsgBox(profilesName "：`n[" mainConfigName "]`n" selectGameName "=" readGame "`n该游戏的配置数据不存在！")
		else
			cfgErrMsgBox(profilesName "：`n[" readGame "]`n" gameExeName "=`n值为空！")
	}
	global processName := gameExe
	;读取并校验当前选择游戏的“开始输入”配置项
	readKey := readCfg(readGame, inputKeyName, "t")
	gameKey := GetKeyName(readKey)
	if (!gameKey) or (gameKey = "CapsLock")
		cfgErrMsgBox(profilesName "：`n[" readGame "]`n" inputKeyName "=" readKey "`n对应的按键配置不支持！")
	global inputKey := gameKey
	;读取并校验当前选择游戏的“发送文本方式”配置项
	readMethod := readCfg(readGame, sendMethodName, "1")
	if !IsInteger(readMethod)
		cfgErrMsgBox(profilesName "：`n[" readGame "]`n" sendMethodName "=" readMethod "`n对应的值必须是 (1~5) 的整数！")
	readMethod := Integer(readMethod)
	if readMethod > 5
		readMethod := 1
	global sendMethod := readMethod
	;读取并校验当前选择游戏的“最小、最大操作延时”配置项
	readMinDelay := readCfg(readGame, minDelayName, "100")
	if !IsInteger(readMinDelay)
		cfgErrMsgBox(profilesName "：`n[" selectGame "]`n" minDelayName "=" readMinDelay "`n对应的值必须是正整数！")
	readMinDelay := Integer(readMinDelay)
	if readMinDelay < minRandomTime
		readMinDelay := minRandomTime
	else if readMinDelay > maxRandomTime
		readMinDelay := maxRandomTime
	global minDelayTime := readMinDelay
	readMaxDelay := readCfg(readGame, maxDelayName, "120")
	if !IsInteger(readMaxDelay)
		cfgErrMsgBox(profilesName "：`n[" selectGame "]`n" maxDelayName "=" readMaxDelay "`n对应的值必须是正整数！")
	readMaxDelay := Integer(readMaxDelay)
	if readMaxDelay < minRandomTime
		readMaxDelay := minRandomTime
	else if readMaxDelay > maxRandomTime
		readMaxDelay := maxRandomTime
	global maxDelayTime := readMaxDelay
	;读取并校验当前选择游戏的“最小、最大键击延时”配置项
	readMinPress := readCfg(readGame, minPressName, "10")
	if !IsInteger(readMinPress)
		cfgErrMsgBox(profilesName "：`n[" selectGame "]`n" minPressName "=" readMinPress "`n对应的值必须是正整数！")
	readMinPress := Integer(readMinPress)
	if readMinPress < minRandomTime
		readMinPress := minRandomTime
	else if readMinPress > maxRandomTime
		readMinPress := maxRandomTime
	global minPressTime := readMinPress
	readMaxPress := readCfg(readGame, maxPressName, "20")
	if !IsInteger(readMaxPress)
		cfgErrMsgBox(profilesName "：`n[" selectGame "]`n" maxPressName "=" readMaxPress "`n对应的值必须是正整数！")
	readMaxPress := Integer(readMaxPress)
	if readMaxPress < minRandomTime
		readMaxPress := minRandomTime
	else if readMaxPress > maxRandomTime
		readMaxPress := maxRandomTime
	global maxPressTime := readMaxPress
	;读取并校验当前选择游戏的“输入框X、Y、W、字体尺寸”配置项
	readPosX := readCfg(readGame, chatPosXName, String(A_ScreenWidth*0.8))
	if !IsNumber(readPosX)
		cfgErrMsgBox(profilesName "：`n[" selectGame "]`n" chatPosXName "=" readPosX "`n对应的值不是数字！")
	readPosX := Integer(readPosX)
	global chatPosX := readPosX
	readPosY := readCfg(readGame, chatPosYName, String(A_ScreenHeight*0.6))
	if !IsNumber(readPosY)
		cfgErrMsgBox(profilesName "：`n[" selectGame "]`n" chatPosYName "=" readPosY "`n对应的值不是数字！")
	readPosY := Integer(readPosY)
	global chatPosY := readPosY
	readPosW := readCfg(readGame, chatPosWName, String(A_ScreenWidth*0.18))
	if !IsNumber(readPosW)
		cfgErrMsgBox(profilesName "：`n[" selectGame "]`n" chatPosWName "=" readPosW "`n对应的值不是数字！")
	readPosW := Integer(readPosW)
	global chatPosW := readPosW
	readFontSize := readCfg(readGame, chatFontSizeName, "12")
	if !IsInteger(readFontSize)
		cfgErrMsgBox(profilesName "：`n[" selectGame "]`n" chatFontSizeName "=" readFontSize "`n对应的值不是整数！")
	readFontSize := Integer(readFontSize)
	if readFontSize < chatMinFontSize
		readFontSize := chatMinFontSize
	else if readFontSize > chatMaxFontSize
		readFontSize := chatMaxFontSize
	global chatFontSize := readFontSize
	readIsFixCNErr := readCfg(readGame, isFixCNErrName, "0")
	if (readIsFixCNErr != "0") && (readIsFixCNErr != "1")
		cfgErrMsgBox(profilesName "：`n[" selectGame "]`n" isFixCNErrName "=" readIsFixCNErr "`n对应的值必须是0或1！")
	global isFixCNErr := Integer(readIsFixCNErr)
}
;刷新选择游戏控件显示
refreshSelectGameCtrl()
{
	selectGameCtrl.Delete()
	selectGameCtrl.Add(gameNameArr)
	selectIndex := 1
	for index, value in gameNameArr
	{
		if value = selectGame
		{
			selectIndex := index
			break
		}
	}
	ControlChooseIndex(selectIndex, selectGameCtrl, myGui)
}
;刷新除选择游戏之外的控件显示
refreshOtherCtrl()
{
	exeNameCtrl.Text := processName
	ControlChooseIndex(sendMethod, sendMethodCtrl, myGui)
	delayTime_Change(minDelayTime, maxDelayTime)
	pressTime_Change(minPressTime, maxPressTime)
	if inputKey = enterKeyName
	{
		ControlSetChecked(true, isEnterKeyCtrl, myGui)
	}else
	{
		inputKeyCtrl.Value := inputKey
		ControlSetChecked(false, isEnterKeyCtrl, myGui)
	}
	ControlSetChecked(isFixCNErr, isFixCNErrCtrl, myGui)
}
;过滤生成游戏名字数组
creatCfgGameArr(sectionStr)
{
	sectionArr := Array()
	;过滤配置文件中所有的[main]配置段
	Loop Parse sectionStr, "`n"
	{
		if (A_LoopField != mainConfigName)
			sectionArr.Push(A_LoopField)
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
	isShow := readCfg(mainConfigName, declarationName)
	if !isShow
		return
	text := "游戏无缝输入中文" toolVersion "
	(

GameXueRen 制作

此工具不涉及游戏文件及内存数据篡改，
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
;取消其他按钮的输入焦点蓝边框的临时解决方案
setMyGuiFocus(isCancel?)
{
	static focusHiddenCtrl := myGui.AddButton("x0 y0 w1 h1 Hidden")
	if startCtrl.btnStatus
	{
		focusHiddenCtrl.Focus()
		return
	}
	if IsSet(isCancel)
	{
		if isCancel
			focusHiddenCtrl.Focus()
		else
		{
			focusHiddenCtrl.Focus()
			startCtrl.Focus()
		}
	}else
		startCtrl.Focus()
}
;设置send、win相关函数执行延时
setRandomKeyDelay()
{
	SetKeyDelay(getRandomPressTime(), getRandomPressTime())
	SetWinDelay getRandomDelayTime()
}
;获取随机的键击时间
getRandomPressTime()
{
	return Random(minPressTime, maxPressTime)
}
;获取随机的操作时间
getRandomDelayTime()
{
	return Random(minDelayTime, maxDelayTime)
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
;向GuiControl添加、更新、删除工具提示
;Tooltip文档：https://learn.microsoft.com/zh-cn/windows/win32/controls/tooltip-control-reference
ControlAddTip(GuiCtrlObj, TipText)
{
	if !(GuiCtrlObj is Gui.Control)
		return 0
	currGui := GuiCtrlObj.Gui
	guiHwnd := currGui.Hwnd
	ctrlHwnd := GuiCtrlObj.Hwnd
	if currGui.HasProp("gmxrTipHwnd")
		tipHwnd := currGui.gmxrTipHwnd
	else
		tipHwnd := 0
	if !tipHwnd
	{
		;初始化创建工具提示，并返回窗口句柄
		CW_USEDEFAULT := 0x80000000
		tipHwnd := DllCall("CreateWindowEx"
			, "UInt", 0                      			  ;-- dwExStyle WS_EX_TOPMOST := 0x8
			, "Str", "TOOLTIPS_CLASS32"                   ;-- lpClassName
			, "Ptr", 0                                    ;-- lpWindowName
			, "UInt", 0x1 | 0x2        					  ;-- dwStyle TTS_ALWAYSTIP | TTS_NOPREFIX
			, "UInt", CW_USEDEFAULT                       ;-- x
			, "UInt", CW_USEDEFAULT                       ;-- y
			, "UInt", CW_USEDEFAULT                       ;-- nWidth
			, "UInt", CW_USEDEFAULT                       ;-- nHeight
			, "Ptr", guiHwnd                              ;-- hWndParent
			, "Ptr", 0                                    ;-- hMenu
			, "Ptr", 0                                    ;-- hInstance
			, "Ptr", 0                                    ;-- lpParam
			, "Ptr")                                      ;-- Return type
		currGui.gmxrTipHwnd := tipHwnd
		;设置工具提示支持多行显示，且最大宽度为屏幕宽度
		SendMessage 0x0418, 0, A_ScreenWidth*96//A_ScreenDPI, tipHwnd ;TTM_SETMAXTIPWIDTH
	}
	cbSize := 24 + (A_PtrSize * 6)
	TOOLINFO := Buffer(cbSize, 0)
	; cbSize
	; uFlags：TTF_SUBCLASS | TTF_IDISHWND (0x10 | 0x1).将鼠标信息转发给控制器、uId参数为Hwnd
	; hwnd, uID
	NumPut("UInt", cbSize, "UInt", 0x11, "Ptr", guiHwnd, "Ptr", ctrlHwnd, TOOLINFO)
	;查询工具提示中是否已注册该控件
	try
		isRegister := SendMessage(0x435, 0, TOOLINFO, tipHwnd) ;TTM_GETTOOLINFOW
	catch Error
		isRegister := false
	;向控件添加、更新或删除工具提示
	if TipText
	{
		;填充工具提示文本到 TOOLINFO
		NumPut("Ptr", StrPtr(TipText), TOOLINFO, 24 + (A_PtrSize * 3))
		;文本不为空，如果控件已注册则更新提示，否则添加注册
		if isRegister
			SendMessage(0x0439, 0, TOOLINFO, tipHwnd) ;TTM_UPDATETIPTEXTW
		else
			SendMessage(0x0432, 0, TOOLINFO, tipHwnd) ;TTM_ADDTOOLW
	} else
	{
		;文本为空且已注册则删除提示
		if isRegister
			SendMessage(0x0433, 0, TOOLINFO, tipHwnd) ;TTM_DELTOOLW
	}
	Return tipHwnd
}
;主动启用或停用工具提示(默认启用)
GuiSetTipEnabled(GuiObj, isEnable)
{
	if !(GuiObj is Gui)
		return
	if !GuiObj.HasProp("gmxrTipHwnd")
		return
	tipHwnd := GuiObj.gmxrTipHwnd
	if !tipHwnd
		return
	if isEnable
		SendMessage 0x401, True, 0, tipHwnd ;TTM_ACTIVATE 启用
	else
		SendMessage 0x401, False, 0, tipHwnd ;停用
}
;设置工具提示的延迟时间
GuiSetTipDelayTime(GuiObj, Automatic?, Initial?, AutoPop?, Reshow?)
{
	if !(GuiObj is Gui)
		return
	if !GuiObj.HasProp("gmxrTipHwnd")
		return
	tipHwnd := GuiObj.gmxrTipHwnd
	if !tipHwnd
		return
	;自动档，依据初始显示延迟时间，自动弹出和重新显示延迟时间分别为其10倍、1/5
	if IsSet(Automatic)
	{
		if !IsInteger(Automatic) or (Automatic < 0)
			Automatic := -1 ;默认值
		else if Automatic > 3200
			Automatic := 3200
		SendMessage 0x403, 0, Automatic, tipHwnd ;TTM_SETDELAYTIME TTDT_AUTOMATIC		
		return
	}
	;设置初始显示延迟时间
	if IsSet(Initial)
	{
		if !IsInteger(Initial) or (Initial < 0)
			Initial := -1 ;默认值为500毫秒
		else if Initial > 32000
			Initial := 32000
		SendMessage 0x403, 3, Initial, tipHwnd ;TTM_SETDELAYTIME TTDT_INITIAL
	}
	;设置自动弹出延迟时间
	if IsSet(AutoPop)
	{
		if !IsInteger(AutoPop) or (AutoPop < 0)
			AutoPop := -1 ;默认值为5000毫秒
		else if AutoPop > 32000
			AutoPop := 32000 ;允许的最大值为32000毫秒
		SendMessage 0x403, 2, AutoPop, tipHwnd ;TTM_SETDELAYTIME TTDT_AUTOPOP
	}
	;设置从一个控件移动到另一个控件，重新显示延迟时间
	if IsSet(Reshow)
	{
		if !IsInteger(Reshow) or (Reshow < 0)
			Reshow := -1 ;默认值为100毫秒
		else if Reshow > 32000
			Reshow := 32000
		SendMessage 0x403, 1, Reshow, tipHwnd ;TTM_SETDELAYTIME TTDT_RESHOW
	}
}
;检查是否为管理身份运行并提示
checkIsAdminRun()
{
	if A_IsAdmin
		return
	if !isShowAdminRun
		return
	static adminRunWarning := false
	if adminRunWarning
		return
	myGui.Opt("+OwnDialogs")
	result := warningMsgBox("
	(
		建议“以管理员身份运行”此工具。
		可确保无缝输入中文功能生效！

		点击“确定”即以管理员身份重启。
		点击“取消”则跳过提示继续运行。

		如何设置始终“以管理员身份运行”?
		选取工具运行文件->鼠标右键
		->属性->兼容性
		->勾选“以管理员身份运行此程序”
		->应用。
	)", "重要提示！", "OKCancel Icon! Default1")
	if result = "OK"
	{
		try
		{
			if A_IsCompiled
				Run '*RunAs "' A_ScriptFullPath '" /restart'
			else
				Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
		} catch Error as err
		{
			extraInfo := err.Extra
			if (extraInfo != "操作已被用户取消。`r`n") && (extraInfo != "操作已被用户取消。")
			{
				warningMsgBox("无法以管理员身份运行！`n将尝试以普通用户身份运行。", "运行错误！", "OK Icon!")
				if A_IsCompiled
					Run '"' A_ScriptFullPath '" /restart'
				else
					Run '"' A_AhkPath '" /restart "' A_ScriptFullPath '"'
				ExitApp
			}
		}else
		{
			ExitApp
		}
	}
	;仅提示一次
	adminRunWarning := true
}
;重新加载
clickReload(*)
{
	changeChatGui(-1)
	Reload()
}
;退出
clickExit(*)
{
	;退出之前保存输入框位置
	changeChatGui(-1)
	ExitApp
}
;创建默认配置文件及内置游戏配置项
defaultGameCfg()
{
	FileAppend "
	(
[main]
选择游戏=幽灵行动：荒野
最大等待响应时间=5
输入框最大字符数=88
延时最大值=1000
启动声明=1
显示提示=1
[幽灵行动：荒野]
运行程序=GRW.exe
开始输入=t
发送文本方式=1
修复中文乱码=1
最小操作延时=100
最大操作延时=120
最小键击延时=10
最大键击延时=20
输入框X=1552
输入框Y=674
输入框W=344
输入框字体尺寸=12
[幽灵行动：断点]
运行程序=GRB.exe
开始输入=Enter
发送文本方式=5
最小操作延时=100
最大操作延时=120
最小键击延时=10
最大键击延时=20
输入框X=1420
输入框Y=696
输入框W=384
输入框字体尺寸=12
[幽灵行动：断点-vulkan]
运行程序=GRB_vulkan.exe
开始输入=Enter
发送文本方式=5
最小操作延时=100
最大操作延时=120
最小键击延时=10
最大键击延时=20
输入框X=1420
输入框Y=696
输入框W=384
输入框字体尺寸=12
[彩虹六号：围攻]
运行程序=RainbowSix.exe
开始输入=y
发送文本方式=2
最小操作延时=100
最大操作延时=120
最小键击延时=10
最大键击延时=20
输入框X=1382	
输入框Y=778
输入框W=288
输入框字体尺寸=12
[彩虹六号：围攻-vulkan]
运行程序=RainbowSix_Vulkan.exe
开始输入=y
发送文本方式=2
最小操作延时=100
最大操作延时=120
最小键击延时=10
最大键击延时=20
输入框X=1382
输入框Y=778
输入框W=288
输入框字体尺寸=12
[无人深空]
运行程序=NMS.exe
开始输入=Enter
发送文本方式=1
最小操作延时=100
最大操作延时=120
最小键击延时=10
最大键击延时=20
输入框X=98
输入框Y=948
输入框W=600
输入框字体尺寸=12
)", profilesName, "CP0"
	return ["幽灵行动：荒野", "幽灵行动：断点", "幽灵行动：断点-vulkan", "彩虹六号：围攻", "彩虹六号：围攻-vulkan", "无人深空"]
}
;关于
clickAbout(*)
{
	setMyGuiFocus()
	MsgBox "游戏无缝输入中文" toolVersion "
	(

GameXueRen 制作
此工具开源且永久免费！禁止贩卖出售！
https://github.com/GameXueRen/GRW-CNChat
游戏交流群：299177445 (游击战王牌大队)

常见问题1：发送中文后，游戏内显示为 ??? 类似乱码。
解决办法：勾选工具界面的“修复中文???乱码”选项解决。
->或者在启动游戏前，先切换到中文输入法，再启动游戏。
->或者进入win系统设置->时间和语言->语言->首选语言，
在“中文(简体，中国)”或“英语(美国)”语言选项下删除“美式键盘”。
->或者更换其他中文输入法尝试解决。

常见问题2：启动后，游戏内无法正常调用输入框或发送中文。
解决办法：选取工具运行文件->鼠标右键->属性->兼容性
->勾选“以管理员身份运行此程序”->应用，接着重新运行工具尝试解决。

更新记录：
公测版v1~v2.2（2024/03/05-2024/03/23）：
初步支持《幽灵行动荒野》无缝中文输入，支持同步打开游戏内聊天框。
兼容中文输入法下按Enter键导入英文，而不是直接发送。
v2版提供自定义按键、参数微调功能，来适用更多游戏。
支持“开始输入”按键设置为Enter。
正式版v2.3（2024/03/25）：修复已知BUG，正式发布！
正式版v2.4（2024/04/11）：
优化热键逻辑，支持调整输入框高度。添加“手动发送”，来适用非聊天场景。
添加界面提示，内置“无人深空”游戏支持。
正式版v2.4.1（2024/04/13）：修复已知BUG。
正式版v2.4.3（2024/05/25）：
优化发送非中文字符的速度，优化输入框显示与消失的响应性。
启动时支持实时调整参数及输入框。
正式版v2.4.4（2024/06/13）:
增加“修复发送中文后显示为???乱码”的功能。
增加“以管理员身份运行”提示，提高兼容性。
增加更多自定义配置选项，见工具设置。
)", "关于"
}
;使用说明
clickReadme(*)
{
	setMyGuiFocus()
	MsgBox "
	(
1、进入游戏画面，并确保为“无边框模式”或“窗口化”。
此工具暂时不兼容游戏“全屏模式”下的中文输入。

2、工具界面选项介绍。
选择游戏：可选择已存储在配置文件中及工具内置的游戏配置项。
添加：可添加游戏配置项，依次输入“游戏名称”及“游戏窗口对应的程序完整名称”。

发送文本方式：不同游戏，可调试不同的“发送文本方式”来兼容。

键击延时：此为工具模拟按键按下的保持时间，默认为10~20毫秒之间随机。
对于一些游戏，太低的键击延时将导致模拟按键不生效。
如果出现概率性无法联动打开游戏内输入框，或者发送漏字的情况，
可适当调高此参数来调试。

操作延时：此为工具模拟窗口操作的延时，默认为100~120毫秒之间随机。
对于一些游戏，太低的操作延时将导致多个连续的模拟窗口动作不生效。
教高的操作延时会让工具的开启输入、发送文本、取消输入动作较为迟滞。

调整输入框：勾选后，在游戏内可随意拖动输入框位置及调整宽度，
工具同时会记住位置。

手动发送：手动输入文字并发送到对应窗口内的“输入光标处，适用一些非聊天场景。

开始输入：配置开始聊天的按键，且须与游戏内的开始聊天按键配置一致。
额外Enter勾选框：勾选后，即配置开始输入按键为“Enter”。

3、在游戏内，正常按“开始输入”按键聊天，按“回车”发送，按“Esc”取消聊天。
无缝中文输入。请确保游戏内“文本聊天”按键设置与工具的一致。

常见问题1：发送中文后，游戏内显示乱码问号。
解决办法：进入win系统设置->时间和语言->语言->首选语言->中文(简体，中国)，
在该语言选项下删除“美式键盘”即可解决。
(如需额外配置“美式键盘”，请在首选语言->添加语言->“英语(美国)”语言选项下添加)
或者在启动游戏前，先切换到中文输入法，再启动游戏。
或者更好其他中文输入法尝试解决。

常见问题2：启动后，游戏内无法正常调用输入框或发送中文。
解决办法：工具鼠标右键->属性->兼容性->勾选“以管理员身份运行此程序”->应用。
接着重新运行工具即可解决。
	)", "使用说明"
}