#!/bin/bash -ex

date
echo "begin oracleXE backup"

# credentials
XCRED="/root/bin/credentials"

if [ ! -f $XCRED ]; then
  echo "$XCRED does not exist."
  exit 1
fi

XOXEBACKUPACTIVE=$(cat $XCRED | grep XOXEBACKUPACTIVE | cut -d "=" -f2)
if [ ! $XOXEBACKUPACTIVE == "YES" ]; then
  exit 1
  echo "oracleXE-backup is not activated in credentials"
fi

XOXEUSER=$(cat $XCRED | grep XOXEUSER | cut -d "=" -f2)
XOXEPWD=$(cat $XCRED | grep XOXEPWD | cut -d "=" -f2)
XBACKUPPATH=$(cat $XCRED | grep XBACKUPPATH | cut -d "=" -f2)
XOXEORACLEHOME=$(cat $XCRED | grep XOXEORACLEHOME | cut -d "=" -f2)
XDATE=$(date +"%Y%m%d")

export ORACLE_HOME=$XOXEORACLEHOME
export ORACLE_SID=XE

XCRON=$(grep backup_oracleXE.sh /etc/crontab | wc -l)

if [ $XCRON -eq 0 ]; then
  echo "0 2 * * *	root	/root/bin/git/backup/backup_oracleXE.sh >> /var/log/backup_oracleXE.log" >> /etc/crontab
fi

mkdir -p $XBACKUPPATH

XEXP="/bin/exp"
# Dump database into SQL file
$XOXEORACLEHOME$XEXP $XOXEUSER/$XOXEPWD FILE=$XBACKUPPATH/$XDATE-oracleXE-$XOXEUSER.dmp OWNER=$XOXEUSER statistics=none 2>&1

# Make tar
tar cvzf $XBACKUPPATH/$XDATE-oracleXE-$XOXEUSER.tgz $XBACKUPPATH/$XDATE-oracleXE-$XOXEUSER.dmp

# Delete SQL-file
rm $XBACKUPPATH/$XDATE-oracleXE-$XOXEUSER.dmp

# Delete files older than 1 days
find $XBACKUPPATH/* -mtime +0 -exec rm {} \;

#this file is only needed to check for monitoring if backup is working - we will check the date of the file
touch $XBACKUPPATH/check_backup_oracleXE

echo "end oracleXE backup"
date


exit 0
