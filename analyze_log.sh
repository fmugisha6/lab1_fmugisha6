#!/usr/bin/env bash

# Summarize driving sessions recorded by transit_program.py.
log_file="${1:-transit_session.log}"

if [[ ! -f "$log_file" ]]; then
    printf 'Error: log file not found: %s\n' "$log_file" >&2
    exit 1
fi

awk '
    /^===== New session started / { sessions++ }
    /\[WARN\] Zebra crossing! Stopping/ { zebra_stops++ }
    /\[WARN\] Changing lane:/ { lane_changes++ }
    /\[OK\] Driver[[:space:]]*:/ {
        driver = $0
        sub(/^.*Driver[[:space:]]*:[[:space:]]*/, "", driver)
        latest_driver = driver
    }
    /\[OK\] Top speed[[:space:]]*:/ {
        top_speed = $0
        sub(/^.*Top speed[[:space:]]*:[[:space:]]*/, "", top_speed)
        latest_top_speed = top_speed
    }
    END {
        print "Driving session summary"
        print "-----------------------"
        printf "Sessions: %d\n", sessions
        printf "Zebra crossing stops: %d\n", zebra_stops
        printf "Lane changes: %d\n", lane_changes
        printf "Latest driver: %s\n", latest_driver == "" ? "N/A" : latest_driver
        printf "Latest top speed: %s\n", latest_top_speed == "" ? "N/A" : latest_top_speed
    }
' "$log_file"
