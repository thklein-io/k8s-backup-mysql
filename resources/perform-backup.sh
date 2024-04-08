#!/bin/bash

# Set the has_failed variable to false. This will change if any of the subsequent database backups/uploads fail.
has_failed=false
backup_name=""

# Loop through all the defined databases, seperating by a ,
for CURRENT_DATABASE in ${TARGET_DATABASE_NAMES//,/ }
do
    # Define backup file name with date
    backup_name="${CURRENT_DATABASE}_$(date +'%Y-%m-%d_%H-%M-%S').sql"
    backup_tar_name="${CURRENT_DATABASE}_$(date +'%Y-%m-%d_%H-%M-%S').tar.gz"

    # Perform the database backup. If successful, compress and upload the backup to S3, if unsuccessful print an entry to the console and the log, and set has_failed to true.
    if sqloutput=$(mysqldump -u "$TARGET_DATABASE_USER" -h "$TARGET_DATABASE_HOST" -p"$TARGET_DATABASE_PASSWORD" -P "$TARGET_DATABASE_PORT" "$CURRENT_DATABASE" > /tmp/"$backup_name" 2>&1)
    then
        # Compress the SQL dump file
        tar -czf /tmp/"$backup_tar_name" -C /tmp "$backup_name"

        echo -e "Database backup and compression successfully completed for $CURRENT_DATABASE at $(date +'%d-%m-%Y %H:%M:%S')."

        # Perform the upload to S3. If successful, print an entry to the console and the log. If unsuccessful, set has_failed to true and print an entry to the console and the log.
        if awsoutput=$(aws s3 cp /tmp/"$backup_tar_name" "$AWS_BUCKET_URI""$AWS_BUCKET_BACKUP_PATH"/"$backup_tar_name" 2>&1)
        then
            echo -e "Database backup successfully uploaded for $CURRENT_DATABASE at $(date +'%d-%m-%Y %H:%M:%S')."
        else
            echo -e "Database backup failed to upload for $CURRENT_DATABASE at $(date +'%d-%m-%Y %H:%M:%S'). Error: $awsoutput" | tee -a /tmp/kubernetes-s3-mysql-backup.log
            has_failed=true
        fi

        # Cleanup: Remove the temporary files after uploading
        rm -f /tmp/"$backup_name" /tmp/"$backup_tar_name"
    else
        echo -e "Database backup FAILED for $CURRENT_DATABASE at $(date +'%d-%m-%Y %H:%M:%S'). Error: $sqloutput" | tee -a /tmp/kubernetes-s3-mysql-backup.log
        has_failed=true
    fi
done

# Check if any of the backups have failed. If so, exit with a status of 1. Otherwise exit cleanly with a status of 0.
if [ "$has_failed" = true ]
then
    # If Slack alerts are enabled, send a notification alongside a log of what failed
    if [ "$NOTIFY_ENABLED" = true ]
    then
        # Put the contents of the database backup logs into a variable
        logcontents=$(cat /tmp/kubernetes-s3-mysql-backup.log)

        # Send Slack alert
        /notify.sh "One or more backups on database host $TARGET_DATABASE_HOST failed. The error details are included below:" "$logcontents"
    fi

    echo -e "kubernetes-s3-mysql-backup encountered 1 or more errors. Exiting with status code 1."
    exit 1
else
    # If Slack alerts are enabled, send a notification that all database backups were successful
    if [ "$NOTIFY_ENABLED" = true ]
    then
        /notify.sh "Backup created: $backup_tar_name"
    fi

    exit 0
fi
