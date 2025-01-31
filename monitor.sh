#!/bin/bash


# --------------------------------------------

# LINUX SYSTEM MONITORING & BACKUP TOOL

# Developed by: Wendy Catalan & Eden Reyes

# Automates System Health Monitoring & Data Backup

# --------------------------------------------


# Configuration

EMAILS=("wendy.catalanlopez@laverne.edu" "eden.reyes@laverne.edu")  # Emails for alerts

THRESHOLD=80                             # CPU usage threshold for alerts

BACKUP_DIR="$HOME/backups"               # Where backups will be stored

SOURCE_DIR="/var/log /etc"               # Important system files to back up

LOG_DIR="$HOME/logs"                     # Log storage directory

LOG_FILE="$LOG_DIR/system_monitor.log"   # Main log file

LAST_BACKUP=0                             # Time of the last backup

BACKUP_INTERVAL=60                        # Minimum time (seconds) between backups


# Ensure necessary directories exist

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

touch "$LOG_FILE"


# Function to send email to multiple recipients

send_email() {

    SUBJECT="$1"

    MESSAGE="$2"

    for EMAIL in "${EMAILS[@]}"; do

        echo "$MESSAGE" | mail -s "$SUBJECT" "$EMAIL"

    done

}


# --------------------------------------------

# FUNCTION: Monitor System Performance

# --------------------------------------------

system_monitor() {

    echo "------ System Performance ------" | tee -a "$LOG_FILE"

    echo "Date: $(date)" | tee -a "$LOG_FILE"


    # Get CPU Usage

    CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')

    echo "CPU Usage: $CPU_LOAD%" | tee -a "$LOG_FILE"


    # Check if CPU exceeds threshold

    if (( $(echo "$CPU_LOAD > $THRESHOLD" | bc -l) )); then

        WARNING_MSG=" WARNING: HIGH CPU USAGE DETECTED!\nCPU Usage: $CPU_LOAD%"

        echo "$WARNING_MSG" | tee -a "$LOG_FILE"

        send_email "CPU Alert: High Usage" "$WARNING_MSG"

        echo "📧 Email alert sent to both recipients" | tee -a "$LOG_FILE"

    fi


    # Display Memory Usage

    echo "Memory Usage:" | tee -a "$LOG_FILE"

    free -h | tee -a "$LOG_FILE"


    # Display Disk Usage

    echo "Disk Usage:" | tee -a "$LOG_FILE"

    df -h | grep '^/dev' | tee -a "$LOG_FILE"

}


# --------------------------------------------

#  FUNCTION: Perform Backup

# --------------------------------------------

backup_files() {

    CURRENT_TIME=$(date +%s)


    # Ensure backup directory exists

    mkdir -p "$BACKUP_DIR"


      # Check if enough time has passed since last backup

    if [[ $LAST_BACKUP -eq 0 ]] || (( CURRENT_TIME - LAST_BACKUP >= BACKUP_INTERVAL )); then

        echo " Starting backup process..." | tee -a "$LOG_FILE"

        BACKUP_FILE="$BACKUP_DIR/backup_$(date +%Y-%m-%d_%H-%M-%S).tar.gz"


        # Perform backup

        sudo tar -czvf "$BACKUP_FILE" $SOURCE_DIR &>> "$LOG_FILE"

        if [ $? -eq 0 ]; then

            SUCCESS_MSG=" Backup successful!\nBackup File: $BACKUP_FILE\nDate: $(date)"

            echo "$SUCCESS_MSG" | tee -a "$LOG_FILE"

            send_email "Backup Alert: Completed" "$SUCCESS_MSG"

            LAST_BACKUP=$CURRENT_TIME  # Update last backup time

        else

            ERROR_MSG=" Backup failed. Check logs for details.\nDate: $(date)"

            echo "$ERROR_MSG" | tee -a "$LOG_FILE"

            send_email "Backup Failed Alert" "$ERROR_MSG"

        fi

    else

        SKIPPED_MSG=" Backup skipped. Last backup was at $(date -d @$LAST_BACKUP)."

        echo "$SKIPPED_MSG" | tee -a "$LOG_FILE"

    fi

}


# --------------------------------------------

#  FUNCTION: View Logs

# --------------------------------------------

view_logs() {

    echo " Displaying system logs:" 

    cat "$LOG_FILE"

}


# --------------------------------------------

#  FUNCTION: Real-Time Monitoring

# --------------------------------------------

monitor_system() {

    while true; do

        clear

        echo "Real-Time System Monitoring"

        system_monitor

        sleep 15

    done

}


# --------------------------------------------

#  MENU SYSTEM FOR USER INTERACTION

# --------------------------------------------

while true; do

    echo "================================="

    echo "   Linux System Monitor & Backup   "

    echo "================================="

    echo "1️⃣  Monitor System Performance (One-Time)"

    echo "2️⃣  Perform Backup"

    echo "3️⃣  View Logs"

    echo "4️⃣  Start Real-Time Monitoring"

    echo "5️⃣  Exit"

    echo "================================="

    read -p "Choose an option: " option


    case $option in

        1) system_monitor ;;

        2) backup_files ;;

        3) view_logs ;;

        4) monitor_system ;;

        5) echo " Exiting... Goodbye!" && exit 0 ;;

        *) echo " Invalid option. Please choose a valid option." ;;

    esac

done
