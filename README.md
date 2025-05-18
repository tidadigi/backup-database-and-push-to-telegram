
#!/bin/bash

# === Cấu hình ===
DB_USER="root"
DB_PASS="12345"  #Passwd root mysql
TELEGRAM_BOT_TOKEN="xxxxxxxx" # Token Telegram
TELEGRAM_CHAT_ID="-123456" #ID Group Telegram
BACKUP_DIR="/home/mysql_backup_telegram"

mkdir -p "$BACKUP_DIR"

# Gửi tin nhắn thông báo trước
HEADER_MSG="✅✅✅ Server ${SERVER_IP} - Backup - ${DATE}"
curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
     -d chat_id="$TELEGRAM_CHAT_ID" \
     -d text="$HEADER_MSG"

# Lấy danh sách các database (bỏ qua system DB)
DBS=$(mysql -u"$DB_USER" -p"$DB_PASS" -e "SHOW DATABASES;" | grep -Ev "Database|information_schema|performance_schema|mysql|sys")

for DB in $DBS; do
    FILENAME="${SERVER_IP}-${DB}-${DATE}.sql.gz"
    FILEPATH="${BACKUP_DIR}/${FILENAME}"

    echo "Đang dump database: $DB ..."
    mysqldump -u"$DB_USER" -p"$DB_PASS" "$DB" | gzip > "$FILEPATH"

    echo "Gửi file $FILENAME lên Telegram ..."
    curl -s -F document=@"$FILEPATH" \
         -F chat_id="$TELEGRAM_CHAT_ID" \
         "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendDocument"
done

# Xoá toàn bộ file sau khi gửi
echo "Đang xóa file backup trong $BACKUP_DIR ..."
rm -f ${BACKUP_DIR}/*.sql.gz

echo "Hoàn tất!"
