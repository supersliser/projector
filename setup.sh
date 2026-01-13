#!/bin/bash

sudo mkdir -p /etc/nixos
mkdir -p ~/.config/autostart

sudo cp configuration.nix /etc/nixos/
cp dashboard.html ~/
cp command-server.py ~/
cp autostart ~/.config/autostart/media-center.sh
cp media-center.desktop ~/.config/autostart/
chmod +x ~/.config/autostart/media-center.sh
chmod +x ~/command-server.py