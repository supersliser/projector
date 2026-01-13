#!/bin/bash

sudo mkdir -p /etc/nixos

sudo cp configuration.nix /etc/nixos/
cp dashboard.html ~/
cp command-server.py ~/
cp autostart ~/media-center.sh
chmod +x ~/media-center.sh
chmod +x ~/command-server.py