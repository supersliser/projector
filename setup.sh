#!/bin/bash
set -e

echo "Setting up Media Center..."

# Copy NixOS configuration
sudo cp configuration.nix /etc/nixos/

# Copy user files to home directory
cp dashboard.html ~/
cp command-server.py ~/

echo "Setup complete!"
echo ""
echo "Now run: sudo nixos-rebuild switch"
echo "Then reboot the system."