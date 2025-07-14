#!/bin/sh

set -e

# Create terraria user for rootless operation
if ! getent group terraria > /dev/null 2>&1; then
  addgroup -g "$PGID" terraria
fi
if ! getent passwd terraria > /dev/null 2>&1; then
  adduser -u "$PUID" -G terraria -s /bin/sh -D terraria
fi
chown -R terraria:terraria /opt/terraria

exec su-exec terraria:terraria "/opt/terraria/server.sh"

