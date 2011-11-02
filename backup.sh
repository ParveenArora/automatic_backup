#!/bin/sh
#----------------------------------------------------------------------
# System + MySQL backup script
# This script is licensed under GNU GPL version 3.0 or above
#Author Parveen Arora (osm@parveenarora.in)
# ---------------------------------------------------------------------

#########################
######TO BE MODIFIED#####

### System Setup ###
BACKUP=mysql_backup
TOTAL_BACKUP=allfiles
###System Files Backup Setup#####
DIR=path to system directory 

### MySQL Setup ###
MUSER="User Name of MySQL"
MPASS="Password"
MHOST="localhost"

### SCP server Setup ###
SCPD="path to scp directory"
SCPU="username of scp"
SCPS="host address"
#########################################
######DO NOT MAKE MODIFICATION BELOW#####
#########################################

### Binaries ###
TAR="$(which tar)"
GZIP="$(which gzip)"
SCP="$(which scp)"
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"

### Today + hour in 24h format ###
NOW=$(date +"%d%H%M")

### Create minutely dir ###

mkdir -p $BACKUP/$NOW/$db

### Get all databases name ###
DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
for db in $DBS
do

### Create dir for each databases, backup tables in individual files ###
  mkdir -p $BACKUP/$NOW/$db

  for i in `echo "show tables" | $MYSQL -u $MUSER -h $MHOST -p$MPASS $db|grep -v Tables_in_`;
  do
    FILE=$BACKUP/$NOW/$db/$i.sql.gz
    echo $i; $MYSQLDUMP --add-drop-table --all-databases -q -c -u $MUSER -h $MHOST -p$MPASS $db $i | $GZIP -9 > $FILE
  done
done

### Compress all tables in one nice file to upload ###

ARCHIVE=$BACKUP/$NOW.tar.gz
ARCHIVED=$BACKUP/$NOW

$TAR -cvf $ARCHIVE $ARCHIVED




### Dump backup using SCP ###
cd $BACKUP

DUMPFILE=$NOW.tar.gz
mkdir -p $TOTAL_BACKUP
mv $DUMPFILE $TOTAL_BACKUP
cp -r $DIR $TOTAL_BACKUP


TOTAL=all_$NOW.tar.gz

$TAR -cvf $TOTAL $TOTAL_BACKUP


$SCP $TOTAL $SCPU@$SCPS:$SCPD


### Delete the backup dir and keep archive ###

rm -rf $TOTAL_BACKUP $DUMPFILE $ARCHIVED 
