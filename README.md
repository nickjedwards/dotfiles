# Dotfiles.

Hypr dotfile configuration.

## Prerequisites

### Install Pacman packages

```bash
sudo pacman -S bat \
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
```

### Paru

#### Install Paru

```bash
$ sudo pacman -S --needed base-devel
$ git clone https://aur.archlinux.org/paru.git
$ cd paru
$ makepkg -si
```

#### Install AUR packages

```bash
paru -S rofi-wayland swaylock-effects waybar wlogout
```

### Zsh && Oh My ZSH!

```bash
$ chsh -s $(which zsh)
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### Zsh plugins

**zsh-autosuggestions**

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

**zsh-syntax-highlighting**

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

**zsh-completions**

```bash
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
```

### fzf-git

```bash
git clone https://github.com/junegunn/fzf-git.sh.git
```

### Apply Bat theme

```bash
bat cache --build
```

## Installation

Clone dotfiles into your `$HOME` directory.

```bash
$ git clone git@github.com/nickjedwards/dotfiles.git
$ cd dotfiles
```

Do not modify the file system and instead show what would happen.

```bash
stow --simulate --verbose [package] # E.g.: `stow -nv nvim`
```

Install (stow) the package name(s).

```bash
stow [package] # E.g.: `stow nvim`
```

Delete (unstow) the package name(s).

```bash
stow --delete [package] # E.g.: `stow --delete nvim`
```

# Resources

- [Hyprland NVidia](https://wiki.hyprland.org/Nvidia/)
- [Single GPU Passthrough (Nvidia)](https://github.com/Marrca35/Single-GPU-Passthrough-for-Arch-Linux)
- [NeoVim Lua configuration for PHP and JavaScript](https://marioyepes.com/blog/neovim-ide-with-lua-for-web-development/)
