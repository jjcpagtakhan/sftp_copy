#!/bin/bash

HOST=pacer
USER=instartlogic
PASSWORD=/root/elk/scripts/pass
LOCAL=/root/elk/files
FINAL=/root/elk/final
DIR=/apw
LOG=/var/log/elk/filecopy_`date +%Y%m%d.log`

#set -x
function connect {
# Login to pacer and get APW CDN logs for yesterday
        sshpass -f $PASSWORD sftp $USER@$HOST << !
        cd $DIR
        pwd
        get access_log_`date +"%Y-%m-%d"`*.gz $LOCAL
        bye
!
        if [ $? -eq 0 ]; then
                echo "`date -u` SFTP Login Successful..."
        else
                echo "`date -u` SFTP Login FAILED!!!"
        fi

# Decompress gzip files and store in a single file with date extension
        for i in $LOCAL/*; do
                gzip -dc < $i >> $FINAL/access_log_`date +"%Y-%m-%d"`
                rm -rf $i
        done
        echo "`date -u` Done unzipping and removal of zipped files.."

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

