/**
 * Validation middleware using Joi
 */
const Joi = require('joi');
const { HTTP_STATUS } = require('../utils/constants');

/**
 * Create a validation middleware using a Joi schema
 * @param {Joi.Schema} schema - Joi schema to validate against
 * @param {String} property - Request property to validate (body, query, params)
 * @returns {Function} Middleware function
 */
const validateSchema = (schema, property = 'body') => {
  return (req, res, next) => {
    const { error } = schema.validate(req[property], {
      abortEarly: false,
      stripUnknown: true
    });
    
    if (!error) {
      return next();
    }

    const validationErrors = error.details.map(detail => ({
      field: detail.context.key,
      message: detail.message.replace(/['"]/g, '')
    }));

    return res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'Validation error',
      errors: validationErrors
    });
  };
};

// User schemas
const userSchemas = {
  // Registration schema
  register: Joi.object({
    username: Joi.string().min(3).max(50).required()
      .messages({
        'string.min': 'Username must be at least 3 characters long',
        'string.max': 'Username cannot exceed 50 characters',
        'any.required': 'Username is required'
      }),
    email: Joi.string().email().required()
      .messages({
        'string.email': 'Please enter a valid email address',
        'any.required': 'Email is required'
      }),
    password: Joi.string().min(8).max(100).required()
      .pattern(new RegExp('^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])'))
      .messages({
        'string.min': 'Password must be at least 8 characters long',
        'string.max': 'Password cannot exceed 100 characters',
        'string.pattern.base': 'Password must contain at least one uppercase letter, one lowercase letter, and one number',
        'any.required': 'Password is required'
      }),
    confirmPassword: Joi.string().valid(Joi.ref('password')).required()
      .messages({
        'any.only': 'Passwords do not match',
        'any.required': 'Password confirmation is required'
      })
  }),

  // Login schema
  login: Joi.object({
    email: Joi.string().email().required()
      .messages({
        'string.email': 'Please enter a valid email address',
        'any.required': 'Email is required'
      }),
    password: Joi.string().required()
      .messages({
        'any.required': 'Password is required'
      })
  }),

  // Update user profile schema
  updateProfile: Joi.object({
    username: Joi.string().min(3).max(50)
      .messages({
        'string.min': 'Username must be at least 3 characters long',
        'string.max': 'Username cannot exceed 50 characters'
      }),
    bio: Joi.string().max(500).allow('').optional()
      .messages({
        'string.max': 'Bio cannot exceed 500 characters'
      }),
    avatar_url: Joi.string().uri().allow('').optional()
      .messages({
        'string.uri': 'Avatar URL must be a valid URL'
      })
  })
};

// Question schemas
const questionSchemas = {
  // Create question schema
  create: Joi.object({
    title: Joi.string().min(10).max(255).required()
      .messages({
        'string.min': 'Title must be at least 10 characters long',
        'string.max': 'Title cannot exceed 255 characters',
        'any.required': 'Title is required'
      }),
    description: Joi.string().min(20).max(10000).required()
      .messages({
        'string.min': 'Description must be at least 20 characters long',
        'string.max': 'Description cannot exceed 10000 characters',
        'any.required': 'Description is required'
      }),
    tags: Joi.array().items(Joi.string().max(50)).min(1).max(5).required()
      .messages({
        'array.min': 'At least 1 tag is required',
        'array.max': 'Cannot have more than 5 tags',
        'string.max': 'Tag name cannot exceed 50 characters',
        'any.required': 'Tags are required'
      })
  }),

  // Update question schema
  update: Joi.object({
    title: Joi.string().min(10).max(255)
      .messages({
        'string.min': 'Title must be at least 10 characters long',
        'string.max': 'Title cannot exceed 255 characters'
      }),
    description: Joi.string().min(20).max(10000)
      .messages({
        'string.min': 'Description must be at least 20 characters long',
        'string.max': 'Description cannot exceed 10000 characters'
      }),
    tags: Joi.array().items(Joi.string().max(50)).min(1).max(5)
      .messages({
        'array.min': 'At least 1 tag is required',
        'array.max': 'Cannot have more than 5 tags',
        'string.max': 'Tag name cannot exceed 50 characters'
      })
  })
};

// Answer schemas
const answerSchemas = {
  // Create answer schema
  create: Joi.object({
    content: Joi.string().min(20).max(10000).required()
      .messages({
        'string.min': 'Answer must be at least 20 characters long',
        'string.max': 'Answer cannot exceed 10000 characters',
        'any.required': 'Answer content is required'
      })
  }),

  // Update answer schema
  update: Joi.object({
    content: Joi.string().min(20).max(10000).required()
      .messages({
        'string.min': 'Answer must be at least 20 characters long',
        'string.max': 'Answer cannot exceed 10000 characters',
        'any.required': 'Answer content is required'
      })
  })
};

// Vote schemas
const voteSchemas = {
  create: Joi.object({
    target_type: Joi.string().valid('question', 'answer').required()
      .messages({
        'any.only': 'Target type must be either "question" or "answer"',
        'any.required': 'Target type is required'
      }),
    target_id: Joi.number().integer().positive().required()
      .messages({
        'number.base': 'Target ID must be a number',
        'number.integer': 'Target ID must be an integer',
        'number.positive': 'Target ID must be positive',
        'any.required': 'Target ID is required'
      }),
    vote_type: Joi.number().valid(1, -1).required()
      .messages({
        'any.only': 'Vote type must be either 1 (upvote) or -1 (downvote)',
        'any.required': 'Vote type is required'
      })
  })
};

// Tag schemas
const tagSchemas = {
  create: Joi.object({
    name: Joi.string().min(2).max(50).required()
      .pattern(new RegExp('^[a-zA-Z0-9-_.]+$'))
      .messages({
        'string.min': 'Tag name must be at least 2 characters long',
        'string.max': 'Tag name cannot exceed 50 characters',
        'string.pattern.base': 'Tag name can only contain letters, numbers, hyphens, underscores, and dots',
        'any.required': 'Tag name is required'
      }),
    description: Joi.string().max(500).optional().allow('')
      .messages({
        'string.max': 'Description cannot exceed 500 characters'
      }),
    color: Joi.string().pattern(new RegExp('^#([A-Fa-f0-9]{6})$')).optional()
      .messages({
        'string.pattern.base': 'Color must be a valid hex color code (e.g., #FF5733)'
      })
  })
};

// Query parameter schemas
const queryParamSchemas = {
  pagination: Joi.object({
    page: Joi.number().integer().min(1).default(1)
      .messages({
        'number.base': 'Page must be a number',
        'number.integer': 'Page must be an integer',
        'number.min': 'Page must be at least 1'
      }),
    limit: Joi.number().integer().min(1).max(50).default(10)
      .messages({
        'number.base': 'Limit must be a number',
        'number.integer': 'Limit must be an integer',
        'number.min': 'Limit must be at least 1',
        'number.max': 'Limit cannot exceed 50'
      }),
    sort: Joi.string().valid('newest', 'oldest', 'votes', 'views').default('newest')
      .messages({
        'any.only': 'Sort must be one of: newest, oldest, votes, views'
      })
  })
};

// Password change schema
const passwordSchemas = {
  changePassword: Joi.object({
    oldPassword: Joi.string().required()
      .messages({
        'any.required': 'Current password is required'
      }),
    newPassword: Joi.string().min(8).max(100).required()
      .pattern(new RegExp('^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])'))
      .messages({
        'string.min': 'New password must be at least 8 characters long',
        'string.max': 'New password cannot exceed 100 characters',
        'string.pattern.base': 'New password must contain at least one uppercase letter, one lowercase letter, and one number',
        'any.required': 'New password is required'
      }),
    confirmPassword: Joi.string().valid(Joi.ref('newPassword')).required()
      .messages({
        'any.only': 'Password confirmation does not match new password',
        'any.required': 'Password confirmation is required'
      })
  }),
  
  // Password reset request schema
  resetRequest: Joi.object({
    email: Joi.string().email().required()
      .messages({
        'string.email': 'Please enter a valid email address',
        'any.required': 'Email is required'
      })
  }),
  
  // Password reset schema
  resetPassword: Joi.object({
    resetToken: Joi.string().required()
      .messages({
        'any.required': 'Reset token is required'
      }),
    newPassword: Joi.string().min(8).max(100).required()
      .pattern(new RegExp('^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])'))
      .messages({
        'string.min': 'New password must be at least 8 characters long',
        'string.max': 'New password cannot exceed 100 characters',
        'string.pattern.base': 'New password must contain at least one uppercase letter, one lowercase letter, and one number',
        'any.required': 'New password is required'
      }),
    confirmPassword: Joi.string().valid(Joi.ref('newPassword')).required()
      .messages({
        'any.only': 'Password confirmation does not match new password',
        'any.required': 'Password confirmation is required'
      })
  })
};

// Define the validation middlewares
const validateUser = {
  register: validateSchema(userSchemas.register),
  login: validateSchema(userSchemas.login),
  updateProfile: validateSchema(userSchemas.updateProfile)
};

const validateQuestion = validateSchema(questionSchemas.create);
const validateQuestionUpdate = validateSchema(questionSchemas.update);

// Export answer validation middleware
const validateAnswer = validateSchema(answerSchemas.create);
const validateAnswerUpdate = validateSchema(answerSchemas.update);

// Export vote validation middleware
const validateVote = validateSchema(voteSchemas.create);

const validateTag = validateSchema(tagSchemas.create);

const validatePagination = validateSchema(queryParamSchemas.pagination, 'query');

const validatePasswordChange = validateSchema(passwordSchemas.changePassword);

module.exports = {
  validateUser,
  validateQuestion,
  validateQuestionUpdate,
  validateAnswer,
  validateAnswerUpdate,
  validateVote,
  validateTag,
  validatePagination,
  validatePasswordChange
};
