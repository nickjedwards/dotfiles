# .Dotfiles

My dotfile configuration.

## Prerequisites

### Stow

```sh
sudo apt install stow
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

### Neovim && NvChad

```sh
$ sudo snap install nvim --classic
$ git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
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
