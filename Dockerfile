FROM thechefslc/alpine-base

RUN apk add --update --no-cache \
    lftp \
    ca-certificates \
    openssh-client

COPY start-lftp.sh /usr/local/bin/start-lftp.sh
COPY lftp-mirror.sh /usr/local/bin/lftp-mirror.sh

RUN chmod +x /usr/local/bin/start-lftp.sh
RUN chmod +x /usr/local/bin/lftp-mirror.sh

CMD [ "sh", "/usr/local/bin/start-lftp.sh" ]