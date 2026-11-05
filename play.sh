#!/bin/sh
BASE=/home/shyam/MyWork/Tools/Godot
export XDG_DATA_HOME="$BASE/userdata"
export XDG_CONFIG_HOME="$BASE/userdata"
export XDG_CACHE_HOME="$BASE/userdata"
PROJECT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec "$BASE/Godot_v4.7.2-stable_linux.x86_64" --path "$PROJECT" "$@"
