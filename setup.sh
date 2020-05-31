#!/bin/bash
set -x 

sudo rm -f /etc/apt/sources.list.d/*bionic* # remove bionic repositories

# Add dell drivers for focal fossa

sudo sh -c 'cat > /etc/apt/sources.list.d/focal-dell.list << EOF
deb http://dell.archive.canonical.com/updates/ focal-dell public
# deb-src http://dell.archive.canonical.com/updates/ focal-dell public

deb http://dell.archive.canonical.com/updates/ focal-oem public
# deb-src http://dell.archive.canonical.com/updates/ focal-oem public

deb http://dell.archive.canonical.com/updates/ focal-somerville public
# deb-src http://dell.archive.canonical.com/updates/ focal-somerville public

deb http://dell.archive.canonical.com/updates/ focal-somerville-melisa public
# deb-src http://dell.archive.canonical.com/updates focal-somerville-melisa public
EOF'

sudo apt update -qq

sudo apt install git htop lame net-tools flatpak audacity \
openssh-server sshfs simplescreenrecorder nano \
vlc gthumb gnome-tweaks ubuntu-restricted-extras thunderbird \
gnome-tweak-tool spell synaptic -y

# Install fonts
sudo apt install fonts-firacode
sudo apt install fonts-open-sans

gsettings set org.gnome.desktop.interface font-name 'Open Sans 12'
gsettings set org.gnome.desktop.interface monospace-font-name 'Fira Code Retina 13'

# Install fusuma for handling gestures

sudo gpasswd -a $USER input
sudo apt-get install libinput-tools xdotool 
sudo gem install fusuma

# Remove packages:

sudo apt remove rhythmbox -yy

# Remove snaps and Add Flatpak support:

sudo snap remove gnome-characters gnome-calculator gnome-system-monitor
sudo apt install gnome-characters gnome-calculator gnome-system-monitor \
gnome-software-plugin-flatpak -yy

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Setup GNOME material shell

git clone https://github.com/PapyElGringo/material-shell.git ~/.local/share/gnome-shell/extensions/material-shell@papyelgringo
gnome-shell-extension-tool -e material-shell@papyelgringo

# Install Icon Theme

git clone https://github.com/vinceliuice/Tela-icon-theme.git /tmp/tela-icon-theme
/tmp/tela-icon-theme/install.sh

gsettings set org.gnome.desktop.interface icon-theme 'Tela-grey-dark'

# Add Plata-theme
sudo add-apt-repository ppa:tista/plata-theme -y
sudo apt update -qq && sudo apt install plata-theme

gsettings set org.gnome.desktop.interface gtk-theme "Plata-Noir"
gsettings set org.gnome.desktop.wm.preferences theme "Plata-Noir"


# Setup Development tools

sudo apt remove docker docker-engine docker.io containerd runc
sudo apt install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
sudo install -o root -g root -m 644 /tmp/packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'


curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt update -qq && sudo apt install docker-ce docker-ce-cli containerd.io code

# Purge Firefox, install Chromium:

sudo apt remove firefox -yy
sudo apt remove firefox-locale-en -yy

sudo apt install chromium-browser

## Chat
sudo flatpak install discord -y

## Multimedia
sudo apt install -y gimp
sudo flatpak install spotify -y

## Games
sudo apt install -y steam-installer

# Gotta reboot now:
sudo apt update -qq && sudo apt upgrade -y

echo $'\n'$"Ready for REBOOT"