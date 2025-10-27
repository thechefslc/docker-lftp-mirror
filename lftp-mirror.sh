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
DOWNLOAD_TMP=${DOWNLOAD_TMP}\\n\
LFTP_PARTS=${LFTP_PARTS}\\n\
LFTP_FILES=${LFTP_FILES}\\n\
LFTP_OPTS=${LFTP_OPTS}\\n"


# if no finished files directory specified, default to /config/download
[ -z "$FINISHED_DIR" ] && FINISHED_DIR="/config/download"
[ -z "$DOWNLOAD_TMP" ] && DOWNLOAD_TMP="/config/.download"



# create a directory for placing private key for lftp to use
mkdir -p /config/ssh

# create download temp directory
mkdir -p /config/.download

# create finished downloads directory
mkdir -p /config/download

while true
do
    # LFTP with specified segment & parallel
    echo "[$(date '+%H:%M:%S')] Checking ${REMOTE_DIR} for files....."

# FIX 2: Removed all leading spaces from this block
lftp -u $USERNAME, sftp://$HOST -p $PORT <<-EOF
set ssl:verify-certificate no
set sftp:auto-confirm yes
set sftp:connect-program "ssh -i /config/ssh/id_rsa"

# --- ADD THIS LINE ---
# This logs all file transfers to stderr (which goes to the console)
set xfer:log true

# --- ADD --verbose TO YOUR MIRROR COMMAND ---
mirror -c --verbose $LFTP_OPTS --use-pget-n=$LFTP_PARTS -P$LFTP_FILES $REMOTE_DIR $DOWNLOAD_TMP
quit
EOF
    
    # check if files are in download dir and move to correct location.
    if [ "$(ls -A $DOWNLOAD_TMP)" ]
    then
        echo "[$(date '+%H:%M:%S')] Moving files....."

        # --- START OF FIX ---
        
        # nullglob: glob expands to nothing if no match
        # dotglob: glob matches hidden files (e.g., .config)
        #shopt -s nullglob dotglob

        # 1. Process all SUB-DIRECTORIES first
        for type_dir in "$DOWNLOAD_TMP"/*/
        do
            if [ -d "$type_dir" ]; then
                type_name=$(basename "$type_dir")
                final_dest_dir="$FINISHED_DIR/$type_name"
                
                echo "[$(date '+%H:%M:%S')] Merging contents of $type_name into $final_dest_dir"

                # -p ensures it doesn't fail if the directory already exists
                mkdir -p "$final_dest_dir"
                
                # Move the *contents* of the source dir to the destination
                mv -fv "$type_dir"/* "$final_dest_dir/"
                
                # Clean up the now-empty source "type" directory
                rmdir "$type_dir"
            fi
        done

        # 2. Move any remaining LOOSE FILES
        echo "[$(date '+%H:%M:%S')] Moving loose files..."
        mv -fv "$DOWNLOAD_TMP"/* "$FINISHED_DIR/"

        # Unset shell options
        #shopt -u nullglob dotglob

        # --- END OF FIX ---

    else
        echo "[$(date '+%H:%M:%S')] Nothing to download"
    fi    


    # Repeat process after one minute
    echo "[$(date '+%H:%M:%S')] Sleeping for 1 minute"
    sleep 1m
done