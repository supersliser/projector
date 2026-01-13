#!/bin/bash

sudo mkdir -p /etc/nixos
mkdir -p ~/.config/openbox

sudo cp configuration.nix /etc/nixos/
cp dashboard.html ~/
cp autostart ~/.config/openbox/autostart
chmod +x ~/.config/openbox/autostart