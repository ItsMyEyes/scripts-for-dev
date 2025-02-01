#!/bin/bash

# Remote host configuration
REMOTE_HOST="remote.example.com"
REMOTE_DB_NAME="your_database"
REMOTE_DB_USER="db_username"
REMOTE_DB_PORT="5432"
PASSWORD_DB=""

# Local backup configuration
BACKUP_DIR="/path/to/backup/directory"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/$REMOTE_DB_NAME-$DATE.sql"

# Create backup directory
mkdir -p $BACKUP_DIR

# Perform remote backup
PGPASSWORD=$PASSWORD_DB pg_dump \
  -h $REMOTE_HOST \
  -U $REMOTE_DB_USER \
  -p $REMOTE_DB_PORT \
  $REMOTE_DB_NAME > $BACKUP_FILE

# Compress backup
gzip $BACKUP_FILE

# Delete old backups (30 days)
find $BACKUP_DIR -name "*.gz" -mtime +30 -delete

# Log
echo "Backup completed: $BACKUP_FILE.gz" >> $BACKUP_DIR/backup.log