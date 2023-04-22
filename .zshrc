#################
### ALL MERGE ###
#################

export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"
export ZPLUGDIR="$HOME/.local/src/zsh_plugins"
# export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export TMUX_CONFIG_DIR="$XDG_CONFIG_HOME/tmux"

# Default programs:
export EDITOR="lvim"
export TERMINAL="kitty"
export BROWSER="firefox"
export FMGR="dolphin"

# Other programs settings
export FZF_DEFAULT_OPTS="--layout=reverse --height 40%"

#############
### ZSHRC ###
#############

# Remove background color while listing mounted file
eval "$(dircolors -b ~/.config/zsh/.dircolors)"

# History in cache directory:
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.cache/.zsh_history
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# some useful options (man zshoptions)
setopt autocd extendedglob nomatch menucomplete
setopt interactive_comments
unsetopt PROMPT_SP
stty stop undef		# Disable ctrl-s to freeze terminal.
zle_highlight=('paste:none')

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Useful for substring completion history
# bindkey "^K" history-beginning-search-backward
# bindkey "^J" history-beginning-search-forward
bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward
# Disabling ctrl j,k. It causes auto enter not work

# Move cursor back/forward word with ctrl-<left,right>
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word

# Delete per word with ctrl-<backspace,delete>
bindkey "^H" backward-delete-word
bindkey "^[[M" delete-word
bindkey '^[[P' delete-char
bindkey '^[[3~' delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select () {
case $KEYMAP in
  vicmd) echo -ne '\e[1 q';;      # block
  viins|main) echo -ne '\e[5 q';; # beam
esac
}
zle -N zle-keymap-select
zle-line-init() {
zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
  tmp="$(mktemp -uq)"
  trap 'rm -f $tmp >/dev/null 2>&1 && trap - HUP INT QUIT TERM PWR EXIT' HUP INT QUIT TERM PWR EXIT
  lf -last-dir-path="$tmp" "$@"
  if [ -f "$tmp" ]; then
    dir="$(cat "$tmp")"
    [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
  fi
}
bindkey -s '^o' '^ulfcd\n'
bindkey -s '^s' '^usource $HOME/.zshrc\n'
bindkey -s '^y' '^ubc -lq\n'
bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^[[P' vi-delete-char
bindkey -M vicmd '^e' edit-command-line
bindkey -M visual '^[[P' vi-delete

## zsh abbreviation start
# declare a list of expandable aliases to fill up later
typeset -a ealiases
ealiases=()

# write a function for adding an alias to the list mentioned above
function abbrev-alias() {
alias $1
ealiases+=(${1%%\=*})
}

# expand any aliases in the current line buffer
function expand-ealias() {
if [[ $LBUFFER =~ "\<(${(j:|:)ealiases})\$" ]]; then
  zle _expand_alias
  zle expand-word
fi
zle magic-space
}
zle -N expand-ealias

# Bind the space key to the expand-alias function above, so that space will expand any expandable aliases
bindkey ' '        expand-ealias
bindkey '^ '       magic-space     # control-space to bypass completion
bindkey -M isearch " "      magic-space     # normal space during searches

# A function for expanding any aliases before accepting the line as is and executing the entered command
expand-alias-and-accept-line() {
expand-ealias
zle .backward-delete-char
zle .accept-line
}
zle -N accept-line expand-alias-and-accept-line

# ALIASES
abbrev-alias g="git"
abbrev-alias gst="git status"
abbrev-alias ll="ls -l"
abbrev-alias lm="lampstatus"
abbrev-alias lsuser="awk -F':' '{ print $1}' /etc/passwd"
abbrev-alias lsgroup="cut -d: -f1 /etc/group | sort"
abbrev-alias refont="sudo fc-cache -fv"
abbrev-alias tn="tmux new-session -s "
abbrev-alias tk="tmux kill-session -t "
abbrev-alias trn="tmux rename-session -t "
abbrev-alias tc="tmux attach-session -t "
## zsh abbreviation end
# zshrc end

###############
### ALIASES ###
###############

alias \
	neofetch="fastfetch" \
	bc="bc -ql" \
	ll="ls -l" \
	ls="ls -hN --color=auto --group-directories-first" \
	l="ls -l" \
	la="ls -la" \
	ltr="ls -ltrh" \
	ltra="ls -ltrah" \
	lf="lfub" \
	f="lfub" \
	F="$FMGR ." \
	v="lvim" \
	vv="nvim" \
	vim="vim" \
	tmux="tmux -f $TMUX_CONFIG_DIR/tmux.conf" \
	t="tmux" \
	ta="tmux a" \
	tK="tmux kill-server && echo tmux session killed" \
	tl="tmux ls" \
	tx="tmuxinator" \
	trashput="trash-put" \
	trashempty="trash-empty" \
	trashlist="trash-list" \
	trashrestore="trash-restore" \
	trashrm="trash-rm" \

#################
### SHORTCUTS ###
#################

# vim: filetype=sh
alias cac="cd /home/agung/.cache && ls -a" \
h="cd ~/ && ls -a" \
d="cd ~/Downloads && ls -a" \
D="cd ~/Documents && ls -a" \
p="cd ~/Pictures && ls -a" \
m="cd ~/Music && ls -a" \
vd="cd ~/Videos && ls -a" \
cdd="cd ~/.dotfiles && ls -a" \
cds="cd ~/.stuff && ls -a" \
cf="cd ~/.config && ls -a" \
cw="cd ~/Documents/web && ls -a" \
lc="cd ~/.local && ls -a" \
lcb="cd ~/.local/bin && ls -a" \
lcs="cd ~/.local/share && ls -a" \
htd="cd /srv/http && ls -la" \
sl="cd $HOME/.local/src/suckless && ls -la" \
vb="$EDITOR ~/.local/bin" \
vn="$EDITOR ~/.config/nvim" \
vx="$EDITOR ~/.config/x11/xinitrc" \
vt="$EDITOR ~/.config/tmux/tmux.conf" \
vz="$EDITOR ~/.zshrc" \
vs="cd /etc/sway/ && $EDITOR config" \

##############
### PROMPT ###
##############
## autoload vcs and colors
autoload -Uz vcs_info
autoload -U colors && colors

# enable only git
zstyle ':vcs_info:*' enable git

# setup a hook that runs before every ptompt.
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst

# add a function to check for untracked files in the directory.
# from https://github.com/zsh-users/zsh/blob/master/Misc/vcs_info-examples
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

+vi-git-untracked(){
if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
  git status --porcelain | grep '??' &> /dev/null ; then
  hook_com[staged]+='!' # signify new files with a bang
  fi
}

zstyle ':vcs_info:*' check-for-changes true
# zstyle ':vcs_info:git:*' formats " %r/%S %b %m%u%c "
zstyle ':vcs_info:git:*' formats " %{$fg[blue]%}(%{$fg[red]%}%m%u%c%{$fg[yellow]%}%{$fg[magenta]%} %b%{$fg[blue]%})"

PROMPT="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%m%{$fg[red]%}] %(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )%{$fg[cyan]%}%c%{$reset_color%}"

setopt autocd		# Automatically cd into typed directory.
stty stop undef		# Disable ctrl-s to freeze terminal.
setopt interactive_comments

PROMPT+="\$vcs_info_msg_0_ "

#####################################
### Sourcing plugins in $ZPLUGDIR ###
#####################################

source $ZPLUGDIR/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null
source $ZPLUGDIR/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh 2>/dev/null
source $ZPLUGDIR/zsh-autopair/autopair.plugin.zsh 2>/dev/null
