/**
 * Question API Tests
 */
const request = require('supertest');
const app = require('../server');
const db = require('../config/database');
const { generateToken } = require('../utils/helpers');

let authToken;
let testQuestionId;

/**
 * Before running tests, set up test data
 */
beforeAll(async () => {
  // Create a test user
  const userResult = await db.query(
    `INSERT INTO users (username, email, password_hash, role)
     VALUES ($1, $2, $3, $4)
     RETURNING id`,
    ['testuser', 'test@example.com', '$2a$12$test_hash_for_testing', 'user']
  );
  
  const userId = userResult.rows[0].id;
  
  // Generate JWT token for test user
  authToken = generateToken({ id: userId, role: 'user' });
  
  // Create test tags
  await db.query(
    `INSERT INTO tags (name, description, color)
     VALUES ($1, $2, $3),
            ($4, $5, $6)`,
    ['javascript', 'JavaScript programming language', '#F7DF1E',
     'nodejs', 'Node.js runtime environment', '#43853D']
  );
});

/**
 * Clean up test data after all tests
 */
afterAll(async () => {
  // Clean up test data
  await db.query('DELETE FROM question_tags');
  await db.query('DELETE FROM questions');
  await db.query('DELETE FROM tags');
  await db.query('DELETE FROM users');
});

/**
 * Test getting all questions
 */
describe('GET /api/questions', () => {
  it('should return an empty list of questions initially', async () => {
    const res = await request(app).get('/api/questions');
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.questions).toBeDefined();
    expect(res.body.data.total).toEqual(0);
  });
});

/**
 * Test creating a question
 */
describe('POST /api/questions', () => {
  it('should create a new question with tags', async () => {
    const res = await request(app)
      .post('/api/questions')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Test Question Title',
        description: 'This is a test question description with enough characters to pass validation.',
        tags: ['javascript', 'nodejs']
      });
    
    expect(res.statusCode).toEqual(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.title).toEqual('Test Question Title');
    expect(res.body.data.tags).toContain('javascript');
    expect(res.body.data.tags).toContain('nodejs');
    
    // Save the question ID for later tests
    testQuestionId = res.body.data.id;
  });
  
  it('should return error for invalid input', async () => {
    const res = await request(app)
      .post('/api/questions')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Too short',
        description: 'Too short',
        tags: []
      });
    
    expect(res.statusCode).toEqual(400);
    expect(res.body.success).toBe(false);
  });
  
  it('should require authentication', async () => {
    const res = await request(app)
      .post('/api/questions')
      .send({
        title: 'Test Question Without Auth',
        description: 'This should fail without authentication.',
        tags: ['javascript']
      });
    
    expect(res.statusCode).toEqual(401);
    expect(res.body.success).toBe(false);
  });
});

/**
 * Test getting a question by ID
 */
describe('GET /api/questions/id/:id', () => {
  it('should get a question by ID', async () => {
    const res = await request(app).get(`/api/questions/id/${testQuestionId}`);
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.title).toEqual('Test Question Title');
  });
  
  it('should return 404 for non-existent question', async () => {
    const res = await request(app).get('/api/questions/id/9999');
    
    expect(res.statusCode).toEqual(404);
    expect(res.body.success).toBe(false);
  });
});

/**
 * Test updating a question
 */
describe('PUT /api/questions/:id', () => {
  it('should update a question', async () => {
    const res = await request(app)
      .put(`/api/questions/${testQuestionId}`)
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Updated Question Title',
        description: 'This is an updated question description with enough characters to pass validation.',
        tags: ['javascript']
      });
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.title).toEqual('Updated Question Title');
    expect(res.body.data.tags).toContain('javascript');
    expect(res.body.data.tags).not.toContain('nodejs');
  });
  
  it('should require authentication', async () => {
    const res = await request(app)
      .put(`/api/questions/${testQuestionId}`)
      .send({
        title: 'Another Update Attempt',
        description: 'This should fail without authentication.'
      });
    
    expect(res.statusCode).toEqual(401);
    expect(res.body.success).toBe(false);
  });
});

/**
 * Test getting questions by tag
 */
describe('GET /api/questions/tag/:tag', () => {
  it('should get questions by tag', async () => {
    const res = await request(app).get('/api/questions/tag/javascript');
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.questions.length).toBeGreaterThan(0);
    expect(res.body.data.questions[0].title).toEqual('Updated Question Title');
  });
  
  it('should return empty array for non-existent tag', async () => {
    const res = await request(app).get('/api/questions/tag/nonexistenttag');
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.questions.length).toEqual(0);
  });
});

/**
 * Test deleting a question
 */
describe('DELETE /api/questions/:id', () => {
  it('should delete a question', async () => {
    const res = await request(app)
      .delete(`/api/questions/${testQuestionId}`)
      .set('Authorization', `Bearer ${authToken}`);
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
  });
  
  it('should verify question is deleted', async () => {
    const res = await request(app).get(`/api/questions/id/${testQuestionId}`);
    
    expect(res.statusCode).toEqual(404);
    expect(res.body.success).toBe(false);
  });
});
