#!/bin/sh

# Display variables for troubleshooting
echo -e "Variables set:\\n\
PUID=${PUID}\\n\
PGID=${PGID}\\n\
HOST=${HOST}\\n\
PORT=${PORT}\\n\
USERNAME=${USERNAME}\\n\
REMOTE_DIR=${REMOTE_DIR}\\n\
LFTP_PARTS=${LFTP_PARTS}\\n\
LFTP_FILES=${LFTP_FILES}\\n"

# create a /config downloads directory
mkdir -p /config/download

# create a /config directory for ssh and link ssh area
mkdir -p /config/ssh

while true
do
	# LFTP with settings to /tmp/download directory
	echo "beginning lftp synchronization from $REMOTE_DIR"
	
	lftp -u $USERNAME, sftp://$HOST -p $PORT <<-EOF
        set ssl:verify-certificate no
        set sftp:auto-confirm yes
        set sftp:connect-program "ssh -a -x -i /config/ssh/id_rsa"
	    mirror -c --no-empty-dirs --Remove-source-files --Remove-source-dirs --use-pget-n=$LFTP_PARTS -P$LFTP_FILES $REMOTE_DIR /config/download
	quit
	EOF

    if [ $(ls -A /config/download) ]
    then
        # Move finished downloads to destination directory
        echo "moving finished lftp files to mapped finished downloads path"
	chmod -R 777 /config/download/*
        mv -f /config/download/* /download
    else
        echo "No files downloaded"
    fi

    # Repeat process after one minute
    echo "Sleeping for 1 minute"
    sleep 1m
done
