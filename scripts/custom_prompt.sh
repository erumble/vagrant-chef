# Place this file in /etc/profile.d and wonderful things will happen

# Define some colors
default='\[\033[00m\]'
bold='\[\033[01m\]'
red='\[\033[31m\]'
green='\[\033[32m\]'
yellow='\[\033[33m\]'
blue='\[\033[34m\]'
magenta='\[\033[35m\]'
cyan='\[\033[36m\]'
white='\[\033[37m\]'

# Git branch in prompt.
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Color ls
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# Create a nice colorful command prompt
export PS1="${default}\u@\h ${bold}${blue}\W${green}\$(parse_git_branch)${default} $ "

# Aliases go here
alias reload='source ~/.bash_profile'
alias ls='ls -alh --color=always'
alias be='bundle exec'
alias bi='bundle install'
alias bu='bundle update'

