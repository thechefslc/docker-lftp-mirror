#!/bin/bash
# simple entrypoint script that will run a customized entrypoint
# script it it exists in the /config/entrypoint/ location

if [ -f /config/entrypoint/lftp-mirror.sh ]; then
    echo "Using CUSTOM script"
    /config/entrypoint/lftp-mirror.sh
    
else
    echo "Using DEFAULT script"
    /usr/local/bin/lftp-mirror.sh
fi