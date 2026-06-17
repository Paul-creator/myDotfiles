#!/usr/bin/env python3

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title File2Clipboard
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description Reads files from cliboard and saves their content to Clipboard.
# @raycast.author Paul-creator

import os
import subprocess
import sys

try:
    from AppKit import NSPasteboard, NSFilenamesPboardType
except ImportError:
    print("PyObjC is required. Install it via: pip3 install pyobjc")
    sys.exit(1)

def main():
    pb = NSPasteboard.generalPasteboard()
    # Try to get file paths (as a list) from the clipboard
    filepaths = pb.propertyListForType_(NSFilenamesPboardType)

    if not filepaths:
        print("No file references found in the clipboard.")
        sys.exit(1)

    combined = ""
    for path in filepaths:
        if os.path.isfile(path):
            filename = os.path.basename(path)
            combined += f"{filename}:\n---\n"
            try:
                with open(path, "r", encoding="utf-8") as f:
                    combined += f.read()
            except Exception as e:
                combined += f"Error reading file: {e}"
            combined += "\n---\n"
        else:
            combined += f"Skipping {path}: not a file.\n"

    try:
        subprocess.run("pbcopy", input=combined, text=True, check=True)
        print("Combined content copied to clipboard.")
    except Exception as e:
        print("Error copying to clipboard:", e)

if __name__ == '__main__':
    main()