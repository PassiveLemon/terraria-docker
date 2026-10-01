#!/usr/bin/env bash

set -e

echo "Terraria version: $VERSION"
echo "Arch: $ARCH"

# Run the variables script to check and process server variables
# shellcheck source=./variables.sh
source /opt/terraria/variables.sh

PIPE=/tmp/pipe.pipe

# Shutdown function to send the notice, signal, and ensure its shutdown before exiting
function shutdown() {
  echo "Stopping server..."
  inject "say Shutting down server in 5 seconds..."
  sleep 5s
  inject "exit"
  tmuxPid=$(pgrep tmux)
  while [ -e "/proc/$tmuxPid" ]; do
    sleep .5
  done
  echo "Server stopped."
  rm $PIPE
}

trap shutdown TERM INT

# Replace server config every launch to ensure changes are set
if [ -e "/opt/terraria/server/serverconfig.txt" ]; then
  rm /opt/terraria/server/serverconfig.txt
fi
cp /opt/terraria/config/serverconfig.txt /opt/terraria/server/

# Start terraria in tmux session with a write pipe to output to docker logs
echo "Starting server..."
if [ ! -p "$PIPE" ]; then
  mkfifo $PIPE
fi
CMD="/opt/terraria/server/TerrariaServer"
if [ "$ARCH" = "arm64" ]; then
  CMD="mono --server /opt/terraria/server/TerrariaServer.exe"
fi
tmux new-session -d "$CMD -config /opt/terraria/server/serverconfig.txt | tee $PIPE"

# Sometimes the server doesn't start immediately and hangs. This basically just pokes it into starting.
inject "help"

# Read out pipe to display in docker logs
cat $PIPE &
wait ${!}

