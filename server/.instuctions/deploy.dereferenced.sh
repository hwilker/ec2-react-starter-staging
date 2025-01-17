#!/bin/bash

# Step 1: Rsync files to EC2 instance
rsync -avz --delete -e "ssh -i /mnt/c/Users/harry/.ssh/ec2-react-starter_ed25519.pem" \
  --exclude 'node_modules' --exclude '.git' --exclude '.idea' --exclude '.env' \
  --exclude '.instructions' "/mnt/e/Projects/ec2-react-starter/" "ubuntu@100.24.32.223:~/ec2-react-starter-temp/"

# Step 2: Prepare deployment directory on EC2
ssh -i /mnt/c/Users/harry/.ssh/ec2-react-starter_ed25519.pem ubuntu@100.24.32.223 << EOF
  # Load nvm and the correct Node.js version
  export NVM_DIR="\$HOME/.nvm"
  [ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh" # Load nvm
  nvm use default # Use the default Node.js version

  # Step 3: Verify that the correct Node.js version is being used
  echo "Node version: \$(node -v)"
  echo "NPM version: \$(npm -v)"
  echo "PM2 version: \$(pm2 -v)"

  # Step 4: Prepare the deployment directory
  sudo rm -rf /var/www/ec2-react-starter
  sudo mkdir -p /var/www/ec2-react-starter
  sudo chown -R ubuntu:ubuntu /var/www/ec2-react-starter
  sudo mv ~/ec2-react-starter-temp/* /var/www/ec2-react-starter/
  sudo rm -rf ~/ec2-react-starter-temp

  # Step 5: Install dependencies and build the React app
  cd /var/www/ec2-react-starter
  npm install
  cd client
  npm install
  npm run build

  # Step 7: Copy built React app to Nginx directory
  sudo cp -r /var/www/ec2-react-starter/client/build/* /usr/share/nginx/html/

  # Step 8: Set permissions for Nginx and ecosystem.config.js
  sudo usermod -aG www-data ubuntu
  sudo chown -R www-data:www-data /usr/share/nginx/html
  sudo chmod 640 /var/www/ec2-react-starter/ecosystem.config.js
  sudo chown www-data:www-data /var/www/ec2-react-starter/ecosystem.config.js
  sudo chmod 750 /var/www/ec2-react-starter/

  # Step 9: Start Nginx and deploy the Node.js app with PM2
  sudo systemctl start nginx
  pm2 stop ec2-react-starter-production || true
  pm2 delete ec2-react-starter-production || true
  pm2 cleardump
  pm2 start /var/www/ec2-react-starter/ecosystem.config.js --env production --only ec2-react-starter-production
  pm2 save
EOF
