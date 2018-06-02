#!/bin/sh

# Updating developers database

FOLDER='tmp'
DATE=$(date +%Y-%m-%d_%H-%M)

echo "Backup begin: $DATE" >> $FOLDER/backup.log

pg_dump -v -Z9 -Fc -h 95.213.247.4 -U ksazd raoesv -f $FOLDER/raoesv-$DATE.sql
pg_restore -v -c --dbname=raoesv_development -U postgres $FOLDER/raoesv-$DATE.sql
