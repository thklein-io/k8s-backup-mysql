FROM alpine:3.12

RUN apk add --no-cache mysql-client aws-cli curl bash

# Set Default Environment Variables
ENV TARGET_DATABASE_PORT=3306
ENV NOTIFY_ENABLED=false
ENV HEALTHCHECK_ENABLED=false

WORKDIR /scripts

# Copy scripts and make them executable
COPY scripts/ /scripts/
RUN chmod -R +x /scripts

CMD ["bash", "/scripts/backup.sh"]
