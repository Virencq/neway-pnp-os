# Start the minimal graphical shell only on the primary live console.
if [[ -z "${DISPLAY:-}" && "$(tty 2>/dev/null || true)" == "/dev/tty1" && -z "${NEWAY_SESSION_STARTED:-}" ]]; then
  export NEWAY_SESSION_STARTED=1
  startx -- -nolisten tcp vt1
  status=$?
  printf 'Graphical session stopped (startx exit %s). Use the maintenance console to inspect the system.\n' "$status"
  sleep 10
fi
