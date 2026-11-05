#!/bin/sh
set -eu
BASE=/home/shyam/MyWork/Tools/Godot
export XDG_DATA_HOME="$BASE/userdata"
export XDG_CONFIG_HOME="$BASE/userdata"
export XDG_CACHE_HOME="$BASE/userdata"
export JAVA_HOME="${JAVA_HOME:-/home/shyam/.jdks/jdk-21.0.11+10}"
export ANDROID_HOME="/home/shyam/Android/Sdk"
PROJECT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
mkdir -p "$PROJECT/builds"
"$BASE/Godot_v4.7.2-stable_linux.x86_64" --headless --path "$PROJECT" --editor --import
APK="$PROJECT/builds/GulabiSahar-0.7.0-debug.apk"
"$BASE/Godot_v4.7.2-stable_linux.x86_64" --headless --path "$PROJECT" --export-debug Android "$APK"
# Preserve the original installed debug certificate even if editor settings change.
exec "$ANDROID_HOME/build-tools/36.0.0/apksigner" sign --ks /home/shyam/.android/debug.keystore --ks-key-alias androiddebugkey --ks-pass pass:android "$APK"
