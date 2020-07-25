# Sky3DSPlusNav
	By Mcgrog [2020]

Quick Powershell Script for Navigating Sky3DS+ Library with simple outgrid view displaying rom details that allows marking your current rom and calculating the sortest path to a rom of your choosing via left and right buttons on your sky3ds+
(Windows 10 will work, it may run on older versions of windows, i dont have anything with a wmf <5.1 anymore to test it on)

#File 0)	00_EXECUTE_Sky3ds+RomNavigator.lnk
 - Runs File 1 from explorer via double click.

#File 1)	01_Sky3ds+RomNavigator.ps1
 - On first run or any time a data refresh is required;from the console write R then press enter. (this bring up a menu selection of connected fat32 drives to scan for roms, upon selection the file 02_Games.xml is created, from here you can now remove your sd card and insert it into the sky3ds)
 - On subsequent runs just press enter from the console. (this reads from the generated 02_Games.xml data file and displayed your library including per rom info and config.cfg information from the time of generation)
 
 - The Navigation Screen:
	This out grid view displays rom information discovered on last scan, you can navigate this with arrow keys, mouse, search bar, filters etc.
	To calculate button presses required to navigate directly to the rom of your choice on your sky3ds:
		1. Select the rom that is displayed on your 3DS.
		2. Click Ok or Press Enter.
			(selecting multiple will just result in the first rom being selected)
		3. Select the rom you wish to navigate to from the roms that arent your first selection.
		4. Click Ok or Press Enter.
			(selecting multiple will just result in the first rom being selected)
	
	Shortest path will then be calculated using loopback logic and directions displayed in the console window.

	Example:
		If you have 50 roms, and you want to get from position 45 to position 5,
		the shortest path is by continuing right past 50 by ten clicks as opposed to pressing left 40 times,
		so the script will now display the amount of times pressing the right button can be done quickly without having to wait to for the sky3ds to load up all the roms inbetween.

 - Q then Enter to Quit from the console screen

#File 2)	02_Games.xml
 - Generated whenever the sd card library is scanned.
 - File is called after a library scan or on first launch if no game data exists in memory.

Files can all be kept safely on your sky3ds+ sd card if you travel around and want to bring the navigator with you,
Downside to this is needing to stick the sd card into a computer to launch the Navigator again so storing these files on a pc may prove more convenient,
While the app is kept open from the first hit of enter everything is then stored in memory and sd card is no longer required,
Data wont refresh from the card again unless you tell it to refresh with the R command.
Data wont refresh from 02_Games.xml again after first Enter unless you tell it to refresh with the R command.
