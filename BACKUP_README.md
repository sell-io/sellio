# Database Backup System

This project includes an automated daily backup system for the PostgreSQL database.

## Backup Location

All backups are stored in: `~/sellio-backups/`

Backups are automatically compressed (`.sql.gz` format) and kept for 30 days.

## Manual Backup

### Using the Bash Script

```bash
./bin/backup-db
```

### Using Rails Rake Task

```bash
rails db:backup
```

## Viewing Backups

List all available backups:

```bash
rails db:list_backups
```

Or manually:

```bash
ls -lh ~/sellio-backups/
```

## Restoring from Backup

**⚠️ WARNING: This will replace your current database!**

```bash
rails db:restore[~/sellio-backups/sellio_backup_20260115_124023.sql.gz]
```

Or using psql directly:

```bash
# Decompress first
gunzip ~/sellio-backups/sellio_backup_20260115_124023.sql.gz

# Restore
PGPASSWORD=test psql -h localhost -p 5432 -U postgres -d sellio < ~/sellio-backups/sellio_backup_20260115_124023.sql
```

## Automated Daily Backups

A cron job is configured to run backups automatically every day at 2:00 AM.

To view the cron job:
```bash
crontab -l
```

To edit the cron job:
```bash
crontab -e
```

To change the backup time, edit the cron entry:
```
0 2 * * * cd /home/alex/repos/sellio && /home/alex/repos/sellio/bin/backup-db >> /home/alex/sellio-backups/backup.log 2>&1
```

The format is: `minute hour day month weekday`

Examples:
- `0 2 * * *` - Every day at 2:00 AM
- `0 */6 * * *` - Every 6 hours
- `0 0 * * 0` - Every Sunday at midnight

## Backup Logs

Backup execution logs are saved to: `~/sellio-backups/backup.log`

## Backup Retention

Backups older than 30 days are automatically deleted to save disk space. This can be changed in:
- `bin/backup-db` - Edit the `KEEP_DAYS` variable
- `lib/tasks/backup.rake` - Edit the `30.days.ago` value

## Troubleshooting

### Check if cron is running
```bash
sudo service cron status
```

### View recent backup logs
```bash
tail -f ~/sellio-backups/backup.log
```

### Test backup manually
```bash
./bin/backup-db
```

### Verify backup file
```bash
gunzip -c ~/sellio-backups/sellio_backup_*.sql.gz | head -20
```
