#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Restart Yabai
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🪟

# Documentation:
# @raycast.author Paul-creator

/opt/homebrew/bin/yabai --start-service
/opt/homebrew/bin/yabai --restart-service
/opt/homebrew/bin/skhd --start-service
/opt/homebrew/bin/skhd --restart-service
