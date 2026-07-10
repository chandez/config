# oh-my-posh
eval "$(oh-my-posh init zsh --config $HOME/.config/non-terminal-minimal.omp.toml)"

# plugins
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# Bindkey  
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down