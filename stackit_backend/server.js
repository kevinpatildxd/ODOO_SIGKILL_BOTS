const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const http = require('http');
const compression = require('compression');
require('dotenv').config();

// Import middlewares
const { globalLimiter } = require('./middleware/rateLimit');
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');
const { sanitizeRequestData, validateContentType } = require('./middleware/security');
const logger = require('./utils/logger');
const { checkPoolHealth } = require('./config/database');
const { stats: cacheStats } = require('./utils/caching');

// Initialize Express app
const app = express();
const server = http.createServer(app);

// Import socket.io initialization
const { initializeSocket } = require('./config/socket');
const io = initializeSocket(server);

// Enhanced Security Middleware
// Set strict security headers with helmet
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:"],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"]
    }
  },
  xssFilter: true,
  noSniff: true,
  referrerPolicy: { policy: 'same-origin' },
  hsts: {
    maxAge: 15552000, // 180 days in seconds
    includeSubDomains: true,
    preload: true
  }
}));

// CORS configuration with more options
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3001',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  exposedHeaders: ['X-Total-Count']
}));

// Enable gzip compression to improve performance
app.use(compression());

// Content type validation
app.use(validateContentType);

app.use(express.json({ limit: '1mb' })); // Parse JSON bodies with size limit
app.use(express.urlencoded({ extended: true, limit: '1mb' })); // Parse URL-encoded bodies with size limit

// Input sanitization middleware
app.use(sanitizeRequestData);

app.use(globalLimiter); // Apply rate limiting

// Basic route to test the server
app.get('/', (req, res) => {
  res.json({ 
    message: 'Welcome to StackIt API',
    status: 'Server is running'
  });
});

// Health check endpoint for monitoring
app.get('/health', async (req, res) => {
  try {
    const startTime = process.hrtime();
    
    // Check database health
    const dbHealth = await checkPoolHealth();
    
    // Basic system info
    const systemInfo = {
      uptime: Math.floor(process.uptime()),
      memory: process.memoryUsage(),
      node: process.version,
      platform: process.platform,
      env: process.env.NODE_ENV || 'development'
    };

    // Cache statistics
    const cacheInfo = cacheStats();

    // Calculate response time
    const hrTime = process.hrtime(startTime);
    const responseTimeMs = hrTime[0] * 1000 + hrTime[1] / 1000000;

    // Determine overall health status
    const isHealthy = dbHealth.status === 'healthy';

    res.status(isHealthy ? 200 : 503).json({
      status: isHealthy ? 'ok' : 'degraded',
      timestamp: new Date().toISOString(),
      responseTime: `${responseTimeMs.toFixed(2)}ms`,
      database: dbHealth,
      cache: cacheInfo,
      system: systemInfo
    });
  } catch (err) {
    logger.error('Health check error:', { error: err.message, stack: err.stack });
    res.status(503).json({
      status: 'error',
      message: 'Health check failed',
      error: process.env.NODE_ENV === 'production' ? 'Internal server error' : err.message
    });
  }
});

// Initialize routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/questions', require('./routes/questions'));
app.use('/api/answers', require('./routes/answers'));
app.use('/api/votes', require('./routes/votes'));
app.use('/api/tags', require('./routes/tags'));
app.use('/api/notifications', require('./routes/notifications'));

// 404 handler for undefined routes
app.use(notFoundHandler);

// Error handler middleware (must be last)
app.use(errorHandler);

// Start server
const PORT = process.env.PORT || 3000;
if (process.env.NODE_ENV !== 'test' || process.env.START_SERVER === 'true') {
  server.listen(PORT, () => {
    logger.info(`Server running on port ${PORT}`);
  });
}

// Handle graceful shutdown
const gracefulShutdown = (signal) => {
  logger.info(`${signal} received. Shutting down gracefully...`);
  server.close(() => {
    logger.info('HTTP server closed.');
    process.exit(0);
  });
  
  // Force shutdown after 10s if server hasn't closed
  setTimeout(() => {
    logger.error('Could not close connections in time, forcefully shutting down');
    process.exit(1);
  }, 10000);
};

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

// Handle termination signals
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

module.exports = app; // For testing purposes
