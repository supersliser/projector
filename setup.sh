#!/bin/bash

sudo mkdir -p /etc/nixos

sudo cp configuration.nix /etc/nixos/
cp dashboard.html ~/
cp command-server.py ~/
chmod +x ~/command-server.py