#!/usr/bin/env python3

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Start Windows PC
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Paul-creator

from fritzconnection import FritzConnection

fc = FritzConnection(
    address="https://suszpl7oq5x4koqf.myfritz.net",
    user="admin",
    password="VJroni84D#fji@3fjiosaFM"
)
# this action sends a WOL packet to the given MAC
fc.call_action(
    "Hosts:1",
    "X_AVM-DE_WakeOnLANByMACAddress",
    NewMACAddress="30:9C:23:67:7A:AC"
)
