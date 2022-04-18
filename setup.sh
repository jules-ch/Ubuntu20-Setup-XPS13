#!/bin/bash
set -ex

# Ensure repositories are enabled
sudo add-apt-repository universe
sudo add-apt-repository multiverse
sudo add-apt-repository restricted

# Add dell drivers for focal fossa XPS 13

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

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F9FDA6BED73CDC22

sudo apt update -qq

# Install general utilities
sudo apt install git htop lame net-tools flatpak audacity \
openssh-server sshfs simplescreenrecorder nano \
vlc gthumb gnome-tweaks ubuntu-restricted-extras thunderbird \
ffmpeg ufw \
gnome-tweak-tool spell synaptic -y -qq

# Install drivers
sudo apt install oem-somerville-melisa-meta libfprint-2-tod1-goodix oem-somerville-meta tlp-config -y

# Install fusuma for handling gestures

sudo gpasswd -a $USER input
sudo apt install libinput-tools xdotool ruby -y -qq
sudo gem install --silent fusuma

# Install Howdy for facial recognition
while true; do
  read -p "Facial recognition with Howdy (y/n)?" choice
  case "$choice" in 
    y|Y ) 
    echo "Installing Howdy"
    sudo add-apt-repository ppa:boltgolt/howdy -y > /dev/null 2>&1
    sudo apt update -qq
    sudo apt install howdy -y; break;;
    n|N ) 
    echo "Skipping Install of Howdy"; break;;
    * ) echo "invalid";;
  esac
done

# Remove packages:

sudo apt remove rhythmbox -y -q

# Add Flatpak support:

sudo apt install gnome-software-plugin-flatpak -y

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Icon Theme
[[ -d /tmp/tela-icon-theme ]] && rm -rf /tmp/tela-icon-theme
git clone https://github.com/vinceliuice/Tela-icon-theme.git /tmp/tela-icon-theme > /dev/null 2>&1
/tmp/tela-icon-theme/install.sh -a

gsettings set org.gnome.desktop.interface icon-theme 'Tela-grey-dark'

# Add Plata-theme
sudo add-apt-repository ppa:tista/plata-theme -y > /dev/null 2>&1
sudo apt update -qq && sudo apt install plata-theme -y

gsettings set org.gnome.desktop.interface gtk-theme "Plata-Noir"
gsettings set org.gnome.desktop.wm.preferences theme "Plata-Noir"

# Enable Shell Theme

sudo apt install gnome-shell-extensions -y
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gsettings set org.gnome.shell.extensions.user-theme name "Plata-Noir"

# Install fonts
sudo apt install fonts-firacode fonts-open-sans -y -qq

gsettings set org.gnome.desktop.interface font-name 'Open Sans 12'
gsettings set org.gnome.desktop.interface monospace-font-name 'Fira Code 13'

# Setup Development tools

## Update python essentials
sudo apt install python3 python3-pip python-is-python3 -y
sudo python3 -m pip install -U pip setuptools wheel
python3 -m pip install --user black

## Add build essentials
sudo apt install build-essential -y

## Add Java JDK LTS
sudo apt install openjdk-11-jdk -y

sudo apt install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common -y -q

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
sudo install -o root -g root -m 644 /tmp/packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'


curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" > /dev/null 2>&1
sudo apt update -qq && sudo apt install docker-ce docker-ce-cli docker-compose containerd.io code -y

## Post installation for docker

sudo groupadd -f docker
sudo usermod -aG docker $USER

## Post installation for code (sensible defaults)

code --install-extension ms-python.python
code --install-extension visualstudioexptteam.vscodeintellicode
code --install-extension eamodio.gitlens
code --install-extension ms-azuretools.vscode-docker


## Install Go
wget https://golang.org/dl/go1.17.2.linux-amd64.tar.gz -O /tmp/go1.17.2.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf /tmp/go1.17.2.linux-amd64.tar.gz

if ! grep -qF "export PATH=\$PATH:/usr/local/go/bin" /etc/profile; then
  sudo sh -c 'echo "export PATH=\$PATH:/usr/local/go/bin" >> /etc/profile'
fi

## Install dotnet-core sdk + runtime
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb

sudo apt-get update
sudo apt-get install -y dotnet-sdk-5.0
sudo apt-get install -y aspnetcore-runtime-5.0

sudo flatpak install postman -y

## Node.JS + Yarn Install

echo "Installing Node 14 JS LTS"
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs 
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list 
sudo apt-get update -qq && sudo apt-get install -y yarn


# Setup GNOME material shell (Need Node.js for compilation of the Typescript extension)

git clone -b 3.38 https://github.com/PapyElGringo/material-shell.git ~/material-shell || true
make -C ~/material-shell/ install


# Setup Android Studio for Mobile Development
while true; do
  read -p "Mobile development (Android) (y/n)?" choice
  case "$choice" in 
    y|Y ) 
    sudo dpkg --add-architecture i386 && sudo apt update -qq
    sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386
    wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.1.2.0/android-studio-ide-201.7042882-linux.tar.gz -O /tmp/android-studio-ide-201.7042882-linux.tar.gz
    sudo tar -xzf /tmp/android-studio-ide-201.7042882-linux.tar.gz -C /opt 
    sudo sh -c 'cat > /usr/share/applications/jetbrains-studio.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Icon=/opt/android-studio/bin/studio.svg
Exec="/opt/android-studio/bin/studio.sh" nosplash %f
Comment=The Drive to Develop
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-studio
EOF'
    sudo chmod 644 /usr/share/applications/jetbrains-studio.desktop; break;;
    n|N ) 
    echo "Skipping Install of Android SDKs"; break;;
    * ) echo "invalid";;
  esac
done

## Chat
sudo flatpak install discord -y

## Multimedia
sudo apt install -y gimp
sudo flatpak install spotify -y

# Gotta reboot now:
sudo apt update -qq && sudo apt upgrade -y && sudo apt autoremove -y

echo $'\n'$"Ready for REBOOT"
