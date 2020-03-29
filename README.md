# Kali Setup Script

Prepares Kali for a pentest by enabling session logging, installing tools, and making common configuration changes

<img alt="Gnome" src="https://i.imgur.com/pXh7AUu.png" width=500>
<img alt="i3 + Gnome" src="https://i.imgur.com/DEEJhvO.png" width=400>

## NOTE: THIS SCRIPT ASSUMES YOU ARE RUNNING AS ROOT (LIKE IN THE OLD DAYS)
## NON-ROOT USERS ARE NOT SUPPORTED

## One-liner:
(don't forget to reboot after the script finishes :)
~~~
curl -k -s https://raw.githubusercontent.com/blacklanternsecurity/kali-setup-script/master/kali-setup-script.sh | bash
~~~

## Full feature list:

1. Enables details logging of terminal sessions
	- Including ALL OUTPUT (saved to ~/Logs)
1. Installs the following:
	1. CrackMapExec (from GitHub)
	1. Impacket (from GitHub)
	1. Bloodhound (from GitHub)
	1. EAPhammer (from GitHub)
	1. patator (network brute-force tool)
	1. PCredz
	1. Gowitness
	1. EavesARP
	1. bettercap
	1. docker
	1. Firefox (official non-ESR version)
	1. Chromium
	1. Sublime Text
	1. BoostNote
	1. golang (plus environment)
	1. zmap
	1. LibreOffice
	1. htop
	1. Remmina
	1. gnome-screenshot
	1. realtek-rtl88xxau-dkms (ALFA wireless drivers)
	1. i3 + XFCE desktop environment (optional)
1. Updates system
1. Removes gnome-software
1. Disables auto-lock
1. Enables tap-to-click
1. Initializes Metasploit database
1. Installs rad BLS wallpaper