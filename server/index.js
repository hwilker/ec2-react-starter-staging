const express = require('express')
const cors = require('cors');
const app = express()
var path = require('path');
const dotenv = require('dotenv');

// Determine which environment-specific .env file to load for local development
const env = (process.env.NODE_ENV || '').trim(); //start script is appending a trailing blank

if (env === 'local') {
  const envPath = path.resolve(__dirname, '.env.local');
  dotenv.config({path: envPath});
  console.log(`Loaded environment variables from ${envPath}`);
} else {
  console.log('Running in production/staging mode. Environment variables loaded from ecosystem.config.js');
}

const port = process.env.PORT || 5100;

/*
 CORS Support
 from https://dzone.com/articles/cors-in-node
 */
app.use(function (req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept");
  next();
})


// // Serve static files from the React app
// app.use(express.static(path.join(__dirname, '../client/build')));
//

app.use(express.json());


app.use(cors());

app.get('/api/hello', (req, res) => {
  res.json({msg: 'Hello stage World!!'})
})

app.get('/api/goodbye', (req, res) => {
  res.json({msg: 'Goodbye!'})
})

// Catch-all handler for any requests that don't match an API route
// app.get('*', (req, res) => {
//   res.sendFile(path.join(__dirname, '../client/build', 'index.html'));
// });

// Use 'localhost' for development and '0.0.0.0' for production
// const environment = process.env.NODE_ENV || 'local';
// const host = environment === 'production' ? '0.0.0.0' : 'localhost';
const host = env === 'local' ? 'localhost' : '0.0.0.0'

app.listen(parseInt(port), host, () => {
  console.log(`Example app listening on port ${port} at ${host}`);
});

