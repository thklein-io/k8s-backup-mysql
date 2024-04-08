FROM alpine:3.12

RUN apk add --no-cache mysql-client aws-cli curl bash

# Set Default Environment Variables
ENV TARGET_DATABASE_PORT=3306
ENV NOTIFY_ENABLED=false

# Copy Slack Alert script and make executable
COPY resources/notify.sh /
RUN chmod +x /notify.sh

# Copy backup script and execute
COPY resources/perform-backup.sh /
RUN chmod +x /perform-backup.sh
CMD ["bash", "/perform-backup.sh"]
