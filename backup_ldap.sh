#!/bin/sh
LDAPBK=ldap-$( date +%y%m%d-%H%M ).ldif
BACKUPDIR=/backup
/usr/sbin/slapcat -v -b "dc=ebcont,dc=com" -l $BACKUPDIR/$LDAPBK
tar cfvz $BACKUPDIR/$LDAPBK.tgz $BACKUPDIR/$LDAPBK
rm $BACKUPDIR/$LDAPBK
find $BACKUPDIR/* -mtime +0 -exec rm {} \;