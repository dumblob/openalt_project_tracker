#!/bin/sh

printf '%s\n' 'Script not finished. Nothing done. Exiting.' >&2
exit 1

backup_time="$(date date "+%Y-%m-%d_%T")"
backup_dir="$backup_time-redmine_dirs_and_db"
mkdir "$backup_dir"

# Backup MySQL
database_file = os.path.join("$backup_dir", "mysql_database.sql")
database = MySQL("Redmine database")
database.database = "redmine"
database.username = "redmine"
database.password = ""
database.destination = database_file
database.backup()

# Backup directories
srv_backup = os.path.join("$backup_dir", "redmine")
srv_redmine = Directory("Redmine source")
srv_redmine.path = "/srv/redmine"
srv_redmine.destination = srv_backup
srv_redmine.backup()

# Compress the whole backup
tar_file_name = "{0}.tar.gz".format(backup_time)
tar_file_path = os.path.join("/root", "backup", tar_file_name)

tar = TarCompressor(tar_file_path)
tar.add("$backup_dir")
tar.close()
