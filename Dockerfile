FROM alpine:3.17.1

RUN apk -v --update add \
        python \
        py-pip \
        groff \
        less \
        mailcap \
        mysql-client \
        curl \
        && \
    pip install --upgrade awscli s3cmd python-magic && \
    apk -v --purge del py-pip && \
    rm /var/cache/apk/*

# Set Default Environment Variables
ENV TARGET_DATABASE_PORT=3306
ENV NOTIFY_ENABLED=false
ENV NOTIFY_USERNAME=kubernetes-s3-mysql-backup

# Copy Slack Alert script and make executable
COPY resources/notify.sh /
RUN chmod +x /notify.sh

# Copy backup script and execute
COPY resources/perform-backup.sh /
RUN chmod +x /perform-backup.sh
CMD ["sh", "/perform-backup.sh"]
