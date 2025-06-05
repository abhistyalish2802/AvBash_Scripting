#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Usage: $0 <csv_file>"
  exit 1
fi

CSV_FILE="$1"

if [ ! -f "$CSV_FILE" ]; then
  echo "File not found: $CSV_FILE"
  exit 1
fi

# Skip header, use awk to parse CSV properly (handle quoted fields)
awk -F',' '
NR>1 {
  email = $1;
  birthdate = $2;
  # groups may be quoted with commas, remove quotes
  groups = $3;
  gsub(/"/, "", groups);
  # sharedFolder is $4 (last field)
  sharedFolder = $4;

  # print for debugging
  print email, birthdate, groups, sharedFolder;
}' "$CSV_FILE" | while read -r email birthdate groups sharedFolder; do

  username=$(echo "$email" | awk -F'@' '{print $1}' | tr -d '.')
  password=$(date -d "$birthdate" +"%m%Y" 2>/dev/null)

  echo "🔧 Creating user: $username"

  if id "$username" &>/dev/null; then
    echo "ℹ️ User $username already exists, skipping creation."
  else
    useradd -m -s /bin/bash "$username" && echo "$username:$password" | chpasswd || {
      echo "❌ Failed to create $username"
      continue
    }
  fi

  # Add user to groups
  IFS=',' read -ra grps <<< "$groups"
  for grp in "${grps[@]}"; do
    grp=$(echo "$grp" | xargs)
    if ! getent group "$grp" >/dev/null; then
      groupadd "$grp"
    fi
    usermod -aG "$grp" "$username"
  done

  # Create shared folder if exists
  if [ -n "$sharedFolder" ]; then
    echo "📁 Creating shared folder: $sharedFolder"
    mkdir -p "$sharedFolder"
    chown "$username:$username" "$sharedFolder"
  fi

done

echo "✅ All users processed successfully!"

