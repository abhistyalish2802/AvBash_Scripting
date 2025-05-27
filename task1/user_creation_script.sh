#!/bin/bash

CSV_FILE="$1"
LOG_FILE="/var/log/user_script.log"

if [[ -z "$CSV_FILE" ]]; then
  echo "Usage: $0 <csv_file_path>"
  exit 1
fi

# Download file if URL
if [[ "$CSV_FILE" =~ ^https?:// ]]; then
  echo "Downloading CSV from remote URL..."
  wget -q -O /tmp/users.csv "$CSV_FILE"
  CSV_FILE="/tmp/users.csv"
fi

echo "Starting user creation script at $(date)" | tee -a $LOG_FILE

while IFS=, read -r email birthdate groups sharedFolder; do
  # Skip header line
  if [[ "$email" == "e-mail" ]]; then
    continue
  fi

  # Extract username (first letter of first name + last name, all lowercase)
  username=$(echo "$email" | awk -F@ '{print $1}' | tr '.' '_')

  # Create password MMYYYY from birthdate
  mm=$(echo "$birthdate" | cut -d'-' -f2)
  yyyy=$(echo "$birthdate" | cut -d'-' -f1)
  password="${mm}${yyyy}"

  echo "Creating user: $username with password: $password" | tee -a $LOG_FILE

  # Create user with home dir
  if id "$username" &>/dev/null; then
    echo "User $username already exists, skipping." | tee -a $LOG_FILE
  else
    useradd -m -G $(echo $groups | tr -d '"') "$username"
    echo "$username:$password" | chpasswd
  fi

  # Create shared folder if it doesn't exist
  if [[ ! -d "$sharedFolder" ]]; then
    mkdir -p "$sharedFolder"
    chgrp $(echo $groups | cut -d',' -f1 | tr -d '"') "$sharedFolder"
    chmod 770 "$sharedFolder"
    echo "Created shared folder $sharedFolder with group permissions" | tee -a $LOG_FILE
  fi

  # Create symlink in user's home directory
  ln -s "$sharedFolder" "/home/$username/shared" 2>/dev/null

done < "$CSV_FILE"

echo "User creation script finished at $(date)" | tee -a $LOG_FILE
