#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title iic-osic-tools
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Paul-creator


# Checks Docker, opens a new XQuartz xterm, runs start_x.sh, presses "s", then exits.

set -euo pipefail

XTERM="/opt/X11/bin/xterm"
EXPECT_BIN="$(command -v expect || true)"
START_SCRIPT="/Users/paulkronegger/iic-osic-tools/start_x.sh"

# --- 1) Ensure Docker is running ---
if ! docker info >/dev/null 2>&1; then
  echo "Starting Docker..."
  open -a Docker
  until docker info >/dev/null 2>&1; do
    sleep 1
  done
  echo "Docker is running."
fi

# --- 2) Sanity checks ---
[ -x "$XTERM" ] || { echo "xterm not found at $XTERM (install XQuartz)."; exit 1; }
[ -n "$EXPECT_BIN" ] || { echo "expect not found (brew install expect)."; exit 1; }
[ -x "$START_SCRIPT" ] || { echo "Start script not executable: $START_SCRIPT"; exit 1; }

# --- 3) Create a temp Expect script that runs inside the xterm ---
EXP_SCRIPT="$(mktemp -t xq_expect_XXXX.expect)"
cat > "$EXP_SCRIPT" <<'EOF'
set timeout -1
# Start your script in a login-capable shell so PATH/env are correct
spawn -noecho /bin/bash -lc "/Users/paulkronegger/iic-osic-tools/start_x.sh"
# # Wait ~0.5s, then send "s" + Enter
# after 500
send -- "s\r"
# Exit the shell (closes the xterm when the command finishes)
send -- "exit\r"
expect eof
EOF

# --- 4) Open a NEW xterm window and run the Expect script inside it ---
"$XTERM" -title "iic-osic-tools" -e "$EXPECT_BIN" "$EXP_SCRIPT"

# --- 5) Cleanup ---
rm -f "$EXP_SCRIPT"
