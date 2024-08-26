#!/bin/bash

# Variables
EC2_USER="ubuntu"
EC2_HOST="100.26.97.226"
PEM_PATH="/mnt/c/Users/harry/.ssh/aws-ec2-01.pem"
REMOTE_DEPLOY_DIR="/var/www/aws-ec2-github"
ECOSYSTEM_FILE="ecosystem.config.js"

# SSH into the EC2 instance and run a few basic checks
ssh -i ${PEM_PATH} ${EC2_USER}@${EC2_HOST} << EOF
  echo "Initial directory: \$(pwd)"

  # Change to the deployment directory
  cd ${REMOTE_DEPLOY_DIR}
  echo "After cd, current directory: \$(pwd)"

  # List contents of the current directory
  ls -al

  # Verify if the ecosystem.config.js file is present
  if [ -f "${REMOTE_DEPLOY_DIR}/${ECOSYSTEM_FILE}" ]; then
    echo "${ECOSYSTEM_FILE} found."
  else
    echo "${ECOSYSTEM_FILE} not found!"
  fi

  # Print the full path to the Node.js and PM2 binaries
  which node
  which pm2

  # Verify if the server/index.js file is accessible
  if [ -f "${REMOTE_DEPLOY_DIR}/server/index.js" ]; then
    echo "server/index.js found."
  else
    echo "server/index.js not found!"
  fi
EOF
