#!/bin/bash

CSV_FILE="$1"
LOG_FILE="/var/log/user_script.log"

if [[ -z "$CSV_FILE" ]]; then
  echo "Usage: $0 <csv_file_path_or_url>"
  exit 1
fi

# Download file if it's a remote URL
if [[ "$CSV_FILE" =~ ^https?:// ]]; then
  echo "Downloading CSV from remote URL..."
  wget -q -O /tmp/users.csv "$CSV_FILE"
  CSV_FILE="/tmp/users.csv"
fi

echo "Starting user creation script at $(date)" | tee -a $LOG_FILE

while IFS=, read -r email birthdate groups sharedFolder; do
  # Skip the header line
  if [[ "$email" == "e-mail" ]]; then
    continue
  fi

  # Extract username: first initial + last name (e.g., ltorvalds from linus.torvalds@linux.org)
  username=$(echo "$email" | awk -F@ '{
    split($1, name, ".");
    if (length(name) >= 2)
      printf "%s%s", substr(name[1],1,1), name[2];
    else
      printf "%s", name[1];
  }' | tr '[:upper:]' '[:lower:]')

  # Format password as MMYYYY from birthdate
  mm=$(echo "$birthdate" | cut -d'-' -f2)
  yyyy=$(echo "$birthdate" | cut -d'-' -f1)
  password="${mm}${yyyy}"

  echo "Creating user: $username with password: $password" | tee -a $LOG_FILE

  # Create user if not exists
  if id "$username" &>/dev/null; then
    echo "User $username already exists, skipping." | tee -a $LOG_FILE
  else
    group_list=$(echo $groups | tr -d '"')
    useradd -m -G "$group_list" "$username"
    echo "$username:$password" | chpasswd
    echo "User $username created and added to groups: $group_list" | tee -a $LOG_FILE
  fi

  # Create shared folder if it doesn't exist
  if [[ ! -d "$sharedFolder" ]]; then
    mkdir -p "$sharedFolder"
    primary_group=$(echo $groups | cut -d',' -f1 | tr -d '"')
    chgrp "$primary_group" "$sharedFolder"
    chmod 770 "$sharedFolder"
    echo "Created shared folder $sharedFolder with group permissions" | tee -a $LOG_FILE
  fi

  # Create symlink in user's home directory
  ln -s "$sharedFolder" "/home/$username/shared" 2>/dev/null

done < "$CSV_FILE"

echo "User creation script finished at $(date)" | tee -a $LOG_FILE
