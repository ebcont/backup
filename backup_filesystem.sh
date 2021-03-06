#!/bin/bash -ex

date
echo "begin filesystem backup"

# credentials
XCRED="/root/bin/credentials"

if [ ! -f $XCRED ]; then
  echo "$XCRED does not exist."
  exit 1
fi

XFSBACKUPACTIVE=$(cat $XCRED | grep XFSBACKUPACTIVE | cut -d "=" -f2)
if [ ! $XFSBACKUPACTIVE == "YES" ]; then
  exit 1
fi

XBACKUPPATH=$(cat $XCRED | grep XBACKUPPATH | cut -d "=" -f2)
XFILEPATH=$(cat $XCRED | grep XFILEPATH | cut -d "=" -f2)
XDATE=$(date +"%Y%m%d")

XCRON=$(grep backup_filesystem.sh /etc/crontab | wc -l)

if [ $XCRON -eq 0 ]; then
  echo "0 3 * * *	root	/root/bin/git/backup/backup_filesystem.sh >> /var/log/backup_filesystem.log" >> /etc/crontab
fi

mkdir -p $XBACKUPPATH

# Make tar
tar cvzf $XBACKUPPATH/$XDATE-fs.tgz $XFILEPATH

# Delete files older than 1 days
find $XBACKUPPATH/* -mtime +0 -exec rm {} \;

#this file is only needed to check for monitoring if backup is working - we will check the date of the file
touch $XBACKUPPATH/check_backup_filesystem

echo "end filesystem backup"
date


exit 0
