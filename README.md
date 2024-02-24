# dotfiles

These dotfiles include [nvchad](https://github.com/NvChad/NvChad)

The folder `.config/nvim/custom` is precisely the custom config for nvchad

### Install general packages 
`sudo apt update && sudo apt install -y $(cat pkglist.txt | egrep -v "(^#.*|^$)")`

### Install thefuck tool
pip3 install thefuck --user

### Install ohmyzsh
https://ohmyz.sh/#install

### You may need to add the following to the PATH
`$HOME/.local/bin`

### change the default shell
`chsh -s $(which zsh)`

### Install 'mandatory' oh-my-zsh plygins
`chmod +x clone-all-repos.sh && ./clone-all-repos.sh`

### Install neovim
`https://github.com/neovim/neovim/wiki/Installing-Neovim#linux`

### Install NvChad
https://github.com/NvChad/NvChad

### Setup the config
`cp -r nvim/custom ~/.config/nvim/lua 
`nvim`
`PackerSync`

### Install Node
https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-20-04#option-3-installing-node-using-the-node-version-manager

### Install go
https://go.dev/doc/install

### Install alacritty
`sudo add-apt-repository ppa:mmstick76/alacritty`
`sudo apt update`
`sudo apt install alacritty`

### Copy the config file
`cp .alacritty.yml ~/.alacritty.yml`

### tmux
`mkdir -p ~/.tmux/plugins/`
`git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/`
`cp .tmux.conf ~/`

`sudo apt install tmuxinator`
