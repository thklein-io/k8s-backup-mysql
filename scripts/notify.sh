#!/bin/bash

provider="$NOTIFICATION_PROVIDER"

# Send notification to webhook
if [ "$provider" == "webhook" ]; then
    curl -X POST -d "message=$1" "$NOTIFICATION_WEBHOOK_URL"
# Send notification via Telegram
elif [ "$provider" == "telegram" ]; then
    curl -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" -d chat_id="$TELEGRAM_CHAT_ID" -d text="$1"
fi
