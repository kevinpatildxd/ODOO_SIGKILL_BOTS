const request = require('supertest');
const app = require('../server');
const { connectDB, closeDB } = require('../config/database');
const jwt = require('jsonwebtoken');

// Test user data
const testUser = {
  username: 'testuser',
  email: 'test@example.com',
  password: 'Password123',
  confirmPassword: 'Password123'
};

let authToken;
let userId;

// Connect to database before tests
beforeAll(async () => {
  await connectDB();
});

// Close database connection after tests
afterAll(async () => {
  await closeDB();
});

describe('Authentication Tests', () => {
  // Test registration
  describe('POST /api/auth/register', () => {
    it('should register a new user', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send(testUser);

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.user).toBeDefined();
      expect(response.body.data.user.username).toBe(testUser.username);
      expect(response.body.data.user.email).toBe(testUser.email);
      expect(response.body.data.user.password_hash).toBeUndefined();
    });

    it('should return 400 for missing required fields', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({ email: 'incomplete@example.com' });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should not allow duplicate email registration', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          username: 'anotheruser',
          email: testUser.email, // Using the same email
          password: 'Password123',
          confirmPassword: 'Password123'
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });
  });

  // Test login
  describe('POST /api/auth/login', () => {
    it('should login with valid credentials', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: testUser.email,
          password: testUser.password
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.token).toBeDefined();
      expect(response.body.data.user).toBeDefined();
      expect(response.body.data.user.email).toBe(testUser.email);
      
      // Save token and user ID for later tests
      authToken = response.body.data.token;
      userId = response.body.data.user.id;
      
      // Verify token is valid
      const decoded = jwt.verify(authToken, process.env.JWT_SECRET || 'your-secret-key');
      expect(decoded.userId).toBe(userId);
    });

    it('should not login with invalid password', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: testUser.email,
          password: 'wrongpassword'
        });

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });

    it('should not login with non-existent email', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'nonexistent@example.com',
          password: 'Password123'
        });

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });
  });

  // Test user profile
  describe('GET /api/auth/profile', () => {
    it('should get user profile with valid token', async () => {
      const response = await request(app)
        .get('/api/auth/profile')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.user).toBeDefined();
      expect(response.body.data.user.id).toBe(userId);
      expect(response.body.data.user.email).toBe(testUser.email);
    });

    it('should not get profile without token', async () => {
      const response = await request(app).get('/api/auth/profile');

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });

    it('should not get profile with invalid token', async () => {
      const response = await request(app)
        .get('/api/auth/profile')
        .set('Authorization', 'Bearer invalid-token');

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });
  });

  // Test profile update
  describe('PUT /api/auth/profile', () => {
    it('should update user profile', async () => {
      const updatedData = {
        bio: 'This is my test bio'
      };

      const response = await request(app)
        .put('/api/auth/profile')
        .set('Authorization', `Bearer ${authToken}`)
        .send(updatedData);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.user.bio).toBe(updatedData.bio);
    });
  });
});
