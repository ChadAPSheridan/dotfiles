#!/bin/bash
# Function to parse output of command "wpctl status" and return a list of sinks with their id and name.
parse_wpctl_status() {
    output=$(wpctl status)
    # echo "Parsed output:"
    # echo "$output"
    # echo "************************************************************"
    # Extract sinks section and remove tree characters
sinks=$(echo "$output" | awk '/^.*Sinks/,/^$/{sub(/^[[:space:]]*/, ""); print}' | sed 's/├//g; s/─//g; s/│//g; s/└//g')
    # echo "Sinks section:"
    # echo "$sinks"
    #     echo "************************************************************"
    # Extract sink names and remove volume information
    sinks=$(echo "$sinks" | grep -E '^.*[*]?.*[[:digit:]]+\.' | sed 's/\[vol:[^]]*\]//g')
    # echo "Sink names:"
    # echo "$sinks"
    #     echo "************************************************************"


    sinks=$(echo "$sinks" |sed -E -e 's/^\s*\*\s*([0-9]+)\. (.+)/\1. \2 - Default/g' -e 's/^\s+//')

# echo "Sink names fixed?:"
#     echo "$sinks"
#         echo "************************************************************"
    # # Format sinks
    formatted_sinks=$(echo "$sinks" | awk '{gsub(/^\*/, " - Default ", $0); print}')
    # echo "Formatted sinks:"
    echo "$formatted_sinks"
    # echo "$formatted_sinks"
    # echo "************************************************************"
}
# Call function to parse wpctl status and get the list of sinks
sinks=$(parse_wpctl_status)
# echo "Sinks list:"
# echo "$sinks"

# Create output for rofi
output=""
while IFS= read -r sink; do
    output+="$sink\n"
done <<< "$sinks"
# echo "Output for rofi:"
# echo -e "$output"

# Call rofi to display the list of sinks and get user selection
selected_sink_name=$(echo -e "$output" | rofi -dmenu -markup-rows -p "Select sink" -location 3 -width 200 -lines 5)
# echo "Selected sink name:"
# echo "$selected_sink_name"


# Check if user cancelled the operation
if [[ -z "$selected_sink_name" ]]; then
    echo "User cancelled the operation."
    exit 0
fi

if grep -q "Headset" <<< "$selected_sink_name"; then
    echo "󰋋"
fi
if grep -q "HDMI" <<< "$selected_sind_name"; then
    echo "󰜟"
fi
#echo ""
# Get the sink ID of the selected sink
selected_sink_id=$(echo "$selected_sink_name" | awk -F '. ' '{print $1}')
# echo "Selected sink ID:"
# echo "$selected_sink_id"

# Set the selected sink as the default sink using wpctl
wpctl set-default "$selected_sink_id"
