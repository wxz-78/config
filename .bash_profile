# ============================================================
# INK · ~/.bash_profile
# Arranca labwc automáticamente al iniciar sesión en tty1
# (sin display manager). En cualquier otra tty, o si ya hay una
# sesión gráfica corriendo, simplemente cae a un shell normal.
# ============================================================

# PATH personal
if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    PATH="$HOME/.local/bin:$PATH"
fi
if [ -d "$HOME/bin" ] && [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    PATH="$HOME/bin:$PATH"
fi
export PATH

# Editor por defecto (usa nvim si existe, si no vim)
if command -v nvim >/dev/null 2>&1; then
    export EDITOR=nvim
    export VISUAL=nvim
else
    export EDITOR=vim
    export VISUAL=vim
fi

# -------- lo necesario para que labwc pueda arrancar --------

# XDG_RUNTIME_DIR normalmente lo crea elogind/systemd-logind al hacer
# login; si tu setup no lo provee, este fallback evita que labwc y
# los clientes Wayland fallen al no encontrarlo.
if [ -z "$XDG_RUNTIME_DIR" ]; then
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    if [ ! -d "$XDG_RUNTIME_DIR" ]; then
        mkdir -p "$XDG_RUNTIME_DIR"
        chmod 700 "$XDG_RUNTIME_DIR"
    fi
fi

export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=labwc
export XDG_SESSION_DESKTOP=labwc
export LIBSEAT_BACKEND=seatd

# El resto de variables de la sesión (MOZ_ENABLE_WAYLAND, QT_QPA_PLATFORM,
# XCURSOR_*, etc.) ya viven en ~/.config/labwc/environment y las carga
# labwc solo — no hace falta repetirlas aquí.

# Español para fechas en shell (opcional, coincide con environment de labwc)
# Requiere el locale generado: sudo locale-gen es_ES.UTF-8
# export LC_TIME=es_ES.UTF-8

# -------- arrancar labwc --------
# Solo si: es un login interactivo en tty1, y no hay ya una sesión
# Wayland o X corriendo (evita relanzarlo en tty2, por ssh, etc.)
if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec labwc
fi

# Si no arrancamos labwc (otra tty, o ya había sesión gráfica),
# seguimos como un login shell normal
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
