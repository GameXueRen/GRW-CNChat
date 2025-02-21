#Requires AutoHotkey v2.0
;编译后的程序属性
;@Ahk2Exe-SetCompanyName GameXueRen
;@Ahk2Exe-SetCopyright Copyright © 2024-2025 GameXueRen
;@Ahk2Exe-SetDescription 游戏无缝输入中文
;@Ahk2Exe-SetLanguage 0x0804
;@Ahk2Exe-SetName 游戏无缝输入中文
;@Ahk2Exe-SetOrigFilename GRW-CNChat
;@Ahk2Exe-SetProductVersion 3.0
;@Ahk2Exe-SetVersion 3.0
;@Ahk2Exe-SetMainIcon images\logo_256x256.ico
;@Ahk2Exe-ExeName 游戏无缝输入中文v3.exe
;单例运行
#SingleInstance Force
;版本号
toolVersion := "v3"

;设置速度最快的WinTitle匹配模式
SetTitleMatchMode 3
SetTitleMatchMode "Fast"

;配置文件名
profileName := "游戏无缝输入中文v3配置.ini"
;配置文件[main]段各项名称
mainSection := "main"					;全局配置
selectGameKey := "selectGame"			;当前选择游戏
maxWaitTimeKey := "maxWaitTime" 		;等待窗口响应最长时间
chatMaxLengthKey := "chatMaxLength"		;输入框最大字符数
chatMaxFontSizeKey := "chatMaxFontSize"	;输入框最大字体尺寸
isShowTipKey := "isShowTip"				;是否显示帮助
isShowAdminRunKey := "isShowAdminRun"	;是否显示以管理员运行建议
maxRandomTimeKey := "maxRandomTime"		;允许设置的最大延时
showStartTipKey := "showStartTip"		;是否显示启动声明
autoCloseChatKey := "autoCloseChat"		;是否自动关闭未激活的输入框
saveChatTextKey := "saveChatText"		;是否在自动关闭时保留输入文本
isRelativePosKey := "isRelativePos"		;是否使用相对坐标调整输入框
;游戏配置段各项名称
gameExeKey := "exe"						;窗口进程文件名
gameTitleKey := "title"					;窗口标题
inputKeyKey := "inputKey"				;开始输入按键
sendMethodKey := "sendMethod"			;发送文本方式
isFixCNErrKey := "isFixCNErr"			;是否启用修复中文乱码
pressTimeKey := "pressTime"				;键击延时
delayTimeKey := "delayTime"				;窗口延时
autoLockCapsKey := "autoLockCaps"		;是否启用自动锁定大写
notChatModeKey := "notChatMode"			;是否启用非聊天模式
; 示例：此为根据游戏分辨率分别保存的输入框x,y,W,字体尺寸
; 相对坐标为相对于游戏窗口左上角，绝对坐标为相对于屏幕左上角
;1920x1080=1552,674,344,12
;2560x1440=2200,980,344,14

;游戏窗口激活状态：-1为停止监测，0为未激活，1为已激活
gameActive := -1
;扩展功能启用状态
isAutoLockCaps := false
isNotChatMode := false
;聊天框
chatGui := 0
;是否允许调整输入框”
isMoveEdit := 0

;全局常量
;Enter、Esc、Tab热键标准名称
enterKeyName := "Enter"
escKeyName := "Esc"
tabKeyName := "Tab"
;自定义不会匹配到任何窗口的WinTitle
notExistTitle := "gmxr-WinNotExist"

; 调试
; ListLines()
; ListHotkeys()
; CoordMode "ToolTip", "Screen"

;读取并校验配置文件对应的内容
readCheckMainCfg()
;创建主界面
myGui := Gui("-Resize -MaximizeBox", "游戏无缝输入中文" toolVersion)
;创建控件及关联事件
creatMyGuiCtrl()
;刷新当前选择游戏
refreshSelectGame()
;启动声明
declarationMsgBox()
;设置主界面输入焦点
setMyGuiFocus()

;读取并校验Main配置项中，需要全局实时生效的数据
readCheckMainCfg()
{
	if !FileExist(profileName)
		defaultGameCfg()
	;读取并校验“最大等待响应时间”配置值
	readMaxWaitTime := readMainCfg(maxWaitTimeKey, "5")
	isReWriteCfg := true
	if IsNumber(readMaxWaitTime) {
		readMaxWaitTime := Round(readMaxWaitTime, 1)
		if readMaxWaitTime < 1 
			readMaxWaitTime := 1
		else if readMaxWaitTime > 60
			readMaxWaitTime := 60
		else
			isReWriteCfg := false
	} else {
		readMaxWaitTime := 5
	}
	;自动修正配置文件中错误的配置值
	if isReWriteCfg
		writeMainCfg(readMaxWaitTime, maxWaitTimeKey)
	global maxwaitTime := readMaxWaitTime
	;读取并校验“输入框最大字符数”配置值
	readChatMaxLength := readMainCfg(chatMaxLengthKey, "88")
	isReWriteCfg := true
	if IsInteger(readChatMaxLength) {
		readChatMaxLength := Integer(readChatMaxLength)
		if readChatMaxLength < 88
			readChatMaxLength := 88
		else if readChatMaxLength > 880
			readChatMaxLength := 880
		else
			isReWriteCfg := false
	} else {
		readChatMaxLength := 88
	}
	if isReWriteCfg
		writeMainCfg(readChatMaxLength, chatMaxLengthKey)
	global chatMaxLength := readChatMaxLength
	;读取并校验“延时最大值”配置值(隐性配置)
	readMaxRandomTime := readMainCfg(maxRandomTimeKey, "1000")
	isReWriteCfg := true
	if IsInteger(readMaxRandomTime) {
		readMaxRandomTime := Integer(readMaxRandomTime)
		if readMaxRandomTime < 10
			readMaxRandomTime := 10
		else if readMaxRandomTime > 60000
			readMaxRandomTime := 60000
		else
			isReWriteCfg := false
	} else {
		readMaxRandomTime := 1000
	}
	if isReWriteCfg
		writeMainCfg(readMaxRandomTime, maxRandomTimeKey)
	global maxRandomTime := readMaxRandomTime
	global chatMinFontSize := 10
	;输入框的最大字体尺寸
	readChatMaxFontSize := readMainCfg(chatMaxFontSizeKey, "60")
	isReWriteCfg := true
	if IsInteger(readChatMaxFontSize) {
		readChatMaxFontSize := Integer(readChatMaxFontSize)
		if readChatMaxFontSize < chatMinFontSize
			readChatMaxFontSize := chatMinFontSize
		else if readChatMaxFontSize > 72
			readChatMaxFontSize := 72
		else
			isReWriteCfg := false
	} else {
		readChatMaxFontSize := 60
	}
	if isReWriteCfg
		writeMainCfg(readChatMaxFontSize, chatMaxFontSizeKey)
	global chatMaxFontSize := readChatMaxFontSize
	;是否显示帮助提示
	readShowTip := readMainCfg(isShowTipKey, "1")
	if (readShowTip != "0") && (readShowTip != "1") {
		readShowTip := "1"
		writeMainCfg(readShowTip, isShowTipKey)
	}
	global isShowTip := Integer(readShowTip)
	;是否显示以管理员身份运行建议
	readShowAdminRun := readMainCfg(isShowAdminRunKey, "1")
	if (readShowAdminRun != "0") && (readShowAdminRun != "1") {
		readShowAdminRun := "1"
		writeMainCfg(readShowAdminRun, isShowAdminRunKey)
	}
	global isShowAdminRun := Integer(readShowAdminRun)
	;是否自动关闭未激活的输入框及保留文本
	readAutoCloseChat := readMainCfg(autoCloseChatKey, "1")
	if (readAutoCloseChat != "0") && (readAutoCloseChat != "1") {
		readAutoCloseChat := "1"
		writeMainCfg(readAutoCloseChat, autoCloseChatKey)
	}
	global autoCloseChat := Integer(readAutoCloseChat)
	readSaveChatText := readMainCfg(saveChatTextKey, "1")
	if (readSaveChatText != "0") && (readSaveChatText != "1") {
		readSaveChatText := "1"
		writeMainCfg(readSaveChatText, saveChatTextKey)
	}
	global saveChatText := Integer(readSaveChatText)
	;是否使用相对坐标调整输入框
	readIsRelativePos := readMainCfg(isRelativePosKey, "1")
	if (readIsRelativePos != "0") && (readIsRelativePos != "1") {
		readIsRelativePos := "1"
		writeMainCfg(readIsRelativePos, isRelativePosKey)
	}
	global isRelativePos := Integer(readIsRelativePos)
}
;创建主界面上的控件
creatMyGuiCtrl()
{
	myGuiW := 338	;主界面宽
	marginX := 8	;水平边距
	marginY := 6	;垂直边距
	myGui.MarginX := marginX
	myGui.MarginY := marginY
	mainCtrlW := myGuiW - marginX * 2	;主控件宽

	;选择游戏
	selectBoxH := 60		;选择游戏组高
	selectMarginTop := 16	;选择游戏组顶部间距
	addBtnW := 40			;添加按钮宽
	selectDDLW := mainCtrlW - marginX * 4 - addBtnW * 2	;选择游戏列表宽
	myGui.AddGroupBox("Section xm ym w" mainCtrlW " h" selectBoxH, "选择游戏")
	global selectGameCtrl := myGui.AddDropDownList("v" selectGameKey " xs+" marginX " ys+" selectMarginTop " w" selectDDLW)
	;自定义属性，便于取用
	selectGameCtrl.gameExe := ""
	selectGameCtrl.gameTitle := ""
	global exeNameCtrl := myGui.AddText("+0x200 xp cRed wp y+2")
	global addGameCtrl := myGui.AddButton("x+" marginX " ys+" selectMarginTop " w" addBtnW " h" selectBoxH-selectMarginTop-marginY, "添加`n游戏")
	global deleteGameCtrl := myGui.AddButton("yp wp hp", "删除`n游戏")

	;发送文本方式
	sendBoxH := selectBoxH				;发送组高
	sendMarginTop := selectMarginTop	;发送组顶部间距
	timeBtnW := 60						;延时按钮宽
	sendDDLW := mainCtrlW - marginX * 4 - timeBtnW * 2	;发送方式列表宽
	myGui.AddGroupBox("Section xs ys+" selectBoxH+marginY " w" mainCtrlW " h" sendBoxH, "发送文本方式")
	global sendMethodCtrl := myGui.AddDropDownList("v" sendMethodKey " Choose1 xs+" marginX " ys+" sendMarginTop " w" sendDDLW, ["ControlSendText", "Send{ASC nnnnn}", "Send{U+nnnn}", "SendText", "PostMessage", "CopyPaste"])
	global sendMethodNameCtrl := myGui.AddText("+0x200 xp cRed wp y+2", "发送到指定的窗口")
	global pressTimeCtrl := myGui.AddButton("v" pressTimeKey " x+" marginX " ys+" sendMarginTop " w" timeBtnW " h" sendBoxH-sendMarginTop-marginY, "键击延时`n10-20")
	global delayTimeCtrl := myGui.AddButton("v" delayTimeKey " yp wp hp", "窗口延时`n100-120")
	;自定义属性，便于取用
	pressTimeCtrl.minTime := 10
	pressTimeCtrl.maxTime := 20
	delayTimeCtrl.minTime := 100
	delayTimeCtrl.maxTime := 120

	;扩展功能
	extBoxH := 50		;扩展组高
	extMarginTop := 12	;扩展组顶部间距
	myGui.AddGroupBox("Section xs ys+" sendBoxH+marginY " w" mainCtrlW " h" extBoxH, "扩展功能")
	global autoLockCapsCtrl := myGui.AddCheckbox("v" autoLockCapsKey " Checked0 xs+" marginX " ys+" extMarginTop " h" extBoxH-extMarginTop-marginY, "游玩时禁用中文输入法`n(自动锁定大写)")
	global notChatModeCtrl := myGui.AddCheckbox("v" notChatModeKey " Checked0 yp hp xs+" marginX*2+sendDDLW, "启用非聊天模式`n(仅发送文本)")

	;启动
	startBoxH := 140				;扩展组高
	startMarginTop := 20			;扩展组顶部间距
	startBoxW := sendDDLW+marginX	;扩展组宽
	aboutBtnW := 26					;关于按钮宽
	aboutBtnH := 50					;关于按钮高
	startBtnW := startBoxW-marginX*3-aboutBtnW		;启动按钮宽
	startBtnH := startBoxH-startMarginTop-marginY	;启动按钮高
	myGui.AddGroupBox("Section xs ys+" extBoxH+marginY " w" startBoxW " h" startBoxH)
	global startCtrl := myGui.AddButton("xs+" marginX " ys+" startMarginTop " w" startBtnW " h" startBtnH, "启动")
	startCtrl.SetFont("bold s24")
	;自定义属性，存储启动按钮的启停状态
	startCtrl.btnStatus := false
	global settingsCtrl := myGui.AddButton("yp w" aboutBtnW " h" aboutBtnH, "设`n`n置")
	global aboutCtrl := myGui.AddButton("xp wp hp y+" startBtnH-aboutBtnH*2, "关`n`n于")
	manualSendBtnW := 62	;手动发送按钮宽
	global manualSendCtrl := myGui.AddButton("ys-4 h22 x+-" manualSendBtnW " w" manualSendBtnW, "手动发送")
	global isMoveEditCtrl := myGui.AddCheckbox("yp w80 h20 Checked0 xs+" marginX, "调整输入框")
	
	
	;开始输入
	inputBoxH := startBoxH							;开始输入组高
	inputMarginTop := startMarginTop				;开始输入组顶部间距
	inputBoxW := mainCtrlW - startBoxW - marginY	;开始输入组宽
	inputKeyW := 50		;热键控件宽
	inputKeyH := 20		;热键控件高
	textMarginY := 4	;文本间垂直间距
	textW := 60			;文本控件宽
	textH := Abs(Round((inputBoxH - startMarginTop - inputKeyH * 2 - textMarginY * 5) / 3.0))	;文本控件高
	keyTextW := inputBoxW - marginY * 3 - textW		;热键名称宽
	myGui.AddGroupBox("Section ys xs+" startBoxW+marginY " w" inputBoxW " h" inputBoxH, "开始输入")
	global inputKeyCtrl := myGui.AddHotkey("v" inputKeyKey " Limit254 xs+" marginX " ys+" inputMarginTop " w" inputKeyW " h" inputKeyH, "T")
	;自定义属性，便于取用
	inputKeyCtrl.inputKey := "T"
	global isEnterKeyCtrl := myGui.AddCheckbox("visEnter Checked0 hp yp", enterKeyName)
	global isFixCNErrCtrl := myGui.AddCheckbox("v" isFixCNErrKey " Section Checked0 hp xs+" marginX " y+" textMarginY, "修复中文???乱码")
	myGui.AddText("+0x200 xs y+" textMarginY " w" textW " h" textH, "发送文本：")
	myGui.AddText("+0x200 yp hp w" keyTextW, enterKeyName)
	myGui.AddText("+0x200 xs hp y+" textMarginY " w" textW, "取消输入：")
	myGui.AddText("+0x200 yp hp w" keyTextW, escKeyName)
	myGui.AddText("+0x200 xs hp y+" textMarginY " w" textW, "切换频道：")
	myGui.AddText("+0x200 yp hp w" keyTextW, tabKeyName)
	toolLinkW := 94		;开源链接宽
	toolLinkCtrl := myGui.AddLink("right ym x" myGuiW-marginX-toolLinkW " w" toolLinkW, '开源:<a href="https://github.com/GameXueRen/GRW-CNChat">GRW-CNChat</a>')
	declLinkW := 64		;声明链接宽
	declarationCtrl := myGui.AddLink("right ym w64 x" myGuiW-marginX-toolLinkW-declLinkW " w" declLinkW, '<a>作者声明</a> |')

	;显示主界面
	myGui.Show("AutoSize Center")

	;添加控件事件
	declarationCtrl.OnEvent("Click", (*) => declarationMsgBox(true))

	selectGameCtrl.OnEvent("Change", selectGame_Change)
	addGameCtrl.OnEvent("Click", addGame_Click)
	deleteGameCtrl.OnEvent("Click", deleteGame_Click)

	sendMethodCtrl.OnEvent("Change", sendMethod_Change)
	delayTimeCtrl.OnEvent("Click", delayTime_Click)
	pressTimeCtrl.OnEvent("Click", pressTime_Click)

	autoLockCapsCtrl.OnEvent("Click", autoLockCaps_Click)
	notChatModeCtrl.OnEvent("Click", notChatMode_Click)

	isMoveEditCtrl.OnEvent("Click", isMoveEdit_Click)
	manualSendCtrl.OnEvent("Click", manualSend_Click)
	startCtrl.OnEvent("Click", start_Click)
	aboutCtrl.OnEvent("Click", clickAbout)
	settingsCtrl.OnEvent("Click", openSettingsGui)

	inputKeyCtrl.OnEvent("Change", inputKey_Change)
	isEnterKeyCtrl.OnEvent("Click", isEnterKey_Click)
	isFixCNErrCtrl.OnEvent("Click", isFixCNErr_Click)

	;主界面关闭事件
	myGui.OnEvent("Close", myGui_Close)

	;添加控件提示
	ControlAddTip(toolLinkCtrl, "https://github.com/GameXueRen/GRW-CNChat")

	ControlAddTip(addGameCtrl, "添加新的游戏支持")
	ControlAddTip(deleteGameCtrl, "删除当前游戏支持")

	ControlAddTip(sendMethodCtrl, "不同游戏适用的发送方式不一样`n可选择不同方式进行调试")
	ControlAddTip(pressTimeCtrl, "设置工具模拟按键操作的延时：`n不同游戏适用的延时不一样`n可设置适当延时进行调试`n延时设置范围：10~" maxRandomTime)
	ControlAddTip(delayTimeCtrl, "设置工具模拟窗口操作的延时：`n不同游戏适用的延时不一样`n可设置适当延时进行调试`n延时设置范围：10~" maxRandomTime)

	ControlAddTip(autoLockCapsCtrl, "勾选后,当该游戏窗口激活时,`n自动锁定大写来禁用中文输入法`n游戏窗口未激活时,自动解锁大写")
	ControlAddTip(notChatModeCtrl, "勾选后即启用非聊天模式`n仅发送文本,不模拟其余按键操作")

	ControlAddTip(isMoveEditCtrl, "勾选后支持调整输入框位置及宽高`n并保存到下次显示")
	ControlAddTip(manualSendCtrl, "手动输入文字并发送到：`n对应窗口内的“输入光标处”`n适用一些非聊天场景")
	ControlAddTip(startCtrl, "确保游戏为“无边框”或“窗口化”模式`n启动之后才可正常使用")
	ControlAddTip(settingsCtrl, "打开更多设置")
	ControlAddTip(aboutCtrl, "常见问题`n更新记录")

	ControlAddTip(inputKeyCtrl, "配置开始输入的按键：`n需与游戏内的按键配置一致`n才可同步打开游戏内聊天框")
	ControlAddTip(isEnterKeyCtrl, "勾选后即配置：`n“开始输入”按键为“Enter”键")
	ControlAddTip(isFixCNErrCtrl, "勾选后即尝试修复发送中文时`n显示为 ??? 类似乱码的问题")
	
	; GuiSetTipDelayTime(myGui, 500)
	GuiSetTipEnabled(myGui, isShowTip)

	;托盘右键菜单定制
	trayMenu := A_TrayMenu
	trayMenu.Delete()
	trayMenu.Add("打开", (*) => myGui.Show())
	trayMenu.Add("重新加载", clickReload)
	trayMenu.Add("退出", clickExit)
	trayMenu.ClickCount := 1
	trayMenu.Default := "打开"
	A_IconTip := "游戏无缝输入中文" toolVersion
}
;刷新选择游戏控件显示
refreshSelectGame()
{
	selectGameCtrl.Delete()
	gameNameArr := getAllGameName()
	selectGameCtrl.Add(gameNameArr)
	selectIndex := 0
	selectGame := readMainCfg(selectGameKey)
	for index, value in gameNameArr
	{
		if value = selectGame{
			selectIndex := index
			break
		}
	}
	ControlChooseIndex(selectIndex, selectGameCtrl, myGui)
}
;选择游戏改变
selectGame_Change(GuiCtrlObj, Info)
{
	;当前选择游戏
	selectGame := GuiCtrlObj.Text
	;将选择的游戏写入配置文件
	writeMainCfg(selectGame, selectGameKey)
	;读取并校验当前选择游戏的配置文件关键数据
	isVaildData := false
	gameExe := ""
	gameTitle := ""
	warningMsg := ""
	if selectGame {
		gameExe := readCfg(selectGame, gameExeKey)
		gameTitle := readCfg(selectGame, gameTitleKey)
		if gameExe {
			if (SubStr(gameExe, -4, 4) != ".exe")
				warningMsg := profileName "：`n[" selectGame "]`n" gameExeKey "=" gameExe "`n“" gameExeKey "”(游戏窗口进程文件名)`n此项配置值后缀不是“.exe”！"
			else
				isVaildData := true
		} else {
			if gameTitle {
				if StrLen(gameTitle) > 255
					warningMsg := profileName "：`n[" selectGame "]`n" gameTitleKey "=`n“" gameTitleKey "”(游戏窗口标题)`n此项配置值不能超过255个字符！"
				else
					isVaildData := true
			} else {
				warningMsg := profileName "：`n[" selectGame "]`n" gameExeKey "=`n" gameTitleKey "=`n这两项配置不能同时为空！"
			}	
		}
		deleteGameCtrl.Enabled := true
	} else {
		deleteGameCtrl.Enabled := false
	}
	;控件启用禁用
	sendMethodCtrl.Enabled := isVaildData
	pressTimeCtrl.Enabled := isVaildData
	delayTimeCtrl.Enabled := isVaildData
	autoLockCapsCtrl.Enabled := isVaildData
	notChatModeCtrl.Enabled := isVaildData
	manualSendCtrl.Enabled := isVaildData
	startCtrl.Enabled := isVaildData
	inputKeyCtrl.Enabled := isVaildData
	isEnterKeyCtrl.Enabled := isVaildData
	isFixCNErrCtrl.Enabled := isVaildData
	;记录，方便直接读取
	selectGameCtrl.gameExe := gameExe
	selectGameCtrl.gameTitle := gameTitle
	;刷新关联显示控件数据
	ctrlTip := "游戏窗口匹配信息："
	if gameExe {
		ctrlTip .= "`n" gameExe
		if gameTitle {
			ctrlTip .= "`n" gameTitle
			exeNameCtrl.Text := gameExe " + " gameTitle
		} else {
			exeNameCtrl.Text := gameExe
		}
	} else {
		ctrlTip .= "`n" gameTitle
		exeNameCtrl.Text := gameTitle
	}
	try {
		ControlAddTip(GuiCtrlObj, ctrlTip)
	}
	;无效数据直接结束
	if !isVaildData {
		if warningMsg
			warningMsgBox(warningMsg, "配置文件关键数据无效！")
		return
	}
	;读取并校验当前选择游戏的“发送文本方式”配置项
	sendMethod := readCfg(selectGame, sendMethodKey, "1")
	if (!IsInteger(sendMethod)) or (sendMethod < 1) or (sendMethod > 5) {
		sendMethod := 1
		writeCfg(sendMethod, selectGame, sendMethodKey)
	} else {
		sendMethod := Integer(sendMethod)
	}
	;读取并校验 键击延时、窗口延时
	pressTimeStr := readCfg(selectGame, pressTimeKey)
	isReWriteCfg := false
	minPressTime := 10
	maxPressTime := 20
	loop parse pressTimeStr, "-", A_Space A_Tab
	{
		if A_Index = 1 {
			if IsInteger(A_LoopField) {
				minPressTime := Integer(A_LoopField)
				if minPressTime < 10 {
					minPressTime := 10
					isReWriteCfg := true
				} else if minPressTime > 1000 {
					minPressTime := 1000
					isReWriteCfg := true
				}
			} else {
				isReWriteCfg := true
			}
		} else if A_Index = 2 {
			if IsInteger(A_LoopField) {
				maxPressTime := Integer(A_LoopField)
				if maxPressTime < 10 {
					maxPressTime := 10
					isReWriteCfg := true
				} else if maxPressTime > 1000 {
					maxPressTime := 1000
					isReWriteCfg := true
				}
			} else {
				isReWriteCfg := true
			}
		} else {
			isReWriteCfg := true
			break
		}
	}
	if minPressTime > maxPressTime {
		minPressTime := maxPressTime
		isReWriteCfg := true
	}
	;自动修正配置文件中错误的配置值
	if isReWriteCfg
		writeCfg(minPressTime "-" maxPressTime, selectGame, pressTimeKey)
	delayTimeStr := readCfg(selectGame, delayTimeKey)
	isReWriteCfg := false
	minDelayTime := 100
	maxDelayTime := 120
	loop parse delayTimeStr, "-", A_Space A_Tab
	{
		if A_Index = 1 {
			if IsInteger(A_LoopField) {
				minDelayTime := Integer(A_LoopField)
				if minDelayTime < 10 {
					minDelayTime := 10
					isReWriteCfg := true
				} else if minDelayTime > maxRandomTime {
					minDelayTime := maxRandomTime
					isReWriteCfg := true
				}
			} else {
				isReWriteCfg := true
			}
		} else if A_Index = 2 {
			if IsInteger(A_LoopField) {
				maxDelayTime := Integer(A_LoopField)
				if maxDelayTime < 10 {
					maxDelayTime := 10
					isReWriteCfg := true
				} else if maxDelayTime > maxRandomTime {
					maxDelayTime := maxRandomTime
					isReWriteCfg := true
				}
			} else {
				isReWriteCfg := true
			}
		} else {
			isReWriteCfg := true
			break
		}
	}
	if minDelayTime > maxDelayTime {
		minDelayTime := maxDelayTime
		isReWriteCfg := true
	}
	if isReWriteCfg
		writeCfg(minDelayTime "-" maxDelayTime, selectGame, delayTimeKey)
	;读取并校验扩展功能配置项
	autoLockCaps := readCfg(selectGame, autoLockCapsKey, "0")
	if (autoLockCaps != "0") && (autoLockCaps != "1") {
		autoLockCaps := 0
		writeCfg(autoLockCaps, selectGame, autoLockCapsKey)
	} else {
		autoLockCaps := Integer(autoLockCaps)
	}
	global isAutoLockCaps := autoLockCaps
	notChatMode := readCfg(selectGame, notChatModeKey, "0")
	if (notChatMode != "0") && (notChatMode != "1") {
		notChatMode := 0
		writeCfg(notChatMode, selectGame, notChatModeKey)
	} else {
		notChatMode := Integer(notChatMode)
	}
	global isNotChatMode := notChatMode
	;读取并校验开始输入配置项
	inputKey := GetKeyName(readCfg(selectGame, inputKeyKey, "T"))
	if (!inputKey) or (inputKey="CapsLock") or (inputKey="LWin") or (inputKey="RWin") or (inputKey="Control") or (inputKey="Shift") or (inputKey="Alt") {
		inputKey := "T"
		writeCfg(inputKey, selectGame, inputKeyKey)
	}
	isFixCNErr := readCfg(selectGame, isFixCNErrKey, "0")
	if (isFixCNErr != "0") && (isFixCNErr != "1") {
		isFixCNErr := 0
		writeCfg(isFixCNErr, selectGame, isFixCNErrKey)
	} else {
		isFixCNErr := Integer(isFixCNErr)
	}
	;刷新其他控件数据
	ControlChooseIndex(sendMethod, sendMethodCtrl, myGui)
	pressTimeCtrl.Text := "键击延时`n" minPressTime "-" maxPressTime
	pressTimeCtrl.minTime := minPressTime
	pressTimeCtrl.maxTime := maxPressTime
	delayTimeCtrl.Text := "窗口延时`n" minDelayTime "-" maxDelayTime
	delayTimeCtrl.minTime := minDelayTime
	delayTimeCtrl.maxTime := maxDelayTime
	autoLockCapsCtrl.Value := autoLockCaps
	notChatModeCtrl.Value := notChatMode
	inputKeyCtrl.Value := inputKey
	inputKeyCtrl.inputKey := inputKey
	if inputKey = enterKeyName {
		inputKeyCtrl.Enabled := false
		isEnterKeyCtrl.Value := 1
	}else {
		inputKeyCtrl.Enabled := true
		isEnterKeyCtrl.Value := 0
	}
	isFixCNErrCtrl.Value := isFixCNErr
}
;添加游戏
addGame_Click(GuiCtrlObj, Info)
{
	setMyGuiFocus()
	addGameGuiW := 260
	marginX := 8
	marginY := 6
	mainCtrlW := addGameGuiW - marginX * 2
	addGameGui := Gui("-Resize -MinimizeBox +Owner" myGui.Hwnd, "添加新的游戏支持")
	addGameGui.MarginX := marginX
	addGameGui.MarginY := marginY
	appLV := addGameGui.AddListView("Count20 Grid -LV0x10 -Multi R6 w" mainCtrlW, ["正在运行的窗口", "进程文件名"])
	appLV.ModifyCol(1, 110)
	appLV.ModifyCol(2, mainCtrlW-110-22)
	addGameGui.AddText("0x200 w" mainCtrlW, "(可单击列表中的数据，自动填写以下配置项)")
	exeCheck := addGameGui.AddCheckbox("y+12 wp h14 Checked1", "游戏窗口进程文件名(选其一或同时填写)：")
	exeEdit := addGameGui.AddEdit("wp")
	addEditPlaceholder(exeEdit, "进程文件名后缀必须为.exe")
	titleCheck := addGameGui.AddCheckbox("wp h14 Checked0", "游戏窗口标题(选其一或同时填写)：")
	titleEdit := addGameGui.AddEdit("wp Disabled1")
	addEditPlaceholder(titleEdit, "窗口标题")
	addGameGui.AddText("0x200 wp", "自定义显示名称：")
	nameEdit := addGameGui.AddEdit("wp")
	addEditPlaceholder(nameEdit, "自定义填写在工具中显示的名称")
	
	addBtn := addGameGui.AddButton("w140 h30 xm+" Round((mainCtrlW-140)/2.0), "添加此游戏支持")
	addBtn.SetFont("bold s12")

	getGuiShowCenterXY(addGameGuiW, , &guiX, &guiY)
	addGameGui.Show("AutoSize x" guiX " y" guiY-30)
	addBtn.Focus()

	addGameGui.OnEvent("Close", (*) => myGui.Opt("-Disabled"))
	myGui.Opt("+Disabled")

	exeCheck.OnEvent("Click", exeCheckClick)
	titleCheck.OnEvent("Click", titleCheckClick)
	addBtn.OnEvent("Click", addBtnClick)

	;刷新listview数据
	iconListId := IL_Create(20)
	appLV.SetImageList(iconListId)
	;获取正在运行的所有窗口并解析
	ids := WinGetList()
	title := ""
	exePath := ""
	exeName := ""
	iconIndex := -1
	appLV.Opt("-Redraw")
	for thisId in ids
	{
		try {
			exePath := WinGetProcessPath(thisId)
		} catch {
			exePath := ""
		}
		if exePath {
			SplitPath(exePath, &exeName)
			;排除文件管理器及任务管理器窗口
			if (exeName = "explorer.exe") or (exeName = "Taskmgr.exe")
				continue
			iconIndex := IL_Add(iconListId, exePath)
			if !iconIndex
				iconIndex := -1
		} else {
			exeName := ""
			iconIndex := -1
		}
		try {
			title := WinGetTitle(thisId)
		} catch {
			title := ""
		}
		if title or exePath {
			appLV.Add("Icon" iconIndex, title, exeName)
		}
	}
	appLV.Opt("+Redraw")
	appLV.OnEvent("Click", appLVClick)
	appLVClick(guiCtrlObj, info) {
		if !info
			return
		clickExe := ""
		clickTitle := ""
		try {
			clickExe := guiCtrlObj.GetText(info, 2)
		}
		try {
			clickTitle := guiCtrlObj.GetText(info, 1)
		}
		exeEdit.Text := clickExe
		titleEdit.Text := clickTitle
		nameEdit.Text := clickTitle
		if clickExe {
			ControlSetChecked(1, exeCheck, guiCtrlObj.Gui)
		}else {
			ControlSetChecked(0, exeCheck, guiCtrlObj.Gui)
		}
	}
	exeCheckClick(guiCtrlObj, info) {
		checked := guiCtrlObj.Value
		exeEdit.Enabled := checked
		if !checked {
			titleCheck.Value := true
			titleEdit.Enabled := true
		}
	}
	titleCheckClick(guiCtrlObj, info) {
		checked := guiCtrlObj.Value
		titleEdit.Enabled := checked
		if !checked {
			exeCheck.Value := true
			exeEdit.Enabled := true
		}
	}
	addBtnClick(guiCtrlObj, info) {
		;校验输入数据
		addExe := ""
		addTitle := ""
		if exeCheck.Value {
			addExe := exeEdit.Text
			if !addExe {
				warningMsgBox("游戏窗口进程文件名`n不能为空！", "输入值错误！")
				return
			}
			if (SubStr(addExe, -4, 4) != ".exe") {
				warningMsgBox("游戏窗口进程文件名：`n" addExe "`n后缀不是“.exe”！", "输入值错误！")
				return
			}
		}
		if titleCheck.Value {
			addTitle := titleEdit.Text
			if !addTitle {
				warningMsgBox("游戏窗口标题`n不能为空！", "输入值错误！")
				return
			}
			if StrLen(addTitle) > 255 {
				warningMsgBox("游戏窗口标题`n不能超过255个字符！", "输入值错误！")
				return
			}
		}
		if (!addExe) && (!addTitle) {
			warningMsgBox("游戏窗口进程文件名`n游戏窗口标题`n两者不能同时为空，需至少填写一个！", "输入值错误！")
			return
		}
		addName := nameEdit.Text
		if !addName {
			warningMsgBox("自定义显示名称`n不能为空！", "输入值错误！")
			return
		}
		if StrLen(addName) > 128 {
			warningMsgBox("自定义显示名称`n不能超过128个字符！", "输入值错误！")
			return
		}
		if readCfg(addName) {
			warningMsgBox("自定义显示名称：`n" addName "`n不能与工具内现有的重复！", "输入值错误！")
			return
		}
		if addExe {
			writeCfg(addExe, addName, gameExeKey)
		}
		if addTitle {
			writeCfg(addTitle, addName, gameTitleKey)
		}
		selectGameCtrl.Add([addName])
		ControlChooseIndex(ControlGetItems(selectGameCtrl, myGui).Length, selectGameCtrl, myGui)
		WinClose(guiCtrlObj.Gui)
	}
}
;删除游戏
deleteGame_Click(GuiCtrlObj, Info)
{
	setMyGuiFocus()
	deleteGame := selectGameCtrl.Text
	if !deleteGame
		return
	gameExe := selectGameCtrl.gameExe
	gameTitle := selectGameCtrl.gameTitle
	msgText := "确定要删除此游戏的支持？`n选择游戏：" deleteGame
	if gameExe
		msgText .= "`n窗口进程文件名：" gameExe
	if gameTitle
		msgText .= "`n窗口标题：" gameTitle
	result := warningMsgBox(msgText, "确定删除？", "OKCancel Icon! Default2")
	if result != "OK"
		return
	try {
		IniDelete(profileName, deleteGame)
	}
	;切换到下一个游戏配置项
	selectIndex := selectGameCtrl.Value
	allItems := ControlGetItems(selectGameCtrl, myGui)
	if !(allItems.Has(selectIndex)) {
		warningMsgBox("刷新游戏列表数据出错！", "刷新游戏列表数据出错")
		return
	}
	allItems.RemoveAt(selectIndex)
	selectIndex -= 1
	if selectIndex < 1
		selectIndex := allItems.Length
	selectGameCtrl.Delete()
	selectGameCtrl.Add(allItems)
	ControlChooseIndex(selectIndex, selectGameCtrl, myGui)
}
;发送文本方式改变
sendMethod_Change(GuiCtrlObj, Info)
{
	sendMethod := GuiCtrlObj.Value
	if sendMethod = 1
		methodName := "发送到指定的窗口"
	else if sendMethod = 2
		methodName := "模拟 {Alt + GBK编码} 发送"
	else if sendMethod = 3
		methodName := "发送 Unicode 字符编码"
	else if sendMethod = 4
		methodName := "发送到当前活动窗口"
	else if sendMethod = 5
		methodName := "发送到指定窗口的消息队列中"
	else if sendMethod = 6
		methodName := "模拟Ctrl+C复制 Ctrl+V粘贴"
	else {
		sendMethod := 1
		methodName := ""
	}
	sendMethodNameCtrl.Text := methodName
	writeSelectGameCfg(sendMethod, sendMethodKey)
}
;键击随机延时改变
pressTime_Click(GuiCtrlObj, Info)
{
	tipInfo := "
	(
	工具模拟按键操作的延时
	默认10-20毫秒之间随机

	不同游戏设置一定的延时
	游戏内才可能正常响应
	)"
	showChangeTimeGui(GuiCtrlObj, "键击", tipInfo)
}
;操作随机延时改变
delayTime_Click(GuiCtrlObj, Info)
{
	tipInfo := "
	(
	工具模拟窗口操作的延时
	默认100-120毫秒之间随机

	不同窗口设置一定的延时
	窗口才可能按顺序响应动作
	)"
	showChangeTimeGui(GuiCtrlObj, "窗口", tipInfo)
}
;显示设置延时子窗口
showChangeTimeGui(timeBtn, keyword, tipInfo)
{
	setMyGuiFocus()
	timeGuiW := 160
	marginX := 8
	marginY := 6
	mainCtrlW := timeGuiW - marginX * 2

	timeGui := Gui("-Resize -MinimizeBox +Owner" myGui.Hwnd, "设置" keyword "延时")
	timeGui.MarginX := marginX
	timeGui.MarginY := marginY
	editW := 50
	timeGui.AddText("w" mainCtrlW, tipInfo)
	timeGui.AddText("Section +0x200 wp", keyword "延时最小值：")
	minTimeEdit := timeGui.AddEdit("xs Limit4 Number w" editW, timeBtn.minTime)
	timeGui.AddText("+0x200 yp hp", "毫秒（10-" maxRandomTime "）")
	timeGui.AddText("+0x200 xs w" mainCtrlW, keyword "延时最大值：")
	maxTimeEdit := timeGui.AddEdit("xs Limit4 Number w" editW, timeBtn.maxTime)
	timeGui.AddText("+0x200 yp hp", "毫秒（10-" maxRandomTime "）")
	saveBtn := timeGui.AddButton("w120 h30 xm+" Round((mainCtrlW-120)/2), "设置" keyword "延时")
	saveBtn.SetFont("bold s12")

	getGuiShowCenterXY(timeGuiW, , &timeGuiX, &timeGuiY)
	timeGui.Show("AutoSize x" timeGuiX " y" timeGuiY+50)
	saveBtn.Focus()

	timeGui.OnEvent("Close", (*) => myGui.Opt("-Disabled"))
	myGui.Opt("+Disabled")

	saveBtn.OnEvent("Click", saveBtnClick)
	;保存延时
	saveBtnClick(guiCtrlObj, info)
	{
		minTime := minTimeEdit.Text
		maxTime := maxTimeEdit.Text
		;自动纠正错误的填写值
		if (!minTime) or (!IsInteger(minTime))
			minTime := timeBtn.minTime
		else if minTime < 10
			minTime := 10
		else if minTime > maxRandomTime
			minTime := maxRandomTime
		if (!maxTime) or (!IsInteger(maxTime))
			maxTime := timeBtn.maxTime
		else if maxTime < 10
			maxTime := 10
		else if maxTime > maxRandomTime
			maxTime := maxRandomTime
		if minTime > maxTime
			maxTime := minTime
		writeSelectGameCfg(minTime "-" maxTime, timeBtn.Name)
		timeBtn.Text := keyword "延时`n" minTime "-" maxTime
		timeBtn.minTime := minTime
		timeBtn.maxTime := maxTime
		WinClose(guiCtrlObj.Gui)
	}
}
;禁用中文输入法勾选与取消
autoLockCaps_Click(GuiCtrlObj, Info)
{
	setMyGuiFocus()
	global isAutoLockCaps := GuiCtrlObj.Value
	writeSelectGameCfg(isAutoLockCaps, autoLockCapsKey)
	if (startCtrl.btnStatus) && (!isAutoLockCaps) && GetKeyState("CapsLock", "T") {
		SetCapsLockState("Off")
	}
}
;非聊天模式勾选与取消
notChatMode_Click(GuiCtrlObj, Info)
{
	setMyGuiFocus()
	global isNotChatMode := GuiCtrlObj.Value
	writeSelectGameCfg(isNotChatMode, notChatModeKey)
	inputKey := inputKeyCtrl.inputKey
	if inputKey && (startCtrl.btnStatus) {
		if isNotChatMode
			Hotkey("~" inputKey " Up", inputKeyCallback, "Off")
		else
			Hotkey(inputKey " Up", inputKeyCallback, "Off")
	}
}
;“调整输入框位置大小”勾选与取消处理
isMoveEdit_Click(GuiCtrlObj, Info)
{
	global isMoveEdit := GuiCtrlObj.Value
	if !chatGui
		return
	GuiCtrlObj.Enabled := false
	if isMoveEdit {
		chatGui.Opt("+Caption +Resize")
	}else {
		saveChatGuiPos()
		chatGui.Opt("-Caption -Resize")
	}
	if (WinGetMinMax(chatGui) != -1) {
		chatGui.Show("AutoSize")
	}
	;允许调整窗口大小后，必须在输入框显示后，再次设置窗口最小及最大尺寸，才会及时生效
	if isMoveEdit {
		chatGui.Opt("+MinSize60x" getEditAutoHeight(chatMinFontSize) " +MaxSize" A_ScreenWidth "x" getEditAutoHeight(chatMaxFontSize))
	}
	SetTimer(()=> GuiCtrlObj.Enabled := true, -1000)
}
;手动发送
manualSend_Click(GuiCtrlObj, Info)
{
	setMyGuiFocus()
	selectGame := selectGameCtrl.Text
	if !selectGame {
		warningMsgBox("未选择游戏！", "未选择游戏！")
		return
	}
	checkIsAdminRun()
	sendGuiW := 300
	marginX := 8
	marginY := 6
	mainCtrlW := sendGuiW - marginX * 2

	sendGui := Gui("-Resize -MinimizeBox +Owner" myGui.Hwnd, "手动发送文字到游戏窗口")
	sendGui.MarginX := marginX
	sendGui.MarginY := marginY
	lineBreakW := 100

	sendGui.AddText("+0x200 h20 w" mainCtrlW-marginX-lineBreakW, "选择游戏：" selectGame)
	lineBreakCB := sendGui.AddCheckbox("yp hp w" lineBreakW, "保留回车符发送")
	sendGui.AddText("+0x200 xm hp w" mainCtrlW, "输入文字，发送到匹配以下条件的窗口输入光标处。")
	gameExe := selectGameCtrl.gameExe
	gameTitle := selectGameCtrl.gameTitle
	if gameExe {
		sendGui.AddText("+0x200 xm hp wp", "窗口进程文件名：" gameExe)
	} 
	if gameTitle {
		sendGui.AddText("+0x200 xm hp wp", "窗口标题：" gameTitle)
	}
	textEdit := sendGui.AddEdit("xm r6 Limit880 w" mainCtrlW)
	textEdit.SetFont("s12")
	sendBtn := sendGui.AddButton("xm wp h30", "发送到游戏窗口的输入光标处")
	sendBtn.SetFont("bold s12")

	getGuiShowCenterXY(sendGuiW, , &sendGuiX, &sendGuiY)
	sendGui.Show("AutoSize x" sendGuiX " y" sendGuiY+60)
	sendBtn.Focus()

	sendGui.OnEvent("Close", (*) => myGui.Opt("-Disabled"))
	myGui.Opt("+Disabled")

	sendBtn.OnEvent("Click", sendBtnClick)
	;发送
	sendBtnClick(guiCtrlObj, info)
	{
		if lineBreakCB.Value
			sendText := textEdit.Text
		else
			sendText := StrReplace(textEdit.Text, "`r`n")
		errMsg := sendTextToGame(sendText, false)
		if errMsg
			warningMsgBox(errMsg, "发送失败！")
		else
			textEdit.Text := ""
	}
}
;开始输入按键改变
inputKey_Change(GuiCtrlObj, Info)
{
	inputKey := GetKeyName(GuiCtrlObj.Value)
	;排除一些无效触发事件，及排除设置大小写键
	if (!inputKey) or (inputKey = "CapsLock") {
		GuiCtrlObj.Value := inputKeyCtrl.inputKey
		return
	}
	if (inputKey != (inputKeyCtrl.inputKey)) {
		inputKeyCtrl.inputKey := inputKey
		writeSelectGameCfg(inputKey, inputKeyKey)	
	}
}
;“Enter”控件勾选与取消处理
isEnterKey_Click(GuiCtrlObj, Info)
{
	setMyGuiFocus()
	isEnterKey := GuiCtrlObj.Value
	if isEnterKey {
		inputKeyCtrl.Enabled := false
		inputKeyCtrl.Value := enterKeyName
		if enterKeyName != inputKeyCtrl.inputKey {
			inputKeyCtrl.inputKey := enterKeyName
			writeSelectGameCfg(enterKeyName, inputKeyKey)
		}
	} else {
		inputKeyCtrl.Enabled := true
	}
}
;修复中文???乱码控件事件
isFixCNErr_Click(GuiCtrlObj, Info)
{
	setMyGuiFocus()
	writeSelectGameCfg(GuiCtrlObj.Value, isFixCNErrKey)
}
;启动按钮点击事件处理
start_Click(GuiCtrlObj, Info)
{
	if GuiCtrlObj.btnStatus {
		stopTool()
	} else {
		if (getGameMatchTitle() = notExistTitle) {
			errMsg := Format("
			(
				选择游戏：{}
				进程文件名：{}
				窗口标题：{}
				报错：以上关键配置数据无效！
				（进程文件名、窗口标题有其一或同时存在皆可）
			)", selectGameCtrl.Text, selectGameCtrl.gameExe, selectGameCtrl.gameTitle)
			warningMsgBox(errMsg, "启动失败！")
			return
		}
		if !(sendMethodCtrl.Value) {
			warningMsgBox("未选择发送文本方式！", "启动失败！")
			return
		}
		if !(inputKeyCtrl.inputKey) {
			warningMsgBox("“开始输入”按键的配置无效或不支持！", "启动失败！")
			return
		}
		startTool()
	}
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
	;立即开始监测
	SetTimer(startMonitorGame, -10)
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
;开始监测游戏窗口激活状态，使用WinWait循环监测。
;而使用OnMessage(0x06, onWindowActivate)监听窗口激活消息，经测试，有bug，
;只会监听到工具自身窗口激活与未激活事件，其他窗口无法监听到，原因未知
;https://learn.microsoft.com/zh-cn/windows/win32/inputdev/wm-activate
;https://learn.microsoft.com/zh-cn/windows/win32/winmsg/wm-activateapp
startMonitorGame()
{
	inputKey := inputKeyCtrl.inputKey
	matchTitle := getGameMatchTitle()
	global gameActive := 0
	;开始监测游戏窗口激活状态
	while (gameActive != -1) {
		if WinActive(matchTitle)
			global gameActive := 1
		else
			global gameActive := 0
		if gameActive {
			if !WinWaitNotActive(matchTitle, , 2)
				continue
			if (gameActive = -1)
				break
			global gameActive := 0
			if isNotChatMode {
				Hotkey(inputKey " Up", inputKeyCallback, "Off")
			} else {
				Hotkey("~" inputKey " Up", inputKeyCallback, "Off")
			}
			if isAutoLockCaps {
				SetCapsLockState("Off")
			}
		} else {
			if !WinWaitActive(matchTitle, , 2)
				continue
			if (gameActive = -1)
				break
			global gameActive := 1
			if isNotChatMode {
				Hotkey(inputKey " Up", inputKeyCallback, "On")
			} else {
				Hotkey("~" inputKey " Up", inputKeyCallback, "On")
			}
			if isAutoLockCaps {
				SetCapsLockState("AlwaysOn")
			}
		}
	}
	;停止监测时禁用相关热键
	if isNotChatMode {
		Hotkey(inputKey " Up", inputKeyCallback, "Off")
	} else {
		Hotkey("~" inputKey " Up", inputKeyCallback, "Off")
	}
	if isAutoLockCaps {
		SetCapsLockState("Off")
	}
}
;停止
stopTool()
{
	;停止监测游戏窗口
	global gameActive := -1
	;临时禁用启动按钮
	startCtrl.Enabled := false
	isMoveEditCtrl.Enabled := false
	startCtrl.btnStatus := false
	;销毁聊天框
	changeChatGui(-1)
	;延时更新按钮状态
	SetTimer(enableStartBtn, -1500)
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
	if !WinExist(getGameMatchTitle())
		return
	WinGetClientPos(&gameX, &gameY, &gameW, &gameH)
	;排除最小化时的坐标保存
	if (gameW < 1) or (gameH < 1)
		return
	chatGui.GetPos(&chatX, &chatY)
	chatGui.GetClientPos(, , &clientW, &clientH)
	if (clientW < 1) or (clientH < 1)
		return
	if isRelativePos {
		chatX := chatX-gameX
		chatY := chatY-gameY
	}
	;保存相对或绝对坐标
	writeSelectGameCfg(chatX "," chatY "," clientW "," getEditAutoFontSize(clientH), (gameW "x" gameH))
}
;显示、隐藏或销毁输入框
changeChatGui(state := -1, saveText := false)
{
	static oldState := -1
	;过滤重复调用
	if state = oldState
		return
	if (state = -1) {
		oldState := -1
		;停止监测
		global gameActive := -1
		;禁用输入框相关热键
		Hotkey("~" enterKeyName, sendKeyCallback, "Off")
		Hotkey(tabKeyName, tabKeyCallback, "Off")
		Hotkey("~" escKeyName " Up", escKeyCallback, "Off")
		;保存输入框位置及大小
		if isMoveEdit {
			saveChatGuiPos()
		}
		;销毁输入框
		if chatGui {
			chatGui.Destroy()
			global chatGui := 0
		}
		return
	}
	;初始化聊天框
	if !chatGui {
		chatGuiTitle := "鼠标按此拖动、鼠标靠至左右上下边框调整宽高"
		;根据是否开启调整输入框来创建
		if isMoveEdit {
			global chatGui := Gui("+ToolWindow -SysMenu +Border +Caption +Resize +AlwaysOnTop +MinSize60x" getEditAutoHeight(chatMinFontSize) " +MaxSize" A_ScreenWidth "x" getEditAutoHeight(chatMaxFontSize), chatGuiTitle)
		} else {
			global chatGui := Gui("+ToolWindow -SysMenu +Border -Caption -Resize +AlwaysOnTop", chatGuiTitle)
		}
		chatGui.gamePos := {gameX:0, gameY:0, gameW:0, gameH:0}
		chatGui.stayShow := false
		chatGui.SetFont("bold s12")
		chatGui.BackColor := "Black"
		chatGui.MarginX := 0
		chatGui.MarginY := 0
		chatEdit := chatGui.AddEdit("vchatEdit x0 y0 cWhite BackgroundBlack r1 Disabled1 w280 h24 Limit" chatMaxLength)
		chatClose := chatGui.AddText("vchatClose x+0 hp w20 0x200 Center cWhite BackgroundRed", "X")
		chatClose.SetFont("s12")
		chatGui.Show("Minimize")
		chatGui.Hide()
		chatClose.OnEvent("Click", chatClose_Click)
		chatGui.OnEvent("Size", chatGui_Size)
		chatEdit.OnEvent("Focus", chatEditFocus)
		chatEdit.OnEvent("LoseFocus", chatEditLoseFocus)
	}
	if (state = 0) {
		if chatGui.stayShow
			return
		oldState := state
		chatEdit := chatGui["chatEdit"]
		;是否需要清空已输入文本
		if !saveText {
			chatEdit.Text := ""
		}
		chatEdit.Enabled := false
		if isMoveEdit {
			saveChatGuiPos()
		}
		; 需要先最小化，再隐藏，否则窗口最小化后会残留显示标题栏
		chatGui.Show("Minimize")
		chatGui.Hide()
		;禁用全局取消输入Esc热键
		Hotkey("~" escKeyName " Up", escKeyCallback, "Off")
	} else if (state = 1) {
		if !WinActive(getGameMatchTitle())
			return
		oldState := state
		WinGetClientPos(&gameX, &gameY, &gameW, &gameH)
		gamePos := chatGui.gamePos
		if (gameX != gamePos.gameX) or (gameY != gamePos.gameY) or (gameW != gamePos.gameW) or (gameH != gamePos.gameH) {
			gamePos.gameX := gameX
			gamePos.gameY := gameY
			gamePos.gameW := gameW
			gamePos.gameH := gameH
			chatPos := getChatGuiPos(gameX, gameY, gameW, gameH)
			chatGuiCtrlAutoSize(chatPos.chatW, chatPos.chatH)
			Sleep getRandomDelayTime()
			chatGui.Show("AutoSize x" (chatPos.chatX) " y" (chatPos.chatY))
		} else {
			Sleep getRandomDelayTime()
			chatGui.Show("AutoSize")
		}
		; 允许调整窗口大小后，必须在输入框显示后，再次设置窗口最小及最大尺寸，才会及时生效
		if isMoveEdit {
			chatGui.Opt("+MinSize60x" getEditAutoHeight(chatMinFontSize) " +MaxSize" A_ScreenWidth "x" getEditAutoHeight(chatMaxFontSize))
		}
		chatEdit := chatGui["chatEdit"]
		chatEdit.Enabled := true
		;必须要执行Focus，不然不会主动激活输入框，不会联动触发Focus/LoseFocus事件
		chatEdit.Focus()
		;Foucus会导致文本被全选，此为解决文本被全选的方法
		;EM_SETSEL := 0xB1，将编辑光标移动到末尾
		;https://learn.microsoft.com/zh-cn/windows/win32/controls/em-setsel
		if chatEdit.Text {
			try {
				PostMessage(0xB1, -1, -1, chatEdit, chatGui)
			}
		}
		;启用全局取消输入Esc热键
		Hotkey("~" escKeyName " Up", escKeyCallback, "On")
	}
}
;获取当前游戏分辨率下的输入框绝对坐标及大小
getChatGuiPos(gameX, gameY, gameW, gameH)
{
	chatPosValue := readSelectGameCfg(gameW "x" gameH)
	;输入框相对/绝对坐标默认值（相对于游戏窗口）
	chatW := 360
	chatX := Round(gameW-chatW)
	chatY := Round(gameH*0.6)
	chatFontSize := 14
	;存储值解析
	loop parse chatPosValue, ",", A_Space A_Tab
	{
		if (A_Index = 1) {
			if IsInteger(A_LoopField)
				chatX := Integer(A_LoopField)
		} else if (A_Index = 2) {
			if IsInteger(A_LoopField)
				chatY := Integer(A_LoopField)
		} else if (A_Index = 3) {
			if IsInteger(A_LoopField)
				chatW := Integer(A_LoopField)
		} else if (A_Index = 4) {
			if IsInteger(A_LoopField) {
				if A_LoopField < chatMinFontSize
					chatFontSize := chatMinFontSize
				else if A_LoopField > chatMaxFontSize
					chatFontSize := chatMaxFontSize
				else
					chatFontSize := Integer(A_LoopField)
			}
		} else {
			break
		}
	}
	chatH := getEditAutoHeight(chatFontSize)
	;计算输入框的绝对坐标
	if isRelativePos {
		chatX := Round(gameX+chatX)
		chatY := Round(gameY+chatY)
	} else {
		chatX := Round(chatX)
		chatY := Round(chatY)
	}
	;确保输入框始终显示在屏幕内
	if chatX < 0
		chatX := 0
	else if chatX > A_ScreenWidth-chatW
		chatX := Round(A_ScreenWidth-chatW)
	if chatY < 0
		chatY := 0
	else if chatY > A_ScreenHeight-chatH
		chatY := Round(A_ScreenHeight-chatH)
	return {chatX:chatX, chatY:chatY, chatW:chatW, chatH:chatH, chatFontSize:chatFontSize}
}
;输入窗口按下X关闭按钮
chatClose_Click(GuiCtrlObj, Info)
{
	chatGui.stayShow := false
	changeChatGui(0)
}
;输入框获得键盘焦点
chatEditFocus(guiCtrlObj, info)
{
	if isAutoLockCaps {
		SetCapsLockState("Off")
	}
	;启用发送及切换频道热键
	Hotkey("~" enterKeyName, sendKeyCallback, "On")
	if isNotChatMode {
		Hotkey(tabKeyName, tabKeyCallback, "Off")
	} else {
		Hotkey(tabKeyName, tabKeyCallback, "On")
	}
}
;输入框失去键盘焦点
chatEditLoseFocus(guiCtrlObj, info)
{
	;禁用发送及切换频道热键
	Hotkey("~" enterKeyName, sendKeyCallback, "Off")
	Hotkey(tabKeyName, tabKeyCallback, "Off")
	if autoCloseChat
		changeChatGui(0, saveChatText)
}
;输入窗口大小改变,控件自适应布局
chatGui_Size(GuiObj, MinMax, Width, Height)
{
	if (MinMax = -1)
		return
	if !isMoveEdit
		return
	chatGuiCtrlAutoSize(Width, Height)
}
;输入窗口控件自适应布局
chatGuiCtrlAutoSize(guiW, guiH)
{
	if guiW < 21
		guiW := 21
	if guiH < 1
		guiH := 1
	chatGui["chatEdit"].SetFont("s" getEditAutoFontSize(guiH))
	chatGui["chatEdit"].Move(, , guiW-20, guiH)
	chatGui["chatClose"].Move(guiW-20, , , guiH)
	; chatGui["chatEdit"].Redraw()
	chatGui["chatClose"].Redraw()
}
;开始输入
inputKeyCallback(hotkeyName)
{
	changeChatGui(1)
}
;发送文本
sendKeyCallback(hotkeyName)
{
	if !chatGui
		return
	chatEdit := chatGui["chatEdit"]
	;兼容在中文输入状态下按Enter键直接输入英文
	oldChatText := chatEdit.Value
	KeyWait LTrim(hotkeyName, "~")
	chatText := chatEdit.Value
	if chatText != oldChatText
		return
	changeChatGui(0)
	sendTextToGame(chatText, !isNotChatMode)
}
;发送文本到游戏窗口
sendTextToGame(chatText, chatMode := true)
{
	if !WinExist(getGameMatchTitle())
		return "游戏窗口不存在"
	setRandomKeyDelay()
	WinActivate()
	sendMethod := sendMethodCtrl.Value
	switch sendMethod
	{
		case 2:
			;Alt+nnnnn小键盘方法
			if WinWaitActive(, , maxwaitTime) {
				switchCNIME(true)
				asccode := ""
				loop Parse chatText {
					;AHK的每个字符串都以"空终止符"结束，StrPut两参数计算后的实际字节数需-1
					;分配精确大小的缓冲区(已排除空终止符)
					buf := Buffer(StrPut(A_LoopField, "CP936") - 1)
					;复制字符并转换编码，CP936为GBK编码
					bytes := StrPut(A_LoopField, buf, "CP936")
					;生成ASC码(十进制值)，英文字符为单字节，中文字符为双字节，区分处理
					asc := NumGet(buf, 0, "UChar")
					if (bytes = 2) {
						asc := (asc << 8) + NumGet(buf, 1, "UChar")
					}
					asccode .= "{ASC " asc "}"
				}
				SendEvent asccode
				asccode := ""
				if chatMode {
					setRandomKeyDelay()
					SendEvent "{Enter}"
				}
			}
		case 3:
			;Send {U+nnnn} Unicode字符编码
			if WinWaitActive(, , maxwaitTime) {
				switchCNIME(true)
				unicode := ""
				loop Parse chatText {
					unicode .= Format("{{}U+{:04X}{}}", Ord(A_LoopField))
				}
				SendEvent unicode
				unicode := ""
				if chatMode {
					setRandomKeyDelay()
					SendEvent "{Enter}"
				}
			}
		case 4:
			;SendText 方法
			if WinWaitActive(, , maxwaitTime) {
				switchCNIME(true)
				SendText chatText
				if chatMode {
					setRandomKeyDelay()
					SendEvent "{Enter}"
				}
			}
		case 5:
			;PostMessage 方法
			switchCNIME(true)
			waitTime := getRandomPressTime()
			loop Parse chatText {
				PostMessage(0x102, ord(A_LoopField))
				Sleep waitTime
			}
			if chatMode {
				if WinWaitActive(, , maxwaitTime) {
					setRandomKeyDelay()
					SendEvent "{Enter}"
				}
			}
		case 6:
			;复制粘贴方法
			if WinWaitActive(, , maxwaitTime) {
				switchCNIME(true)
				;保存原有剪贴板内容，避免粘贴后无法恢复
				clipSaved := ClipboardAll()
				A_Clipboard := chatText
				ClipWait(maxwaitTime)
				SendEvent "^v"
				if chatMode {
					setRandomKeyDelay()
					SendEvent "{Enter}"
				}
				;发送完，恢复原有剪贴板内容
				A_Clipboard := clipSaved
				clipSaved := "" ;释放内存
			}
		default:
			;ControlSendText 方法
			switchCNIME(true)
    		ControlSendText chatText
			if chatMode && WinWaitActive(, , maxwaitTime) {
				setRandomKeyDelay()
				SendEvent "{Enter}"
			}
	}
	switchCNIME(false)
	return ""
}
;取消输入
escKeyCallback(hotkeyName)
{
	if !chatGui
		return
	chatGui.stayShow := false
	chatGuiActive := WinActive(chatGui)
	changeChatGui(0)
	;只有在输入框已激活+游戏窗口存在+聊天模式下
	;才在取消输入后，模拟执行游戏窗口内的Esc按键
	if !chatGuiActive
		return
	if !WinExist(getGameMatchTitle())
		return
	WinActivate()
	if isNotChatMode
		return
	if WinWaitActive(, , maxwaitTime) {
		setRandomKeyDelay()
		SendEvent "{Esc}"
	}
}
;切换频道
tabKeyCallback(hotkeyName)
{
	if isNotChatMode
		return
	if !chatGui
		return
	if !WinExist(getGameMatchTitle())
		return
	chatGui.stayShow := true
	WinActivate()
	KeyWait hotkeyName
	if WinWaitActive(, , maxwaitTime) {
		setRandomKeyDelay()
		SendEvent "{Tab}"
	}
	if !chatGui
		return
	chatGui.Show()
	chatEdit := chatGui["chatEdit"]
	chatEdit.Focus()
	if chatEdit.Text {
		try {
			PostMessage(0xB1, -1, -1, chatEdit, chatGui)
		}
	}
	chatGui.stayShow := false
}
;切换中文输入法或恢复原输入法
;IME的ID:"zh",134481924 "en",67699721
switchCNIME(isSwitchCN := false)
{
	if !(isFixCNErrCtrl.Value)
		return
	static inputLocaleID := -1
	if isSwitchCN {
		;切换为中文输入法：0x8040804=134481924
		try {
			threadID := DllCall("GetWindowThreadProcessId", "UInt", WinExist("A"), "UInt", 0)
			localeID := DllCall("GetKeyboardLayout", "UInt", threadID, "UInt")
			if localeID != 134481924 {
				; PostMessage(0x50, 0, 134481924, , "A")
				inputLocaleID := localeID
				SendMessage(0x50, 0, 134481924, , "A")
				Sleep getRandomDelayTime()
			}
		}
	} else {
		if inputLocaleID = -1
			return
		;恢复原输入法。若需切换为美式键盘：0x40904090=67699721
		try {
			; PostMessage(0x50, 0, inputLocaleID, , "A")
			SendMessage(0x50, 0, inputLocaleID, , "A")
		}
		inputLocaleID := -1
	}
}
;获取当前游戏完整窗口匹配条件
getGameMatchTitle()
{
	if IsSet(selectGameCtrl) {
		gameTitle := selectGameCtrl.gameTitle
		gameExe := selectGameCtrl.gameExe
	} else {
		gameTitle := readSelectGameCfg(gameTitleKey)
		gameExe := readSelectGameCfg(gameExeKey)
	}
	if gameTitle {
		if gameExe
			return gameTitle " ahk_exe " gameExe
		else
			return gameTitle
	} else {
		if gameExe
			return "ahk_exe " gameExe
		else
			return notExistTitle
	}
}
;获取输入框最佳匹配高度
getEditAutoHeight(fontSize)
{
	autoHeight := Round(fontSize * A_ScreenDPI / 72.0 + 8.0)
	if autoHeight < 10
		autoHeight := 10
	else if autoHeight > A_ScreenDPI + 8
		autoHeight := Round(A_ScreenDPI + 8)
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
;设置GUI
openSettingsGui(*)
{
	setMyGuiFocus()
	settingsGuiW := 166
	marginX := 8
	marginY := 6
	mainCtrlW := settingsGuiW - marginX*2
	
	settingsGui := Gui("-Resize -MinimizeBox +Owner" myGui.Hwnd, "更多设置")
	settingsGui.MarginX := marginX
	settingsGui.MarginY := marginY
	settingsGui.AddCheckbox("xm ym h20 w" mainCtrlW " Checked" isShowAdminRun " v" isShowAdminRunKey, "显示以管理员运行建议")
	settingsGui.AddCheckbox("xp hp wp Checked" isShowTip " v" isShowTipKey, "显示帮助(鼠标悬停显示)")
	settingsGui.AddCheckbox("xp hp wp Checked" isRelativePos " v" isRelativePosKey, "使用相对坐标定位输入框")
	closeChatCB := settingsGui.AddCheckbox("xp hp wp Checked" autoCloseChat " v" autoCloseChatKey, "自动关闭失去焦点输入框")
	closeTextCB := settingsGui.AddCheckbox("xp hp wp Checked" saveChatText " v" saveChatTextKey " Disabled" (autoCloseChat ? 0 : 1), "自动关闭时保留输入文本")

	editCtrlW := 50
	settingsGui.AddText("Section r1 wp", "等待窗口响应最长时间：")
	settingsGui.AddEdit("xp r1 +Limit5 w" editCtrlW " v" maxWaitTimeKey, maxwaitTime)
	settingsGui.AddText("+0x200 yp hp", "秒（1-60）")
	settingsGui.AddText("xs r1 w" mainCtrlW, "输入框的最大字符数：")
	settingsGui.AddEdit("xp r1 +Number +Limit3 w" editCtrlW " v" chatMaxLengthKey, chatMaxLength)
	settingsGui.AddText("+0x200 yp hp", "个（88-880）")
	settingsGui.AddText("xs r1 w" mainCtrlW, "输入框的最大字体尺寸：")
	settingsGui.AddEdit("xp r1 +Number +Limit2 w" editCtrlW " v" chatMaxFontSizeKey, chatMaxFontSize)
	settingsGui.AddText("+0x200 yp hp", "磅（10-72）")
	savesettingsW := 80
	saveSettingsXM := Round((mainCtrlW-savesettingsW)/2.0)
	if saveSettingsXM < 0
		saveSettingsXM := 0
	saveSettingsCtrl := settingsGui.AddButton("h30 Center xm+" saveSettingsXM " w" savesettingsW, "保存设置")
	saveSettingsCtrl.SetFont("bold s12")

	getGuiShowCenterXY(settingsGuiW, , &settingsGuiX, &settingsGuiY)
	settingsGui.Show("AutoSize x" settingsGuiX " y" settingsGuiY)

	settingsGui.OnEvent("Close", (*) => myGui.Opt("-Disabled"))
	myGui.Opt("+Disabled")
	closeChatCB.OnEvent("Click", (*) => closeTextCB.Enabled := closeChatCB.Value)
	saveSettingsCtrl.OnEvent("Click", saveSettings_Click)
	;保存设置
	saveSettings_Click(GuiCtrlObj, info)
	{
		settingsData := GuiCtrlObj.Gui.Submit(false)
		for ctrlName, ctrlValue in (settingsData.OwnProps())
		{
			if ctrlName = isShowTipKey {
				GuiSetTipEnabled(myGui, ctrlValue)
			}
			writeMainCfg(ctrlValue, ctrlName)
		}
		readCheckMainCfg()
		WinClose(GuiCtrlObj.Gui)
	}
}
;主界面点击关闭按钮的处理
myGui_Close(thisGui)
{
	result := tipMsgBox("确定退出？", "退出", "OKCancel Iconi Default2")
	if (result = "OK") {
		clickExit()
	} else {
		return true
	}
}
;获取子窗口显示在主窗口的中心坐标
getGuiShowCenterXY(subGuiW := 0, subGuiH := 0, &subGuiX := 0, &subGuiY := 0)
{
	if !IsSet(myGui) {
		subGuiX := "Center"
		subGuiY := "Center"
		return false
	}
	myGui.GetPos(&myGuiX, &myGuiY)
	;通过此方法获取的宽度最准确
	myGui.GetClientPos(&clientX, &clientY, &clientW, &clientH)
	if (clientW < 1) or (clientH < 1) {
		subGuiX := "Center"
		subGuiY := "Center"
		return false
	}
	if subGuiW {
		subGuiX := Round(myGuiX+(clientW-subGuiW)/2.0)
	} else {
		subGuiX := clientX
	}
	if subGuiH {
		subGuiY := Round(myGuiY+(clientH-subGuiH)/2.0)
	} else {
		subGuiY := clientY
	}
	return true
}
;设置send、win相关函数执行延时
setRandomKeyDelay()
{
	SetKeyDelay(getRandomPressTime(), getRandomPressTime())
	SetWinDelay(getRandomDelayTime())
}
;获取随机的键击时间
getRandomPressTime()
{
	if IsSet(pressTimeCtrl) {
		return Random(pressTimeCtrl.minTime, pressTimeCtrl.maxTime)
	} else {
		return Random(10, 20)
	}
}
;获取随机的操作时间
getRandomDelayTime()
{
	if IsSet(delayTimeCtrl) {
		return Random(delayTimeCtrl.minTime, delayTimeCtrl.maxTime)
	} else {
		return Random(100, 120)
	}
}
;获取配置文件中所有的游戏名称
getAllGameName()
{
	if !FileExist(profileName)
		return defaultGameCfg()
	gameNameArr := Array()
	allSection := readCfg()
	Loop Parse allSection, "`n" {
		if (A_LoopField != mainSection)
			gameNameArr.Push(A_LoopField)
	}
	allSection := ""
	return gameNameArr
}
;读取配置文件
readCfg(Section?, Key?, Default := "")
{
	return IniRead(profileName, Section ?? unset, Key ?? unset, Default)
}
;写入配置文件
writeCfg(Value, Section, Key)
{
	;避免重复写入
	if (Value = readCfg(Section, Key))
		return
	if !FileExist(profileName)
		defaultGameCfg()
	IniWrite(Value, profileName, Section, Key)
}
;写入当前选择的游戏配置
writeSelectGameCfg(Value, Key)
{
	if IsSet(selectGameCtrl)
		selectGame := selectGameCtrl.Text
	else
		selectGame := readMainCfg(selectGameKey)
	if !selectGame
		return
	writeCfg(Value, selectGame, Key)
}
;读取当前选择的游戏配置
readSelectGameCfg(Key, Default := "")
{
	if IsSet(selectGameCtrl)
		selectGame := selectGameCtrl.Text
	else
		selectGame := readMainCfg(selectGameKey)
	if !selectGame
		return Default
	return readCfg(selectGame, Key, Default)
}
;写入main配置
writeMainCfg(Value, Key)
{
	writeCfg(Value, mainSection, Key)
}
;读取main配置
readMainCfg(Key, Default := "")
{
	return readCfg(mainSection, Key, Default)
}
;普通的警告样式弹窗
warningMsgBox(text := "", title := "警告!", options := "Icon!", btnTextArr?)
{
	if IsSet(myGui) {
		myGui.Opt("+OwnDialogs")
	}
	return showCenterMsgBox(text, title, options, btnTextArr ?? unset)
}
;普通的提示样式弹窗
tipMsgBox(text := "", title := "提示!", options := "Iconi", btnTextArr?)
{
	if IsSet(myGui) {
		myGui.Opt("+OwnDialogs")
	}
	return showCenterMsgBox(text, title, options, btnTextArr ?? unset)
}
;声明样式弹窗
declarationMsgBox(isForceShow := false)
{
	if (!isForceShow) && (!readMainCfg(showStartTipKey))
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

点击 “拒绝” 拒绝声明并退出。
点击 “接受” 接受声明并继续。
点击 “接受且不再提示” 接受声明且启动时不再提示。
	)"
	res := warningMsgBox(text, "作者声明!", "AbortRetryIgnore Icon! Default2", ["拒绝", "接受", "接受且不再提示"])
	if res = "Abort" {
		ExitApp
	} else if res = "Ignore" {
		writeMainCfg("0", showStartTipKey)
	}
}
;取消其他按钮的输入焦点蓝边框的临时解决方案
setMyGuiFocus(isCancel?)
{
	static focusHiddenCtrl := myGui.AddButton("x0 y0 w1 h1 Hidden")
	if startCtrl.btnStatus {
		focusHiddenCtrl.Focus()
		return
	}
	if IsSet(isCancel) {
		if isCancel {
			focusHiddenCtrl.Focus()
		} else {
			focusHiddenCtrl.Focus()
			startCtrl.Focus()
		}
	}else {
		startCtrl.Focus()
	}
}
;显示在主窗口或屏幕中央、自定义按钮名称的MsgBox。较安全的实现方法，但是改变坐标时会有残影
showCenterMsgBox(text := "", title := "", options?, btnTextArr?)
{
	if !title
		title := A_ScriptName
	;仅匹配指定标题+对话框类型+归属于当前程序的窗口。对话框的窗口类名称为“#32770”
	;https://learn.microsoft.com/zh-cn/windows/win32/winauto/dialog-box
	msgTitle := (title " ahk_class #32770 ahk_exe " (A_IsCompiled ? A_ScriptFullPath : A_AhkPath))
	changeMsgBoxFunc := changeMsgBoxPosBtn.Bind(msgTitle, btnTextArr ?? unset)
	SetTimer(changeMsgBoxFunc, 10)
	res := MsgBox(text, title, options ?? unset)
	if IsSet(changeMsgBoxFunc)
		SetTimer(changeMsgBoxFunc, 0)
	return res ?? ""
	changeMsgBoxPosBtn(matchTitle, textArr?)
	{
		if !WinExist(matchTitle)
			return
		SetTimer(, 0)
		msgBoxW := 0
		msgBoxH := 0
		try {
			WinGetPos(, , &msgBoxW, &msgBoxH)
		}
		;仅主窗口存在且不为最小化时，显示在主窗口中央。其他保持默认显示在屏幕中央
		if (msgBoxW > 1) && (msgBoxH > 1) && IsSet(myGui) {
			try {
				myGui.GetPos(&mainGuiX, &mainGuiY, &mainGuiW, &mainGuiH)
				if (mainGuiW > 1) && (mainGuiH > 1) {
					guiX := Round(mainGuiX + ((mainGuiW - msgBoxW) / 2.0))
					guiY := Round(mainGuiY + ((mainGuiH - msgBoxH) / 2.0))
					;保证对话框显示在屏幕中
					if guiX < 0
						guiX := 0
					else if guiX > (A_ScreenWidth - msgBoxW)
						guiX := A_ScreenWidth - msgBoxW
					if guiY < 0
						guiY := 0
					else if guiY > (A_ScreenHeight - msgBoxH)
						guiY := A_ScreenHeight - msgBoxH
					WinMove(guiX, guiY)
				}
			}
		}
		if !IsSet(textArr)
			return
		; 通过ClassNN定位对应按钮："Button1"是类名为"Button"的第一个控件，以此类推。
		; 目前MsgBox系统对话框最多有3个按钮
		for btnIndex, btnText in textArr
		{
			if btnIndex > 3
				break
			try {
				ControlSetText(btnText, "Button" btnIndex)
			}
		}
	}
}
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
	if !tipHwnd {
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
	if TipText {
		;填充工具提示文本到 TOOLINFO
		NumPut("Ptr", StrPtr(TipText), TOOLINFO, 24 + (A_PtrSize * 3))
		;文本不为空，如果控件已注册则更新提示，否则添加注册
		if isRegister
			SendMessage(0x0439, 0, TOOLINFO, tipHwnd) ;TTM_UPDATETIPTEXTW
		else
			SendMessage(0x0432, 0, TOOLINFO, tipHwnd) ;TTM_ADDTOOLW
	} else {
		;文本为空且已注册则删除提示
		if isRegister
			SendMessage(0x0433, 0, TOOLINFO, tipHwnd) ;TTM_DELTOOLW
	}
	return tipHwnd
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
	if IsSet(Automatic) {
		if !IsInteger(Automatic) or (Automatic < 0)
			Automatic := -1 ;默认值
		else if Automatic > 3200
			Automatic := 3200
		SendMessage 0x403, 0, Automatic, tipHwnd ;TTM_SETDELAYTIME TTDT_AUTOMATIC		
		return
	}
	;设置初始显示延迟时间
	if IsSet(Initial) {
		if !IsInteger(Initial) or (Initial < 0)
			Initial := -1 ;默认值为500毫秒
		else if Initial > 32000
			Initial := 32000
		SendMessage 0x403, 3, Initial, tipHwnd ;TTM_SETDELAYTIME TTDT_INITIAL
	}
	;设置自动弹出延迟时间
	if IsSet(AutoPop) {
		if !IsInteger(AutoPop) or (AutoPop < 0)
			AutoPop := -1 ;默认值为5000毫秒
		else if AutoPop > 32000
			AutoPop := 32000 ;允许的最大值为32000毫秒
		SendMessage 0x403, 2, AutoPop, tipHwnd ;TTM_SETDELAYTIME TTDT_AUTOPOP
	}
	;设置从一个控件移动到另一个控件，重新显示延迟时间
	if IsSet(Reshow) {
		if !IsInteger(Reshow) or (Reshow < 0)
			Reshow := -1 ;默认值为100毫秒
		else if Reshow > 32000
			Reshow := 32000
		SendMessage 0x403, 1, Reshow, tipHwnd ;TTM_SETDELAYTIME TTDT_RESHOW
	}
}
;给编辑控件添加提示文本
;https://learn.microsoft.com/zh-cn/windows/win32/controls/em-setcuebanner
addEditPlaceholder(editCtrl, placeholder)
{
	if !placeholder
		return
	try {
		SendMessage(0x1501, true, StrPtr(placeholder), editCtrl.Hwnd)
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
	result := tipMsgBox("
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
	)", "重要提示！", "OKCancel Iconi Default1")
	if result = "OK" {
		try {
			if A_IsCompiled
				Run '*RunAs "' A_ScriptFullPath '" /restart'
			else
				Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
		} catch Error as err {
			extraInfo := err.Extra
			if (extraInfo != "操作已被用户取消。`r`n") && (extraInfo != "操作已被用户取消。") {
				warningMsgBox("无法以管理员身份运行！`n将尝试以普通用户身份运行。", "运行错误！", "OK Icon!")
				if A_IsCompiled
					Run '"' A_ScriptFullPath '" /restart'
				else
					Run '"' A_AhkPath '" /restart "' A_ScriptFullPath '"'
				ExitApp
			}
		}else {
			ExitApp
		}
	}
	;工具运行期间仅提示一次
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
selectGame=幽灵行动：荒野
maxWaitTime=5
chatMaxFontSize=60
chatMaxLength=88
maxRandomTime=1000
showStartTip=1
isShowTip=1
isShowAdminRun=1
autoCloseChat=1
saveChatText=1
isRelativePos=1
[幽灵行动：荒野]
exe=GRW.exe
inputKey=t
sendMethod=1
isFixCNErr=1
pressTime=10-20
delayTime=100-120
autoLockCaps=0
notChatMode=0
1920x1080=1552,674,360,14
[幽灵行动：断点]
exe=GRB.exe
inputKey=Enter
sendMethod=5
1920x1080=1420,696,384,14
[幽灵行动：断点-vulkan]
exe=GRB_vulkan.exe
inputKey=Enter
sendMethod=5
1920x1080=1420,696,384,14
[彩虹六号：围攻]
exe=RainbowSix.exe
inputKey=y
sendMethod=2
1920x1080=1382,778,288,14
[彩虹六号：围攻-DX11]
exe=RainbowSix_DX11.exe
inputKey=y
sendMethod=2
1920x1080=1382,778,288,14
[无人深空]
exe=NMS.exe
inputKey=Enter
sendMethod=1
[无人深空-适用非聊天场景]
exe=NMS.exe
inputKey=Enter
sendMethod=1
notChatMode=1
[星露谷物语]
exe=Stardew Valley.exe
inputKey=t
sendMethod=1
[绝地潜兵2]
title=HELLDIVERS™ 2
inputKey=Enter
sendMethod=2
[Deadlock(死锁)]
exe=project8.exe
inputKey=Enter
sendMethod=1
[命运2]
exe=destiny2.exe
inputKey=Enter
sendMethod=1
)", profileName, "UTF-16"
	return [
"幽灵行动：荒野",
"幽灵行动：断点",
"幽灵行动：断点-vulkan",
"彩虹六号：围攻",
"彩虹六号：围攻-DX11",
"无人深空",
"无人深空-适用非聊天场景",
"星露谷物语",
"绝地潜兵2",
"Deadlock(死锁)",
"命运2"
]
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
正式版v3（2025/02/21）:
优化了添加新的游戏支持、手动发送的窗口体验。
增加窗口标题匹配，来适配无法通过运行程序定位窗口的游戏。
增加以Unicode字符编码的发送文本方式
增加“游玩时禁用中文输入法”的功能。
增加“非聊天模式”的功能，仅输入文本，不模拟其余按键操作。
调整聊天框后的位置及大小，与游戏分辨率绑定保存相对坐标。
集成更多游戏支持：星露谷物语、绝地潜兵2、死锁、命运2。
)", "关于"
}