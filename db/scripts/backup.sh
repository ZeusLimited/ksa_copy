#!/bin/bash

TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm)
BACKUP_NAME="ksazd_backup"
BACKUP_FILENAME="${BACKUP_NAME}_${TIMESTAMP}.dir"
BACKUP_DIR="/home/deployer"
BACKUP_LOG="${BACKUP_DIR}/log_$BACKUP_NAME-$TIMESTAMP.log"

cd $BACKUP_DIR && pg_dump -h 10.101.102.131 -U ksazd -v -Z 5 -j 4 -F d -f $BACKUP_FILENAME raoesv 2> $BACKUP_LOG

cd $BACKUP_DIR && cp $BACKUP_FILENAME /documents/pg_backups/$BACKUP_NAME/$TIMESTAMP/

# smtp

rm -rf $BACKUP_FILENAME

rm $BACKUP_LOG
