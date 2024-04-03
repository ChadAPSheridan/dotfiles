#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
polybar-msg cmd quit
# Otherwise you can use the nuclear option:
# killall -q polybar

# Launch bar1 and bar2
echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log /tmp/polybar3.log 
# /tmp/polybar4.log /tmp/polybar5.log /tmp/polybar6.log
polybar main 2>&1 | tee -a /tmp/polybar1.log & disown
polybar right 2>&1 | tee -a /tmp/polybar2.log & disown
polybar left 2>&1 | tee -a /tmp/polybar3.log & disown
# polybar mainspace 2>&1 | tee -a /tmp/polybar4.log & disown
# polybar rightspace 2>&1 | tee -a /tmp/polybar5.log & disown
# polybar leftspace 2>&1 | tee -a /tmp/polybar6.log & disown
echo "Bars launched..."