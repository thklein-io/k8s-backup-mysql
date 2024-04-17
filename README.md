# kubernetes-backup-mysql

## Overview

- **Backup**: Backup MySQL databases to S3
- **Notify**: Notify about the status of the backup, e.g. via Webhook (Slack, etc.) or Telegram
- **Healthcheck**: Ping about the status of the backup

## Object Storage IAM Policy

Here's an example IAM policy that would work for the backup job.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::<BUCKET_NAME>"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::<BUCKET_NAME>/*"
        }
    ]
}
```
