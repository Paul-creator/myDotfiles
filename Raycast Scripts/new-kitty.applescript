#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title New Kitty
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 😺

# Documentation:
# @raycast.author Paul-creator

tell application "System Events"
	set kittyIsRunning to (name of processes) contains "kitty"
end tell

if kittyIsRunning then
	tell application "System Events"
		tell process "kitty"
			click menu item "New OS Window" of menu "Shell" of menu bar 1
		end tell
	end tell
else
	tell application "kitty" to activate
end if