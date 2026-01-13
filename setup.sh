#!/bin/bash

sudo mkdir -p /etc/nixos
mkdir -p ~/.config/openbox

sudo cp configuration.nix /etc/nixos/
cp dashboard.html ~/
cp command-server.py ~/
cp autostart ~/.config/openbox/autostart
chmod +x ~/.config/openbox/autostart
chmod +x ~/command-server.py