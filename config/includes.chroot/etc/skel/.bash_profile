# Start the operator GUI only on the first virtual terminal.
if [ -z "${DISPLAY:-}" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ]; then
    # Xorg must be able to create its per-user log before startx is called.
    mkdir -p "$HOME/.local/share/xorg" "$HOME/.openpnp2"
    chown -R "$(id -un):$(id -gn)" "$HOME/.local"
    exec startx -- -nolisten tcp vt1
fi
