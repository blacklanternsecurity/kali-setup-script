#!/bin/bash

# make sure we're root
if [[ "$EUID" -ne 0 ]]
then
    printf "Please run as root\n"
    exit 1
fi

# enable command aliasing
shopt -s expand_aliases

# skip prompts in apt-upgrade, etc.
export DEBIAN_FRONTEND=noninteractive
alias apt-get='apt-get -o Dpkg::Options::="--force-confdef" -y'


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
printf '[+] Disabling LL-MNR\n'
printf '============================================================\n\n'
echo '[Match]
name=*

[Network]
LLMNR=no' > /etc/systemd/network/90-disable-llmnr.network


# printf '\n============================================================\n'
# printf '[+] Removing the abomination that is gnome-software\n'
# printf '============================================================\n\n'
# killall gnome-software
# while true
# do
#     pgrep gnome-software &>/dev/null || break
#     sleep .5
# done
# yes '' | apt-get remove gnome-software


printf '\n============================================================\n'
printf '[+] Setting Theme\n'
printf '============================================================\n\n'
# dark theme
# gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
mkdir -p '/usr/share/wallpapers/wallpapers/' &>/dev/null
wallpaper_file="$(find . -type f -name hackerman.png)"
if [[ -z "$wallpaper_file" ]]
then
    wget -P '/usr/share/wallpapers/wallpapers/' https://raw.githubusercontent.com/blacklanternsecurity/kali-setup-script/master/hackerman.png
else
    cp "$wallpaper_file" '/usr/share/wallpapers/wallpapers/hackerman.png'
fi
gsettings set org.gnome.desktop.background primary-color "#000000"
gsettings set org.gnome.desktop.background secondary-color "#000000"
gsettings set org.gnome.desktop.background color-shading-type "solid"
gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/wallpapers/wallpapers/hackerman.png"
gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/wallpapers/wallpapers/hackerman.png"
gsettings set org.gnome.desktop.background picture-options scaled
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s /usr/share/wallpapers/wallpapers/hackerman.png


# printf '\n============================================================\n'
# printf '[+] Installing i3\n'
# printf '============================================================\n\n'
# # install dependencies
# yes '' | apt-get install i3 j4-dmenu-desktop gnome-flashback fonts-hack feh
# cd /opt
# git clone https://github.com/csxr/i3-gnome
# cd i3-gnome
# make install
# # make startup script
# echo '#!/bin/bash
# # xrandr --output eDP-1 --mode 1920x1080
# feh --bg-scale /usr/share/wallpapers/wallpapers/hackerman.png
# ' > /root/.config/i3_startup.sh
# 
# # set up config
# grep '### KALI SETUP SCRIPT ###' /etc/i3/config.keycodes || echo '
# ### KALI SETUP SCRIPT ###
# # win+L lock screen
# bindsym $sup+l exec i3lock -i /usr/share/wallpapers/wallpapers/hackerman.png
# # gnome settings daemon
# exec --no-startup-id /usr/lib/gnome-settings-daemon/gsd-xsettings
# # gnome power manager
# exec_always --no-startup-id gnome-power-manager
# # polkit-gnome
# exec --no-startup-id /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
# # gnome flashback
# exec --no-startup-id gnome-flashback
# # resolution / wallpaper
# exec_always --no-startup-id bash "/root/.config/i3_startup.sh"
# 
# # BLS theme
# # class             border  background  text        indicator   child_border
# client.focused      #444444 #444444     #FFFFFF     #FFFFFF     #444444
# ' >> /etc/i3/config.keycodes
# 
# # gnome terminal
# sed -i 's/^bindcode $mod+36 exec.*/bindcode $mod+36 exec gnome-terminal/' /etc/i3/config.keycodes
# # improved dmenu
# sed -i 's/.*bindcode $mod+40 exec.*/bindcode $mod+40 exec --no-startup-id j4-dmenu-desktop/g' /etc/i3/config.keycodes
# # mod+shift+e logs out of gnome
# sed -i 's/.*bindcode $mod+Shift+26 exec.*/bindcode $mod+Shift+26 exec gnome-session-quit/g' /etc/i3/config.keycodes
# # hack font
# sed -i 's/^font pango:.*/font pango:hack 11/' /etc/i3/config.keycodes
# # focus child
# sed -i 's/bindcode $mod+39 layout stacking/#bindcode $mod+39 layout stacking/g' /etc/i3/config.keycodes
# sed -i 's/.*bindsym $mod+d focus child.*/bindcode $mod+39 focus child/g' /etc/i3/config.keycodes


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
printf '     - vncsnapshot\n'
printf '     - zmap\n'
printf '     - LibreOffice\n'
printf '     - htop\n'
printf '     - Remmina\n'
printf '     - NFS server\n'
printf '     - DNS Server\n'
printf '     - hcxtools (hashcat)\n'
printf '============================================================\n\n'
yes '' | apt-get install \
    realtek-rtl88xxau-dkms \
    golang \
    docker.io \
    gnome-screenshot \
    terminator \
    python-pip \
    python3-dev \
    python3-pip \
    patator \
    net-tools \
    vncsnapshot \
    zmap \
    libreoffice \
    htop \
    remmina \
    nfs-kernel-server \
    dnsmasq \
    hcxtools \
    gnome-terminal
python2 -m pip install pipenv
python3 -m pip install pipenv
python3 -m pip install mitmproxy

# enable and start docker
systemctl stop docker &>/dev/null
echo '{"bip":"172.16.199/24"}' > /etc/docker/daemon.json
systemctl enable docker --now

# initialize mitmproxy cert
mitmproxy &
killall mitmproxy
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
yes '' | apt-get update
yes '' | apt-get upgrade


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
yes '' | apt-get install chromium
sed -i 's#Exec=/usr/bin/chromium %U#Exec=/usr/bin/chromium --no-sandbox %U#g' /usr/share/applications/chromium.desktop


printf '\n============================================================\n'
printf '[+] Installing Zmap Asset Inventory\n'
printf '============================================================\n\n'
cd /root/Downloads
mv zmap-asset-inventory "zmap-asset-inventory.bak$(date +%s)" &> /dev/null
git clone https://github.com/blacklanternsecurity/zmap-asset-inventory
docker build --network host -t zmap-assets zmap-asset-inventory


printf '\n============================================================\n'
printf '[+] Installing Bloodhound\n'
printf '============================================================\n\n'
# uninstall old version
yes '' | apt-get remove bloodhound
rm -rf /opt/BloodHound-linux-x64 &>/dev/null

# download latest bloodhound release from github
release_url="https://github.com/$(curl -s https://github.com/BloodHoundAD/BloodHound/releases | egrep -o '/BloodHoundAD/BloodHound/releases/download/.{1,10}/BloodHound-linux-x64.zip' | head -n 1)"
cd /opt
wget "$release_url"
unzip -o 'BloodHound-linux-x64.zip'
rm 'BloodHound-linux-x64.zip'

# fix white screen issue
echo -e '#!/bin/bash\n/opt/BloodHound-linux-x64/BloodHound --no-sandbox $@' > /usr/local/bin/bloodhound
chmod +x /usr/local/bin/bloodhound

# install Neo4J
wget -O - https://debian.neo4j.org/neotechnology.gpg.key | apt-key add -
echo 'deb https://debian.neo4j.org/repo stable/' > /etc/apt/sources.list.d/neo4j.list
yes '' | apt-get update
yes '' | apt-get install neo4j

# increase open file limit
yes '' | apt-get install neo4j gconf-service gconf2-common libgconf-2-4
mkdir -p /usr/share/neo4j/logs /usr/share/neo4j/run
grep '^root   soft    nofile' /etc/security/limits.conf || echo 'root   soft    nofile  500000
root   hard    nofile  600000' >> /etc/security/limits.conf
grep 'NEO4J_ULIMIT_NOFILE=60000' /etc/default/neo4j 2>/dev/null || echo 'NEO4J_ULIMIT_NOFILE=60000' >> /etc/default/neo4j
grep 'fs.file-max' /etc/sysctl.conf 2>/dev/null || echo 'fs.file-max=500000' >> /etc/sysctl.conf
sysctl -p
neo4j start

# install cypheroth, which automates bloodhound queries & outputs to CSV
cd /opt
git clone https://github.com/seajaysec/cypheroth
ln -s /opt/cypheroth ~/Downloads/cypheroth
ln -s /opt/cypheroth/cypheroth.sh /usr/local/bin/cypheroth



printf '\n============================================================\n'
printf '[+] Installing Bettercap\n'
printf '============================================================\n\n'
yes '' | apt-get install libnetfilter-queue-dev libpcap-dev libusb-1.0-0-dev
go get -v github.com/bettercap/bettercap


printf '\n============================================================\n'
printf '[+] Installing EapHammer\n'
printf '============================================================\n\n'
cd /opt
git clone https://github.com/s0lst1c3/eaphammer.git
cd eaphammer
apt-get install $(grep -vE "^\s*#" kali-dependencies.txt  | tr "\n" " ")
chmod +x kali-setup
# remove prompts from setup script
sed -i 's/.*input.*update your package list.*/    if False:/g' kali-setup
sed -i 's/.*input.*upgrade your installed packages.*/    if False:/g' kali-setup
sed -i 's/.*apt.* install.*//g' kali-setup
./kali-setup
ln -s /opt/eaphammer ~/Downloads/eaphammer
ln -s /opt/eaphammer/eaphammer /usr/local/bin/eaphammer


printf '\n============================================================\n'
printf '[+] Installing Gowitness\n'
printf '============================================================\n\n'
go get -v github.com/sensepost/gowitness


printf '\n============================================================\n'
printf '[+] Installing PCredz\n'
printf '============================================================\n\n'
yes '' | apt-get remove python-pypcap
yes '' | apt-get install python-libpcap
cd /opt
git clone https://github.com/lgandx/PCredz.git
ln -s /opt/PCredz/Pcredz.py /usr/local/bin/pcredz


printf '\n============================================================\n'
printf '[+] Installing EavesARP\n'
printf '============================================================\n\n'
cd ~/Downloads
git clone https://github.com/arch4ngel/eavesarp
cd eavesarp && python3 -m pip install -r requirements.txt
cd && ln -s ~/Downloads/eavesarp/eavesarp.py /usr/local/bin/eavesarp


printf '\n============================================================\n'
printf '[+] Installing CrackMapExec\n'
printf '============================================================\n\n'
cme_dir="$(ls -d /root/.local/share/virtualenvs/* | grep CrackMapExec | head -n 1)"
if [[ ! -z "$cme_dir" ]]; then rm -r "$cme_dir" &>/dev/null; fi
rm -rf /opt/CrackMapExec &>/dev/null
yes '' | apt-get install libssl-dev libffi-dev python-dev build-essential
cd /opt
git clone --recursive https://github.com/byt3bl33d3r/CrackMapExec
cd CrackMapExec && python2 -m pipenv install
python2 -m pipenv run python setup.py install
#ln -s ~/.local/share/virtualenvs/$(ls /root/.local/share/virtualenvs | grep CrackMapExec | head -n 1)/bin/cme /usr/bin/cme
#ln -s ~/.local/share/virtualenvs/$(ls /root/.local/share/virtualenvs | grep CrackMapExec | head -n 1)/bin/cmedb /usr/bin/cmedb
ln -s ~/.local/share/virtualenvs/$(ls /root/.local/share/virtualenvs | grep CrackMapExec | head -n 1)/bin ~/Downloads/crackmapexec
cd / && rm -r /opt/CrackMapExec
yes '' | apt-get install crackmapexec


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
ln -s ~/.local/share/virtualenvs/$(ls /root/.local/share/virtualenvs | grep impacket | head -n 1)/bin ~/Downloads/impacket
cd / && rm -r /opt/impacket


printf '\n============================================================\n'
printf '[+] Installing Sublime Text\n'
printf '============================================================\n\n'
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
yes '' | apt-get install apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" > /etc/apt/sources.list.d/sublime-text.list
yes '' | apt-get update
yes '' | apt-get install sublime-text


printf '\n============================================================\n'
printf '[+] Installing BoostNote\n'
printf '============================================================\n\n'
boost_deb_url="https://github.com$(curl -Ls https://github.com/BoostIO/boost-releases/releases/latest | egrep -o '/BoostIO/boost-releases/releases/download/.+.deb')"
cd /opt
wget -O boostnote.deb "$boost_deb_url"
yes '' | apt-get install gconf2 gvfs-bin
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
        logfile=$logdir/$(date +%F_%H_%M_%S).$$.log
        export UNDER_SCRIPT=$logfile
        script -f -q $logfile
        exit
fi' >> ~/.bashrc


printf '\n============================================================\n'
printf '[+] Disabling Animations\n'
printf '============================================================\n\n'
gsettings set org.gnome.desktop.interface enable-animations false


printf '\n============================================================\n'
printf '[+] Disabling Terminal Transparency\n'
printf '============================================================\n\n'
profile=$(gsettings get org.gnome.Terminal.ProfilesList default)
profile=${profile:1:-1}
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" use-transparent-background false
# bring back minimize/maxminize buttons
gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close


printf '\n============================================================\n'
printf '[+] Enabling Tap-to-click\n'
printf '============================================================\n\n'
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
xfconf-query -c pointers -p /SynPS2_Synaptics_TouchPad/Properties/libinput_Tapping_Enabled -s 1
xfconf-query -c pointers -p /SynPS2_Synaptics_TouchPad/Properties/libinput_Tap_Action -s 0 -s 0 -s 0 -s 0 -s 1 -s 3 -s 2


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
# this seems to remove undesired packages
#apt-get -y autoremove
#apt-get -y autoclean
updatedb
rmdir ~/Music ~/Public ~/Videos ~/Templates ~/Desktop &>/dev/null
gsettings set org.gnome.shell favorite-apps "['firefox.desktop', 'org.gnome.Terminal.desktop', 'terminator.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Screenshot.desktop', 'sublime_text.desktop', 'boostnote.desktop']"


printf '\n============================================================\n'
printf "[+] Done. Don't forget to reboot! :)\n"
printf "[+] You may also want to install:\n"
printf '     - BurpSuite Pro\n'
printf '     - Firefox Add-Ons\n'
printf '============================================================\n\n'

# restart systemd-networkd for LL-MNR disablement
systemctl restart systemd-networkd
