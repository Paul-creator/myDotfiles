#!/usr/bin/env python3

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Latex brackets \[ \] to dollars $$ $$
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Paul-creator

import subprocess, re

# Read clipboard
text = subprocess.run(['pbpaste'], stdout=subprocess.PIPE).stdout.decode('utf-8')

# Replace \[...\] with $$...$$ and \(...\) with $...$
text = re.sub(r'\\\[(.*?)\\\]', r'$$\1$$', text, flags=re.DOTALL)
text = re.sub(r'\\\((.*?)\\\)', r'$\1$', text, flags=re.DOTALL)

# Write back to clipboard
subprocess.run(['pbcopy'], input=text.encode('utf-8'))
