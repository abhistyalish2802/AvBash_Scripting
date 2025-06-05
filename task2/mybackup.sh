#!/bin/bash

# Ask which directory to backup
read -rp "Enter the directory to backup: " source_dir

# Check if source directory exists
if [ ! -d "$source_dir" ]; then
    echo "Error: Directory '$source_dir' does not exist."
    exit 1
fi

# Ask where to save the backup
read -rp "Enter the backup destination directory: " backup_dir

# Create backup directory if it doesn't exist
if [ ! -d "$backup_dir" ]; then
    echo "Backup directory '$backup_dir' does not exist. Creating it..."
    mkdir -p "$backup_dir"
fi

# Fixed backup filename
backup_file="mybackup.tar.gz"

# Create the compressed backup (overwrite if exists)
tar -czf "${backup_dir}/${backup_file}" -C "$(dirname "$source_dir")" "$(basename "$source_dir")"

# Success message
echo "Backup created successfully: ${backup_dir}/${backup_file}"
