setopt autocd		# Automatically cd into typed directory.
stty stop undef		# Disable ctrl-s to freeze terminal.

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# GITSTATUS_LOG_LEVEL=ERROR

# XDG
# XDG_CONFIG_HOME not explicitly set defaults to: $HOME/.config
# XDG_DATA_HOME: not explicitly set defaults to: $HOME/.local/share
# XDG_CONFIG_DIRS not explicitly set defaults to: /etc/xdg
# XDG_DATA_DIRS: not explicitly set defaults to: /usr/local/share/:/usr/share/
# XDG_DATA_RUNTIME_DIR: not explicitly set defaults to: <??>

# Alias to startx
export XDG_DATA_HOME=${HOME}/.local/share
export XDG_CONFIG_HOME=${HOME}/.config
export XDG_CACHE_HOME=${HOME}/.cache
export RUSTUP_HOME=${XDG_DATA_HOME}/rustup
export CARGO_HOME=${XDG_DATA_HOME}/cargo
alias startx='startx ${XDG_CONFIG_HOME}/X11/xinitrc'
alias gpg='gpg2 --homedir ${XDG_DATA_HOME}/gnupg'
alias mbsync='mbsync -c ${XDG_CONFIG_HOME}/isync/mbsyncrc'
alias lynx='lynx -cfg=${XDG_CONFIG_HOME}/lynx/lynx.cfg -lss=${XDG_CONFIG_HOME}/lynx/lynx.lss'
export AWS_SHARED_CREDENTIALS_FILE=${XDG_CONFIG_HOME}/aws/credentials
export AWS_CONFIG_FILE=${XDG_CONFIG_HOME}/aws/config
export TMUX_CONFIG="{$XDG_CONFIG_HOME}/tmux/tmux.conf"
export GNUPGHOME=${XDG_DATA_HOME}/gnupg
export LESSKEY=${XDG_CONFIG_HOME}/less/lesskey
export LESSHISTFILE=${XDG_CACHE_HOME}/less/history
export NOTMUCH_CONFIG=${XDG_CONFIG_HOME}/notmuch/notmuchrc
export NMBGIT=${XDG_DATA_HOME}/notmuch/nmbug
export NPM_CONFIG_USERCONFIG=${XDG_CONFIG_HOME}/npm/npmrc
export PASSWORD_STORE_DIR=${XDG_DATA_HOME}/pass
export PYLINTHOME=${XDG_CACHE_HOME}/pylint
export XAUTHORITY=${XDG_RUNTIME_DIR}/Xauthority
export DOCKER_CONFIG=${XDG_CONFIG_HOME}/docker
export DOCKER_CLI_EXPERIMENTAL=enabled
export LAMBDA_ARCH="linux/arm64"
export RUST_TARGET="aarch64-unknown-linux-gnu"
export RUST_VERSION="latest"
export PROJECT_NAME="rust_on_aws"


# Load aliases and shortcuts if existent.
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/shortcutrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/shortcutrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/functionsrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/functionsrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/zshnameddirrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/zshnameddirrc"

# Enable colors and change prompt:
autoload -U colors && colors	# Load colors
# PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
# Assembling the prompt
setopt prompt_subst # set prompt substitution option
#[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/zshrc.sh" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/zshrc.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/gitstatusrc"
PROMPT="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green4]%}@%{$fg[blue]%}%M %{$fg[green]%}%(5~|%-1~/…/%3~|%4~)%{$fg[red]%}]%{$reset_color%}$%b "
RPROMPT='%B$(git_super_status) %{$bg[white]$fg[black]%}%@%{$reset_color%}%b'

# add to path if not exists
addtopath ${CARGO_HOME}/bin
addtopath ${HOME}/.local/bin
addtopath ${XDG_APPLICATIONS_DIR}

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
export EDITOR=nvim; VISUAL=nvim
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# zle history search, use up and down arrows
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
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
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp" >/dev/null
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}

bindkey -s '^o' 'lfcd\n'
bindkey -s '^a' 'bc -l\n'
bindkey -s '^f' 'cd "$(dirname "$(fzf)")"\n'
bindkey '^[[P' delete-char

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Enable command completion for aws_cli
autoload bashcompinit && bashcompinit
complete -C '/usr/local/bin/aws_completer' aws

# Source rustup
. ${XDG_DATA_HOME}/cargo/env

# Load syntax highlighting; should be last.
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
