#!/usr/bin/env python 
import subprocess
import logging
import os

# Set up logging
log_file = os.path.join(os.getcwd(), "debug.log")
logging.basicConfig(filename=log_file, level=logging.DEBUG, format='%(asctime)s - %(levelname)s: %(message)s')

# Function to parse output of command "wpctl status" and return a dictionary of sinks with their id and name.
def parse_wpctl_status():
    try:
        # Execute the wpctl status command and store the output in a variable.
        logging.info("Executing 'wpctl status' command...")
        output = str(subprocess.check_output("wpctl status", shell=True, encoding='utf-8'))
        logging.debug(f"Command output: {output}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Error executing 'wpctl status': {e}")
        return []

    # remove the ascii tree characters and return a list of lines
    lines = output.replace("├", "").replace("─", "").replace("│", "").replace("└", "").splitlines()

    # get the index of the Sinks line as a starting point
    sinks_index = None
    for index, line in enumerate(lines):
        if "Sinks:" in line:
            sinks_index = index
            break

    logging.debug(f"Sinks index: {sinks_index}")

    # start by getting the lines after "Sinks:" and before the next blank line and store them in a list
    sinks = []
    for line in lines[sinks_index + 1:]:
        if not line.strip():
            break
        sinks.append(line.strip())

    logging.debug(f"Extracted sinks: {sinks}")

    # remove the "[vol:" from the end of the sink name
    for index, sink in enumerate(sinks):
        sinks[index] = sink.split("[vol:")[0].strip()

    logging.debug(f"Processed sinks: {sinks}")

    # strip the * from the default sink and instead append "- Default" to the end. Looks neater in the wofi list this way.
    for index, sink in enumerate(sinks):
        if sink.startswith("*"):
            sinks[index] = sink.strip().replace("*", "").strip() + " - Default"

    logging.debug(f"Formatted sinks: {sinks}")

    # make the dictionary in this format {'sink_id': <int>, 'sink_name': <str>}
    sinks_dict = [{"sink_id": int(sink.split(".")[0]), "sink_name": sink.split(".")[1].strip()} for sink in sinks]

    logging.debug(f"Parsed sinks dictionary: {sinks_dict}")

    return sinks_dict

# get the list of sinks ready to put into wofi - highlight the current default sink
output = ''
sinks = parse_wpctl_status()
for items in sinks:
    if items['sink_name'].endswith(" - Default"):
        output += f"<b>-> {items['sink_name']}</b>\n"
    else:
        output += f"{items['sink_name']}\n"

# Call wofi and show the list. take the selected sink name and set it as the default sink
wofi_command = f"echo '{output}' | wofi --show=dmenu --hide-scroll --allow-markup --define=hide_search=true --location=top_right --width=600 --height=200 --xoffset=-60"
wofi_process = subprocess.run(wofi_command, shell=True, encoding='utf-8', stdout=subprocess.PIPE, stderr=subprocess.PIPE)

if wofi_process.returncode != 0:
    logging.info("User cancelled the operation.")
    exit(0)

selected_sink_name = wofi_process.stdout.strip()
logging.info(f"Selected sink name: {selected_sink_name}")

sinks = parse_wpctl_status()
selected_sink = next(sink for sink in sinks if sink['sink_name'] == selected_sink_name)
subprocess.run(f"wpctl set-default {selected_sink['sink_id']}", shell=True)
logging.debug(f"wpctl set-default {selected_sink['sink_id']}")

logging.debug(wofi_process.stderr)
