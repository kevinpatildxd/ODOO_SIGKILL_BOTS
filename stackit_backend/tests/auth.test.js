const request = require('supertest');
const app = require('../server');
const db = require('../config/database');
const jwt = require('jsonwebtoken');

// Mock user data
const testUser = {
  username: 'testuser',
  email: 'test@example.com',
  password: 'Password123',
  confirmPassword: 'Password123'
};

// Mock user returned from registration
const mockRegisteredUser = {
  id: 1,
  username: 'testuser',
  email: 'test@example.com',
  role: 'user',
  avatar_url: null,
  bio: null,
  reputation: 0,
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString()
};

// Mock token for auth tests
const mockToken = jwt.sign(
  { userId: 1, role: 'user' },
  process.env.JWT_SECRET || 'your-secret-key',
  { expiresIn: '1h' }
);

// Set up database mocks
beforeAll(() => {
  // Mock database query responses
  db.query.mockImplementation((sql, params) => {
    // Registration query
    if (sql.includes('INSERT INTO users') && params && params[0] === testUser.username) {
      return Promise.resolve({
        rows: [{ id: 1 }],
        rowCount: 1
      });
    }
    
    // Login query
    if (sql.includes('SELECT * FROM users WHERE email') && params && params[0] === testUser.email) {
      return Promise.resolve({
        rows: [{
          id: 1,
          username: testUser.username,
          email: testUser.email,
          password_hash: '$2a$12$test_hash_that_will_validate', // Mock hash that bcrypt will "verify"
          role: 'user'
        }],
        rowCount: 1
      });
    }
    
    // Get user profile query
    if (sql.includes('SELECT id, username, email, role') && params && params[0] === 1) {
      return Promise.resolve({
        rows: [mockRegisteredUser],
        rowCount: 1
      });
    }
    
    // Update profile query
    if (sql.includes('UPDATE users SET') && params && params[params.length - 1] === 1) {
      return Promise.resolve({
        rows: [{
          ...mockRegisteredUser,
          bio: 'This is my test bio',
          updated_at: new Date().toISOString()
        }],
        rowCount: 1
      });
    }
    
    // Default empty response
    return Promise.resolve({ rows: [], rowCount: 0 });
  });
});

// Clean up mocks after all tests
afterAll(() => {
  jest.clearAllMocks();
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
      
      // Verify token format in response
      expect(response.body.data.token).toBeDefined();
      expect(typeof response.body.data.token).toBe('string');
      
      // No need to save token as we'll use our mock token for remaining tests
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
        .set('Authorization', `Bearer ${mockToken}`);

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
        .set('Authorization', `Bearer ${mockToken}`)
        .send(updatedData);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.user.bio).toBe(updatedData.bio);
    });
  });
});
