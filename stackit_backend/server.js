const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const http = require('http');
require('dotenv').config();

// Import middlewares
const { globalLimiter } = require('./middleware/rateLimit');
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');
const logger = require('./utils/logger');

// Initialize Express app
const app = express();
const server = http.createServer(app);

// Import socket.io initialization
const { initializeSocket } = require('./config/socket');
const io = initializeSocket(server);

// Middleware
app.use(helmet()); // Security headers
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3001',
  credentials: true
}));
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies
app.use(globalLimiter); // Apply rate limiting

// Basic route to test the server
app.get('/', (req, res) => {
  res.json({ 
    message: 'Welcome to StackIt API',
    status: 'Server is running'
  });
});

// Initialize routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/questions', require('./routes/questions'));
// app.use('/api/answers', require('./routes/answers'));
// app.use('/api/votes', require('./routes/votes'));
app.use('/api/tags', require('./routes/tags'));
// app.use('/api/notifications', require('./routes/notifications'));

// 404 handler for undefined routes
app.use(notFoundHandler);

// Error handler middleware (must be last)
app.use(errorHandler);

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  logger.info(`Server running on port ${PORT}`);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  logger.error('Unhandled Rejection:', { error: err.message, stack: err.stack });
  // Close server & exit process
  server.close(() => process.exit(1));
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  logger.error('Uncaught Exception:', { error: err.message, stack: err.stack });
  // Close server & exit process
  server.close(() => process.exit(1));
});

module.exports = app; // For testing purposes
