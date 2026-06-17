#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Stop Yabai
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🪟

# Documentation:
# @raycast.author Paul-creator

/opt/homebrew/bin/yabai --stop-service
/opt/homebrew/bin/skhd --stop-service
