#!/bin/bash

# Rofi menu for Pomodoro Timer by ani
# Gives a list of options to start or stop the timer.

# Options: "Work / Chill" in minutes
OPTIONS="25 / 5
40 / 10
50 / 15
Stop"

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -config /home/ani/.config/rofi/pomodoro_menu.rasi -p "Pomodoro")

# Exit if no choice is made
if [ -z "$CHOICE" ]; then
    exit 0
fi

if [ "$CHOICE" == "Stop" ]; then
    # Stop the timer
    /home/ani/.config/polybar/scripts/pomodoro.sh stop
else
    # Parse work and chill times from the choice
    WORK=$(echo "$CHOICE" | cut -d'/' -f1 | tr -d ' ')
    CHILL=$(echo "$CHOICE" | cut -d'/' -f2 | tr -d ' ')
    # Start the timer with the selected durations
    /home/ani/.config/polybar/scripts/pomodoro.sh start "$WORK" "$CHILL"
fi
