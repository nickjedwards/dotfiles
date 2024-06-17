#!/usr/bin/env bash

# Install Pacman packages
yes '' | sudo pacman -S bat \
    eza \
    fd \
    fzf \
    git-delta \
    jq \
    hyprland \
    hyprpaper \
    neovim \
    pavucontrol \
    ripgrep \
    starship \
    stow \
    tmux \
    wireplumber \
    zsh

# Install AUR packages
yes '' | paru -S rofi-wayland swaylock-effects waybar wlogout

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

# Apply Bat theme
bat cache --build

