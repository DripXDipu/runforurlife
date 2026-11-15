#!/bin/sh
printf '\033c\033]0;%s\a' Runforurlife
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Runforurlife.x86_64" "$@"
