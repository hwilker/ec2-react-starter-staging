module.exports = {
  apps: [
    {
      name: 'aws-ec2-github-production',
      script: '/var/www/aws-ec2-github/server/index.js',
      cwd: '/var/www/aws-ec2-github',
      watch: true,
      env: {
        PORT: 5100,
        NODE_ENV: 'production'
      }
    },
    {
      name: "aws-ec2-github-staging",
      script: '/var/www/aws-ec2-github/server/index.js',
      cwd: '/var/www/aws-ec2-github',
      watch: true,
      env: {
        PORT: 5100,
        NODE_ENV: 'staging'
      }
    }
  ]
};
