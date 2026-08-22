#!/usr/bin/env bash

dirs="$HOME/code $HOME/desktop"
target_dir=$(find $dirs -maxdepth 1 -mindepth 1 -type d | fzf)
session_name=$(echo $target_dir | sed -E 's/.*\/(.*)/\1/')
tmux new -s $session_name -d -c $target_dir
tmux switch -t $session_name
