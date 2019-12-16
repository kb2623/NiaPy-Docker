autoload -Uz compinit promptinit
compinit
promptinit

# Vi mode
bindkey -v

# This will set the default prompt to the walters theme
prompt adam2

alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

