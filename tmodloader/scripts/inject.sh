#!/bin/sh

set -e

su-exec terraria:terraria /usr/bin/tmux send-keys "$1" Enter

