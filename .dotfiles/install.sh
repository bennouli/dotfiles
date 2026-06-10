#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

##############
## PACKAGES ##
##############

# install official Arch packages
sudo pacman -S --needed - < "$SCRIPT_DIR/official-packages.txt"

# install yay (can't use pacman for AUR; needs git + base-devel to build)
if ! command -v yay >/dev/null; then
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay && makepkg -si
  cd ~
fi

# install Arch User Repository packages
yay -S --needed - < "$SCRIPT_DIR/aur-packages.txt"

############
## LOCALE ##
############

echo 'LANG=en_US.UTF-8' | sudo tee /etc/locale.conf
echo 'en_US.UTF-8 UTF-8' | sudo tee -a /etc/locale.gen
echo 'de_DE.UTF-8 UTF-8' | sudo tee -a /etc/locale.gen
sudo locale-gen

##############
## SERVICES ##
##############
# each service explicitly installs its package so the step works
# regardless of what the package lists happen to contain

# bluetooth
sudo systemctl enable bluetooth.service

# SDDM (display manager for hyprland)
sudo pacman -S --needed sddm
sudo systemctl enable sddm

# docker
sudo pacman -S --needed docker docker-compose
sudo systemctl enable --now docker  # enable + start immediately
# add user to docker group so sudo isn't needed every time
if ! groups "$USER" | grep -q docker; then
    sudo usermod -aG docker "$USER"
fi

###########
## SHELL ##
###########

# install Oh-My-Zsh (zsh + curl come from official-packages.txt)
# RUNZSH/CHSH=no keeps the installer non-interactive
RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

############
## LAPTOP ##
############

# laptop only: power management via tlp (not in the package lists)
if [ -d /sys/class/power_supply/BAT0 ]; then
  sudo pacman -S --needed tlp
  sudo systemctl enable --now tlp
  sudo sed -i 's/#START_CHARGE_THRESH_BAT0=.*/START_CHARGE_THRESH_BAT0=75/' /etc/tlp.conf
  sudo sed -i 's/#STOP_CHARGE_THRESH_BAT0=.*/STOP_CHARGE_THRESH_BAT0=80/' /etc/tlp.conf
fi

#############
## SCRIPTS ##
#############

# make all shell scripts executable
# any shell scripts in the repo should live in ~/.local/bin
find "$HOME/.local/bin" -type f -name "*.sh" -exec chmod +x {} \;
