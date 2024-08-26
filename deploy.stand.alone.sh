#!/bin/bash

# Variables
EC2_USER="ubuntu"
EC2_HOST="100.26.97.226"
PEM_PATH="/mnt/c/Users/harry/.ssh/aws-ec2-01.pem"
LOCAL_PATH="/mnt/e/Projects/aws-ec2-github/
TEMP_DIR="aws-ec2-github-temp"
REMOTE_TEMP_DIR="~/${TEMP_DIR}"
REMOTE_DEPLOY_DIR="/var/www/aws-ec2-github"
NGINX_HTML_DIR="/usr/share/nginx/html"
ECOSYSTEM_FILE="ecosystem.config.js"
PM2_APP_NAME="aws-ec2-github-production"

# Step 1: Rsync files to EC2 instance
rsync -avz --delete -e "ssh -i ${PEM_PATH}" \
  --exclude 'node_modules' --exclude '.git' --exclude '.idea' --exclude '.env' \
  "${LOCAL_PATH}" "${EC2_USER}@${EC2_HOST}:${REMOTE_TEMP_DIR}/"


# Step 2: Prepare deployment directory on EC2
ssh -i ${PEM_PATH} ${EC2_USER}@${EC2_HOST} << EOF
  export PATH=/home/ubuntu/.nvm/versions/node/v20.16.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

  # Prepare the deployment directory
  sudo rm -rf ${REMOTE_DEPLOY_DIR}
  sudo mkdir -p ${REMOTE_DEPLOY_DIR}
  sudo chown -R ${EC2_USER}:${EC2_USER} ${REMOTE_DEPLOY_DIR}
  sudo mv ${REMOTE_TEMP_DIR}/* ${REMOTE_DEPLOY_DIR}/
  sudo rm -rf ${REMOTE_TEMP_DIR}

  # Install dependencies and build the React app
  cd ${REMOTE_DEPLOY_DIR}
  npm install
  cd client
  npm install
  npm run build

  # Copy built React app to Nginx directory
  sudo cp -r ${REMOTE_DEPLOY_DIR}/client/build/* ${NGINX_HTML_DIR}/

  # Set permissions for Nginx and ecosystem.config.js
  sudo usermod -aG www-data ${EC2_USER}
  sudo chown -R www-data:www-data ${NGINX_HTML_DIR}
  sudo chmod 640 ${REMOTE_DEPLOY_DIR}/${ECOSYSTEM_FILE}
  sudo chown www-data:www-data ${REMOTE_DEPLOY_DIR}/${ECOSYSTEM_FILE}
  sudo chmod 750 ${REMOTE_DEPLOY_DIR}/

  # Start Nginx and deploy the Node.js app with PM2
  sudo systemctl start nginx
  pm2 stop ${PM2_APP_NAME} || true
  pm2 delete ${PM2_APP_NAME} || true
  pm2 cleardump
  pm2 start ${REMOTE_DEPLOY_DIR}/${ECOSYSTEM_FILE} --env production --only ${PM2_APP_NAME}
  pm2 save
EOF
