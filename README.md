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

### fzf

```sh
$ git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
$ ~/.fzf/install
```

### fzf-git

### fd

### bat

```sh
git clone https://github.com/junegunn/fzf-git.sh.git
```

### git-delta

Install .deb from [releases](https://github.com/dandavison/delta/releases)

### eza

```sh
$ sudo mkdir -p /etc/apt/keyrings
$ wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
$ echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
$ sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
$ sudo apt update
$ sudo apt install -y eza
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

# Resources

- [NeoVim Lua configuration for PHP and JavaScript](https://marioyepes.com/blog/neovim-ide-with-lua-for-web-development/)
