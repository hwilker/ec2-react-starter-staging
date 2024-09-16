#!/bin/bash

# Define variables
# IP: 54.165.40.108
# ALT FORM IP: 54-165-40-108
HOST="ec2-54-165-40-108.compute-1.amazonaws.com"
USER="ubuntu"
PEM_PATH="/mnt/c/Users/harry/.ssh/ec2-react-starter_ed25519.pem"

# Construct the SSH command
SSH_COMMAND="ssh -i $PEM_PATH $USER@$HOST"
echo "Executing command: $SSH_COMMAND"

# Execute the SSH command
$SSH_COMMAND