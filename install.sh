#!/bin/bash

# Arch post-install setup script for Jonathan
# FINAL CLEAN VERSION — no placeholders, no bullshit

set -e

USERNAME=$(whoami)
echo "[+] Running as $USERNAME"

echo "[+] Updating system..."
sudo pacman -Syu --noconfirm

# Sudo without password
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USERNAME

# Base packages
sudo pacman -S --noconfirm git curl wget zsh neovim unzip zip nano \
  fzf ripgrep bat exa btop htop zoxide kitty \
  ttf-jetbrains-mono-nerd ttf-firacode-nerd noto-fonts noto-fonts-emoji

# yay
if ! command -v yay &> /dev/null; then
  echo "[+] Installing yay..."
  sudo pacman -S --needed --noconfirm base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay && makepkg -si --noconfirm
  cd ~
fi

# Docker
sudo pacman -S --noconfirm docker
sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker $USERNAME
sudo systemctl enable docker --now

# Audio
sudo pacman -S --noconfirm pipewire pipewire-pulse wireplumber pavucontrol easyeffects qpwgraph

# Hyprland + Wayland tools
sudo pacman -S --noconfirm hyprland xdg-desktop-portal-hyprland \
  rofi-wayland waybar swww dunst hyprpaper wl-clipboard grim slurp

# Shell + Theme
yay -S --noconfirm zsh-theme-powerlevel10k
chsh -s $(which zsh)

# Apps
yay -S --noconfirm firefox brave-bin librewolf-bin discord spotify obsidian onlyoffice-bin

# Dev tools
yay -S --noconfirm visual-studio-code-bin lazygit gh
sudo pacman -S --noconfirm python python-pip nodejs npm go rustup

# AI stack
curl -fsSL https://ollama.com/install.sh | sh
yay -S --noconfirm openwebui-bin

# VPN
yay -S --noconfirm protonvpn networkmanager network-manager-applet
sudo systemctl enable NetworkManager --now

# Gaming
yay -S --noconfirm steam lutris heroic-games-launcher-bin \
  wine winetricks gamemode mangohud \
  dxvk-bin vkd3d proton-ge-custom-bin xpadneo-dkms-git

# Security tools
yay -S --noconfirm burpsuite wireshark-qt nmap gobuster hashcat john

# Flatpak
sudo pacman -S --noconfirm flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Hyprland rice config
echo "[+] Applying Hyprland config..."
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/rofi
mkdir -p ~/.config/kitty
mkdir -p ~/Pictures

# Wallpaper
curl -Lo ~/Pictures/wall.png https://raw.githubusercontent.com/prasanthrangan/hyprdots/main/wallpapers/wall.png

# Hyprland config
cat <<EOF > ~/.config/hypr/hyprland.conf
exec-once = swww init && swww img ~/Pictures/wall.png
exec-once = waybar &
exec-once = dunst &
exec-once = nm-applet &
exec-once = blueman-applet &
exec-once = easyeffects --gapplication-service &

input {
  kb_layout = us
}

general {
  gaps_in = 5
  gaps_out = 10
  border_size = 2
  col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
  col.inactive_border = rgba(595959aa)
}

decoration {
  rounding = 10
  blur = true
  blur_size = 5
  blur_passes = 2
  drop_shadow = false
}

animations {
  enabled = yes
  animation = windows, 1, 7, default
  animation = fade, 1, 10, default
  animation = workspaces, 1, 6, default
}

bind = SUPER, Return, exec, kitty
bind = SUPER, Q, killactive,
bind = SUPER, E, exec, thunar
bind = SUPER, V, togglefloating,
bind = SUPER, R, exec, rofi -show drun
bind = SUPER, F, fullscreen,
bind = SUPER, D, exec, rofi -show run
bind = SUPER, W, exec, firefox
EOF

# Waybar config
cat <<EOF > ~/.config/waybar/config
{ "layer": "top", "position": "top", "modules-left": ["clock"], "modules-right": ["cpu", "memory", "network", "battery"] }
EOF

# Rofi config
cat <<EOF > ~/.config/rofi/config.rasi
configuration {
  show-icons: true;
  font: "FiraCode Nerd Font 12";
}
EOF

# Kitty config
cat <<EOF > ~/.config/kitty/kitty.conf
font_family FiraCode Nerd Font
font_size 12.0
EOF

echo "[✓] Setup complete. Reboot and launch Hyprland."
