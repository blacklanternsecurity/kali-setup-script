#!/bin/bash

# skip prompts in apt-upgrade, etc.
export DEBIAN_FRONTEND=noninteractive

printf '\n============================================================\n'
printf '[+] Disabling Auto-lock, Sleep on AC\n'
printf '============================================================\n\n'
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'


printf '\n============================================================\n'
printf '[+] Removing the abomination that is gnome-software\n'
printf '============================================================\n\n'
killall gnome-software
while true
do
	pgrep gnome-software &>/dev/null || break
	sleep .5
done
apt-get -y remove gnome-software


printf '\n============================================================\n'
printf '[+] Setting Wallpaper\n'
printf '============================================================\n\n'
wallpaper_file="$(find . -name bls_wallpaper.png)"
if [[ -z "$wallpaper_file" ]]
then
	wget https://raw.githubusercontent.com/blacklanternsecurity/kali-setup-script/master/bls_wallpaper.png
	wallpaper_file="$(find . -name bls_wallpaper.png)"
fi
mkdir -p '/usr/share/wallpapers/wallpapers/' &>/dev/null
cp "$wallpaper_file" '/usr/share/wallpapers/wallpapers/'
echo 
gsettings set org.gnome.desktop.background primary-color "#000000"
gsettings set org.gnome.desktop.background secondary-color "#000000"
gsettings set org.gnome.desktop.background color-shading-type "solid"
gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/wallpapers/wallpapers/bls_wallpaper.png"
gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/wallpapers/wallpapers/bls_wallpaper.png"
gsettings set org.gnome.desktop.background picture-options scaled


printf '\n============================================================\n'
printf '[+] Installing:\n'
printf '     - wireless drivers\n'
printf '     - golang\n'
printf '     - gnome-screenshot\n'
printf '     - terminator\n'
printf '     - pip\n'
printf '     - patator\n'
printf '     - zmap\n'
printf '============================================================\n\n'
apt-get -y install \
	realtek-rtl88xxau-dkms \
	golang \
	gnome-screenshot \
	terminator \
	python-pip \
	python3-dev \
	python3-pip \
	patator \
	zmap


printf '\n============================================================\n'
printf '[+] Updating System\n'
printf '============================================================\n\n'
apt-get -y update
apt-get -y upgrade


printf '\n============================================================\n'
printf '[+] Installing Firefox\n'
printf '============================================================\n\n'
if [[ ! -f /usr/share/applications/firefox.desktop ]]
then
	wget -O /tmp/firefox.tar.bz2 'https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US'
	cd /opt
	tar -xvjf /tmp/firefox.tar.bz2
	if [[ -f /usr/bin/firefox ]]; then mv /usr/bin/firefox /usr/bin/firefox.bak; fi
	ln -s /opt/firefox/firefox /usr/bin/firefox
	rm /tmp/firefox.tar.bz2

	cat <<EOF > /usr/share/applications/firefox.desktop
[Desktop Entry]
Name=Firefox
Comment=Browse the World Wide Web
GenericName=Web Browser
X-GNOME-FullName=Firefox Web Browser
Exec=/opt/firefox/firefox %u
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=firefox-esr
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
StartupWMClass=Firefox-esr
StartupNotify=true
EOF
fi


printf '\n============================================================\n'
printf '[+] Installing Chromium\n'
printf '============================================================\n\n'
apt-get install -y chromium
sed -i 's#Exec=/usr/bin/chromium %U#Exec=/usr/bin/chromium --no-sandbox %U#g' /usr/share/applications/chromium.desktop


printf '\n============================================================\n'
printf '[+] Installing CrackMapExec\n'
printf '============================================================\n\n'
rm -r $(ls /root/.local/share/virtualenvs | grep CrackMapExec | head -n 1)
rm -r /opt/CrackMapExec
apt-get install -y libssl-dev libffi-dev python-dev build-essential
pip install pipenv
cd /opt
git clone --recursive https://github.com/byt3bl33d3r/CrackMapExec
cd CrackMapExec && pipenv install
python2 -m pipenv run python setup.py install
#ln -s ~/.local/share/virtualenvs/$(ls /root/.local/share/virtualenvs | grep CrackMapExec | head -n 1)/bin/cme /usr/bin/cme
#ln -s ~/.local/share/virtualenvs/$(ls /root/.local/share/virtualenvs | grep CrackMapExec | head -n 1)/bin/cmedb /usr/bin/cmedb
ln -s ~/.local/share/virtualenvs/$(ls /root/.local/share/virtualenvs | grep CrackMapExec | head -n 1)/bin ~/Downloads/crackmapexec_bleeding_edge
cd / && rm -r /opt/CrackMapExec
apt-get -y install crackmapexec


printf '\n============================================================\n'
printf '[+] Installing Impacket\n'
printf '============================================================\n\n'
rm -r $(ls /root/.local/share/virtualenvs | grep impacket | head -n 1)
rm -r /opt/impacket
cd /opt
git clone https://github.com/CoreSecurity/impacket.git
cd impacket && pipenv install
python2 -m pipenv run python setup.py install
#ln -s ~/.local/share/virtualenvs/$(ls /root/.local/share/virtualenvs | grep impacket | head -n 1)/bin/*.py /usr/bin/
ln -s ~/.local/share/virtualenvs/$(ls /root/.local/share/virtualenvs | grep impacket | head -n 1)/bin ~/Downloads/impacket_bleeding_edge
cd / && rm -r /opt/impacket


printf '\n============================================================\n'
printf '[+] Installing Sublime Text\n'
printf '============================================================\n\n'
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
apt-get -y install apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" > /etc/apt/sources.list.d/sublime-text.list
apt-get -y update
apt-get -y install sublime-text


printf '\n============================================================\n'
printf '[+] Enabling bash session logging\n'
printf '============================================================\n\n'
grep -q 'UNDER_SCRIPT' ~/.bashrc || echo 'if [ -z "$UNDER_SCRIPT" ]; then
        logdir=$HOME/Logs
        if [ ! -d $logdir ]; then
                mkdir $logdir
        fi
        gzip -q $logdir/*.log &>/dev/null
        logfile=$logdir/$(date +%F_%T).$$.log
        export UNDER_SCRIPT=$logfile
        script -f -q $logfile
        exit
fi' >> ~/.bashrc


printf '\n============================================================\n'
printf '[+] Disabling Animations\n'
printf '============================================================\n\n'
gsettings set org.gnome.desktop.interface enable-animations false


printf '\n============================================================\n'
printf '[+] Enabling Tap-to-click\n'
printf '============================================================\n\n'
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true


printf '\n============================================================\n'
printf '[+] Initializing Metasploit Database\n'
printf '============================================================\n\n'
msfdb init


printf '\n============================================================\n'
printf '[+] Disabling grub quiet mode\n'
printf '============================================================\n\n'
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT=""/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg


printf '\n============================================================\n'
printf '[+] Unzipping RockYou\n'
printf '============================================================\n\n'
gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null
ln -s /usr/share/wordlists ~/Downloads/wordlists 2>/dev/null


printf '\n============================================================\n'
printf '[+] Cleaning Up\n'
printf '============================================================\n\n'
apt-get -y autoremove
apt-get -y autoclean
updatedb
rmdir ~/Music ~/Public ~/Videos ~/Templates ~/Desktop &>/dev/null
gsettings set org.gnome.shell favorite-apps "['firefox.desktop', 'org.gnome.Terminal.desktop', 'terminator.desktop', 'org.gnome.Nautilus.desktop', 'sublime_text.desktop']"


printf '\n============================================================\n'
printf '[+] Done.\n'
printf "[+] Don't forget to manually install:\n"
printf '     - BurpSuite Pro\n'
printf '     - Firefox Add-Ons\n'
printf '============================================================\n\n'