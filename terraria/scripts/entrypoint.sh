#!/bin/sh

set -e

PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

case "$PUID" in
  ''|*[!0-9]*) echo "Invalid PUID: $PUID" >&2; exit 2 ;;
esac
case "$PGID" in
  ''|*[!0-9]*) echo "Invalid PGID: $PGID" >&2; exit 2 ;;
esac

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

