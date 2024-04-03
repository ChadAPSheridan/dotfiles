#!/bin/bash

# Function to get disk usage percentage for a given partition
get_disk_usage() {
    partition="$1"
    df_output=$(df -h "$partition" | tail -1)
    usage_percentage=$(echo "$df_output" | awk '{print $5}' | sed 's/%//')
    echo "$usage_percentage"
}

# Function to toggle between label and usage percentage when clicked
toggle_label_percentage() {
    partition="$1"
    label="$2"
    percentage=$(get_disk_usage "$partition")

    if [[ $label == *"󰋜"* ]]; then
        echo "%{F#AAAAAA}$partition %{F-}$percentage%"
    else
        echo "%{F#AAAAAA}󰋜 %{F-}$percentage%"
    fi
}

# Main loop
while true; do
    home_label="%{F#AAAAAA}󰋜 %{F-}/home"
    root_label="%{F#AAAAAA} %{F-}/"

    echo "$home_label"
    echo "$root_label"

    # Listen for click events
    read -r event
    if [[ $event == *"button"* ]]; then
        button=$(echo "$event" | awk '{print $2}')
        partition=$(echo "$event" | awk '{print $3}')
        
        if [[ $button == "1" ]]; then
            if [[ $partition == "/home" ]]; then
                echo "$(toggle_label_percentage "$partition" "$home_label")"
            elif [[ $partition == "/" ]]; then
                echo "$(toggle_label_percentage "$partition" "$root_label")"
            fi
        fi
    fi
done
