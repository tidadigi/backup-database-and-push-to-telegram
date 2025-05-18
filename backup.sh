#!/bin/bash

# === Config ===
DB_USER="root"
DB_PASS="12345"  #Passwd root mysql
TELEGRAM_BOT_TOKEN="xxxxxxxx" # Token Telegram
TELEGRAM_CHAT_ID="-123456" #ID Group Telegram
DATE=$(date +"%d-%m-%Y")
SERVER_IP=$(hostname -I | awk '{print $1}')
BACKUP_DIR="/root/mysql_backup_telegram"

mkdir -p "$BACKUP_DIR"

# Send a notification message in advance
HEADER_MSG="✅✅✅ Server ${SERVER_IP} - Backup - ${DATE}"
curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
     -d chat_id="$TELEGRAM_CHAT_ID" \
     -d text="$HEADER_MSG"

# List all databases (excluding system databases)
DBS=$(mysql -u"$DB_USER" -p"$DB_PASS" -e "SHOW DATABASES;" | grep -Ev "Database|information_schema|performance_schema|mysql|sys")

for DB in $DBS; do
    FILENAME="${SERVER_IP}-${DB}-${DATE}.sql.gz"
    FILEPATH="${BACKUP_DIR}/${FILENAME}"

    echo "Dumping database: $DB ..."
    mysqldump -u"$DB_USER" -p"$DB_PASS" "$DB" | gzip > "$FILEPATH"

    echo "Send the file $FILENAME to Telegram ..."
    curl -s -F document=@"$FILEPATH" \
         -F chat_id="$TELEGRAM_CHAT_ID" \
         "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendDocument"
done

# Delete all files after sending
echo "Deleting backup files in $BACKUP_DIR ..."
rm -f ${BACKUP_DIR}/*.sql.gz

echo "Complete!"
