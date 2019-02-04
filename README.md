# docker-lftp-mirror
- Description:
  - Quick &amp; dirty SFTP mirror via LFTP
  
- Instructions:
  - Set required environmental variables
  - Place id_rsa file in /config/ssh (/host/volume/dir/ssh)

- Variables:
  - Required
    - PUID: UserId used to run process / file ownership
    - PGID: GroupId used to run process / file ownership
    - HOST: IP/host/url of host
    - PORT: Port of host
    - USERNAME: SSH user on host
    - REMOTE_DIR: Directory on host to mirror locally
    - LFTP_PARTS: Number of parts in which to split files (-use-pget[-n=N])
    - LFTP_FILES: Number of files to download in parallel (--parallel[=N])
  - Optional
    - FINISHED_DIR: Optional finished directory to place finished transfer (by default, downloads end up in /config/download)
