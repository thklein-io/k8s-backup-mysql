#!/bin/bash

if [ "$1" = "fail" ]; then
    curl -m 10 --retry 5 -X POST -d "message=Backup failed for $TARGET_DATABASE_HOST" "$HEALTHCHECK_URL/fail"
else
    curl -m 10 --retry 5 -X POST -d "message=Backup succeeded for $TARGET_DATABASE_HOST" "$HEALTHCHECK_URL"
fi
