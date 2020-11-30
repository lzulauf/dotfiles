# dotfiles
My configuration files

# Setup
1. git clone dotfiles
1. Symlink files into home directory
    1. `ln -s dotfiles/gitconfig .gitconfig`
    1. `ln -s dotfiles/gitignore_global .gitignore_global`
    1. `ln -s dotfiles/python .python`
    1. `ln -s dotfiles/inputrc .inputrc` (readline setup)
1. Create .zshrc: `echo "source dotfiles/zshrc/zshrc" > .zshrc`
1. Add starship configuration: `mkdir -p ~/.config && ln -s ~/dotfiles/starship.toml ~/.config/`
1. Create .tmux.conf: `echo "source-file dotfiles/tmux_general.conf" > .tmux.conf`
1. Brew Installation
    1. Install Brew (https://brew.sh/)
    1. `ln -s dotfiles/Brewfile ~/.Brewfile`
    1. `brew bundle --global`
  
