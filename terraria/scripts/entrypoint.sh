#!/bin/sh

set -e

# Create terraria user for rootless operation
if ! getent group terraria > /dev/null 2>&1; then
  groupadd -g "$PGID" terraria
fi
if ! getent passwd terraria > /dev/null 2>&1; then
  useradd -u "$PUID" -g terraria -s /bin/sh -m terraria
fi
chown -R "$PUID:$PGID" /opt/terraria

exec gosu "$PUID:$PGID" "/opt/terraria/server.sh"

