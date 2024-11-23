#!/bin/bash

# Check if a command is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <command>"
    exit 1
fi

# Capture the command
COMMAND="$*"

LOG_DIR="$HOME/log"
mkdir -p "$LOG_DIR"

# Create a time-based log file name in ISO 8601 format
LOG_FILE="$LOG_DIR/$(date -u +%Y-%m-%dT%H-%M-%SZ).log"
echo "Log created to $LOG_FILE"

# Create the log file right away with the initial command information
{
    echo "Command:"
    echo "$COMMAND"
    echo ""
    echo "Log file created at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo ""
} > "$LOG_FILE"

# Variable to store output and start time
OUTPUT=""
START_TIME=$(date +%s)

# Trap SIGINT (Ctrl+C) to ensure we save the log and add a termination line
trap 'on_interrupt' SIGINT

on_interrupt() {
    echo ""
    echo "Process interrupted by SIGINT. Saving log..."
    save_log
    {
        echo "Process terminated by SIGINT at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo ""  # New line
    } >> "$LOG_FILE"
    exit 1
}

save_log() {
    # Get the end time in seconds since epoch
    END_TIME=$(date +%s)

    # Calculate the time taken
    TIME_TAKEN=$((END_TIME - START_TIME))

    # Save output, time output, and timestamp to the log file with new lines in between
    {
        echo "Output:"
        echo "$OUTPUT"
        echo ""  # New line
        echo "Time Taken: $TIME_TAKEN seconds"
        echo ""  # New line
        echo "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo ""  # New line
    } >> "$LOG_FILE"
    echo "Log saved to $LOG_FILE"
}

# Execute the command and capture the output while printing it to the console
OUTPUT=$({ time $COMMAND; } 2>&1 | tee /dev/tty)

# Call save_log after the command completes
save_log