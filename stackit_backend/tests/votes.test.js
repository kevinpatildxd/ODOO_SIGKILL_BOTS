/**
 * Vote API Tests
 */
const request = require('supertest');
const app = require('../server');
const db = require('../config/database');
const { generateToken } = require('../utils/helpers');

let userToken;
let secondUserToken;
let testQuestionId;
let testAnswerId;
let voteId;

/**
 * Before running tests, set up test data
 */
beforeAll(async () => {
  // Create test users
  const userResult = await db.query(
    `INSERT INTO users (username, email, password_hash, role)
     VALUES ($1, $2, $3, $4)
     RETURNING id`,
    ['votetestuser', 'votetest@example.com', '$2a$12$test_hash_for_testing', 'user']
  );
  
  const userId = userResult.rows[0].id;
  
  const secondUserResult = await db.query(
    `INSERT INTO users (username, email, password_hash, role)
     VALUES ($1, $2, $3, $4)
     RETURNING id`,
    ['votetestseconduser', 'votetestsecond@example.com', '$2a$12$test_hash_for_testing', 'user']
  );
  
  const secondUserId = secondUserResult.rows[0].id;
  
  // Generate JWT tokens for test users
  userToken = generateToken({ userId: userId, role: 'user' });
  secondUserToken = generateToken({ userId: secondUserId, role: 'user' });
  
  // Create a test question
  const questionResult = await db.query(
    `INSERT INTO questions (title, description, slug, user_id)
     VALUES ($1, $2, $3, $4)
     RETURNING id`,
    [
      'Test Question for Voting',
      'This is a test question description for testing vote functionality',
      'test-question-for-voting',
      userId
    ]
  );
  
  testQuestionId = questionResult.rows[0].id;
  
  // Create a test answer
  const answerResult = await db.query(
    `INSERT INTO answers (content, question_id, user_id)
     VALUES ($1, $2, $3)
     RETURNING id`,
    [
      'This is a test answer for testing vote functionality',
      testQuestionId,
      userId
    ]
  );
  
  testAnswerId = answerResult.rows[0].id;
});

/**
 * Clean up test data after all tests
 */
afterAll(async () => {
  // Clean up test data
  await db.query('DELETE FROM votes WHERE target_type IN ($1, $2) AND target_id IN ($3, $4)', 
    ['question', 'answer', testQuestionId, testAnswerId]);
  await db.query('DELETE FROM answers WHERE id = $1', [testAnswerId]);
  await db.query('DELETE FROM questions WHERE id = $1', [testQuestionId]);
  await db.query('DELETE FROM users WHERE username IN ($1, $2)', ['votetestuser', 'votetestseconduser']);
});

/**
 * Test voting on a question
 */
describe('POST /api/votes', () => {
  it('should create an upvote on a question', async () => {
    const res = await request(app)
      .post('/api/votes')
      .set('Authorization', `Bearer ${userToken}`)
      .send({
        target_type: 'question',
        target_id: testQuestionId,
        vote_type: 1 // Upvote
      });
    
    expect(res.statusCode).toEqual(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.target_type).toEqual('question');
    expect(res.body.data.target_id).toEqual(testQuestionId);
    expect(res.body.data.vote_type).toEqual(1);
    
    // Save vote ID for later tests
    voteId = res.body.data.id;
  });
  
  it('should prevent duplicate votes from same user on same target', async () => {
    const res = await request(app)
      .post('/api/votes')
      .set('Authorization', `Bearer ${userToken}`)
      .send({
        target_type: 'question',
        target_id: testQuestionId,
        vote_type: 1
      });
    
    expect(res.statusCode).toEqual(400);
    expect(res.body.success).toBe(false);
  });
  
  it('should allow different users to vote on same target', async () => {
    const res = await request(app)
      .post('/api/votes')
      .set('Authorization', `Bearer ${secondUserToken}`)
      .send({
        target_type: 'question',
        target_id: testQuestionId,
        vote_type: 1
      });
    
    expect(res.statusCode).toEqual(201);
    expect(res.body.success).toBe(true);
  });
  
  it('should create a downvote on an answer', async () => {
    const res = await request(app)
      .post('/api/votes')
      .set('Authorization', `Bearer ${secondUserToken}`)
      .send({
        target_type: 'answer',
        target_id: testAnswerId,
        vote_type: -1 // Downvote
      });
    
    expect(res.statusCode).toEqual(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.target_type).toEqual('answer');
    expect(res.body.data.target_id).toEqual(testAnswerId);
    expect(res.body.data.vote_type).toEqual(-1);
  });
  
  it('should require valid target_type', async () => {
    const res = await request(app)
      .post('/api/votes')
      .set('Authorization', `Bearer ${userToken}`)
      .send({
        target_type: 'invalid',
        target_id: testQuestionId,
        vote_type: 1
      });
    
    expect(res.statusCode).toEqual(400);
    expect(res.body.success).toBe(false);
  });
  
  it('should require valid vote_type', async () => {
    const res = await request(app)
      .post('/api/votes')
      .set('Authorization', `Bearer ${userToken}`)
      .send({
        target_type: 'question',
        target_id: testQuestionId,
        vote_type: 2 // Invalid vote type
      });
    
    expect(res.statusCode).toEqual(400);
    expect(res.body.success).toBe(false);
  });
  
  it('should require authentication', async () => {
    const res = await request(app)
      .post('/api/votes')
      .send({
        target_type: 'question',
        target_id: testQuestionId,
        vote_type: 1
      });
    
    expect(res.statusCode).toEqual(401);
    expect(res.body.success).toBe(false);
  });
});

/**
 * Test getting votes for a target
 */
describe('GET /api/votes', () => {
  it('should get votes for a question', async () => {
    const res = await request(app)
      .get('/api/votes')
      .query({
        target_type: 'question',
        target_id: testQuestionId
      });
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.data.length).toEqual(2); // We created 2 votes on the question
  });
  
  it('should get votes for an answer', async () => {
    const res = await request(app)
      .get('/api/votes')
      .query({
        target_type: 'answer',
        target_id: testAnswerId
      });
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.data.length).toEqual(1); // We created 1 vote on the answer
  });
  
  it('should return empty array for target with no votes', async () => {
    // Create a new answer without votes
    const answerResult = await db.query(
      `INSERT INTO answers (content, question_id, user_id)
       VALUES ($1, $2, $3)
       RETURNING id`,
      ['Another test answer without votes', testQuestionId, 1]
    );
    
    const emptyAnswerId = answerResult.rows[0].id;
    
    const res = await request(app)
      .get('/api/votes')
      .query({
        target_type: 'answer',
        target_id: emptyAnswerId
      });
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.data.length).toEqual(0);
    
    // Clean up the test answer
    await db.query('DELETE FROM answers WHERE id = $1', [emptyAnswerId]);
  });
});

/**
 * Test getting user's vote on a target
 */
describe('GET /api/votes/user', () => {
  it('should get a user\'s vote on a question', async () => {
    const res = await request(app)
      .get('/api/votes/user')
      .set('Authorization', `Bearer ${userToken}`)
      .query({
        target_type: 'question',
        target_id: testQuestionId
      });
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.vote_type).toEqual(1); // User upvoted
  });
  
  it('should return null for no vote', async () => {
    // Create a new answer
    const answerResult = await db.query(
      `INSERT INTO answers (content, question_id, user_id)
       VALUES ($1, $2, $3)
       RETURNING id`,
      ['A test answer the user has not voted on', testQuestionId, 1]
    );
    
    const noVoteAnswerId = answerResult.rows[0].id;
    
    const res = await request(app)
      .get('/api/votes/user')
      .set('Authorization', `Bearer ${userToken}`)
      .query({
        target_type: 'answer',
        target_id: noVoteAnswerId
      });
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toBeNull();
    
    // Clean up the test answer
    await db.query('DELETE FROM answers WHERE id = $1', [noVoteAnswerId]);
  });
  
  it('should require authentication', async () => {
    const res = await request(app)
      .get('/api/votes/user')
      .query({
        target_type: 'question',
        target_id: testQuestionId
      });
    
    expect(res.statusCode).toEqual(401);
    expect(res.body.success).toBe(false);
  });
});

/**
 * Test changing a vote
 */
describe('PUT /api/votes/:id', () => {
  it('should change vote from upvote to downvote', async () => {
    const res = await request(app)
      .put(`/api/votes/${voteId}`)
      .set('Authorization', `Bearer ${userToken}`)
      .send({
        vote_type: -1
      });
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.vote_type).toEqual(-1);
  });
  
  it('should prevent updating by non-owner', async () => {
    const res = await request(app)
      .put(`/api/votes/${voteId}`)
      .set('Authorization', `Bearer ${secondUserToken}`)
      .send({
        vote_type: 1
      });
    
    expect(res.statusCode).toEqual(403);
    expect(res.body.success).toBe(false);
  });
  
  it('should require authentication', async () => {
    const res = await request(app)
      .put(`/api/votes/${voteId}`)
      .send({
        vote_type: 1
      });
    
    expect(res.statusCode).toEqual(401);
    expect(res.body.success).toBe(false);
  });
});

/**
 * Test deleting a vote
 */
describe('DELETE /api/votes/:id', () => {
  it('should prevent deletion by non-owner', async () => {
    const res = await request(app)
      .delete(`/api/votes/${voteId}`)
      .set('Authorization', `Bearer ${secondUserToken}`);
    
    expect(res.statusCode).toEqual(403);
    expect(res.body.success).toBe(false);
  });
  
  it('should delete a vote', async () => {
    const res = await request(app)
      .delete(`/api/votes/${voteId}`)
      .set('Authorization', `Bearer ${userToken}`);
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
  });
  
  it('should verify vote is deleted', async () => {
    const res = await request(app)
      .get('/api/votes/user')
      .set('Authorization', `Bearer ${userToken}`)
      .query({
        target_type: 'question',
        target_id: testQuestionId
      });
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toBeNull();
  });
});
