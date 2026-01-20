#!/bin/sh

set -e

# Create terraria user for rootless operation
if ! getent group terraria > /dev/null 2>&1; then
  groupadd -g "$PGID" terraria
fi
if ! getent passwd terraria > /dev/null 2>&1; then
  useradd -u "$PUID" -g terraria -s /bin/sh -m terraria
fi

mkdir -p /opt/terraria/config/Worlds/

chown -R terraria:terraria /opt/terraria
chmod -R 775 /opt/terraria/

exec gosu terraria:terraria "/opt/terraria/server.sh"

