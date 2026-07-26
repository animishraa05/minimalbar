#!/usr/bin/env bash

# made by ani

# Kill any old Polybar instances
killall -q polybar 2>/dev/null

# Now, launch my glorious bar! I'm piping output to a log, just in case things get weird.
echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
polybar -c ~/.config/polybar/config.ini i3_bar 2>&1 | tee -a /tmp/polybar1.log & disown

# A little confirmation, because I like to know my bars are doing their thing.
echo "Bars launched..."