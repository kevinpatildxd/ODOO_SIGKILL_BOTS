/**
 * Socket handlers for question-related events
 * @module sockets/questionSocket
 */

const questionService = require('../services/questionService');
const answerService = require('../services/answerService');
const notificationService = require('../services/notificationService');
const logger = require('../utils/logger');

/**
 * Attach question-related socket event handlers to the Socket.io instance
 * @param {Object} io - Socket.io server instance
 */
function attachQuestionHandlers(io) {
  io.on('connection', (socket) => {
    // Handle joining a question room
    socket.on('join_question', (questionId) => {
      try {
        if (!questionId) {
          return socket.emit('error', { message: 'Question ID is required' });
        }
        
        const roomName = `question_${questionId}`;
        socket.join(roomName);
        logger.info(`User ${socket.userId} joined ${roomName}`);
      } catch (error) {
        logger.error(`Error joining question room: ${error.message}`);
        socket.emit('error', { message: 'Failed to join question room' });
      }
    });

    // Handle leaving a question room
    socket.on('leave_question', (questionId) => {
      try {
        if (!questionId) {
          return socket.emit('error', { message: 'Question ID is required' });
        }
        
        const roomName = `question_${questionId}`;
        socket.leave(roomName);
        logger.info(`User ${socket.userId} left ${roomName}`);
      } catch (error) {
        logger.error(`Error leaving question room: ${error.message}`);
        socket.emit('error', { message: 'Failed to leave question room' });
      }
    });

    // Handle real-time answer creation
    socket.on('new_answer', async (data) => {
      try {
        // Validate required fields
        if (!data || !data.questionId || !data.content) {
          return socket.emit('error', { message: 'Question ID and content are required' });
        }

        // Create the answer in the database
        const answer = await answerService.createAnswer({
          question_id: data.questionId,
          user_id: socket.userId,
          content: data.content
        });

        // Get question info for notification
        const question = await questionService.getQuestionById(data.questionId);
        
        // Create notification for question author
        if (question.user_id !== socket.userId) {
          await notificationService.notifyNewAnswer({
            answer_id: answer.id,
            question_id: data.questionId,
            answer_user_id: socket.userId,
            question_title: question.title
          });
        }

        // Broadcast to all users in the question room
        const roomName = `question_${data.questionId}`;
        io.to(roomName).emit('answer_added', {
          ...answer,
          username: socket.username
        });
        
        logger.info(`New answer added to question ${data.questionId} by user ${socket.userId}`);
      } catch (error) {
        logger.error(`Error adding new answer: ${error.message}`);
        socket.emit('error', { message: 'Failed to add answer' });
      }
    });

    // Handle real-time question updates
    socket.on('question_updated', async (data) => {
      try {
        if (!data || !data.questionId) {
          return socket.emit('error', { message: 'Question ID is required' });
        }

        // Verify the user is the question owner (handled by service)
        const updatedQuestion = await questionService.getQuestionById(data.questionId);
        
        // Broadcast to all users in the question room
        const roomName = `question_${data.questionId}`;
        io.to(roomName).emit('question_updated', updatedQuestion);
        
        logger.info(`Question ${data.questionId} updated by user ${socket.userId}`);
      } catch (error) {
        logger.error(`Error updating question: ${error.message}`);
        socket.emit('error', { message: 'Failed to update question' });
      }
    });
    
    // Handle viewing a question - track view count
    socket.on('view_question', async (questionId) => {
      try {
        if (!questionId) {
          return socket.emit('error', { message: 'Question ID is required' });
        }

        // Increment view count
        await questionService.incrementViewCount(questionId);
        
        logger.debug(`Question ${questionId} viewed by user ${socket.userId}`);
      } catch (error) {
        logger.error(`Error tracking question view: ${error.message}`);
        // We don't emit errors for view tracking to avoid disrupting the user experience
      }
    });
  });
}

module.exports = attachQuestionHandlers;
