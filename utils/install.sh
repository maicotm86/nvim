#!/bin/bash

set -o nounset    # error when referencing undefined variable
set -o errexit    # exit when command fails


installnode() { \
  echo "Installing node..."
  curl -sL install-node.now.sh/lts | bash
  npm i -g neovim
}

installpip() { \
  echo "Installing pip..."
  curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
  python3 get-pip.py
  rm get-pip.py
}

installpynvim() { \
  echo "Installing pynvim..."
  pip install pynvim
}

installcocextensions() { \
  # Install extensions
  mkdir -p ~/.config/coc/extensions
  cd ~/.config/coc/extensions
  [ ! -f package.json ] && echo '{"dependencies":{}}'> package.json
  # Change extension names to the extensions you need
  npm install coc-explorer coc-snippets coc-json --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod
}

cloneconfig() { \
  echo "Cloning Nvim Mach 2 configuration"
  git clone https://github.com/ChristianChiarulli/nvim.git ~/.config/nvim
}

moveoldnvim() { \
  echo "Moving your config to nvim.old"
  mv $HOME/.config/nvim $HOME/.config/nvim.old
}

installplugins() { \
  mv $HOME/.config/nvim/init.vim $HOME/.config/nvim/init.vim.tmp
  mv $HOME/.config/nvim/utils/init.vim $HOME/.config/nvim/init.vim
  echo "Installing plugins..."
  nvim --headless +PlugInstall +qall > /dev/null 2>&1
  mv $HOME/.config/nvim/init.vim $HOME/.config/nvim/utils/init.vim
  mv $HOME/.config/nvim/init.vim.tmp $HOME/.config/nvim/init.vim
}

asktoinstallnode() { \
  echo "node not found"
  echo -n "Would you like to install node now (y/n)? "
  read answer
  [ "$answer" != "${answer#[Yy]}" ] && installnode && installcocextensions
}

asktoinstallpip() { \
  echo "pip not found"
  echo -n "Would you like to install pip now (y/n)? "
  read answer
  [ "$answer" != "${answer#[Yy]}" ] && installpip
}

installonmac() { \
  brew install ripgrep fzf ranger
}

pipinstallueberzug() { \
  which pip > /dev/null && pip install ueberzug || echo "Not installing ueberzug pip not found"
}

installonubuntu() { \
  sudo apt install ripgrep fzf ranger  
  pipinstallueberzug
}


installonarch() { \
  sudo pacman -S install ripgrep fzf ranger
  which yay > /dev/null && yay -S python-ueberzug-git || pipinstallueberzug
}

installextrapackages() { \
  [ "$(uname)" == "Darwin" ] && installonmac
  [  -n "$(uname -a | grep Ubuntu)" ] && installonubuntu
  [ -f "/etc/arch-release" ] && installonarch
  [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ] && echo "Windows not currently supported"
}

# Welcome
echo 'Installing Nvim Mach 2'

# install node and neovim support
which node > /dev/null && echo "node installed, moving on..." || asktoinstallnode

# install pip
which pip > /dev/null && echo "pip installed, moving on..." || asktoinstallpip

# install pynvim
pip list | grep pynvim > /dev/null && echo "pynvim installed, moving on..." || installpynvim

# move old nvim directory if it exists
[ -d "$HOME/.config/nvim" ] && moveoldnvim 

# clone config down
cloneconfig

echo "Nvim Mach 2 is better with at least ripgrep, ueberzug and ranger"
echo -n "Would you like to install these now?  (y/n)? "
read answer
[ "$answer" != "${answer#[Yy]}" ] && installextrapackages || echo "not installing extra packages"

# install plugins
which nvim > /dev/null && installplugins
