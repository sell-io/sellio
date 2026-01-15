namespace :db do
  desc "Backup the database"
  task backup: :environment do
    require 'fileutils'
    
    db_config = ActiveRecord::Base.connection_config
    db_name = db_config[:database]
    db_user = db_config[:username] || 'postgres'
    db_host = db_config[:host] || 'localhost'
    db_port = db_config[:port] || 5432
    db_password = db_config[:password] || ''
    
    backup_dir = File.join(Dir.home, 'sellio-backups')
    FileUtils.mkdir_p(backup_dir)
    
    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    backup_file = File.join(backup_dir, "sellio_backup_#{timestamp}.sql")
    
    puts "Starting database backup..."
    puts "Database: #{db_name}"
    puts "Backup file: #{backup_file}"
    
    # Set password for pg_dump
    ENV['PGPASSWORD'] = db_password
    
    # Create backup
    system("pg_dump -h #{db_host} -p #{db_port} -U #{db_user} -d #{db_name} -F p > #{backup_file}")
    
    if $?.success?
      # Compress the backup
      system("gzip #{backup_file}")
      compressed_file = "#{backup_file}.gz"
      
      size = File.size(compressed_file)
      size_mb = (size / 1024.0 / 1024.0).round(2)
      
      puts "✓ Backup completed successfully!"
      puts "  File: #{compressed_file}"
      puts "  Size: #{size_mb} MB"
      
      # Clean up old backups (keep last 30 days)
      puts "Cleaning up old backups (keeping last 30 days)..."
      old_backups = Dir.glob(File.join(backup_dir, "sellio_backup_*.sql.gz"))
      old_backups.each do |backup|
        if File.mtime(backup) < 30.days.ago
          File.delete(backup)
          puts "  Deleted: #{File.basename(backup)}"
        end
      end
      
      remaining = Dir.glob(File.join(backup_dir, "sellio_backup_*.sql.gz")).count
      puts "✓ Cleanup complete. Total backups: #{remaining}"
      
      # Backup storage directory
      puts "Backing up storage directory..."
      storage_dir = Rails.root.join('storage')
      if Dir.exist?(storage_dir)
        storage_backup = File.join(backup_dir, "sellio_storage_#{timestamp}.tar.gz")
        system("tar -czf #{storage_backup} -C #{Rails.root} storage/")
        if $?.success?
          size = File.size(storage_backup)
          size_mb = (size / 1024.0 / 1024.0).round(2)
          puts "✓ Storage backup completed!"
          puts "  File: #{storage_backup}"
          puts "  Size: #{size_mb} MB"
        else
          puts "⚠ Storage backup failed"
        end
      else
        puts "⚠ Storage directory not found, skipping..."
      end
    else
      puts "✗ Backup failed!"
      exit 1
    end
  end
  
  desc "List all database backups"
  task :list_backups do
    backup_dir = File.join(Dir.home, 'sellio-backups')
    
    if Dir.exist?(backup_dir)
      backups = Dir.glob(File.join(backup_dir, "sellio_backup_*.sql.gz")).sort_by { |f| File.mtime(f) }.reverse
      
      if backups.any?
        puts "Database backups:"
        puts "-" * 80
        backups.each do |backup|
          size = File.size(backup)
          size_mb = (size / 1024.0 / 1024.0).round(2)
          mtime = File.mtime(backup)
          puts "#{File.basename(backup)}"
          puts "  Size: #{size_mb} MB"
          puts "  Date: #{mtime.strftime('%Y-%m-%d %H:%M:%S')}"
          puts
        end
      else
        puts "No backups found."
      end
    else
      puts "Backup directory does not exist: #{backup_dir}"
    end
  end
  
  desc "Restore database from backup"
  task :restore, [:backup_file] => :environment do |t, args|
    if args[:backup_file].nil?
      puts "Usage: rails db:restore[path/to/backup.sql.gz]"
      exit 1
    end
    
    backup_file = args[:backup_file]
    
    unless File.exist?(backup_file)
      puts "Error: Backup file not found: #{backup_file}"
      exit 1
    end
    
    db_config = ActiveRecord::Base.connection_config
    db_name = db_config[:database]
    db_user = db_config[:username] || 'postgres'
    db_host = db_config[:host] || 'localhost'
    db_port = db_config[:port] || 5432
    db_password = db_config[:password] || ''
    
    puts "WARNING: This will replace the current database!"
    print "Are you sure you want to continue? (yes/no): "
    confirmation = STDIN.gets.chomp
    
    unless confirmation.downcase == 'yes'
      puts "Restore cancelled."
      exit 0
    end
    
    puts "Restoring database from: #{backup_file}"
    
    # Decompress if needed
    if backup_file.end_with?('.gz')
      puts "Decompressing backup..."
      system("gunzip -c #{backup_file} > /tmp/restore_temp.sql")
      restore_file = '/tmp/restore_temp.sql'
    else
      restore_file = backup_file
    end
    
    # Set password for psql
    ENV['PGPASSWORD'] = db_password
    
    # Drop and recreate database
    puts "Dropping existing database..."
    system("psql -h #{db_host} -p #{db_port} -U #{db_user} -d postgres -c \"DROP DATABASE IF EXISTS #{db_name};\"")
    system("psql -h #{db_host} -p #{db_port} -U #{db_user} -d postgres -c \"CREATE DATABASE #{db_name};\"")
    
    # Restore from backup
    puts "Restoring database..."
    system("psql -h #{db_host} -p #{db_port} -U #{db_user} -d #{db_name} < #{restore_file}")
    
    if $?.success?
      puts "✓ Database restored successfully!"
      
      # Clean up temp file
      File.delete(restore_file) if File.exist?(restore_file)
    else
      puts "✗ Restore failed!"
      exit 1
    end
  end
end
