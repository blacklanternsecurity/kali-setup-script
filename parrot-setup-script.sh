#!/bin/bash

# make sure we're root
if [[ "$EUID" -ne 0 ]]
then
    printf "Please run as root\n"
    exit 1
fi

# skip prompts in apt-upgrade, etc.
export DEBIAN_FRONTEND=noninteractive

printf '\n============================================================\n'
printf '[+] Removing Parrot Updater\n'
printf '============================================================\n\n'
killall zenity
apt-get -y remove parrot-updater

printf '\n============================================================\n'
printf '[+] Disabling LL-MNR\n'
printf '============================================================\n\n'
echo '[Match]
name=*

[Network]
LLMNR=no' > /etc/systemd/network/90-disable-llmnr.network


printf '\n============================================================\n'
printf '[+] Setting Theme\n'
printf '============================================================\n\n'

mkdir -p '/usr/share/wallpapers/wallpapers/' &>/dev/null
wallpaper_file="$(find . -type f -name bls_wallpaper.png)"
if [[ -z "$wallpaper_file" ]]
then
    wget -P '/usr/share/wallpapers/wallpapers/' https://raw.githubusercontent.com/blacklanternsecurity/kali-setup-script/master/bls_wallpaper.png
else
    cp "$wallpaper_file" '/usr/share/wallpapers/wallpapers/bls_wallpaper.png'
fi

# set desktop background
dconf load /org/mate/desktop/background/ <<EOF
[/]
color-shading-type='solid'
picture-filename='/usr/share/wallpapers/wallpapers/bls_wallpaper.png'
picture-options='scaled'
primary-color='rgb(0,0,0)'
secondary-color='rgb(44,0,30)'
EOF

# set terminal prompt
#NEWPS1='PS1="\[\033[0;31m\]\342\224\214\342\224\200[$(if [[ ${EUID} == 0 ]]; then echo '"'"'\[\033[01;31m\]root\[\033[01;33m\]@\[\033[01;96m\]\h'"'"'; else echo '"'"'\[\033[0;39m\]\u\[\033[01;33m\]@\[\033[01;96m\]\h'"'"'; fi)\[\033[0;31m\]]\342\224\200[\[\033[0;32m\]\w\[\033[0;31m\]]\n\[\033[0;31m\]\342\224\224\342\224\200\342\224\200\342\225\274\[\033[0m\]\[\e[01;33m\]\\$\[\e[0m\] "'
#for homedir in $(grep -v '/nologin$\|/false$' /etc/passwd | cut -d: -f6 | grep -v '^/$' | grep '^/root\|^/home')
#do
#    sed -i '/^PS1=.*/c\' "$homedir/.bashrc"
#    echo -n "${NEWPS1}" >> "$homedir/.bashrc"
#done


printf '\n============================================================\n'
printf '[+] Installing:\n'
printf '     - wireless drivers\n'
printf '     - golang & environment\n'
printf '     - docker\n'
printf '     - gnome-screenshot\n'
printf '     - terminator\n'
printf '     - pip & pipenv\n'
printf '     - mitmproxy\n'
printf '     - patator\n'
printf '     - bettercap\n'
printf '     - vncsnapshot\n'
printf '     - zmap\n'
printf '     - LibreOffice\n'
printf '     - htop\n'
printf '     - Remmina\n'
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
    remmina \
    nfs-kernel-server
python2 -m pip install pipenv
python3 -m pip install pipenv
python3 -m pip install mitmproxy

# initialize mitmproxy cert
mitmproxy --help
# trust certificate
cp ~/.mitmproxy/mitmproxy-ca-cert.cer /usr/local/share/ca-certificates/mitmproxy-ca-cert.crt
update-ca-certificates

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
printf '[+] Installing Bettercap\n'
printf '============================================================\n\n'
apt-get -y install libnetfilter-queue-dev libpcap-dev libusb-1.0-0-dev
go get -v github.com/bettercap/bettercap


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
printf '[+] Initializing Metasploit Database\n'
printf '============================================================\n\n'
systemctl start postgresql
systemctl enable postgresql
msfdb init


printf '\n============================================================\n'
printf '[+] Disabling grub quiet mode\n'
printf '============================================================\n\n'
sed -i 's/GRUB_CMDLINE_LINUX="quiet splash noautomount"/GRUB_CMDLINE_LINUX="noautomount"/g' /etc/default/grub.d/parrot.cfg
grub-mkconfig -o /boot/grub/grub.cfg


printf '\n============================================================\n'
printf '[+] Unzipping RockYou\n'
printf '============================================================\n\n'
gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null
ln -s /usr/share/wordlists ~/Downloads/wordlists 2>/dev/null


printf '\n============================================================\n'
printf '[+] Consolidating Panel\n'
printf '============================================================\n\n'
# configure panel
dconf load /org/mate/panel/ <<EOF
[general]
object-id-list=['menu-bar', 'object_1', 'object_11', 'object_4', 'object_12', 'object_13', 'object_14', 'object_15', 'object_16', 'object-0', 'object-1', 'object-2', 'object-4', 'object-5', 'object-6', 'object-7', 'object-8', 'object-3']
toplevel-id-list=['bottom']

[objects/object-0]
applet-iid='ClockAppletFactory::ClockApplet'
locked=true
object-type='applet'
panel-right-stick=false
position=2668
toplevel-id='bottom'

[objects/object-0/prefs]
custom-format=''
format='24-hour'

[objects/object-1]
applet-iid='GvcAppletFactory::GvcApplet'
locked=true
object-type='applet'
panel-right-stick=false
position=2640
toplevel-id='bottom'

[objects/object-2]
applet-iid='NetspeedAppletFactory::NetspeedApplet'
locked=true
object-type='applet'
panel-right-stick=false
position=2585
toplevel-id='bottom'

[objects/object-2/prefs]
auto-change-device=true
change-icon=true
device='eth0'
short-unit=false
show-bits=false
show-icon=true
show-quality-icon=true
show-sum=true

[objects/object-3]
launcher-location='/usr/share/applications/mate-screenshot.desktop'
locked=true
object-type='launcher'
panel-right-stick=false
position=212
toplevel-id='bottom'

[objects/object-4]
launcher-location='/usr/share/applications/mate-terminal.desktop'
locked=true
object-type='launcher'
panel-right-stick=false
position=82
toplevel-id='bottom'

[objects/object-5]
launcher-location='/usr/share/applications/firefox.desktop'
locked=true
object-type='launcher'
panel-right-stick=false
position=134
toplevel-id='bottom'

[objects/object-6]
launcher-location='/usr/share/applications/sublime_text.desktop'
locked=true
object-type='launcher'
panel-right-stick=false
position=134
toplevel-id='bottom'

[objects/object-7]
launcher-location='/usr/share/applications/caja-browser.desktop'
locked=true
object-type='launcher'
panel-right-stick=false
position=108
toplevel-id='bottom'

[objects/object-8]
launcher-location='/usr/share/applications/boostnote.desktop'
locked=true
object-type='launcher'
panel-right-stick=false
position=160
toplevel-id='bottom'

[objects/object_1]
applet-iid='BriskMenuFactory::BriskMenu'
locked=true
object-type='applet'
panel-right-stick=false
position=1
toplevel-id='bottom'

[toplevels/bottom]
auto-hide=false
enable-buttons=false
expand=true
orientation='bottom'
screen=0
size=26
x-centered=true
x-right=-1
y=1607
y-bottom=0

[toplevels/bottom/background]
color='rgb(0,0,0)'
opacity=31575
type='color'

[toplevels/toplevel_0]
enable-arrows=true
enable-buttons=true
orientation='right'
size=36

[toplevels/toplevel_1]
enable-arrows=true
enable-buttons=true
orientation='right'
size=32

[toplevels/toplevel_1/background]
color='#008080'
opacity=41704
type='color'
EOF

# set keybindings
gsettings set org.mate.Marco.window-keybindings unmaximize '<Alt>F5'
gsettings set org.mate.Marco.window-keybindings minimize '<Mod4>Down'
gsettings set org.mate.Marco.window-keybindings begin-move '<Alt>F7'
gsettings set org.mate.Marco.window-keybindings activate-window-menu '<Alt>space'
gsettings set org.mate.Marco.window-keybindings move-to-workspace-up '<Control><Shift><Alt>Up'
gsettings set org.mate.Marco.window-keybindings move-to-workspace-right '<Control><Shift><Alt>Right'
gsettings set org.mate.Marco.window-keybindings maximize '<Mod4>Up'
gsettings set org.mate.Marco.window-keybindings tile-to-corner-ne '<Alt><Mod4>Right'
gsettings set org.mate.Marco.window-keybindings tile-to-corner-sw '<Shift><Alt><Mod4>Left'
gsettings set org.mate.Marco.window-keybindings tile-to-side-e '<Mod4>Right'
gsettings set org.mate.Marco.window-keybindings move-to-workspace-left '<Control><Shift><Alt>Left'
gsettings set org.mate.Marco.window-keybindings tile-to-corner-se '<Shift><Alt><Mod4>Right'
gsettings set org.mate.Marco.window-keybindings move-to-center '<Alt><Mod4>c'
gsettings set org.mate.Marco.window-keybindings begin-resize '<Alt>F8'
gsettings set org.mate.Marco.window-keybindings tile-to-corner-nw '<Alt><Mod4>Left'
gsettings set org.mate.Marco.window-keybindings tile-to-side-w '<Mod4>Left'
gsettings set org.mate.Marco.window-keybindings move-to-workspace-down '<Control><Shift><Alt>Down'
gsettings set org.mate.Marco.window-keybindings toggle-maximized '<Alt>F10'
gsettings set org.mate.Marco.window-keybindings close '<Alt>F4'

printf '\n============================================================\n'
printf '[+] Cleaning Up\n'
printf '============================================================\n\n'
# currently this removes way too many packages when running as root
#apt-get -y autoremove
apt-get -y autoclean
updatedb
rmdir ~/Music ~/Public ~/Videos ~/Templates ~/Desktop &>/dev/null

# fix file explorer bug
apt-get -y remove --purge caja
apt-get -y install caja
sed -i 's/Exec=caja.*/Exec=caja --force-desktop/g' '/usr/share/applications/caja.desktop'

# add space after shell prompt
sed -i 's/\[0m\\]"$/[0m\\] "/g' '/root/.bashrc'

# remove all users except for root
read -p "Delete all users except for root? (y/n)" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    for user in $(ls /home)
    do
        userdel -rf "${user}"
    done
fi


printf '\n============================================================\n'
printf "[+] Done. Don't forget to reboot! :)\n"
printf "[+] You may also want to install:\n"
printf '     - BurpSuite Pro\n'
printf '     - Firefox Add-Ons\n'
printf '============================================================\n\n'

# restart systemd-networkd for LL-MNR disablement
systemctl restart systemd-networkd