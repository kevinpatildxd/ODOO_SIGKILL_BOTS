/**
 * Socket handlers for vote-related events
 * @module sockets/voteSocket
 */

const voteService = require('../services/voteService');
const questionService = require('../services/questionService');
const answerService = require('../services/answerService');
const notificationService = require('../services/notificationService');
const logger = require('../utils/logger');

/**
 * Attach vote-related socket event handlers to the Socket.io instance
 * @param {Object} io - Socket.io server instance
 */
function attachVoteHandlers(io) {
  io.on('connection', (socket) => {
    // Handle voting on a question
    socket.on('vote_question', async (data) => {
      try {
        // Validate required fields
        if (!data || !data.questionId || data.voteType === undefined) {
          return socket.emit('error', { message: 'Question ID and vote type are required' });
        }

        // Validate vote type (1 for upvote, -1 for downvote, 0 for removing vote)
        if (![1, -1, 0].includes(data.voteType)) {
          return socket.emit('error', { message: 'Vote type must be 1, -1, or 0' });
        }

        // Process the vote
        const result = await voteService.voteOnQuestion(
          socket.userId,
          data.questionId,
          data.voteType
        );

        // Get question info for notification
        const question = await questionService.getQuestionById(data.questionId);

        // Create notification for question author
        if (question.user_id !== socket.userId && data.voteType !== 0) {
          await notificationService.notifyVote({
            target_type: 'question',
            target_id: data.questionId,
            voter_id: socket.userId,
            vote_type: data.voteType
          });
        }

        // Broadcast to all users in the question room
        const roomName = `question_${data.questionId}`;
        io.to(roomName).emit('vote_updated', {
          targetType: 'question',
          targetId: data.questionId,
          voteCount: result.newVoteCount,
          userVote: data.voteType
        });
        
        logger.info(`Question ${data.questionId} voted by user ${socket.userId} with vote type ${data.voteType}`);
      } catch (error) {
        logger.error(`Error voting on question: ${error.message}`);
        socket.emit('error', { message: 'Failed to vote on question' });
      }
    });

    // Handle voting on an answer
    socket.on('vote_answer', async (data) => {
      try {
        // Validate required fields
        if (!data || !data.answerId || data.voteType === undefined || !data.questionId) {
          return socket.emit('error', { message: 'Answer ID, question ID, and vote type are required' });
        }

        // Validate vote type (1 for upvote, -1 for downvote, 0 for removing vote)
        if (![1, -1, 0].includes(data.voteType)) {
          return socket.emit('error', { message: 'Vote type must be 1, -1, or 0' });
        }

        // Process the vote
        const result = await voteService.voteOnAnswer(
          socket.userId,
          data.answerId,
          data.voteType
        );

        // Get answer author for notification
        const answer = await answerService.getAnswerById(data.answerId);

        // Create notification for answer author
        if (answer.user_id !== socket.userId && data.voteType !== 0) {
          await notificationService.notifyVote({
            target_type: 'answer',
            target_id: data.answerId,
            voter_id: socket.userId,
            vote_type: data.voteType
          });
        }

        // Broadcast to all users in the question room
        const roomName = `question_${data.questionId}`;
        io.to(roomName).emit('vote_updated', {
          targetType: 'answer',
          targetId: data.answerId,
          voteCount: result.newVoteCount,
          userVote: data.voteType
        });
        
        logger.info(`Answer ${data.answerId} voted by user ${socket.userId} with vote type ${data.voteType}`);
      } catch (error) {
        logger.error(`Error voting on answer: ${error.message}`);
        socket.emit('error', { message: 'Failed to vote on answer' });
      }
    });
  });
}

module.exports = attachVoteHandlers;
