# [General Settings]
# Ensure that there is dot zsh directory
# setopt needed to silence pushd/popd messages
setopt pushdsilent
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

# Remove suffix chars (otherwise default value but without pipe)
ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&'

# Store OS for later use
OS=$(uname -s)

# [Command History Settings]
HISTFILE=$ZDOTDIR/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups hist_ignore_space share_history inc_append_history extended_history hist_verify


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

# Esc to work as undoing key
bindkey "\e" undo


# [Autocorrection Settings]
setopt correct_all


# [Command Completion Settings]
# See: http://zsh.sourceforge.net/Doc/Release/Completion-System.html

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate

# for all completions: grouping the output
zstyle ':completion:*' group-name ''

# show original completion first
zstyle ':completion:*' group-order original corrections

# Allow 2 errors in approximate completion
zstyle ':completion:*:approximate:*' max-errors 2

# colored completion - use my LS_COLORS
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

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

autoload -Uz compinit
compinit


# [Color Settings]
autoload -Uz colors
colors

# Alias various commands to produce colored output
# There are some differences between syntax for different operating systems
case "$OS" in
"Darwin")
    alias ls='ls -G'
    ;;
"Linux")
   alias ls='ls --color=auto'
   ;;
esac

alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'
alias grep='grep --colour=auto'



# [Version Control Module Settings]
# Needed for vcs_info prompt substitution
setopt prompt_subst

# Enabling and configuring vcs_info module
# http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Version-Control-Information
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git cvs svn hg
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' actionformats ' %F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f'
zstyle ':vcs_info:*' formats ' %F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f'
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'


# [Prompt Color and Output Settings]
# Fetch version control information before formatting prompt
precmd() {
    vcs_info
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
   ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor line)
fi

# Utilize history substring search
# https://github.com/zsh-users/zsh-history-substring-search
if [ -e $ZDOTDIR/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
   source $ZDOTDIR/zsh-history-substring-search/zsh-history-substring-search.zsh

   # Re-bind the up/down keys to history searches 
   bindkey '^[[A' history-substring-search-up
   bindkey '^[[B' history-substring-search-down
fi
