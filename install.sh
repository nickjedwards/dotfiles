#!/usr/bin/env bash

# Install pacman/AUR packages
yes '' | paru -S \
    bat \
    bibata-cursor-theme-bin \
    brightnessctl \
    btop \
    cava \
    cliphist \
    dms-shell \
    eza \
    fastfetch \
    fd \
    fzf \
    ghostty \
    git-delta \
    gnome-themes-extra \
    hyprcursor \
    hypridle \
    hyprland \
    hyprshot \
    jq \
    lazydocker-bin \
    lazygit \
    less \
    matugen \
    neovim \
    numix-circle-icon-theme-git \
    nwg-look \
    pavucontrol \
    pacman-contrib \
    pass \
    power-profiles-daemon \
    qt5-wayland \
    qt6-wayland \
    qt6ct \
    quickshell-git \
    ripgrep \
    satty \
    slurp \
    sound-theme-freedesktop \
    starship \
    stow \
    tmux \
    ttf-jetbrains-mono-nerd \
    ttf-nerd-fonts-symbols \
    ttf-rubik-vf \
    vscodium-bin \
    wf-recorder \
    wireplumber \
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
