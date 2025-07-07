#!/bin/sh

set -e

tmux send-keys "$1" Enter

