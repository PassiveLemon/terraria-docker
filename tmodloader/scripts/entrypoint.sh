#!/usr/bin/env bash

echo "tModLoader version: $VERSION"

# Run the variables script to check and process server variables
# shellcheck source=./variables.sh
source /opt/terraria/variables.sh

pipe=/tmp/pipe.pipe

# Shutdown function to send the notice, signal, and ensure its shutdown before exiting
function shutdown () {
  echo "Stopping server..."
  inject "say Shutting down server in 3 seconds..."
  sleep 3s
  inject "exit"
  tmuxPid=$(pgrep tmux)
  while [ -e "/proc/$tmuxPid" ]; do
    sleep .5
  done
  echo "Server stopped."
  rm $pipe
}

trap shutdown TERM INT

# Replace server config every launch to ensure changes are set
if [ -e "/opt/terraria/server/serverconfig.txt" ]; then
  rm /opt/terraria/server/serverconfig.txt
fi
cp /opt/terraria/config/serverconfig.txt /opt/terraria/server/

# Start terraria in tmux session with a write pipe to output to docker logs
echo "Starting server with modpack ${MODPACK}..."
if [ ! -p "$pipe" ]; then
  mkfifo $pipe
fi
tmux new-session -d "/opt/terraria/server/start-tModLoaderServer.sh -config /opt/terraria/server/serverconfig.txt | tee $pipe"

# Sometimes the server doesn't start immediately and hangs. This basically just pokes it into starting.
inject "help"

# Read out pipe to display in docker logs
cat $pipe &
wait ${!}

