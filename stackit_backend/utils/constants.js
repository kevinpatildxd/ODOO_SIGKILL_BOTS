/**
 * Application-wide constants
 */

// HTTP Status Codes
const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  UNPROCESSABLE_ENTITY: 422,
  INTERNAL_SERVER_ERROR: 500
};

// User roles
const USER_ROLES = {
  USER: 'user',
  MODERATOR: 'moderator',
  ADMIN: 'admin'
};

// Question status types
const QUESTION_STATUS = {
  ACTIVE: 'active',
  CLOSED: 'closed',
  DELETED: 'deleted'
};

// Vote types
const VOTE_TYPES = {
  UPVOTE: 1,
  DOWNVOTE: -1
};

// Vote target types
const VOTE_TARGETS = {
  QUESTION: 'question',
  ANSWER: 'answer'
};

// Notification types
const NOTIFICATION_TYPES = {
  ANSWER: 'answer',
  VOTE: 'vote',
  COMMENT: 'comment',
  ACCEPT: 'accept',
  MENTION: 'mention'
};

// Pagination defaults
const PAGINATION = {
  DEFAULT_PAGE: 1,
  DEFAULT_LIMIT: 10,
  MAX_LIMIT: 50
};

// Rate limiting
const RATE_LIMIT = {
  WINDOW_MS: process.env.RATE_LIMIT_WINDOW_MS || 900000, // 15 minutes in milliseconds
  MAX_REQUESTS: process.env.RATE_LIMIT_MAX_REQUESTS || 100 // Max requests per windowMs
};

module.exports = {
  HTTP_STATUS,
  USER_ROLES,
  QUESTION_STATUS,
  VOTE_TYPES,
  VOTE_TARGETS,
  NOTIFICATION_TYPES,
  PAGINATION,
  RATE_LIMIT
};
