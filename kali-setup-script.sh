#!/bin/bash

# skip prompts in apt-upgrade, etc.
export DEBIAN_FRONTEND=noninteractive

printf '\n============================================================\n'
printf '[+] Disabling Auto-lock, Sleep on AC\n'
printf '============================================================\n\n'
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
# disable menus in gnome terminal
gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar false
# disable "close terminal?" prompt
gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false


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
printf '[+] Setting Theme\n'
printf '============================================================\n\n'
# dark theme
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
mkdir -p '/usr/share/wallpapers/wallpapers/' &>/dev/null
wallpaper_file="$(find . -type f -name bls_wallpaper.png)"
if [[ -z "$wallpaper_file" ]]
then
    wget -P '/usr/share/wallpapers/wallpapers/' https://raw.githubusercontent.com/blacklanternsecurity/kali-setup-script/master/bls_wallpaper.png
else
    cp "$wallpaper_file" '/usr/share/wallpapers/wallpapers/bls_wallpaper.png'
fi
gsettings set org.gnome.desktop.background primary-color "#000000"
gsettings set org.gnome.desktop.background secondary-color "#000000"
gsettings set org.gnome.desktop.background color-shading-type "solid"
gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/wallpapers/wallpapers/bls_wallpaper.png"
gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/wallpapers/wallpapers/bls_wallpaper.png"
gsettings set org.gnome.desktop.background picture-options scaled


printf '\n============================================================\n'
printf '[+] Installing i3\n'
printf '============================================================\n\n'
# install dependencies
apt-get -y install i3 j4-dmenu-desktop gnome-flashback fonts-hack feh
cd /opt
git clone https://github.com/csxr/i3-gnome
cd i3-gnome
make install
# make startup script
echo '#!/bin/bash
# xrandr --output eDP-1 --mode 1920x1080
feh --bg-scale /usr/share/wallpapers/wallpapers/bls_wallpaper.png
' > /root/.config/i3_startup.sh

# set up config
grep '### KALI SETUP SCRIPT ###' /etc/i3/config.keycodes || echo '
### KALI SETUP SCRIPT ###
# gnome settings daemon
exec --no-startup-id /usr/lib/gnome-settings-daemon/gsd-xsettings
# gnome power manager
exec_always --no-startup-id gnome-power-manager
# polkit-gnome
exec --no-startup-id /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
# gnome flashback
exec --no-startup-id gnome-flashback
# resolution / wallpaper
exec_always --no-startup-id bash "/root/.config/i3_startup.sh"

# BLS theme
# class             border  background  text        indicator   child_border
client.focused      #444444 #444444     #FFFFFF     #FFFFFF     #444444
' >> /etc/i3/config.keycodes

# gnome terminal
sed -i 's/^bindcode $mod+36 exec.*/bindcode $mod+36 exec gnome-terminal/' /etc/i3/config.keycodes
# improved dmenu
sed -i 's/.*bindcode $mod+40 exec.*/bindcode $mod+40 exec --no-startup-id j4-dmenu-desktop/g' /etc/i3/config.keycodes
# mod+shift+e logs out of gnome
sed -i 's/.*bindcode $mod+Shift+26 exec.*/bindcode $mod+Shift+26 exec gnome-session-quit/g' /etc/i3/config.keycodes
# hack font
sed -i 's/^font pango:.*/font pango:hack 11/' /etc/i3/config.keycodes
# focus child
sed -i 's/bindcode $mod+39 layout stacking/#bindcode $mod+39 layout stacking/g' /etc/i3/config.keycodes
sed -i 's/.*bindsym $mod+d focus child.*/bindcode $mod+39 focus child/g' /etc/i3/config.keycodes
# win+L lock screen
sed -i '/set $mod Mod1/a\set $sup Mod4\nbindcode $sup+l exec i3lock -i /usr/share/wallpapers/wallpapers/bls_wallpaper.png' /etc/i3/config.keycodes


printf '\n============================================================\n'
printf '[+] Installing:\n'
printf '     - wireless drivers\n'
printf '     - golang & environment\n'
printf '     - docker\n'
printf '     - gnome-screenshot\n'
printf '     - terminator\n'
printf '     - pip & pipenv\n'
printf '     - patator\n'
printf '     - bettercap\n'
printf '     - vncsnapshot\n'
printf '     - zmap\n'
printf '     - LibreOffice\n'
printf '     - htop\n'
printf '     - NFS server\n'
printf '============================================================\n\n'
apt-get -y install \
    realtek-rtl88xxau-dkms \
    golang \
    docker.io \
    gnome-screenshot \
    terminator \
    python-pip \
    python3-dev \
    python3-pip \
    patator \
    bettercap \
    vncsnapshot \
    zmap \
    libreoffice \
    htop \
    nfs-kernel-server
python2 -m pip install pipenv
python3 -m pip install pipenv
mkdir -p /root/go
gopath_exp='export GOPATH="$HOME/.go"'
path_exp='export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"'
sed -i '/export GOPATH=.*/c\' ~/.profile
sed -i '/export PATH=.*GOPATH.*/c\' ~/.profile
echo $gopath_exp | tee -a "$HOME/.profile"
grep -q -F "$path_exp" "$HOME/.profile" || echo $path_exp | tee -a "$HOME/.profile"
. "$HOME/.profile"

# enable NFS server (without any shares)
systemctl enable nfs-server
systemctl start nfs-server
fgrep '1.1.1.1/255.255.255.255(rw,sync,all_squash,anongid=0,anonuid=0)' /etc/exports &>/dev/null || echo '#/root        1.1.1.1/255.255.255.255(rw,sync,all_squash,anongid=0,anonuid=0)' >> /etc/exports
exportfs -a

# example NetworkManager.conf line for blacklist interfaces
fgrep 'unmanaged-devices' &>/dev/null /etc/NetworkManager/NetworkManager.conf || echo -e '[keyfile]\nunmanaged-devices=mac:de:ad:be:ef:de:ad' >> /etc/NetworkManager/NetworkManager.conf


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
printf '[+] Installing Bloodhound\n'
printf '============================================================\n\n'
# uninstall old version
apt-get -y remove bloodhound
# download latest bloodhound release from github
release_url="https://github.com/$(curl -s https://github.com/BloodHoundAD/BloodHound/releases | egrep -o '/BloodHoundAD/BloodHound/releases/download/.{1,10}/BloodHound-linux-x64.zip' | head -n 1)"
cd /opt
wget "$release_url"
unzip -o 'BloodHound-linux-x64.zip'
rm 'BloodHound-linux-x64.zip'
ln -s '/opt/BloodHound-linux-x64/BloodHound' '/usr/local/bin/bloodhound'

apt-get -y install neo4j gconf-service gconf2-common libgconf-2-4
mkdir -p /usr/share/neo4j/logs /usr/share/neo4j/run
grep '^root   soft    nofile' /etc/security/limits.conf || echo 'root   soft    nofile  500000
root   hard    nofile  600000' >> /etc/security/limits.conf
grep 'NEO4J_ULIMIT_NOFILE=60000' /etc/default/neo4j 2>/dev/null || echo 'NEO4J_ULIMIT_NOFILE=60000' >> /etc/default/neo4j
grep 'fs.file-max' /etc/sysctl.conf 2>/dev/null || echo 'fs.file-max=500000' >> /etc/sysctl.conf
sysctl -p
# apt-get install -y bloodhound
neo4j start


printf '\n============================================================\n'
printf '[+] Installing CrackMapExec\n'
printf '============================================================\n\n'
rm -r $(ls /root/.local/share/virtualenvs | grep CrackMapExec | head -n 1) &>/dev/null
rm -r /opt/CrackMapExec &>/dev/null
apt-get install -y libssl-dev libffi-dev python-dev build-essential
pip install pipenv
cd /opt
git clone --recursive https://github.com/byt3bl33d3r/CrackMapExec
cd CrackMapExec && python2 -m pipenv install
python2 -m pipenv run python setup.py install
#ln -s ~/.local/share/virtualenvs/$(ls /root/.local/share/virtualenvs | grep CrackMapExec | head -n 1)/bin/cme /usr/bin/cme
#ln -s ~/.local/share/virtualenvs/$(ls /root/.local/share/virtualenvs | grep CrackMapExec | head -n 1)/bin/cmedb /usr/bin/cmedb
ln -s ~/.local/share/virtualenvs/$(ls /root/.local/share/virtualenvs | grep CrackMapExec | head -n 1)/bin ~/Downloads/crackmapexec_bleeding_edge
cd / && rm -r /opt/CrackMapExec
apt-get -y install crackmapexec


printf '\n============================================================\n'
printf '[+] Installing Impacket\n'
printf '============================================================\n\n'
rm -r $(ls /root/.local/share/virtualenvs | grep impacket | head -n 1) &>/dev/null
rm -r /opt/impacket &>/dev/null
cd /opt
git clone https://github.com/CoreSecurity/impacket.git
cd impacket && python2 -m pipenv install
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
printf '[+] Installing BoostNote\n'
printf '============================================================\n\n'
boost_deb_url="https://github.com$(curl -Ls https://github.com/BoostIO/boost-releases/releases/latest | egrep -o '/BoostIO/boost-releases/releases/download/.+.deb')"
cd ~/Downloads
wget -O boostnote.deb "$boost_deb_url"
apt-get -y install gconf2 gvfs-bin
dpkg -i boostnote.deb
rm boostnote.deb


printf '\n============================================================\n'
printf '[+] Enabling bash session logging\n'
printf '============================================================\n\n'
grep -q 'UNDER_SCRIPT' ~/.bashrc || echo 'if [ -z "$UNDER_SCRIPT" ]; then
        logdir=$HOME/Logs
        if [ ! -d $logdir ]; then
                mkdir $logdir
        fi
        #gzip -q $logdir/*.log &>/dev/null
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
systemctl start postgresql
systemctl enable postgresql
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
gsettings set org.gnome.shell favorite-apps "['firefox.desktop', 'org.gnome.Terminal.desktop', 'terminator.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Screenshot.desktop', 'sublime_text.desktop', 'boostnote.desktop']"


printf '\n============================================================\n'
printf '[+] Done.\n'
printf "[+] Don't forget to manually install:\n"
printf '     - BurpSuite Pro\n'
printf '     - Firefox Add-Ons\n'
printf '============================================================\n\n'