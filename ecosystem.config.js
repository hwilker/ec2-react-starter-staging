module.exports = {
  apps: [
    {
      name: 'ec2-react-starter-production',
      script: '/var/www/ec2-react-starter/server/index.js',
      cwd: '/var/www/ec2-react-starter',
      watch: true,
      env: {
        PORT: 5100,
        NODE_ENV: 'production'
      }
    },
    {
      name: "ec2-react-started-staging",
      script: '/var/www/ec2-react-starter/server/index.js',
      cwd: '/var/www/ec2-react-starter',
      watch: true,
      env: {
        PORT: 5100,
        NODE_ENV: 'staging'
      }
    }
  ]
};
