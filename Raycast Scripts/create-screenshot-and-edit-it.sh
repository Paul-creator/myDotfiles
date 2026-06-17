#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Create screenshot and edit it
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Paul-creator

#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title aa
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Paul-creator

osascript <<END
    -- Take a screenshot and save it to the desktop
    do shell script "screencapture -i ~/Desktop/screenshot.png"

    -- Open the screenshot in Preview and show the markup toolbar
    tell application "Preview"
        activate
        set screenshotFile to (POSIX file "/Users/paulkronegger/Desktop/screenshot.png") as alias
        open screenshotFile
        delay 0.5 -- wait for the document to finish opening
        tell application "System Events"
            keystroke "a" using {command down, shift down}
        end tell
    end tell
END
