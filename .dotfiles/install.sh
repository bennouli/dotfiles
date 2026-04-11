# install official Arch packages
sudo pacman -S --needed - < official-packages.txt

# install yay (can't use pacman for AUR)
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay && makepkg -si
cd ~

# install Arch User Registry packages
yay -S --needed - < aur-packages.txt

# laptop only
if [ -d /sys/class/power_supply/BAT0 ]; then
  sudo pacman -S --needed tlp
  sudo systemctl enable --now tlp
  sudo sed -i 's/#START_CHARGE_THRESH_BAT0=.*/START_CHARGE_THRESH_BAT0=75/' /etc/tlp.conf
  sudo sed -i 's/#STOP_CHARGE_THRESH_BAT0=.*/STOP_CHARGE_THRESH_BAT0=80/' /etc/tlp.conf
fi
