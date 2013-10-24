#!/bin/bash -ex

date
echo "begin oracleXE backup"
echo "debug1"

# credentials
XCRED="/root/bin/credentials"
echo "debug2"

if [ ! -f $XCRED ]; then
  echo "$XCRED does not exist."
  exit 1
fi
echo "debug3"

XOXEBACKUPACTIVE=$(cat $XCRED | grep XOXEBACKUPACTIVE | cut -d "=" -f2)
if [ ! $XOXEBACKUPACTIVE == "YES" ]; then
  exit 1
  echo "oracleXE-backup is not activated in credentials
fi
echo "debug4"

XOXEUSER=$(cat $XCRED | grep XOXEUSER | cut -d "=" -f2)
XOXEPWD=$(cat $XCRED | grep XOXEPWD | cut -d "=" -f2)
XBACKUPPATH=$(cat $XCRED | grep XBACKUPPATH | cut -d "=" -f2)
XDATE=$(date +"%Y%m%d")
echo "debug5"

XCRON=$(grep backup_oracleXE.sh /etc/crontab | wc -l)
echo "debug6"

if [ $XCRON -eq 0 ]; then
  echo "0 2 * * *	root	/root/bin/git/backup/backup_oracleXE.sh >> /var/log/backup_oracleXE.log" >> /etc/crontab
fi
echo "debug7"

mkdir -p $XBACKUPPATH
echo "debug8"

# Dump database into SQL file
exp $XOXEUSER/$XOXEPWD FILE=$XBACKUPPATH/$XDATE-oracleXE-$XOXEUSER.dmp OWNER=$XOXEUSER statistics=none
echo "debug9"

# Make tar
tar cvzf $XBACKUPPATH/$XDATE-oracleXE-$XOXEUSER.tgz $XBACKUPPATH/$XDATE-oracleXE-$XOXEUSER.dmp
echo "debug10"

# Delete SQL-file
rm $XBACKUPPATH/$XDATE-oracleXE-$XOXEUSER.dmp
echo "debug11"

# Delete files older than 1 days
find $XBACKUPPATH/* -mtime +1 -exec rm {} \;
echo "debug12"

#this file is only needed to check for monitoring if backup is working - we will check the date of the file
touch $XBACKUPPATH/check_backup_oracleXE
echo "debug13"

echo "end oracleXE backup"
date


exit 0
