#!/bin/sh

set -e

gosu terraria:terraria /usr/bin/tmux send-keys "$1" Enter

