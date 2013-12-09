#!/bin/bash -ex

date
echo "begin ldap backup"

# credentials
XCRED="/root/bin/credentials"

if [ ! -f $XCRED ]; then
  echo "$XCRED does not exist."
  exit 1
fi

XLDAPBACKUPACTIVE=$(cat $XCRED | grep XLDAPBACKUPACTIVE | cut -d "=" -f2)
if [ ! $XLDAPBACKUPACTIVE == "YES" ]; then
  exit 1
fi

XLDAPBASE=$(cat $XCRED | grep XLDAPBASE | cut -d "=" -f2-)
XBACKUPPATH=$(cat $XCRED | grep XBACKUPPATH | cut -d "=" -f2-)

XDATE=$(date +"%Y%m%d")


if [ $XBACKUPPATH == "/" ]; then
	echo "Big mistake!"
	exit 1
fi

mkdir -p $XBACKUPPATH

# Dump ldap into ldif file
/usr/sbin/slapcat -v -b "$XLDAPBASE" -l $XBACKUPPATH/$XDATE-ldap.ldif

# Make tar
tar cvzf $XBACKUPPATH/$XDATE-ldap.ldif.tgz $XBACKUPPATH/$XDATE-ldap.ldif

# Delete SQL-file
rm $XBACKUPPATH/$XDATE-ldap.ldif

# Delete files older than 1 days
find $XBACKUPPATH/* -mtime +0 -exec rm {} \;

#this file is only needed to check for monitoring if backup is working - we will check the date of the file
touch $XBACKUPPATH/check_backup_ldap

echo "end ldap backup"
date


exit 0
