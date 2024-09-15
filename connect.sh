#!/bin/bash

# Define variables
HOST="ec2-100-26-194-152.compute-1.amazonaws.com"
USER="ubuntu"
PEM_PATH="/mnt/c/Users/harry/.ssh/ec2-react-starter_ed25519.pem"

# Construct the SSH command
SSH_COMMAND="ssh -i $PEM_PATH $USER@$HOST"
echo "Executing command: $SSH_COMMAND"

# Execute the SSH command
$SSH_COMMAND

