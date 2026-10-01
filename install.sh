#!/usr/bin/env bash

# Install pacman/AUR packages
yes '' | paru -S \
    bat \
    bibata-cursor-theme-bin \
    brightnessctl \
    btop \
    cava \
    cliphist \
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
    hyprlock \
    hyprpaper \
    hyprshot \
    hyprsunset \
    jq \
    lazydocker-bin \
    lazygit \
    less \
    neovim \
    numix-circle-icon-theme-git \
    nwg-look \
    pavucontrol \
    pacman-contrib \
    pass \
    pipewire \
    playerctl \
    power-profiles-daemon \
    qt5-wayland \
    qt6-wayland \
    qt6ct \
    quickshell \
    ripgrep \
    satty \
    slurp \
    sound-theme-freedesktop \
    starship \
    stow \
    tmux \
    ttf-inter \
    ttf-jetbrains-mono-nerd \
    ttf-nerd-fonts-symbols \
    wf-recorder \
    wireplumber \
    xdg-desktop-portal-hyprland \
    zed \
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

# Stow prerequisites
stow bat paru tmux zsh

# Install shell
yes '' | paru -Sy morphin
ln -sf ${HOME}/.dotfiles/wallpapers/swirls.jpg ~/.config/wallpaper

# Install tmux catppuccin theme
mkdir -p ${HOME}/.config/tmux/plugins/catppuccin
git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ${HOME}/.config/tmux/plugins/catppuccin/tmux

# Configure bat theme
bat cache --build
