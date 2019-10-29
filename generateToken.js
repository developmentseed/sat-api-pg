const jsonwebtoken = require('jsonwebtoken');
const dotenv = require('dotenv');
dotenv.config();
const jwt = jsonwebtoken.sign({ role: 'application' }, process.env.JWT_SECRET);
console.log(jwt);
