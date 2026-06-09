#!/bin/bash

DARK="WhiteSur-Dark"
LIGHT="WhiteSur-Light"

current=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")

if [ "$current" = "$DARK" ]; then
    gsettings set org.gnome.desktop.interface gtk-theme "$LIGHT"
    gsettings set org.gnome.desktop.interface color-scheme "default"
    sed -i 's/^theme = .*/theme = GitHub Light Default/' ~/.config/ghostty/config.ghostty
else
    gsettings set org.gnome.desktop.interface gtk-theme "$DARK"
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    sed -i 's/^theme = .*/theme = Rose Pine Moon/' ~/.config/ghostty/config.ghostty
fi

pkill -USR2 ghostty
