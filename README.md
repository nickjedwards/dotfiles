# .Dotfiles

My dotfile configuration.

## Prerequisites

### Stow

```sh
sudo apt install stow
```

### Kitty

```sh
$ curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
$ ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
$ cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
$ sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty.desktop
$ sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty.desktop
```

### Alacritty

```sh
sudo apt install alacritty
```

### Zsh && Oh My ZSH!

```sh
$ sudo apt install zsh
$ chsh -s $(which zsh)
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Tmux

```sh
sudo apt install tmux
```

### ripgrep

```sh
sudo apt install ripgrep
```

### Neovim

```sh
sudo snap install nvim --classic
```

## Installation

Clone dotfiles into your `$HOME` directory

```sh
$ git clone git@github.com/nickjedwards/dotfiles.git
$ cd dotfiles
```

Create symlinks

```sh
stow .
```
