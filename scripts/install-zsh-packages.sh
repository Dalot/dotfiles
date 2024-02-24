# This package provides syntax highlighting for the shell 
#zsh-syntax-highlighting-git

#Implementation of fish shell's history search to type any command from history.
#zsh-history-substring-search

#auto-suggestions/auto-completion
#zsh-autosuggestions

cd $ZSH/plugins
rm -rf zsh-syntax-highlighting && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
rm -rf zsh-history-substring-search && git clone https://github.com/zsh-users/zsh-history-substring-search
rm -rf zsh-autosuggestions && git clone https://github.com/zsh-users/zsh-autosuggestions
cd -
