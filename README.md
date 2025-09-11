# Dotfiles.

Hypr dotfile configuration.

## Prerequisites

### Install Paru

```bash
$ sudo pacman -S --needed base-devel
$ git clone https://aur.archlinux.org/paru.git
$ cd paru
$ makepkg -si
```
## Installation

Clone dotfiles into your `$HOME` directory.

```bash
$ git clone git@github.com/nickjedwards/dotfiles.git
$ cd dotfiles
$ ./install.sh
```
## Usage

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

### Wallpaper

**Note:** A wallpaper is required for Hyprpaper, Rofi and Swaylock to appear correctly.

```bash
ln -sf ~/dotfiles/wallpapers/swirls.jpg ~/.config/wallpaper
```

# Resources

- [Wallpapers](https://github.com/orangci/walls-catppuccin-mocha)
- [Hyprland NVidia](https://wiki.hyprland.org/Nvidia/)
- [Single GPU Passthrough (Nvidia)](https://github.com/Marrca35/Single-GPU-Passthrough-for-Arch-Linux)
- [NeoVim Lua configuration for PHP and JavaScript](https://marioyepes.com/blog/neovim-ide-with-lua-for-web-development/)
