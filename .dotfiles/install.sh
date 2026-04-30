SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# install official Arch packages
sudo pacman -S --needed - < "$SCRIPT_DIR/official-packages.txt"

# install yay (can't use pacman for AUR)
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay && makepkg -si
cd ~

# locale
echo 'LANG=en_US.UTF-8' | sudo tee /etc/locale.conf
echo 'en_US.UTF-8 UTF-8' | sudo tee -a /etc/locale.gen
echo 'de_DE.UTF-8 UTF-8' | sudo tee -a /etc/locale.gen
sudo locale-gen

# install Arch User Registry packages
yay -S --needed - < "$SCRIPT_DIR/aur-packages.txt"

# install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Enable SDDM for hyprland
sudo pacman -S sddm
sudo systemctl enable sddm

# docker
sudo pacman -S docker docker-compose
sudo systemctl enable --now docker  # enable + start immediately

# Only add to group if not already in it
if ! groups $USER | grep -q docker; then
    sudo usermod -aG docker $USER # add user to docker group so no need for sudo every time
fi

# laptop only
if [ -d /sys/class/power_supply/BAT0 ]; then
  sudo pacman -S --needed tlp
  sudo systemctl enable --now tlp
  sudo sed -i 's/#START_CHARGE_THRESH_BAT0=.*/START_CHARGE_THRESH_BAT0=75/' /etc/tlp.conf
  sudo sed -i 's/#STOP_CHARGE_THRESH_BAT0=.*/STOP_CHARGE_THRESH_BAT0=80/' /etc/tlp.conf
fi

