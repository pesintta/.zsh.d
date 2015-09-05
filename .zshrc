# [General Settings]
# Ensure that there is dot zsh directory
setopt pushdsilent              # setopt needed to silence pushd/popd messages
setopt extended_glob            # enable zsh style globbing
setopt no_nomatch               # proceed with cmd even if glob does not match
if [ -z "$ZDOTDIR" ]; then
   if [ -L ~/.zshrc ]; then
      pushd
      cd $(dirname $(readlink ~/.zshrc))
      ZDOTDIR=$(pwd -P)
      popd
   else
      ZDOTDIR=$(dirname ~/.zshrc)
   fi
fi
if [ ! -d $ZDOTDIR ]; then mkdir -p $ZDOTDIR; fi

# Populate LS_COLORS
if [ -x /usr/bin/dircolors ]; then
   if [ -r ~/.dir_colors ]; then
      eval "`dircolors ~/.dir_colors`"
   elif [ -r /etc/dir_colors ]; then
      eval "`dircolors /etc/dir_colors`"
   else
      eval "`dircolors`"
   fi
fi

# Remove suffix chars (otherwise default value but without pipe)
ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&'

# Store OS for later use
OS=$(uname -s)

# [Command History Settings]
HISTFILE=$ZDOTDIR/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups hist_ignore_space hist_reduce_blanks extended_history hist_verify


# [Directory Stack Settings]
# Dirstack options
DIRSTACKSIZE=20
setopt autopushd pushdminus pushdtohome
# Ignore duplicates in stack
setopt pushdignoredups
alias d="dirs -v"

# Keep a persistent dirstack in $ZDTODIR/.zdirstack
DIRSTACKFILE="$ZDOTDIR/.zdirstack"
if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
   dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
   [[ -d $dirstack[1] ]] && cd $dirstack[1]
fi
chpwd() {
   print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
}


# [Key Binding Settings]
# One can type cat and press the key that does not work to get the keycode...
# Setting default (emacs) mode of keybindings
bindkey -e

# Terminal kursor moving keys (Home,End,Delete)
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[3~" delete-char

# PageUp, PageDown move in history (like in bash)
bindkey "\e[5~" up-line-or-history
bindkey "\e[6~" down-line-or-history

# Esc to work as undoing key
bindkey "\e" undo

# Shift-Tab as reverse complete
bindkey "\e[Z" reverse-menu-complete

# Ctrl / Alt + arrow move left/right a word
bindkey "\e[1;3C" forward-word
bindkey "\e[1;3D" backward-word
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word


# [Autocorrection Settings]
setopt correct_all

# Ignore corrections that begin with underscore (internal functions mostly)
CORRECT_IGNORE="_*"
# Ignore file corrections that begin with a dot (available from zsh 5.0.7 -> ) 
CORRECT_IGNORE_FILE=".*"


# [Command Completion Settings]
# See: http://zsh.sourceforge.net/Doc/Release/Completion-System.html

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate

# for all completions: grouping the output
zstyle ':completion:*' group-name ''

# show original completion first
zstyle ':completion:*' group-order original corrections

# Allow 2 errors in approximate completion
zstyle ':completion:*:approximate:*' max-errors 2

# colored completion - use my LS_COLORS if available
zstyle ':completion:*' list-colors ''
if [ -n "$LS_COLORS" ]; then
   zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
fi

# Enable completion menu by arrow keys
zstyle ':completion:*' menu select

# Case insensitive completion matching and substring completion
zstyle ':completion:*' matcher-list 'm:{a-zåäöûA-ZÅÄÖÛ}={A-ZÅÄÖÛa-zåäöû}' 'r:|[._-]=* r:|=*' ' l:|=* r:|=*'

# Some command specific completions
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# for all completions: grouping / headline / ...
zstyle ':completion:*:messages' format $'\e[01;35m -- %d -- \e[00;00m'
zstyle ':completion:*:warnings' format $'\e[01;31m -- No Matches Found -- \e[00;00m'
zstyle ':completion:*:descriptions' format $'\e[01;33m -- %d -- \e[00;00m'
zstyle ':completion:*:corrections' format $'\e[01;33m -- %d -- \e[00;00m'

# statusline for many hits
zstyle ':completion:*:default' select-prompt $'\e[01;35m -- Match %M    %P -- \e[00;00m'

# for all completions: show comments when present
zstyle ':completion:*' verbose yes

# Completion caching for speed
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $ZDOTDIR/.zcompcache

# auto rehash commands after completion mismatch
# http://www.zsh.org/mla/users/2011/msg00531.html
zstyle ':completion:*' rehash true

zstyle :compinstall filename '~/.zshrc'

# add custom completions if they exist
if [ -d $ZDOTDIR/gentoo-zsh-completions/src ]; then
   fpath=("$ZDOTDIR/gentoo-zsh-completions/src" $fpath)
fi

autoload -Uz compinit
compinit

# Force loading of completion list and bind '+' key to accept but stay in menu
zmodload zsh/complist
bindkey -M menuselect "+" accept-and-menu-complete


# [Color Settings]
autoload -Uz colors
colors

# Alias various commands to produce colored output
# There are some differences between syntax for different operating systems
case "$OS" in
"Darwin")
   alias l='ls -G'
   alias ls='ls -G'
   alias ll='ls -la -G'
    ;;
"Linux")
   alias l='ls --color=auto'
   alias ls='ls --color=auto'
   alias ll='ls -la --color=auto'
   ;;
esac

alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'
alias grep='grep --colour=auto'

alias x='exit'


# [Version Control Module Settings]
# Needed for vcs_info prompt substitution
setopt prompt_subst

# Enabling and configuring vcs_info module
# http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Version-Control-Information
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git cvs svn hg
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%F{6}●'
zstyle ':vcs_info:*' unstagedstr '%F{3}●'
zstyle ':vcs_info:*' actionformats ' %F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%c%u%F{3}|%F{1}%a%F{5}]%m%f'
zstyle ':vcs_info:*' formats ' %F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%c%u%F{5}]%m%f'
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
zstyle ':vcs_info:git*+set-message:*' hooks git-status

# Extra hook run in case of git
# This will fill vcs_info variable %m with extra informative status
function +vi-git-status() {
   local ahead behind
   local -a gitstatus

   ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD --count 2> /dev/null)
   (( $ahead )) && gitstatus+=( "%B%F{4}↑${ahead}%f%b" )

   behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} --count 2> /dev/null)
   (( $behind )) && gitstatus+=( "%B%F{5}↓${behind}%f%b" )

   hook_com[misc]+=$gitstatus
}


# [Prompt Color and Output Theme Settings]
# Generic function to set terminal title
function title {
   [[ "$EMACS" == *term* ]] && return

   # if $2 is unset use $1 as default
   # if it is set and empty, leave it as is
   : ${2=$1}

   if [[ "$TERM" == screen* ]]; then
      print -Pn "\ek$1:q\e\\" #set screen hardstatus, usually truncated at 20 chars
   elif [[ "$TERM" == xterm* ]] || [[ "$TERM" == rxvt* ]] || [[ "$TERM" == ansi ]] || [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
      print -Pn "\e]2;$2:q\a" #set window name
      print -Pn "\e]1;$1:q\a" #set icon (=tab) name
   fi
}

# Default terminal titles for terminals and tabs
ZSH_THEME_TERM_TAB_TITLE_IDLE="%15<..<%~%<<" #15 char left truncated PWD
ZSH_THEME_TERM_TITLE_IDLE="%n@%m: %~"

# Fetch version control information before formatting prompt
precmd() {
   vcs_info
   title $ZSH_THEME_TERM_TAB_TITLE_IDLE $ZSH_THEME_TERM_TITLE_IDLE
}

# Fetch command that is about to be executed and set it to title
preexec() {
   emulate -L zsh

   # cmd name only, or if this is sudo or ssh, the next cmd
   local CMD=${1[(wr)^(*=*|sudo|ssh|rake|-*)]:gs/%/%%}
   local LINE="${2:gs/%/%%}"

   title '$CMD' '%100>...>$LINE%<<'
}

# Prompt like "username@host ~/relativepath %"
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
# for possible settings.
# Also doing color configuration (for root as well) and git prompt
# SSH'ed connections are prefixed with red (ssh)

function ssh_prompt {
   if [ -n "$SSH_CLIENT" ]; then echo "(ssh) "; else echo ""; fi
}

PROMPT='%{$fg_bold[red]%}$(ssh_prompt)%(!.%{$fg_bold[red]%}.%{$fg_bold[green]%}%n@)%m %{$fg_bold[blue]%}%(!.%1~.%~) %{$reset_color%}%#${vcs_info_msg_0_} '

# Clock on the right hand side
RPROMPT='%{$fg[red]%}%*%{$reset_color%}'


# [Plugin and Extension Settings]
# Syntax highlighting (needs to be before history substring searches)
# https://github.com/zsh-users/zsh-syntax-highlighting
if [ -e $ZDOTDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
   source $ZDOTDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
   ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern line)
fi

# Utilize history substring search
# https://github.com/zsh-users/zsh-history-substring-search
if [ -e $ZDOTDIR/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
   source $ZDOTDIR/zsh-history-substring-search/zsh-history-substring-search.zsh

   # Re-bind the up/down keys to history searches 
   bindkey '^[[A' history-substring-search-up
   bindkey '^[[B' history-substring-search-down
fi
