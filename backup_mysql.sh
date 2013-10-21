#!/bin/bash -ex

date
echo "begin mysql backup"

# credentials
XCRED="/root/bin/credentials"

if [ ! -f $XCRED ]; then
  echo "$XCRED does not exist."
  exit 1
fi

XMYSQLBACKUPACTIVE=$(cat $XCRED | grep XMYSQLBACKUPACTIVE | cut -d "=" -f2)
if [ ! $XMYSQLBACKUPACTIVE == "YES" ]; then
  exit 1
fi

XMYSQLUSER=$(cat $XCRED | grep XMYSQLUSER | cut -d "=" -f2)
XMYSQLPWD=$(cat $XCRED | grep XMYSQLPWD | cut -d "=" -f2)
XMYSQLHOST=$(cat $XCRED | grep XMYSQLHOST | cut -d "=" -f2)
XMYSQLDBNAME=$(cat $XCRED | grep XMYSQLDBNAME | cut -d "=" -f2)
XBACKUPPATH=$(cat $XCRED | grep XBACKUPPATH | cut -d "=" -f2)
XDATE=$(date +"%Y%m%d")

XCRON=$(grep backup_mysql.sh /etc/crontab | wc -l)

if [ $XCRON -eq 0 ]; then
  echo "0 1 * * *	root	/root/bin/git/backup/backup_mysql.sh >> /var/log/backup_mysql.log" >> /etc/crontab
fi

mkdir -p $XBACKUPPATH

# Dump database into SQL file
mysqldump --user=$XMYSQLUSER --password=$XMYSQLPWD --host=$XMYSQLHOST $XMYSQLDBNAME > $XBACKUPPATH/$XDATE-mysql-$XMYSQLDBNAME.sql

# Make tar
tar cvzf $XBACKUPPATH/$XDATE-mysql-$XMYSQLDBNAME.tgz $XBACKUPPATH/$XDATE-mysql-$XMYSQLDBNAME.sql

# Delete SQL-file
rm $XBACKUPPATH/$XDATE-mysql-$XMYSQLDBNAME.sql

# Delete files older than 1 days
find $XBACKUPPATH/* -mtime +1 -exec rm {} \;

#this file is only needed to check for monitoring if backup is working - we will check the date of the file
touch $XBACKUPPATH/check_backup_mysql

echo "end mysql backup"
date


exit 0
