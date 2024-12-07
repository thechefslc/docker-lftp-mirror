#!/bin/sh

# Display variables for troubleshooting
echo -e "Variables set:\\n\
PUID=${PUID}\\n\
PGID=${PGID}\\n\
HOST=${HOST}\\n\
PORT=${PORT}\\n\
USERNAME=${USERNAME}\\n\
REMOTE_DIR=${REMOTE_DIR}\\n\
FINISHED_DIR=${FINISHED_DIR}\\n\
LFTP_PARTS=${LFTP_PARTS}\\n\
LFTP_FILES=${LFTP_FILES}\\n\
LFTP_OPTS=${LFTP_OPTS}\\n\
\\n\
Using DEFAULT script...\\n"


#--no-empty-dirs --Remove-source-files --Remove-source-dirs

# if no finished files directory specified, default to /config/download
[ -z "$FINISHED_DIR" ] && FINISHED_DIR="/config/download"

# create a directory for placing private key for lftp to use
mkdir -p /config/ssh

# create finished downloads directory
mkdir -p /config/download

while true
do
	# LFTP with specified segment & parallel
	echo "[$(date '+%H:%M:%S')] Checking ${REMOTE_DIR} for files....."
	
	lftp -u $USERNAME, sftp://$HOST -p $PORT <<-EOF
        set ssl:verify-certificate no
        set sftp:auto-confirm yes
        set sftp:connect-program "ssh -a -x -i /config/ssh/id_rsa"
	    mirror -c $LFTP_OPTS --use-pget-n=$LFTP_PARTS -P$LFTP_FILES $REMOTE_DIR $FINISHED_DIR
	quit
	EOF

#    if [ "$(ls -A /config/.download)" ]
#    then
#    	# Move finished downloads to destination directory
#    	echo "[$(date '+%H:%M:%S')] Moving files....."
#   	chmod -R 777 /config/.download/*
#       mv -fv /config/.download/* $FINISHED_DIR
#    else
#        echo "[$(date '+%H:%M:%S')] Nothing to download"
#    fi
    # Repeat process after one minute
    echo "[$(date '+%H:%M:%S')] Sleeping for 1 minute"
    sleep 1m
done