#!/bin/bash

case "$(uname -s)" in
    Linux*)     echo "" ;;  # Linux Nerd Font Icon
    Darwin*)    echo "" ;;  # macOS Nerd Font Icon
    CYGWIN*|MINGW*) echo "" ;;  # Windows Nerd Font Icon
    *)          echo "?" ;;  # Unknown OS
esac
