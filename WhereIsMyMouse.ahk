;====================================================================================================
; __          ___                     _____       __  __         __  __
; \ \        / / |                   |_   _|     |  \/  |       |  \/  |
;  \ \  /\  / /| |__   ___ _ __ ___    | |  ___  | \  / |_   _  | \  / | ___  _   _ ___  ___
;   \ \/  \/ / | '_ \ / _ \ '__/ _ \   | | / __| | |\/| | | | | | |\/| |/ _ \| | | / __|/ _ \
;    \  /\  /  | | | |  __/ | |  __/  _| |_\__ \ | |  | | |_| | | |  | | (_) | |_| \__ \  __/
;     \/  \/   |_|_|_|\___|_|  \___| |_____|___/ |_|  |_|\__, | |_|  |_|\___/ \__,_|___/\___|
;                                                         __/ |
;                                                        |___/
;                       _             _ _ _                _____       _   _
;                      | |           |  __ \              |  __ \     | \ | |
;                      | |__  _   _  | |__) |__ _ __   ___| |  | | ___|  \| | ___  _ __ ___
;                      | '_ \| | | | |  ___/ _ \ '_ \ / _ \ |  | |/ _ \ . ` |/ _ \| '_ ` _ \
;                      | |_) | |_| | | |  |  __/ |_) |  __/ |__| |  __/ |\  | (_) | | | | | |
;                      |_.__/ \__, | |_|   \___| .__/ \___|_____/ \___|_| \_|\___/|_| |_| |_|
;                              __/ |           | |
;                             |___/            |_|
;
; 
;====================================================================================================
;
; DESCRIPTION:
;   This portable utility makes it easy to find the mouse pointer on the screen by
;   displaying an animation that drives your eyes to where the mouse pointer is.
;   It's inpired in Find My Mouse utility from MS Powertoys.
;
; YEAR:
;   2021
;
; AUTHOR:
;  PepeDeNom (https://github.com/PepeDeNom)
;
;====================================================================================================



;=================================================================================================
; Autoexec section
;=================================================================================================

#SingleInstance, force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn all,outputdebug 
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#persistent
#include include\gdip.ahk ;download gdip.ahk at http://www.autohotkey.net/~tic/Gdip.ahk save it in the same directory as this script as gdip.ahk
coordmode,mouse,screen
Process, Priority,, High
;@Ahk2Exe-SetMainIcon .\images\WhereIsMyMouse.ico							;Compiler directive

;On exit, call the exit function to close Gdip
OnExit("ExitFunc")

;-------------------------------------------------------------------------
;Global variables
; - gObm, gHbm, gHdc, gGraphics, gGdip_pToken, gPBrush, gPBrush2 			;GDI+ variables
; - gHwndGuiBackground, gHwndGuiSpotlight 									;Gui windows handle
; - gnSpotlightDiameter, gnZoomFactor, gsAlternativeHotkey					;Spotlight characteristics

;-------------------------------------------------------------------------
;Config file (Appdata\Roaming\WhereIsMyMouse\config.ini)
WorkingDir := A_AppData "\WhereIsMyMouse"
if !FileExist(WorkingDir)
	FileCreateDir, %WorkingDir%

SetWorkingDir %WorkingDir%

if ( !FileExist("images") )
    FileCreateDir, images

FileInstall, images\WhereIsMyMouse.ico, % A_WorkingDir . "\images\WhereIsMyMouse.ico"

FileConfig := WorkingDir "\Config.ini"
ReadConfig(FileConfig)

;-------------------------------------------------------------------------
;Create graphic environment
CreateGuis()
InitializeGdip()








;=================================================================================================
; Hotkeys
;=================================================================================================

;-------------------------------------------------------------------------
;Activate the spotlight: Double click with the Left Control key
;
Hotkey, ~LControl, LControlDoubleClickControl, On ;initial state: on (activated)

;-------------------------------------------------------------------------
;Double click LCONTROL hotkey detection function
;
LControlDoubleClickControl() {
	if (A_PriorHotkey != "~LControl" or A_TimeSincePriorHotkey > 200) {
		;Too much time between presses, so this isn't a double-press.
		KeyWait, LControl ;Wait until LControl key is released
		return
	}
	;It's a double click LCONTROL --> Show spotlight
	ShowSpotlight()
}


;-------------------------------------------------------------------------
;Alternative key combination to activate the spotlight: This one is 
;going to be used by an external aplication in order to send a command to 
;this script.
;In my case, the thumb button of the mouse will send this hotkey configured
;in Logitech Options, becouse it's a hardcoded key that can't be catch
;by AHK. For example, as alternative hotkey I use win+u (#u). This combination
;have to be configured in config file: %appdata%\WhereIsMyMouse\config.ini 
;in label AlternativeHotkey
if (gsAlternativeHotkey)
	Hotkey, %gsAlternativeHotkey%, ShowSpotlight, On

;-------------------------------------------------------------------------
;Hotkeys to deactivate spotlight:
;	- Left Control click (only one LCONTROL click needed to turn off the spotlight)
;	- Left mouse button click
;	- ESC key
;
;This hotkeys will be activated inside the ShowSpotlight function.










;=================================================================================================
; Tray menú
;=================================================================================================
Menu, Tray, Icon, %A_WorkingDir%\images\WhereIsMyMouse.ico
Menu, Tray, NoStandard
Menu, Tray, Add, Preferences, MenuPrefs
Menu, Tray, Add
Menu, Tray, Add, Suspend/Resume, MenuSuspend
Menu, Tray, Add
Menu, Tray, Add, Exit, MenuExit
Return

MenuSuspend() {
	Suspend	
}

MenuExit() {
	ExitApp
}

MenuPrefs() {
	global 
	Gui, Font, s10 bold
	Gui, Add, Text,x20 y20, Circle diameter:
	Gui, Font, s10 norm
	Gui, Add, Slider, x10 y40 w400 vnDiameterSlider Range100-300 TickInterval10 ToolTip, %gnSpotlightDiameter%
	Gui, Add, Text,x20 y80, Small
	Gui, Add, Text,x193 y80, Medium
	Gui, Add, Text,x360 y80, Large
	Gui, Font, s08 italic
	Gui, Add, Text,x20 y110, (Recommended value: 200)

	Gui, Add, Text, x5 y160 w400 0x10

	Gui, Font, s10 norm
	Gui, Font, s10 bold
	Gui, Add, Text,x20 y180, Animation zoom factor
	Gui, Font, s10 norm
	Gui, Add, Slider, x10 y200 w400 vnZoomSlider Range1-20 TickInterval1 ToolTip, %gnZoomFactor%
	Gui, Add, Text,x20 y240, Short animation
	Gui, Add, Text,x193 y240, 
	Gui, Add, Text,x304 y240, Long animation
	Gui, Font, s08 italic
	Gui, Add, Text,x20 y270, (Recommended value: 5)

	Gui, Add, Text, x5 y300 w400 0x10
	
	Gui, Font, s10 norm
	Gui, Font, s10 bold
	Gui, Add, Text,x20 y320 , Windows startup
	Gui, Font, s10 norm
	Gui, Add, CheckBox, %  "x20 y350" . (RunAtStartup_Get() ? " Checked" : "") . " vrunAtStartupCheckbox", Run at windows startup?

	Gui, Font, s10 norm
	Gui, Add, Button, x130 y400 Default w80 gMenuPrefs_Ok, Ok
	Gui, Add, Button, x210 y400 w80 gMenuPrefs_Cancel, Cancel
	Gui, Show,h440, WhereIsMyMouse config
}

MenuPrefs_OK() {
	Global
	Gui,Submit
	IniWrite, %nDiameterSlider%, %FileConfig%, GENERAL, SpotlightDiameter
	IniWrite, %nZoomSlider%, %FileConfig%, GENERAL, ZoomFactor
	gnSpotlightDiameter := nDiameterSlider
	nSpotlightRadius := round(gnSpotlightDiameter /2)
	gnZoomFactor := nZoomSlider

	if (RunAtStartup_Get() != runAtStartupCheckbox)
		RunAtStartup_Set(runAtStartupCheckbox)

	Gui, Destroy

	;Regenerate graphics environment with the new dimensions
	ShutdownGdip()
	InitializeGdip()
}

MenuPrefs_Cancel(){
	Gui, Destroy
}










;=================================================================================================
; Spotlight control
;=================================================================================================

;-------------------------------------------------------------------------
; Display a dark translucent background and the light of a spotlight that
; follows the mouse movement to help locate it on the screen.
;
ShowSpotlight() {
	global gHwndGuiBackground, gHwndGuiSpotlight 							;Gui windows handle
	global gGraphics, gPBrush, gPBrush2										;Pointer to the graphics of the bitmap
	global gnSpotlightDiameter, gnZoomFactor, gsAlternativeHotkey			;Spotlight characteristics

	WinGet, sProceso, ProcessName, A
	if (sProceso <> "mstsc.exe") { 											;Not working with windows remote desktop

		FollowMouseControl(False)											;If there is a previous spotlight following the mouse, deactivate it.

		Hotkey, ~LControl, LControlDoubleClickControl, Off					;Disable LControl double click
		if (gsAlternativeHotkey)
			Hotkey, %gsAlternativeHotkey%, HideSpotlight, On 				;Change the alternative hotkey to hide the spotlight
		Hotkey, ~LBUTTON, HideSpotlight, On									;Enable stop spotlight hotkey -> mouse left button
		Hotkey, ~LControl, HideSpotlight, On								;Enable stop spotlight hotkey -> left control key
		Hotkey, ESC, HideSpotlight, On										;Enable stop spotlight hotkey -> Esc key

		WinGetPos, nDesktop_X, nDesktop_Y, Desktop_W, Desktop_H, Program Manager ;Desktop dimensions
		
		Gui, %gHwndGuiBackground%:show, x%nDesktop_X% y%nDesktop_Y% w%Desktop_W% h%Desktop_H% NA	;Show gui (black transparent background gui and spotlight gui)
		WinSet, Transparent, 150, ahk_id %gHwndGuiBackground% 				;Transparency for the background so you can see all windows
		Gui,%gHwndGuiSpotlight%: show, NA 									;Show spotlight gui above the backgroud gui

		Gdip_SetCompositingMode(gGraphics, 1)								;CompositingMode=1 --> overwrite drawings 
		Gdip_SetSmoothingMode(gGraphics, 1) 								;SmoothingMode=1 --> HighSpeed

		nDiameter := gnSpotlightDiameter * gnZoomFactor 						;Starting diameter
		nCoef := 1.15 														;Circle decrease coefficient (15% per loop iteration)
		loop {
			DrawCircle(nDiameter)
			sleep 10														;Wait 10ms to draw next frame of the animation
			nDiameter := round(nDiameter/nCoef)								;Decrease the circle diameter for next iteration
		} Until nDiameter < gnSpotlightDiameter

		DrawCircle(gnSpotlightDiameter)										;Draw last circle with the preconfigured diameter
		FollowMouseControl(True)											;Spotlight follows mouse movements for easy location
	}
}


;-------------------------------------------------------------------------
; Hide the Spotlight: Draw a "closing" animation with the spotlight,
; erase and hide guis and stop the hotkeys that launch this function.
;
HideSpotlight() {
	global gHwndGuiBackground, gHwndGuiSpotlight 							;Gui windows handle
	global gGraphics, gPBrush, gPBrush2										;Pointer to the graphics of the bitmap
	global gnSpotlightDiameter, gnZoomFactor, gsAlternativeHotkey			;Spotlight characteristics
	
	FollowMouseControl(false)												;Stop following the mouse

	Hotkey, ~LBUTTON, HideSpotlight, Off									;Stop spotlight hotkeys
	Hotkey, ~LControl, HideSpotlight, Off
	Hotkey, ESC, HideSpotlight, Off

	nDiameter := gnSpotlightDiameter 										;Actual diameter
	nCoef := 1.15 															;Circle decrease coefficient (15% per loop iteration)

	while (nDiameter < gnSpotlightDiameter*gnZoomFactor/2) {
		nDiameter := nDiameter * nCoef										;Increase the circle diameter
		DrawCircle(nDiameter, 50) ;Transparency=50: the more transparent the circle, the darker the user's view (because of the dark background gui)
		sleep 5 															;Wait to draw next frame of the animation
	}
	
	Gdip_GraphicsClear(gGraphics) 											;Erase circle
	Gui, %gHwndGuiSpotlight%: hide											;Hide spotlight gui
	Gui, %gHwndGuiBackground%: hide											;Hide background gui
	
	Hotkey, ~LControl, LControlDoubleClickControl, On						;Activate LControl double click control to be able to launch the spotlight another time
	if (gsAlternativeHotkey)
		Hotkey, %gsAlternativeHotkey%, ShowSpotlight, On					;Activate alternative hotkey to show the spotlight
}


;-------------------------------------------------------------------------
; Draw a circle around the mouse position.
; 	- inDiameter: Diameter of the circle
;	- inTransparecy (optional parameter): 
;
DrawCircle(inDiameter, inTransparency := 255) {
	global gHwndGuiSpotlight 												;Gui window handle
	global gHdc, gGraphics, gPBrush 										;Device context, pointer to the bitmap and Pointer to the brush

	;Circle's position
	nRadius := round(inDiameter/2)
	mousegetpos, nMouse_X, nMouse_Y
	nCircle_X := round(nMouse_X - nRadius)
	nCircle_Y := round(nMouse_Y - nRadius)

	;Draw the circle
	Gdip_GraphicsClear(gGraphics)
	Gdip_FillEllipse(gGraphics,gPBrush,0,0,inDiameter,inDiameter) 			;Spotlight circle
	UpdateLayeredWindow(gHwndGuiSpotlight, gHdc, nCircle_X,nCircle_Y,inDiameter,inDiameter, inTransparency)
}









;=================================================================================================
; Follow mouse functions
;=================================================================================================

;-------------------------------------------------------------------------
; Enable or disable spotlight follow mouse.
; 	- ibState = true --> enable spotlight follow mouse
; 	- ibState = false --> disable spotlight follow mouse
;
FollowMouseControl(ibState) {
	global nPreviousMouse_X, nPreviousMouse_Y, nPreviousMouseMovementTick

	if (ibState) {
		;Initialize mouse movement control variables
		nPreviousMouse_X := 0
		nPreviousMouse_Y := 0
		nPreviousMouseMovementTick := ""
		SetTimer, FollowMouse, 10 											;Timmer to follow the mouse movement
	} else {
		SetTimer, FollowMouse, off 											;Cancel previous timer
	}
}

;-------------------------------------------------------------------------
; Function call by a timmer. It moves the layered window so the spotlight
; follows the mouse pointer
;
FollowMouse() {
	global gHwndGuiSpotlight 												;Gui window handle
	global gHdc  															;Device context
	global gnSpotlightDiameter, nSpotlightRadius						  	;Spotlight characteristics
	global nPreviousMouse_X, nPreviousMouse_Y, nPreviousMouseMovementTick 	;Control mouse movements between function calls

	mousegetpos, nMouse_X, nMouse_Y

	;If no movement in 3 seconds -> hide spotlight
	if (nMouse_X = nPreviousMouse_X and nMouse_Y = nPreviousMouse_Y) {
		
		if (A_TickCount - nPreviousMouseMovementTick > 3000)
			HideSpotlight()
		
	} else {
		;Save position and timestamp for next iteration
		nPreviousMouse_X := nMouse_X
		nPreviousMouse_Y := nMouse_Y
		nPreviousMouseMovementTick := A_TickCount

		;Update spotlight position acording to the new mouse position
		nCircle_X := nMouse_X - nSpotlightRadius
		nCircle_Y := nMouse_Y - nSpotlightRadius
		UpdateLayeredWindow(gHwndGuiSpotlight, gHdc, nCircle_X,nCircle_Y, gnSpotlightDiameter, gnSpotlightDiameter)
	}
}


;=================================================================================================
; Graphic environment
;=================================================================================================

;-------------------------------------------------------------------------
; Create two guis: One for the dark traslucent backgroud and another for
; the spotlight
;
CreateGuis() {
	global gHwndGuiBackground, gHwndGuiSpotlight
	static WS_EX_TRANSPARENT 	:= "E0x00000020" 							;Gui can be clicked through
	static WS_EX_LAYERED		:= "E0x00080000"							;Overlay window

	;Background gui
	Gui, New, -Caption +%WS_EX_TRANSPARENT% +alwaysontop +toolwindow +HwndgHwndGuiBackground 
	Gui, %gHwndGuiBackground%:Color, 0x000000 								;Black (we will apply transparency)

	;Spotlight gui
	Gui, New, -Caption +%WS_EX_TRANSPARENT% +%WS_EX_LAYERED% +alwaysontop +toolwindow  +HwndgHwndGuiSpotlight 
}

;-------------------------------------------------------------------------
; Initialize GDI+ environment and bitmap to draw
; 
InitializeGdip() {
	global

	If !gGdip_pToken := Gdip_Startup() {
		MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
		ExitApp
	}
	;Create a gdi bitmap with the width and height of the desktop, which we are going to draw on.
	gHbm := CreateDIBSection(gnSpotlightDiameter * gnZoomFactor, gnSpotlightDiameter * gnZoomFactor)
	gHdc := CreateCompatibleDC()
	gObm := SelectObject(gHdc, gHbm)
	gGraphics := Gdip_GraphicsFromHdc(gHdc)
	gPBrush := Gdip_BrushCreateSolid(0x90FFFFFF)
}

;-------------------------------------------------------------------------
; Shutdown GDI+
;
ShutdownGdip()
{
    global gPBrush, gPBrush2, gObm, gHbm, gHdc, gGraphics, gGdip_pToken 	;GDI+ variables

	Gdip_DeleteBrush(gPBrush)
	Gdip_DeleteBrush(gPBrush2)
	SelectObject(gHdc, gObm)
	DeleteObject(gHbm)
	DeleteDC(gHdc)
	Gdip_DeleteGraphics(gGraphics)
    Gdip_Shutdown(gGdip_pToken)
}



;=================================================================================================
; General functions
;=================================================================================================

;-------------------------------------------------------------------------
; Read config file and store values in global variables
;
ReadConfig(isFichero) {
	global gnSpotlightDiameter
	global nSpotlightRadius
	global gnZoomFactor
	global gsAlternativeHotkey
	
	if FileExist(isFichero) {
		IniRead, gnSpotlightDiameter, %isFichero%, GENERAL, SpotlightDiameter,  200
		IniRead, gnZoomFactor, %isFichero%, GENERAL, ZoomFactor, 5
		IniRead, gsAlternativeHotkey, %isFichero%, GENERAL, AlternativeHotkey, %A_Space%
	} else {
		;Default values
		gnSpotlightDiameter := 200
		gnZoomFactor := 5
		gsAlternativeHotkey := A_Space
		IniWrite, %gnSpotlightDiameter%, %isFichero%, GENERAL, SpotlightDiameter
		IniWrite, %gnZoomFactor%, %isFichero%, GENERAL, ZoomFactor
		IniWrite, %gsAlternativeHotkey%, %isFichero%, GENERAL, AlternativeHotkey
	}
	nSpotlightRadius := round(gnSpotlightDiameter /2)
}

;-------------------------------------------------------------------------
; Returns true if this utility has a link at windows startup folder.
; Otherwise returns false
;
RunAtStartup_Get() {
	SplitPath, A_ScriptFullPath, name, dir, ext, name_no_ext, drive
	linkFile := A_Startup . "\" . name_no_ext . ".lnk"
	if !FileExist(linkFile) {
		return false
	} else {
		FileGetShortcut, % linkFile, OutTarget
		return (OutTarget = A_ScriptFullPath ? true : false)        		;Returns true if linkFile target is this script
	}
}

;-------------------------------------------------------------------------
; Creates or deletes the link in windows startup folder
;
RunAtStartup_Set(value) {
	SplitPath, A_ScriptFullPath, name, dir, ext, name_no_ext, drive
	linkFile := A_Startup . "\" . name_no_ext . ".lnk"
	
	if (value) {
		if FileExist(linkFile)
			FileDelete, %linkFile%

		FileCreateShortcut, % A_ScriptFullPath, % linkFile, % dir
		
	} else {
		FileDelete, % linkFile
	}
	
	return !ErrorLevel
}


;-------------------------------------------------------------------------
; On exit
;
ExitFunc(ExitReason, ExitCode){
	ShutdownGdip()
}