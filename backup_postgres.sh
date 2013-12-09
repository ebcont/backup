#!/bin/bash -ex

date
echo "begin pgsql backup"

# credentials
XCRED="/root/bin/credentials"

if [ ! -f $XCRED ]; then
  echo "$XCRED does not exist."
  exit 1
fi

XPGSQLBACKUPACTIVE=$(cat $XCRED | grep XPGSQLBACKUPACTIVE | cut -d "=" -f2)
if [ ! $XPGSQLBACKUPACTIVE == "YES" ]; then
  exit 1
fi

XPGSQLDBNAME=$1
XBACKUPPATH=$(cat $XCRED | grep XBACKUPPATH | cut -d "=" -f2)

XDATE=$(date +"%Y%m%d")


if [ $XBACKUPPATH == "/" ]; then
	echo "Big mistake!"
	exit 1
fi

mkdir -p $XBACKUPPATH

# Dump database into SQL file
su - postgres -c "pg_dump $XPGSQLDBNAME" > $XBACKUPPATH/$XDATE-pgsql-$XPGSQLDBNAME.sql

# Make tar
tar cvzf $XBACKUPPATH/$XDATE-pgsql-$XPGSQLDBNAME.tgz $XBACKUPPATH/$XDATE-pgsql-$XPGSQLDBNAME.sql

# Delete SQL-file
rm $XBACKUPPATH/$XDATE-pgsql-$XPGSQLDBNAME.sql

# Delete files older than 1 days
find $XBACKUPPATH/* -mtime +0 -exec rm {} \;

#this file is only needed to check for monitoring if backup is working - we will check the date of the file
touch $XBACKUPPATH/check_backup_pgsql

echo "end pgsql backup"
date


exit 0
