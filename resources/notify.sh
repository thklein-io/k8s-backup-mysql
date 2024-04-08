#!/bin/bash

curl -X POST -d "message=$1" "$NOTIFICATION_WEBHOOK_URL"
