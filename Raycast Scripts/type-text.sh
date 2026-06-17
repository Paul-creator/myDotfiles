#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Type Text
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description Types clipboard
# @raycast.author Paul-creator


# Read from clipboard
clipboardContent="$(pbpaste)"

type text
cliclick "t:$clipboardContent"
