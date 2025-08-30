#!/bin/bash

# Function to perform the backup
perform_backup() {
    local timestamp=$(date +%d_%m_%Y)
    local backup_file="/data/backup/${timestamp}_App.sql"
    mysqldump --defaults-extra-file=~/.my.cnf posdb > "$backup_file"
}

# Function to calculate sleep duration until next 11 PM
calculate_sleep_duration() {
    local current_time=$(date +%s)
    local target_time=$(date -d "23:00" +%s)
    local seconds_in_a_day=86400

    if [ "$current_time" -ge "$target_time" ]; then
        target_time=$((target_time + seconds_in_a_day))
    fi

    local sleep_duration=$((target_time - current_time))
    echo $sleep_duration
}

# Main loop
while true; do
    perform_backup
    sleep_duration=$(calculate_sleep_duration)
    sleep $sleep_duration
done
