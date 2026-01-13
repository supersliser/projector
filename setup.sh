#!/bin/bash

mkdir -p /etc/nixos
mkdir -p ~/.config/openbox

cp configuration.nix /etc/nixos/
cp dashboard.html ~/
cp autostart ~/.config/openbox/autostart