#!/bin/bash

# install.sh 
final_script_path = "/mnt/data/install.sh"

final_script_content = f"""#!/bin/bash

# Arch post-install setup script for Jonathan
# Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
# Run after base Arch install with network access:
# git clone https://github.com/YOUR_USER/YOUR_REPO.git
# cd YOUR_REPO && ./install.sh

set -e

USERNAME=$(whoami)
echo "[+] Running as $USERNAME"

echo "[+] Updating system..."
sudo pacman -Syu --noconfirm

# Sudo no password
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USERNAME

# Essentials
sudo pacman -S --noconfirm git curl wget zsh neovim nano unzip zip \\
  fzf ripgrep bat exa btop htop zoxide kitty \\
  ttf-jetbrains-mono-nerd ttf-firacode-nerd noto-fonts noto-fonts-emoji

# yay
if ! command -v yay &> /dev/null; then
  echo "[+] Installing yay..."
  sudo pacman -S --needed --noconfirm base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay && makepkg -si --noconfirm
  cd ~
fi

# Docker setup
sudo pacman -S --noconfirm docker
sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker $USERNAME
sudo systemctl enable docker --now

# Audio
sudo pacman -S --noconfirm pipewire pipewire-pulse wireplumber pavucontrol easyeffects qpwgraph

# Hyprland + desktop setup
sudo pacman -S --noconfirm hyprland xdg-desktop-portal-hyprland rofi-wayland waybar \\
  swww dunst hyprpaper wl-clipboard grim slurp

# Powerlevel10k
yay -S --noconfirm zsh-theme-powerlevel10k
chsh -s $(which zsh)

# Apps
yay -S --noconfirm firefox brave-bin librewolf-bin discord spotify obsidian onlyoffice-bin

# Editors
yay -S --noconfirm visual-studio-code-bin lazygit gh

# Dev languages
sudo pacman -S --noconfirm python python-pip nodejs npm go rustup

# AI
curl -fsSL https://ollama.com/install.sh | sh
yay -S --noconfirm openwebui-bin

# VPN
yay -S --noconfirm protonvpn networkmanager network-manager-applet
sudo systemctl enable NetworkManager --now

# Gaming
yay -S --noconfirm steam lutris heroic-games-launcher-bin \\
  wine winetricks gamemode mangohud \\
  dxvk-bin vkd3d proton-ge-custom-bin xpadneo-dkms-git

# Security
yay -S --noconfirm burpsuite wireshark-qt nmap gobuster hashcat john

# Flatpak
sudo pacman -S --noconfirm flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Hyprland config (you can replace this after clone)
mkdir -p ~/.config/hypr
cp -r ./dotfiles/hypr/* ~/.config/hypr/ 2>/dev/null || true

echo "[✓] All done. Reboot and enjoy your new system."
"""

# Save to file
with open(final_script_path, "w") as file:
    file.write(final_script_content)

final_script_path
