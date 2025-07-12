/**
 * Test PostgreSQL database connection
 */

const { pool } = require('../config/database');
const logger = require('../utils/logger');

async function testConnection() {
  logger.info('Testing database connection...');
  
  try {
    // Try to connect to the database
    const client = await pool.connect();
    logger.info('Database connection successful!');
    
    // Run a simple query
    const result = await client.query('SELECT NOW() as current_time');
    logger.info(`Current database time: ${result.rows[0].current_time}`);
    
    // Release the client back to the pool
    client.release();
    
    // Close the pool
    await pool.end();
    logger.info('Connection pool closed.');
    
    return true;
  } catch (error) {
    logger.error('Database connection failed:', { error: error.message, stack: error.stack });
    
    // Provide helpful troubleshooting info
    logger.error('Please check your database connection settings:');
    logger.error(`- Database Host: ${process.env.DB_HOST || 'localhost'}`);
    logger.error(`- Database Name: ${process.env.DB_NAME || 'stackit_db'}`);
    logger.error(`- Database User: ${process.env.DB_USER || 'stackit_user'}`);
    logger.error(`- Database Port: ${process.env.DB_PORT || '5432'}`);
    
    return false;
  }
}

// If this script is run directly
if (require.main === module) {
  testConnection()
    .then(success => {
      if (!success) {
        process.exit(1);
      }
    })
    .catch(err => {
      logger.error('Unexpected error during connection test:', { error: err.message });
      process.exit(1);
    });
}

module.exports = testConnection; 