#!/bin/bash

# made by ani
# This script checks for system updates. I like to keep my system fresh and secure, so I always know when it's time to update.

# I use `checkupdates` to see how many packages need an upgrade. It's like checking for new loot!
UPDATES=$(checkupdates 2>/dev/null | wc -l)

# If there are no updates, I show a green checkmark and a zero. All clear!
if [ "$UPDATES" -eq 0 ]; then
    echo " 0"
# Otherwise, I show a warning icon and the number of pending updates. Time to get to work!
else
    echo " ${UPDATES}"
fi