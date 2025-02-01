# MySQL Database Backup Tool Documentation

## Overview
This tool provides functionality for importing and exporting MySQL databases with various features including compression, verification, and error handling.

## Prerequisites
- MySQL/MariaDB installed
- bash shell
- gzip utility
- Appropriate database permissions

## Installation
1. Download both scripts to your server
2. Make them executable:
```bash
chmod +x mysql_backup.sh
```

## Usage

### Export Database
Export a database to a compressed backup file.

```bash
./mysql_backup.sh export DB_USER DB_PASS DB_NAME BACKUP_PATH
```

Parameters:
- `DB_USER`: MySQL username
- `DB_PASS`: MySQL password
- `DB_NAME`: Database name to export
- `BACKUP_PATH`: Directory where backup will be stored

Example:
```bash
./mysql_backup.sh export myuser mypassword mydatabase /backups
```

This will create a file like: `/backups/mydatabase_20240202_123456.sql.gz`

### Import Database
Import a database from a backup file (supports both .sql and .sql.gz files).

```bash
./mysql_backup.sh import DB_USER DB_PASS DB_NAME IMPORT_FILE
```

Parameters:
- `DB_USER`: MySQL username
- `DB_PASS`: MySQL password
- `DB_NAME`: Target database name
- `IMPORT_FILE`: Path to the backup file

Example:
```bash
./mysql_backup.sh import myuser mypassword mydatabase /backups/mydatabase_20240202_123456.sql.gz
```

## Features

### Export Features
- Timestamped backups
- Automatic compression
- Backup verification
- Includes:
  - Stored procedures
  - Triggers
  - Events
  - Table structures
  - Data
- Creates backup directories automatically
- Transaction-consistent backups

### Import Features
- Supports compressed (.gz) and uncompressed files
- Automatic database creation if needed
- Clear error reporting
- Handles large imports efficiently

## Error Handling
The script includes comprehensive error checking:
- Verifies file existence
- Checks backup integrity
- Validates database connections
- Reports clear error messages

## Example Workflow

1. Create a backup:
```bash
./mysql_backup.sh export dbuser dbpass production_db /var/backups/mysql
```

2. Verify the backup file exists:
```bash
ls -l /var/backups/mysql/production_db_*.sql.gz
```

3. Import to a new database:
```bash
./mysql_backup.sh import dbuser dbpass new_database /var/backups/mysql/production_db_20240202_123456.sql.gz
```

## Best Practices

1. **Security**
   - Store credentials securely
   - Use a dedicated backup user
   - Restrict backup file permissions

2. **Backup Strategy**
   - Schedule regular backups
   - Keep multiple backup generations
   - Test restores periodically

3. **Performance**
   - Schedule backups during low-usage periods
   - Monitor disk space
   - Clean up old backups

## Troubleshooting

### Common Issues

1. Permission Denied
```bash
chmod +x mysql_backup.sh
```

2. Backup Directory Not Found
```bash
mkdir -p /path/to/backup
```

3. Database Connection Failed
- Verify credentials
- Check MySQL server status
- Confirm network connectivity

### Error Messages

- "ERROR: Backup file is empty or missing"
  - Check disk space
  - Verify MySQL permissions

- "ERROR: Import failed"
  - Verify file integrity
  - Check database permissions
  - Ensure sufficient disk space

## Support
For issues or feature requests:
1. Check error messages
2. Verify permissions
3. Check MySQL logs
4. Contact database administrator

## Future Enhancements
- Multiple database backup support
- Email notifications
- Backup rotation
- Cloud storage integration

## License
This tool is provided as-is under the MIT license. Feel free to modify and distribute according to your needs.