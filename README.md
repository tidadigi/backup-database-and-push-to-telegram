
#!/bin/bash

# === Cấu hình ===
DB_USER="root"

DB_PASS="12345"  #Passwd root mysql

TELEGRAM_BOT_TOKEN="xxxxxxxx" # Token Telegram

TELEGRAM_CHAT_ID="-123456" #ID Group Telegram

BACKUP_DIR="/home/mysql_backup_telegram"

mkdir -p "$BACKUP_DIR"


# Optional, run it daily using crontab
To run the script daily you can create a cronjob using crontab (usually it is installed as default on a Linux server). So open crontab using:

$ crontab -e

Fill the last line with:

0 0 * * * cd /home/backup/; backup.sh

This will run the script daily on at midnight 😉.

That's all! Open an issue if you need anything.
