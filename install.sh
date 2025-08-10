#!/usr/bin/env bash

# Install Pacman packages
yes '' | sudo pacman -S bat \
    brightnessctl \
    dunst \
    eza \
    fastfetch \
    fd \
    fzf \
    git-delta \
    grim \
    hyprcursor \
    hypridle \
    hyprland \
    hyprpaper \
    jq \
    less \
    neovim \
    pacman-contrib \
    pavucontrol \
    qt5-wayland \
    qt6-wayland \
    ripgrep \
    starship \
    stow \
    tmux \
    ttf-jetbrains-mono-nerd \
    ttf-nerd-fonts-symbols \
    wireplumber \
    xdg-desktop-portal-hyprland \
    zsh

# Install AUR packages
yes '' | paru -S bibata-cursor-theme-bin \
    btop \
    flameshot \
    ghostty \
    lazydocker-bin \
    lazygit \
    nerdfetch \
    numix-circle-icon-theme-git \
    polkit-gnome \
    rofi-wayland \
    swaylock-effects \
    vscodium-bin \
    waybar \
    wlogout \
    zen-browser-bin

# Zsh && Oh My ZSH!
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Zsh plugins
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions

# fzf-git
git clone https://github.com/junegunn/fzf-git.sh.git ${HOME}/fzf-git.sh

stow bat
# Apply Bat theme
bat cache --build

# Setup wallpaper
ln -sf ~/dotfiles/wallpapers/swirls.jpg ~/.config/wallpaper
