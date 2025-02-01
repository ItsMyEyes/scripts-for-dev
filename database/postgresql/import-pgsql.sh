#!/bin/bash

# Configuration
DB_HOST="remote_host"
DB_NAME="your_database"
DB_USER="your_username"
DB_PORT="5432"
DB_PASSWORD="your_password"
BACKUP_FILE="/path/to/your/backup.sql.gz"

# Drop and recreate database
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -p $DB_PORT postgres -c "DROP DATABASE IF EXISTS $DB_NAME;"
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -p $DB_PORT postgres -c "CREATE DATABASE $DB_NAME;"

# Restore from backup
gunzip < $BACKUP_FILE | PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -p $DB_PORT $DB_NAME

echo "Restore completed for $DB_NAME"