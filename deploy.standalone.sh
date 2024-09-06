#!/bin/bash

# Variables
EC2_USER="ubuntu"
EC2_HOST="100.26.194.152"
PEM_PATH="/mnt/c/Users/harry/.ssh/ec2-react-starter_ed25519.pem"
LOCAL_PATH="/mnt/e/Projects/ec2-react-starter/"
TEMP_DIR="ec2-react-starter-temp"
REMOTE_TEMP_DIR="~/${TEMP_DIR}"
REMOTE_DEPLOY_DIR="/var/www/ec2-react-starter"
NGINX_HTML_DIR="/usr/share/nginx/html"
ECOSYSTEM_FILE="ecosystem.config.js"
PM2_APP_NAME="ec2-react-starter-production"


# Step 1: Rsync files to EC2 instance
rsync -avz --delete -e "ssh -i ${PEM_PATH} -o StrictHostKeyChecking=no" \
  --exclude 'node_modules' --exclude '.git' --exclude '.idea' --exclude '.env' \
 --exclude '.instructions' "${LOCAL_PATH}" "${EC2_USER}@${EC2_HOST}:${REMOTE_TEMP_DIR}/"

# Step 2: Prepare deployment directory on EC2
ssh -i ${PEM_PATH} -o StrictHostKeyChecking=no  ${EC2_USER}@${EC2_HOST} << EOF
  # Load nvm and the correct Node.js version
  export NVM_DIR="\$HOME/.nvm"
  [ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh" # Load nvm
  nvm use stable

  # Step 3: Verify that the correct Node.js version is being used
  echo "Node version: \$(node -v)"
  echo "NPM version: \$(npm -v)"
  echo "PM2 version: \$(pm2 -v)"

  # Step 4: Prepare the deployment directory
  sudo rm -rf ${REMOTE_DEPLOY_DIR}
  sudo mkdir -p ${REMOTE_DEPLOY_DIR}
  sudo chown -R ${EC2_USER}:${EC2_USER} ${REMOTE_DEPLOY_DIR}
  sudo mv ${REMOTE_TEMP_DIR}/* ${REMOTE_DEPLOY_DIR}/
  sudo rm -rf ${REMOTE_TEMP_DIR}

  # Step 5: Install dependencies and build the React app
  cd ${REMOTE_DEPLOY_DIR}
  npm install
  cd client
  npm ci
  npm run build

  # Step 7: Copy built React app to Nginx directory
  sudo cp -r ${REMOTE_DEPLOY_DIR}/client/build/* ${NGINX_HTML_DIR}/

  # Step 8: Set permissions for Nginx and ecosystem.config.js
  sudo usermod -aG www-data ${EC2_USER}
  sudo chown -R www-data:www-data ${NGINX_HTML_DIR}
  sudo chmod 640 ${REMOTE_DEPLOY_DIR}/${ECOSYSTEM_FILE}
  sudo chown www-data:www-data ${REMOTE_DEPLOY_DIR}/${ECOSYSTEM_FILE}
  sudo chmod 750 ${REMOTE_DEPLOY_DIR}/

  # Step 9: Start Nginx and deploy the Node.js app with PM2
  sudo systemctl start nginx
  pm2 stop ${PM2_APP_NAME} || true
  pm2 delete ${PM2_APP_NAME} || true
  pm2 cleardump
  pm2 start ${REMOTE_DEPLOY_DIR}/${ECOSYSTEM_FILE} --env production --only ${PM2_APP_NAME}
  pm2 save
EOF
