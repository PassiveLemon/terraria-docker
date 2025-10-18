#!/usr/bin/env bash

set -e

ID=$(id -u)

if [ "$ID" = "0" ]; then
  gosu terraria:terraria /usr/bin/tmux send-keys "$1" Enter
else
  /usr/bin/tmux send-keys "$1" Enter
fi

