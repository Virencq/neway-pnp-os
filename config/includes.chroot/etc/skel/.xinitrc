#!/bin/sh
xset s off
xset -dpms
xset s noblank
openbox-session &
exec /usr/local/bin/neway-openpnp-session
