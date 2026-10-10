# Auto-start the graphical OpenPnP session only on the primary live console.
if [[ -z "${DISPLAY:-}" && "$(tty 2>/dev/null || true)" == "/dev/tty1" && -z "${NEWAY_SESSION_STARTED:-}" ]]; then
  export NEWAY_SESSION_STARTED=1
  startx -- -nolisten tcp vt1
  status=$?
  printf 'OpenPnP graphical session stopped (startx exit %s). Check logs and use the maintenance instructions.\n' "$status"
  sleep 30
fi
