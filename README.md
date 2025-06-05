<<<<<<< HEAD
# AvBash_Scripting
Scripts for learning and automating tasks with Bash shell.
AvBash_Scripting## Author
Name: Abhishek Choudhary
Student ID: 1000118874
Last Update: 2025-05-28

Setup Instructions
Make sure you have Docker installed on your computer.
Pull or build the Ubuntu Docker container for running the scripts.
Clone this repository to your local machine or inside your Docker container.
Open a terminal and go to the AvBash_Scripting folder.
The scripts you need are inside the task1 and task2 folders.
You can run the scripts directly using the bash command inside the container or your terminal.
How to execute the scripts
To run the user creation script: bash task1/user_creation_script.sh
To run the backup script: bash task2/backup_script.sh

=======
# User Management and Backup Scripts for Dockerized Ubuntu

## Author
- Name: Abhishek Singh
- Student ID: 1000118874
- Last Update: 2025-06-06

## Project Overview
This project contains two main scripts:
- User Management script (`user_manager.sh`) that reads a CSV file to create users, assign groups, set passwords, and create shared folder symlinks inside a Docker Ubuntu container.
- Backup script (`mybackup.sh`) that creates compressed backups of specified directories and stores them in a given destination inside the container.

## Setup Instructions
1. Start your Docker container running Ubuntu.
2. Copy the project folder (`task1` and `task2`) inside the container or create them manually.
3. Ensure both scripts are executable:
   ```bash
   chmod +x /root/project/task1/user_manager.sh
   chmod +x /root/project/task2/mybackup.sh
>>>>>>> 3e907ab (Final submission: Added Task 1, Task 2, README, and Self Assessment)
