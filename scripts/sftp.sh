#!/bin/bash

HOST=pacer
USER=instartlogic
PASSWORD=/root/elk/scripts/pass
LOCAL=/root/elk/files
FINAL=/root/elk/final
DIR=(apw jcw cp)
LOG=/var/log/elk/filecopy_`date +%Y%m%d.log`

set -x
function connect {
# Login to pacer and get CDN logs for yesterday
	for i in ${DIR[*]}; do
        	sshpass -f $PASSWORD sftp $USER@$HOST << !
        	cd $i
        	pwd
		get access_log_`date +"%Y-%m-%d"`*.gz $LOCAL/$i
        	bye
!
		if [ $? -eq 0 ]; then
                	echo "`date -u` SFTP Login for $i is Successful..."
        	else
                	echo "`date -u` SFTP Login for $i has FAILED!!!"
        	fi
	done

# Decompress gzip files and store in a single file with date extension
	for i in ${DIR[*]}; do
        	for x in $LOCAL/$i/*; do
                	gzip -dc < $x >> $FINAL/"$i"_access_log_`date +"%Y-%m-%d"`
                	rm -rf $x
        	done
		echo "`date -u` $i - Done unzipping and removal of zipped files.."
	done

}

# Delete files older than 2 days
function delete {
        find $FINAL/* -mtime +2 -exec rm {} \;
        echo "`date -u` Removed log file older than 2 days.."
}

# Logs all activities
function log {
        exec 1>>$LOG 2>&1
}

log
connect
delete
