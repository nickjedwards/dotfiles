#!/usr/bin/env bash

# Install pacman/AUR packages
yes '' | paru -S bat \
    bibata-cursor-theme-bin \
    brightnessctl \
    btop \
    cliphist \
    eza \
    fastfetch \
    fd \
    fzf \
    ghostty \
    git-delta \
    hyprcursor \
    hypridle \
    hyprland \
    hyprpaper \
    hyprshot \
    jq \
    lazydocker-bin \
    lazygit \
    less \
    neovim \
    numix-circle-icon-theme-git \
    pavucontrol \
    pacman-contrib \
    pass \
    polkit-gnome \
    power-profiles-daemon \
    qt5-wayland \
    qt6-wayland \
    ripgrep \
    rofi-wayland \
    satty \
    starship \
    stow \
    swaylock-effects \
    swaync-git \
    swayosd \
    tmux \
    ttf-jetbrains-mono-nerd \
    ttf-nerd-fonts-symbols \
    vscodium-bin \
    waybar \
    wireplumber \
    wlogout \
    xdg-desktop-portal-hyprland \
    zen-browser-bin \
    zoxide \
    zsh

# Zsh && Oh My ZSH!
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Zsh plugins
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions

# Install tmux catppuccin theme
stow tmux
mkdir -p ${HOME}/.config/tmux/plugins/catppuccin
git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ${HOME}/.config/tmux/plugins/catppuccin/tmux

# Configure bat theme
stow bat
bat cache --build

# Setup wallpaper
ln -sf ${HOME}/dotfiles/walls/swirls.jpg ${HOME}/.config/wallpaper
