#!/bin/bash

# Prompt for the directory to back up (or take from argument)
if [ -z "$1" ]; then
  read -p "Enter the directory to back up: " source_dir
else
  source_dir=$1
fi

# Check if directory exists
if [ ! -d "$source_dir" ]; then
  echo "Directory '$source_dir' does not exist."
  exit 1
fi

# Prompt for the backup destination
read -p "Enter the backup destination directory: " backup_dest

# Create destination directory if it doesn't exist
mkdir -p "$backup_dest"

# Create a timestamped backup file name
timestamp=$(date +"%Y%m%d_%H%M%S")
archive_name="backup_$(basename $source_dir)_$timestamp.tar.gz"

# Create the backup
tar -czf "$backup_dest/$archive_name" "$source_dir"

if [ $? -eq 0 ]; then
  echo "✅ Backup successful!"
  echo "Backup saved at: $backup_dest/$archive_name"
else
  echo "❌ Backup failed!"
fi
