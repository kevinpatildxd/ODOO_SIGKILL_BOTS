/**
 * Main socket.io handler that integrates all socket modules
 * @module sockets/index
 */

const { initializeSocket } = require('../config/socket');
const attachQuestionHandlers = require('./questionSocket');
const attachVoteHandlers = require('./voteSocket');
const attachNotificationHandlers = require('./notificationSocket');

/**
 * Initialize and configure all socket handlers
 * @param {Object} server - HTTP server instance
 * @returns {Object} Configured Socket.io instance
 */
const setupSockets = (server) => {
  // Initialize the Socket.io instance with authentication middleware
  const io = initializeSocket(server);
  
  // Attach handlers for different features
  attachQuestionHandlers(io);
  attachVoteHandlers(io);
  attachNotificationHandlers(io);
  
  return io;
};

module.exports = setupSockets;
