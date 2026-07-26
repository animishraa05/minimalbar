#!/bin/bash

# made by ani

# This script grabs the current wallpaper path from pywal's cache. I use it to display the wallpaper name on my bar, or just to know what awesome background I'm rocking.
WALLPAPER_PATH=$(cat ~/.cache/wal/wal)

# I extract just the filename because the full path is too much info for my bar.
FILENAME=$(basename "$WALLPAPER_PATH")

# Echo the filename so Polybar can pick it up.
echo "$FILENAME"