# ============================================================
# INK · ~/.bashrc
# ============================================================

# Solo seguir si es interactiva
case $- in
    *i*) ;;
      *) return ;;
esac

# -------- historial --------
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend
shopt -s checkwinsize
shopt -s globstar 2>/dev/null

# -------- completado --------
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# -------- colores base (grises + xterm-256, sin depender de truecolor) --------
INK_RESET="\[\e[0m\]"
INK_DIM="\[\e[38;5;242m\]"     # gris apagado
INK_FG="\[\e[38;5;253m\]"      # casi blanco
INK_WHITE="\[\e[1;97m\]"       # blanco fuerte
INK_MUTE_GREEN="\[\e[38;5;108m\]"
INK_MUTE_RED="\[\e[38;5;138m\]"

# -------- prompt de dos líneas --------
# ┌─[user@host]─[~/ruta]─(rama git)
# └─❯
__ink_git_branch() {
    local b
    b=$(git symbolic-ref --short HEAD 2>/dev/null) || \
    b=$(git rev-parse --short HEAD 2>/dev/null) || return
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        printf ' %s(%s ✗)%s' "$INK_MUTE_RED" "$b" "$INK_RESET"
    else
        printf ' %s(%s)%s' "$INK_MUTE_GREEN" "$b" "$INK_RESET"
    fi
}

__ink_prompt() {
    local exit=$?
    local mark="❯"
    [ $exit -ne 0 ] && mark="${INK_MUTE_RED}❯${INK_RESET}" || mark="${INK_WHITE}❯${INK_RESET}"

    PS1="${INK_DIM}┌─[${INK_FG}\u@\h${INK_DIM}]─[${INK_WHITE}\w${INK_DIM}]$(__ink_git_branch)${INK_RESET}\n${INK_DIM}└─${mark} ${INK_RESET}"
}
PROMPT_COMMAND=__ink_prompt

# -------- ls / dircolors: escala de grises, sin colores saturados --------
export LS_COLORS="di=1;97:ln=38;5;250:so=38;5;242:pi=38;5;242:ex=1;37:bd=38;5;242:cd=38;5;242:su=38;5;242:sg=38;5;242:tw=38;5;242:ow=38;5;242"

if command -v eza >/dev/null 2>&1; then
    alias ls='eza --group-directories-first --icons'
    alias ll='eza -lh --group-directories-first --icons'
    alias la='eza -lah --group-directories-first --icons'
    alias lt='eza --tree --level=2 --icons'
else
    alias ls='ls --color=auto'
    alias ll='ls -lh --color=auto'
    alias la='ls -lah --color=auto'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never --theme=ansi'
fi

alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'

# -------- navegación --------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# -------- herramientas que ya usas --------
alias y='__ink_yazi_cd'
__ink_yazi_cd() {
    # yazi: al salir, cambia el shell al directorio donde te quedaste
    local tmp
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd" || return
    fi
    rm -f -- "$tmp"
}

alias netui='cmst'                  # GUI de connman
alias sysmon='btop'
alias ff='fastfetch'
alias ports='ss -tulpn'
alias update='sudo pacman -Syu'      # cámbialo si tu artix usa pacman/pamac distinto

# -------- git corto --------
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'

# -------- man pages en escala de grises --------
export LESS_TERMCAP_mb=$'\e[1;37m'
export LESS_TERMCAP_md=$'\e[1;97m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[38;5;242m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[4;97m'

# -------- fastfetch al abrir una terminal interactiva --------
if command -v fastfetch >/dev/null 2>&1 && [ -z "$INK_NO_FASTFETCH" ]; then
    fastfetch
fi
