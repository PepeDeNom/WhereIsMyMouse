# WhereIsMyMouse
This portable utility makes it easy to find the mouse pointer on the screen by displaying a spotlight that drives your eyes to where the mouse pointer is.
It's inspired in [Find My Mouse](https://docs.microsoft.com/es-es/windows/powertoys/mouse-utilities) utility from [Microsoft Powertoys](https://github.com/microsoft/PowerToys).

![Animation](https://user-images.githubusercontent.com/94808889/175427355-0adaa216-42d4-4515-b9fa-9d42213788d4.gif)

## Table of contents
* [General info](#general-info)
* [Install](#install)
* [How to use?](#how-to-use)
* [Technology](#technology)
* [Antivirus blocking Autohotkey language](#antivirus-blocking-autohotkey-language)
* [Acknowledgments](#acknowledgments)

## General info
Nowadays monitors have increased considerably in size and resolution, and it's also very common to work with more than one monitor. These situations make it sometimes difficult to find the mouse pointer on the screen. To solve it we can use:
* The windows integrated utility that draw circles around the pointer when pressing control key. It can be found under *Settings>Devices>Mouse>Additional mouse options>Pointer options>Check: show location when CTRL is pressed.* In my opinion this is not the best visual solution, but of course, it is integrated into all windows systems. 
* The great [Find My Mouse](https://docs.microsoft.com/es-es/windows/powertoys/mouse-utilities) utility included in [Microsoft Powertoys](https://github.com/microsoft/PowerToys). But unfortunately this utility isn't portable so it can't be used on computers where you don't have administration privileges.

For these reasons, I've developed my own portable version of *Find My Mouse*.

## Install
It's portable, doesn't need installation. Put the executable *WhereIsMyMouse.exe* in the location of your choice.

## How to use?
To activate the spotlight to locate the mouse pointer:
* Left control double key press

To deactivate the spotlight:
* One press of the left control key
* One click with left mouse button
* Escape key
* Wait a few seconds without moving the mouse

## Technology
This utility is entirely written in Autohotkey v1.1, which is a widely used opensource programming language which allows to write very cool utilities easily.

If you are a programmer and you didn't know Autohotkey, give it try:
* Autohotkey official website: [www.autohotkey.com](https://www.autohotkey.com/)
* Autohotkey source code: [github.com/Lexikos/AutoHotkey_L](https://github.com/Lexikos/AutoHotkey_L/)

## Antivirus blocking Autohotkey language
Some antivirus give false positives with Autohotkey language, with which this utility has been programmed. If you find yourself in this situation:
* You can check that the file is virus-free with the vast majority of major antiviruses at the 's multiantivirus analyser [www.virustotal.com](https://www.virustotal.com/)
* If you have programming skills, you can take a look to the source code and compile it yourself (you have to download and install Autohotkey from [www.autohotkey.com](https://www.autohotkey.com/) and compile it with "Convert .ahk to .exe" utility)

Sadly, this is a common situation that happens with some antivirus that use an ultra-aggressive approach that generate false-positives. You can read this article from Nirsoft: [Antivirus companies cause a big headache to small developers](http://blog.nirsoft.net/2009/05/17/antivirus-companies-cause-a-big-headache-to-small-developers/).

To solve this problem and if you have enough privileges on the computer, you can register an exception for *WhereIsMyMouse.exe* in the antivirus configuration.

## Acknowledgments
Thanks to the powertoys development team for the great tools they provide.
- Source: https://github.com/microsoft/PowerToys

Thanks to tic (Tariq Porter) for his GDI+ Library.
- Author: Tariq Porter
- Source: https://www.autohotkey.com/boards/viewtopic.php?t=6517

Thanks to Maxim Basinski for his magnifying glass icon.
- Author: Maxim Basinski
- License: CC Atribution
- Source: https://icon-icons.com/es/icono/lupa-b%C3%BAsqueda-magnifing-gafas/78347

And above all, thanks to the entire autohotkey community.
- https://www.autohotkey.com/boards/
