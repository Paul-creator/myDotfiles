#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open New Instance
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🆕
# @raycast.argument1 {"type": "dropdown", "placeholder": "Choose Application", "data": [{"title": "📚 PDF Expert v3.11", "value": "PDF Expert v3.11"}, {"title": "📚 PDFgear", "value": "PDFgear"}, {"title": "🖥️ Kitty", "value": "kitty"}]}

APP_NAME="/Applications/$1.app"

echo "$APP_NAME"


open -na "$APP_NAME"
echo "Opened new instance of $APP_NAME"