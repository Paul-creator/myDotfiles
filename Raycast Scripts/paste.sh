#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Paste
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📋
# @raycast.argument1 {"type": "dropdown", "placeholder": "Choose data", "data": [{"title": "SV-Nr.", "value": "4581021202"}, {"title": "Steuernummer", "value": "532889318"}, {"title": "Passnummer", "value": "U0134761"}, {"title": "IBan-Revolut", "value": "LT81 3250 0796 1916 9332"}, {"title": "Bic-Revolut", "value": "REVOLT21"}, {"title": "IBan-Raiffeisen", "value": "AT79 3451 0000 0393 7018"}, {"title": "Bic-Raiffeisen", "value": "RZOOAT2L510"}, {"title": "Mathema. clear vars", "value": "mathematicaClearVars"}, {"title": "Matrikelnummer", "value": "12344729"}, {"title": "JKU-Email", "value": "k12344729@students.jku.at"}]}

# Documentation:
# @raycast.description Paste stuff like IBan, social insurance number, etc.
# @raycast.author Paul-creator

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 key"
    exit 1
fi

value=$1
if [ "$value" = "mathematicaClearVars" ]; then
    value="ClearAll[\"Global\`*\"]"
fi
echo -n "$value" | pbcopy

# Verwende AppleScript, um den Text einzufügen
osascript <<EOF
tell application "System Events"
    keystroke "v" using command down
end tell


