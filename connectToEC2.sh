#!/bin/bash

# Define variables
HOST="ec2-100-26-97-226.compute-1.amazonaws.com"
USER="ubuntu"
TARGET_DIR="aws-ec2-github-temp"
PEM_PATH="/mnt/c/Users/harry/.ssh/aws-ec2-01.pem"

# Construct the SSH command
SSH_COMMAND="ssh -i $PEM_PATH $USER@$HOST"
echo "Executing command: $SSH_COMMAND"

# Optionally, include a remote command to execute on the EC2 instance
REMOVE_TEMP_DIR="mkdir -p $TARGET_DIR"

# Execute the SSH command
$SSH_COMMAND

# Remove target directory
$REMOVE_TEMP_DIR
