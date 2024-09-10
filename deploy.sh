#!/bin/bash

# Define variables (these can be modified if running standalone for debugging)
APP_NAME="ec2-react-starter"
BASE_DIR="/var/www"
NGINX_HTML_DIR="/usr/share/nginx/html"
REMOTE_TEMP_DIR="$HOME/app"
ECOSYSTEM_FILE="ecosystem.config.js"
STAGE="production"
REMOTE_DEPLOY_DIR="${BASE_DIR}/${APP_NAME}"
PM2_APP_NAME="${APP_NAME}-${STAGE}"
EC2_USER="ubuntu" # Replace with the correct user if needed

# Make deploy.sh executable
chmod +x $HOME/app/deploy.sh
exit 1

# Source the nvm script to ensure pm2 is in PATH
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Prepare the deployment directory
sudo rm -rf "$REMOTE_DEPLOY_DIR"
sudo mkdir -p "$REMOTE_DEPLOY_DIR"
sudo chown -R "$EC2_USER:$EC2_USER" "$REMOTE_DEPLOY_DIR"
sudo mv "$REMOTE_TEMP_DIR"/* "$REMOTE_DEPLOY_DIR"/
sudo rm -rf "$REMOTE_TEMP_DIR"

# Copy built React app to Nginx directory
sudo cp -r "$REMOTE_DEPLOY_DIR/client/build/"* "$NGINX_HTML_DIR/"

# Set permissions for Nginx and ecosystem.config.js
sudo usermod -aG www-data "$EC2_USER"
sudo chown -R www-data:www-data "$NGINX_HTML_DIR"
sudo chmod 640 "$REMOTE_DEPLOY_DIR/$ECOSYSTEM_FILE"
sudo chown www-data:www-data "$REMOTE_DEPLOY_DIR/$ECOSYSTEM_FILE"
sudo chmod 750 "$REMOTE_DEPLOY_DIR"

# Start Nginx and deploy the Node.js app with PM2
pm2 stop "$PM2_APP_NAME" || true
pm2 delete "$PM2_APP_NAME" || true
pm2 cleardump
pm2 start "$REMOTE_DEPLOY_DIR/$ECOSYSTEM_FILE" --env production --only "$PM2_APP_NAME"
pm2 save

# Restart Nginx to serve the latest React build
sudo systemctl restart nginx

