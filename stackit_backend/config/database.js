const { Pool } = require('pg');
require('dotenv').config();
const logger = require('../utils/logger');

// Create a connection pool with optimized settings
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'stackit_db',
  user: process.env.DB_USER || 'stackit_user',
  password: process.env.DB_PASSWORD || 'password',
  max: parseInt(process.env.DB_POOL_MAX || '20'), // Maximum number of clients in the pool
  idleTimeoutMillis: parseInt(process.env.DB_IDLE_TIMEOUT || '30000'), // How long a client is allowed to remain idle before being closed
  connectionTimeoutMillis: parseInt(process.env.DB_CONNECT_TIMEOUT || '2000'), // How long to wait for a connection
  statement_timeout: parseInt(process.env.DB_STATEMENT_TIMEOUT || '30000'), // Cancel queries after 30s by default
  query_timeout: parseInt(process.env.DB_QUERY_TIMEOUT || '30000'), // Cancel queries after 30s by default
  application_name: 'stackit_api', // Helps identify connections in database logs
  keepAlive: true, // Keeps connections alive with periodic packets
  keepAliveInitialDelayMillis: 10000, // Delay before first keep-alive probe
});

// The pool will emit an error on behalf of any idle clients
pool.on('error', (err, client) => {
  logger.error('Unexpected error on idle client', { error: err.message, stack: err.stack });
  process.exit(-1);
});

// Performance monitoring
pool.on('connect', () => {
  logger.debug('New connection established with the database');
});

// Track connection count
let activeConnections = 0;
pool.on('acquire', () => {
  activeConnections++;
  logger.debug(`Connection acquired from pool. Active connections: ${activeConnections}`);
});

pool.on('remove', () => {
  activeConnections--;
  logger.debug(`Connection removed from pool. Active connections: ${activeConnections}`);
});

// Helper function to run SQL queries with improved logging and performance tracking
const query = async (text, params) => {
  const start = Date.now();
  
  try {
    const res = await pool.query(text, params);
    const duration = Date.now() - start;
    
    // Log queries that take longer than 1s to identify potential bottlenecks
    if (duration > 1000) {
      logger.warn('Long query execution', { 
        query: text,
        duration,
        rows: res.rowCount
      });
    } else {
      logger.debug('Query executed', { 
        query: text.substring(0, 80) + (text.length > 80 ? '...' : ''),
        duration, 
        rows: res.rowCount 
      });
    }
    
    return res;
  } catch (err) {
    logger.error('Database query error', {
      query: text,
      params,
      error: err.message,
      duration: Date.now() - start
    });
    throw err;
  }
};

// Helper function to get a client from the pool with optimized timeout handling
const getClient = async () => {
  const client = await pool.connect();
  const query = client.query;
  const release = client.release;
  
  // Set a timeout of 5 seconds, after which we will log this client's last query
  const timeout = setTimeout(() => {
    logger.error('A client has been checked out for too long!', {
      lastQuery: client.lastQuery ? JSON.stringify(client.lastQuery).substring(0, 100) : 'none'
    });
  }, 5000);
  
  // Monkey patch the query method to keep track of the last query executed
  client.query = (...args) => {
    client.lastQuery = args;
    return query.apply(client, args);
  };
  
  client.release = () => {
    // Clear the timeout
    clearTimeout(timeout);
    // Set the methods back to their old versions
    client.query = query;
    client.release = release;
    return release.apply(client);
  };
  
  return client;
};

// Transaction helper with automatic rollback on error
const transaction = async (callback) => {
  const client = await getClient();
  
  try {
    await client.query('BEGIN');
    const result = await callback(client);
    await client.query('COMMIT');
    return result;
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
};

// Batch query helper for better performance
const batch = async (queries) => {
  const results = [];
  await transaction(async (client) => {
    for (const { text, params } of queries) {
      const result = await client.query(text, params);
      results.push(result);
    }
  });
  return results;
};

// Check pool health
const checkPoolHealth = async () => {
  try {
    await query('SELECT 1');
    return {
      status: 'healthy',
      connections: {
        total: pool.totalCount,
        idle: pool.idleCount,
        active: activeConnections
      }
    };
  } catch (err) {
    return {
      status: 'unhealthy',
      error: err.message
    };
  }
};

module.exports = {
  pool,
  query,
  getClient,
  transaction,
  batch,
  checkPoolHealth
};
