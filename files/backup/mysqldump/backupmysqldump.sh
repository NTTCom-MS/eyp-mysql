#!/bin/bash

# puppet managed file

function initbck
{

	if [ -z "${DESTINATION}" ];
	then
		echo "no destination defined"
		BCKFAILED=1
	else
		mkdir -p $DESTINATION
		BACKUPTS=$(date +%Y%m%d%H%M)

		if [ -z "${LOGDIR}" ];
		then
			LOGDIR=$DESTINATION
		fi

		CURRENTBACKUPLOG="$LOGDIR/$BACKUPTS.log"

		BCKFAILED=0

		if [ -z "$LOGDIR" ];
		then
			exec 2>&1
		else
			exec >> $CURRENTBACKUPLOG 2>&1
		fi
	fi
}

function mailer
{
	MAILCMD=$(which mail 2>/dev/null)
	if [ -z "$MAILCMD" ];
	then
		echo "mail not found, skipping"
	else
		if [ -z "$MAILTO" ];
		then
			echo "mail skipped, no MAILTO defined"
			exit $BCKFAILED
		else
			if [ -z "$LOGDIR" ];
			then
				if [ "$BCKFAILED" -eq 0 ];
				then
					echo "OK" | $MAILCMD -s "$IDHOST-MySQL-OK" $MAILTO
				else
					echo "ERROR - no log file configured" | $MAILCMD -s "$IDHOST-MySQL-ERROR" $MAILTO
				fi
			else
				if [ "$BCKFAILED" -eq 0 ];
				then
					$MAILCMD -s "$IDHOST-MySQL-OK" $MAILTO < $CURRENTBACKUPLOG
				else
					$MAILCMD -s "$IDHOST-MySQL-ERROR" $MAILTO < $CURRENTBACKUPLOG
				fi
			fi
		fi
	fi
}

function dump_grants
{
	GRANTSDEST="$DESTINATION/$BACKUPTS"
	mkdir -p $GRANTSDEST

	GRANTSDESTFILE="$GRANTSDEST/${IDHOST}.grants.sql"

	echo "SELECT DISTINCT CONCAT('SHOW GRANTS FOR ''', user, '''@''', host, ''';') FROM mysql.user" | $MYSQLBIN ${MYSQL_INSTANCE_OPTS} -N | $MYSQLBIN ${MYSQL_INSTANCE_OPTS} -N 2>/dev/null | sed 's/$/;/' > $GRANTSDESTFILE

	if [[ ! -s "$GRANTSDESTFILE" ]];
	then
		echo "grants.sql not created or empty"
		BCKFAILED=1
	fi

}

function mysqldump
{
	DUMPDEST="$DESTINATION/$BACKUPTS"

	mkdir -p $DUMPDEST

	DBS=${DBS-$(echo show databases | $MYSQLBIN ${MYSQL_INSTANCE_OPTS} -N  | grep -vE '^(information|performance)_schema$|^mysql$')}

	MASTERDATA=${MASTERDATA-1}

	DUMPDESTFILE="$DUMPDEST/${IDHOST}.all.databases.sql"

	if [ -z "$DBS" ];
	then
		echo "no dbs found"
		BCKFAILED=1
	else
		MYSQLDUMP_BASEOPTS=${MYSQLDUMP_BASEOPTS-"--opt --routines -E --master-data=$MASTERDATA"}

		CURRENTBACKUPLOGDUMPERR=${CURRENTBACKUPLOG-$DUMPDESTFILE.err}

		"$MYSQLDUMPBIN" $MYSQLDUMP_BASEOPTS $MYSQLDUMP_EXTRAOPTS --databases $DBS > $DUMPDESTFILE 2> ${CURRENTBACKUPLOGDUMPERR}

		if [ "$?" -ne 0 ];
		then
			echo "mysqldump error, check logs"
			BCKFAILED=1
		fi

		if [ ! -z "$(cat ${CURRENTBACKUPLOG}.err)" ];
		then
			echo "mysqldump error, check log ${CURRENTBACKUPLOGDUMPERR}"
			BCKFAILED=1
		fi

		if [[ ! -s "$DUMPDESTFILE" ]];
		then
			echo "dump empty or not found, check logs"
			BCKFAILED=1
		fi
	fi

}

function cleanup
{
	if [ -z "$RETENTION" ];
	then
		echo "cleanup skipped, no RETENTION defined"
	else
		find $DESTINATION -type f -mtime +$RETENTION -delete
		find $DESTINATION -type d -empty -delete
	fi
}

function compress
{
	if [ -z "$COMPRESS" ];
	then
		echo "compress skipped"
	else
		find $DESTINATION/$BACKUPTS -type f -exec gzip -9 {} \;
	fi
}

PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"

BASEDIRBCK=$(dirname $0)
BASENAMEBCK=$(basename $0)
IDHOST=${IDHOST-$(hostname -s)}

if [ ! -z "${INSTANCE_NAME}" ];
then
	MYSQL_INSTANCE_OPTS="--defaults-file=/etc/mysql/${INSTANCE_NAME}/my.cnf"
fi

if [ ! -z "$1" ] && [ -f "$1" ];
then
	. $1 2>/dev/null
else
	if [[ -s "$BASEDIRBCK/${BASENAMEBCK%%.*}.config" ]];
	then
		. $BASEDIRBCK/${BASENAMEBCK%%.*}.config 2>/dev/null
	else
		echo "config file missing"
		BCKFAILED=1
	fi
fi

MYSQLBIN=${MYSQLBIN-$(which mysql 2>/dev/null)}
if [ -z "$MYSQLBIN" ];
then
	echo "mysql not found"
	BCKFAILED=1
fi

MYSQLDUMPBIN=${MYSQLDUMPBIN-$(which mysqldump 2>/dev/null)}
if [ -z "$MYSQLDUMPBIN" ];
then
	echo "mysqldump not found"
	BCKFAILED=1
fi

VERSIOMYSQL=$(echo 'select version();' | $MYSQLBIN ${MYSQL_INSTANCE_OPTS} -N)

if [ "$?" -ne 0 ];
then
	echo "error connecting to MySQl"
	BCKFAILED=1
fi

#
#
#

initbck

if [ "$BCKFAILED" -ne 1 ];
then
	date
	echo GRANTS
	dump_grants
	date
	echo DUMP
	mysqldump
	date
fi

mailer
compress
cleanup
