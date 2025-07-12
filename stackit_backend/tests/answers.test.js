/**
 * Answer API Tests
 */
const request = require('supertest');
const app = require('../server');
const db = require('../config/database');
const { generateToken } = require('../utils/helpers');

let authToken;
let testQuestionId;
let testAnswerId;
let secondUserToken;

/**
 * Before running tests, set up test data
 */
beforeAll(async () => {
  // Create a test user
  const userResult = await db.query(
    `INSERT INTO users (username, email, password_hash, role)
     VALUES ($1, $2, $3, $4)
     RETURNING id`,
    ['answertestuser', 'answertest@example.com', '$2a$12$test_hash_for_testing', 'user']
  );
  
  const userId = userResult.rows[0].id;
  
  // Create a second test user for testing authorization
  const secondUserResult = await db.query(
    `INSERT INTO users (username, email, password_hash, role)
     VALUES ($1, $2, $3, $4)
     RETURNING id`,
    ['seconduser', 'second@example.com', '$2a$12$test_hash_for_testing', 'user']
  );
  
  const secondUserId = secondUserResult.rows[0].id;
  
  // Generate JWT tokens for test users
  authToken = generateToken({ userId: userId, role: 'user' });
  secondUserToken = generateToken({ userId: secondUserId, role: 'user' });
  
  // Create a test question
  const questionResult = await db.query(
    `INSERT INTO questions (title, description, slug, user_id)
     VALUES ($1, $2, $3, $4)
     RETURNING id`,
    [
      'Test Question for Answers',
      'This is a test question description for testing answer functionality',
      'test-question-for-answers',
      userId
    ]
  );
  
  testQuestionId = questionResult.rows[0].id;
});

/**
 * Clean up test data after all tests
 */
afterAll(async () => {
  // Clean up test data
  await db.query('DELETE FROM answers WHERE question_id = $1', [testQuestionId]);
  await db.query('DELETE FROM questions WHERE id = $1', [testQuestionId]);
  await db.query('DELETE FROM users WHERE username IN ($1, $2)', ['answertestuser', 'seconduser']);
});

/**
 * Test creating an answer
 */
describe('POST /api/answers', () => {
  it('should create a new answer', async () => {
    const res = await request(app)
      .post('/api/answers')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        content: 'This is a test answer with enough characters to pass validation.',
        question_id: testQuestionId
      });
    
    expect(res.statusCode).toEqual(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.content).toEqual('This is a test answer with enough characters to pass validation.');
    expect(res.body.data.question_id).toEqual(testQuestionId);
    
    // Save the answer ID for later tests
    testAnswerId = res.body.data.id;
  });
  
  it('should return error for invalid input', async () => {
    const res = await request(app)
      .post('/api/answers')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        content: 'Too short',
        question_id: testQuestionId
      });
    
    expect(res.statusCode).toEqual(400);
    expect(res.body.success).toBe(false);
  });
  
  it('should return error for non-existent question', async () => {
    const res = await request(app)
      .post('/api/answers')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        content: 'This is a test answer for a non-existent question.',
        question_id: 9999
      });
    
    expect(res.statusCode).toEqual(404);
    expect(res.body.success).toBe(false);
  });
  
  it('should require authentication', async () => {
    const res = await request(app)
      .post('/api/answers')
      .send({
        content: 'This answer should fail without authentication.',
        question_id: testQuestionId
      });
    
    expect(res.statusCode).toEqual(401);
    expect(res.body.success).toBe(false);
  });
});

/**
 * Test getting answers for a question
 */
describe('GET /api/answers/question/:questionId', () => {
  it('should get answers for a question', async () => {
    const res = await request(app).get(`/api/answers/question/${testQuestionId}`);
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.data.length).toBeGreaterThan(0);
    expect(res.body.data[0].content).toEqual('This is a test answer with enough characters to pass validation.');
  });
  
  it('should return empty array for question with no answers', async () => {
    // Create a new question without answers
    const questionResult = await db.query(
      `INSERT INTO questions (title, description, slug, user_id)
       VALUES ($1, $2, $3, $4)
       RETURNING id`,
      ['Another Test Question', 'This question has no answers', 'another-test-question', 1]
    );
    
    const emptyQuestionId = questionResult.rows[0].id;
    
    const res = await request(app).get(`/api/answers/question/${emptyQuestionId}`);
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.data.length).toEqual(0);
    
    // Clean up the test question
    await db.query('DELETE FROM questions WHERE id = $1', [emptyQuestionId]);
  });
});

/**
 * Test getting a specific answer
 */
describe('GET /api/answers/:id', () => {
  it('should get an answer by ID', async () => {
    const res = await request(app).get(`/api/answers/${testAnswerId}`);
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.id).toEqual(testAnswerId);
    expect(res.body.data.content).toEqual('This is a test answer with enough characters to pass validation.');
  });
  
  it('should return 404 for non-existent answer', async () => {
    const res = await request(app).get('/api/answers/9999');
    
    expect(res.statusCode).toEqual(404);
    expect(res.body.success).toBe(false);
  });
});

/**
 * Test updating an answer
 */
describe('PUT /api/answers/:id', () => {
  it('should update an answer', async () => {
    const res = await request(app)
      .put(`/api/answers/${testAnswerId}`)
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        content: 'This is an updated test answer with enough characters to pass validation.'
      });
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.content).toEqual('This is an updated test answer with enough characters to pass validation.');
  });
  
  it('should prevent updating by non-owner', async () => {
    const res = await request(app)
      .put(`/api/answers/${testAnswerId}`)
      .set('Authorization', `Bearer ${secondUserToken}`)
      .send({
        content: 'This update should fail because different user.'
      });
    
    expect(res.statusCode).toEqual(403);
    expect(res.body.success).toBe(false);
  });
  
  it('should require authentication', async () => {
    const res = await request(app)
      .put(`/api/answers/${testAnswerId}`)
      .send({
        content: 'This update should fail without authentication.'
      });
    
    expect(res.statusCode).toEqual(401);
    expect(res.body.success).toBe(false);
  });
});

/**
 * Test accepting an answer
 */
describe('PATCH /api/answers/:id/accept', () => {
  it('should mark an answer as accepted', async () => {
    const res = await request(app)
      .patch(`/api/answers/${testAnswerId}/accept`)
      .set('Authorization', `Bearer ${authToken}`);
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.is_accepted).toBe(true);
  });
  
  it('should prevent accepting by non-question-owner', async () => {
    const res = await request(app)
      .patch(`/api/answers/${testAnswerId}/accept`)
      .set('Authorization', `Bearer ${secondUserToken}`);
    
    expect(res.statusCode).toEqual(403);
    expect(res.body.success).toBe(false);
  });
});

/**
 * Test deleting an answer
 */
describe('DELETE /api/answers/:id', () => {
  it('should prevent deletion by non-owner', async () => {
    const res = await request(app)
      .delete(`/api/answers/${testAnswerId}`)
      .set('Authorization', `Bearer ${secondUserToken}`);
    
    expect(res.statusCode).toEqual(403);
    expect(res.body.success).toBe(false);
  });
  
  it('should delete an answer', async () => {
    const res = await request(app)
      .delete(`/api/answers/${testAnswerId}`)
      .set('Authorization', `Bearer ${authToken}`);
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
  });
  
  it('should verify answer is deleted', async () => {
    const res = await request(app).get(`/api/answers/${testAnswerId}`);
    
    expect(res.statusCode).toEqual(404);
    expect(res.body.success).toBe(false);
  });
});
