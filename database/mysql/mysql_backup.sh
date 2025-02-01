#!/bin/bash

# mysql_export.sh
# Script for exporting MySQL databases with various options
export_mysql_db() {
    local DB_USER="$1"
    local DB_PASS="$2"
    local DB_NAME="$3"
    local BACKUP_PATH="$4"
    local DATE=$(date +%Y%m%d_%H%M%S)
    local BACKUP_FILE="${BACKUP_PATH}/${DB_NAME}_${DATE}.sql"
    local COMPRESSED_FILE="${BACKUP_FILE}.gz"

    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_PATH"

    echo "Starting backup of database: $DB_NAME"
    
    # Export database
    if mysqldump --user="$DB_USER" --password="$DB_PASS" \
        --databases "$DB_NAME" \
        --add-drop-database \
        --add-drop-table \
        --create-options \
        --quote-names \
        --set-charset \
        --triggers \
        --routines \
        --events \
        --single-transaction \
        --quick > "$BACKUP_FILE"; then
        
        echo "Database export completed: $BACKUP_FILE"
        
        # Compress the backup
        if gzip -9 "$BACKUP_FILE"; then
            echo "Backup compressed: $COMPRESSED_FILE"
            
            # Verify the backup file exists and has size greater than 0
            if [ -s "$COMPRESSED_FILE" ]; then
                echo "Backup verified successfully"
                return 0
            else
                echo "ERROR: Backup file is empty or missing"
                return 1
            fi
        else
            echo "ERROR: Compression failed"
            return 1
        fi
    else
        echo "ERROR: Database export failed"
        return 1
    fi
}

# Usage example for export:
# ./mysql_export.sh "username" "password" "database_name" "/path/to/backup/dir"

#!/bin/bash

# mysql_import.sh
# Script for importing MySQL databases
import_mysql_db() {
    local DB_USER="$1"
    local DB_PASS="$2"
    local DB_NAME="$3"
    local IMPORT_FILE="$4"

    echo "Starting import to database: $DB_NAME"

    # Check if import file exists
    if [ ! -f "$IMPORT_FILE" ]; then
        echo "ERROR: Import file does not exist: $IMPORT_FILE"
        return 1
    fi

    # Create database if it doesn't exist
    if mysql --user="$DB_USER" --password="$DB_PASS" \
        -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`"; then
        
        # Handle compressed files
        if [[ "$IMPORT_FILE" == *.gz ]]; then
            echo "Importing compressed file..."
            if gunzip < "$IMPORT_FILE" | mysql --user="$DB_USER" \
                --password="$DB_PASS" "$DB_NAME"; then
                echo "Import completed successfully"
                return 0
            else
                echo "ERROR: Import failed"
                return 1
            fi
        else
            echo "Importing uncompressed file..."
            if mysql --user="$DB_USER" --password="$DB_PASS" \
                "$DB_NAME" < "$IMPORT_FILE"; then
                echo "Import completed successfully"
                return 0
            else
                echo "ERROR: Import failed"
                return 1
            fi
        fi
    else
        echo "ERROR: Failed to create database"
        return 1
    fi
}

# Combined usage script
#!/bin/bash

# Main script that combines both import and export functionality
set -e

show_usage() {
    echo "Usage:"
    echo "  Export: $0 export DB_USER DB_PASS DB_NAME BACKUP_PATH"
    echo "  Import: $0 import DB_USER DB_PASS DB_NAME IMPORT_FILE"
    echo
    echo "Examples:"
    echo "  $0 export myuser mypass mydatabase /path/to/backup"
    echo "  $0 import myuser mypass mydatabase /path/to/backup/mydatabase.sql.gz"
}

# Main execution
case "$1" in
    "export")
        if [ $# -ne 5 ]; then
            show_usage
            exit 1
        fi
        export_mysql_db "$2" "$3" "$4" "$5"
        ;;
    "import")
        if [ $# -ne 5 ]; then
            show_usage
            exit 1
        fi
        import_mysql_db "$2" "$3" "$4" "$5"
        ;;
    *)
        show_usage
        exit 1
        ;;
esac

# Usage example for import:
# ./mysql_import.sh "username" "password" "database_name" "/path/to/backup/file.sql.gz"