# Do not store commands prefixed with a space
setopt HIST_IGNORE_SPACE

#Delays the Homebrew auto update so it's mostly invisible.
#Ensure https://github.com/DomT4/homebrew-autoupdate is active
#Run once per computer: brew autoupdate --start 86400
export HOMEBREW_AUTO_UPDATE_SECS="86400"

export EDITOR='vim'
export VISUAL='code'

# https://github.com/sharkdp/bat
[[ -f /usr/local/bin/bat ]] && alias cat=bat
[[ -f /usr/local/bin/dua ]] && alias du=dua
# https://github.com/BurntSushi/ripgrep
[[ -f /usr/local/bin/rg  ]] && alias grep=rg
# https://github.com/sharkdp/fd
# [[ -f /usr/local/bin/fd  ]] && alias find=find



if [[ -f /usr/local/bin/exa ]]; then 
	alias ls=exa

	alias l='ls -1a'         # Lists in one column, hidden files.
	alias ll='ls -l --git --icons'        # Lists human readable sizes.
	alias lr='ll -R'         # Lists human readable sizes, recursively.
	alias la='ll -a'         # Lists human readable sizes, hidden files.
	alias lm='la | "$PAGER"' # Lists human readable sizes, hidden files through pager.
	alias lx='ll -XB'        # Lists sorted by extension (GNU only).
	alias lk='ll -Sr'        # Lists sorted by size, largest last.
	alias lt='ll -tr'        # Lists sorted by date, most recent last.
	alias lc='lt -c'         # Lists sorted by date, most recent last, shows change time.
	alias lu='lt -u'         # Lists sorted by date, most recent last, shows access time.
	alias sl='ls'            # I often screw this up.

fi


alias cdd="cd ~/Downloads"
alias dl="cd ~/Downloads"

alias youtubedl="brew upgrade youtube-dl ; youtube-dl -f 'bestvideo[ext=mp4][fps<50]+bestaudio[ext=m4a]/best[ext=mp4]/best' --no-playlist"
alias youtubedl_720p="brew upgrade youtube-dl ; youtube-dl -f '136+bestaudio[ext=m4a]/bestvideo[ext=mp4][fps<50][height<=720p]+bestaudio[ext=m4a]/best[ext=mp4][height<=720p]' --no-playlist"


unalias o
function o {
  if [[ $# -gt 0 ]]; then
      open $1
  else
      open .
  fi
}

alias timestamp='date +"%s"'
alias sb='e ~/.zprezto && e ~/.zpreztorc && sbt && e ~/.zprezto/modules/carlosefonseca/init.zsh && rb'
alias sbc='e ~/.zprezto/modules/carlosefonseca/init.zsh'
alias sbt='e ~/.zprezto/modules/talkdesk/init.zsh'
alias rb='exec zsh'
alias s="e ."
alias f="fork ."

function pry_r {
  pry -e "require_relative \"$1\""
}

# export GEM_HOME=$HOME/.gems/3.0

# export PATH=/usr/local/opt/ruby/bin:$GEM_HOME/bin:/usr/local/lib/ruby/gems/2.7.0/bin:$PATH


# check for system java before doing this.
# export JAVA_HOME=/Applications/Android\ Studio.app/Contents/jre/jdk/Contents/Home



# Remember:
# slit N -> Print column N
# get URL -> Downloads file
# find-exec *.txt rm
# cdls
# http-serve

path+=("${0:h}/bin")

alias zap="brew uninstall --zap"

eval $(/opt/homebrew/bin/brew shellenv)

# Python for TTY
if command -v pyenv 1>/dev/null 2>&1; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

alias wget="curl -O"
