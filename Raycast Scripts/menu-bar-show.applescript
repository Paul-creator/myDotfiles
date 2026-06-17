#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Show menu bar
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Paul-creator

tell application "System Events"
	set autohide menu bar of dock preferences to false
end tell

