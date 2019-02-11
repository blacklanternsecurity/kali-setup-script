# kali-setup-script

Prepares Kali for a pentest by enabling session logging, installing tools, and making common configuration changes

<img src="https://i.imgur.com/pXh7AUu.png" width=500>

## One-liner:

~~~
curl -k -s https://raw.githubusercontent.com/blacklanternsecurity/kali-setup-script/master/kali-setup-script.sh | bash
~~~

## Full feature list:

1. Saves record of terminal sessions
	- Including ALL OUTPUT (saved to ~/Logs)
1. Installs the following:
	1. CrackMapExec (from GitHub)
	1. Impacket (from GitHub)
	1. patator (network brute-force tool)
	1. Firefox (official non-ESR version)
	1. Chromium
	1. Sublime Text
	1. golang
	1. gnome-screenshot
	1. realtek-rtl88xxau-dkms (ALFA wireless drivers)
1. Updates system
1. Removes gnome-software
1. Disables animations
1. Disables auto-lock
1. Enables tap-to-click
1. Initializes Metasploit database
1. Installs rad BLS wallpaper
1. Cleans up favorites menu