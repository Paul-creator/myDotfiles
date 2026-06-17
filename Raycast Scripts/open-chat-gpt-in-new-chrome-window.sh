#!/bin/zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open ChatGPT in New Chrome Window
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🚀

# Documentation:
# @raycast.author Paul-creator

# Replace the URL below with your desired website:
URL="https://chatgpt.com"

/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --new-window "$URL" --profile-directory="Default" &
