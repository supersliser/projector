#!/bin/bash

sudo mkdir -p /etc/nixos
mkdir -p ~/.config/autostart
mkdir -p ~/.config/systemd/user
mkdir -p ~/.local/bin

sudo cp configuration.nix /etc/nixos/
cp dashboard.html ~/
cp command-server.py ~/

# Copy startup script
cp autostart ~/.local/bin/media-center.sh
chmod +x ~/.local/bin/media-center.sh
chmod +x ~/command-server.py

# Setup systemd user service
cp media-center.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable media-center.service

# Also keep GNOME autostart as backup
cp media-center.desktop ~/.config/autostart/