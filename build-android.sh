#!/bin/sh
set -eu
BASE=/home/shyam/MyWork/Tools/Godot
export XDG_DATA_HOME="$BASE/userdata"
export XDG_CONFIG_HOME="$BASE/userdata"
export XDG_CACHE_HOME="$BASE/userdata"
export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/temurin-17-jdk-amd64}"
export ANDROID_HOME="${ANDROID_HOME:-/home/shyam/Android/sdk}"
PROJECT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
mkdir -p "$PROJECT/builds"
"$BASE/Godot_v4.7.2-stable_linux.x86_64" --headless --path "$PROJECT" --editor --import --quit
PROFILE="${1:-standard}"
case "$PROFILE" in
  standard) PRESET="Android"; APK="$PROJECT/builds/GulabiSahar-0.9.9-debug.apk" ;;
  preview) PRESET="Android Preview"; APK="$PROJECT/builds/GulabiSahar-0.9.9-preview-debug.apk" ;;
  *) echo "Usage: $0 [standard|preview]" >&2; exit 2 ;;
esac
"$BASE/Godot_v4.7.2-stable_linux.x86_64" --headless --path "$PROJECT" --export-debug "$PRESET" "$APK"
# Preserve the original installed debug certificate even if editor settings change.
exec "$ANDROID_HOME/build-tools/36.0.0/apksigner" sign --ks /home/shyam/.android/debug.keystore --ks-key-alias androiddebugkey --ks-pass pass:android "$APK"
