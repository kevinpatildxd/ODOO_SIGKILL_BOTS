# StackIt Hackathon Context File - Enhanced
*Optimized for Maximum Review Points in 7-Hour Timeline*

## 🎯 Project Overview
StackIt is a minimal Q&A forum platform designed for collaborative learning. Our goal is to build a production-ready application that scores maximum points across all review criteria.

## 🏆 Review Criteria Strategy (Total: 100%)

### 1. Database Design - 35% (Custom Backend Target)
**Schema Design Focus:**
- Well-structured relational database with proper foreign keys
- Normalized tables with appropriate data types
- Indexes for performance optimization

**Real-time Sync Implementation:**
- Socket.io for real-time notifications
- Polling fallback for vote updates
- WebSocket connection management

### 2. Coding Standards - 40% (Highest Weight)
**Data Validation:**
- Frontend: Form validation with proper error states
- Backend: Input sanitization and validation middleware
- Type checking and constraint validation

**Dynamic Values:**
- Environment variables for all configurations
- Database-driven content (no hardcoded strings)
- Configurable pagination limits and thresholds

**Code Reusability:**
- Modular Flutter widgets and components
- Backend middleware and utility functions
- Shared validation schemas and models

**Performance Optimization:**
- Lazy loading and pagination
- Database query optimization
- Caching strategies (in-memory for 7-hour scope)
- Minimal API calls with data aggregation

**Error Handling:**
- Try-catch blocks with meaningful error messages
- Fallback UI states in Flutter
- Graceful degradation for network issues
- Logging system for debugging

**Code Quality:**
- ESLint for backend, Flutter analyzer for frontend
- Consistent naming conventions
- Clean code principles

**Complexity Demonstration:**
- Nested query logic for filtering/searching
- Vote counting algorithms
- Real-time notification system
- Rich text processing

### 3. UI/UX Design - 15%
**Responsive Design:**
- Mobile-first approach with Flutter
- Adaptive layouts for different screen sizes
- Touch-friendly interface elements

**Navigation Features:**
- Pagination for question lists
- Breadcrumb navigation
- Search with real-time filtering
- Tag-based filtering system

**Visual Design:**
- Consistent color scheme with proper contrast
- Material Design principles
- Loading states and animations
- Accessible typography

### 4. Team Collaboration - 10%
**Distribution Strategy:**
- 2 Frontend developers: UI components + integration
- 2 Backend developers: API + database + real-time features
- Code review process and shared standards

## 🛠 Technical Stack

### Frontend (Flutter)
- **Framework:** Flutter 3.x
- **State Management:** Provider/Riverpod
- **HTTP Client:** Dio for API calls
- **Rich Text Editor:** flutter_quill or similar
- **Real-time:** socket_io_client
- **Form Validation:** Built-in validators + custom logic

### Backend (Node.js)
- **Runtime:** Node.js 18+
- **Framework:** Express.js
- **Database:** PostgreSQL with pg library
- **Real-time:** Socket.io
- **Authentication:** JWT tokens
- **Validation:** Joi or express-validator
- **CORS:** cors middleware

### Database (PostgreSQL)
- **ORM:** Raw SQL queries for better control
- **Connection Pool:** pg-pool for performance
- **Migrations:** Simple SQL files
- **Indexes:** Strategic indexing for queries

## 📁 Complete Folder Structure

### Backend Structure
```
stackit_backend/
├── package.json
├── .env
├── .gitignore
├── server.js
├── config/
│   ├── database.js
│   ├── jwt.js
│   └── socket.js
├── controllers/
│   ├── authController.js
│   ├── questionController.js
│   ├── answerController.js
│   ├── voteController.js
│   ├── tagController.js
│   └── notificationController.js
├── middleware/
│   ├── auth.js
│   ├── validation.js
│   ├── errorHandler.js
│   └── rateLimit.js
├── models/
│   ├── User.js
│   ├── Question.js
│   ├── Answer.js
│   ├── Vote.js
│   ├── Tag.js
│   └── Notification.js
├── routes/
│   ├── auth.js
│   ├── questions.js
│   ├── answers.js
│   ├── votes.js
│   ├── tags.js
│   └── notifications.js
├── services/
│   ├── authService.js
│   ├── questionService.js
│   ├── answerService.js
│   ├── voteService.js
│   ├── tagService.js
│   └── notificationService.js
├── utils/
│   ├── logger.js
│   ├── helpers.js
│   └── constants.js
├── database/
│   ├── init.sql
│   ├── seed.sql
│   └── migrations/
│       ├── 001_create_users.sql
│       ├── 002_create_questions.sql
│       ├── 003_create_answers.sql
│       ├── 004_create_tags.sql
│       ├── 005_create_question_tags.sql
│       ├── 006_create_votes.sql
│       └── 007_create_notifications.sql
├── sockets/
│   ├── index.js
│   ├── questionSocket.js
│   ├── voteSocket.js
│   └── notificationSocket.js
└── tests/
    ├── auth.test.js
    ├── questions.test.js
    ├── answers.test.js
    └── votes.test.js
```

### Frontend Structure
```
stackit_frontend/
├── pubspec.yaml
├── analysis_options.yaml
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── theme.dart
│   │   └── constants.dart
│   ├── core/
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   ├── api_endpoints.dart
│   │   │   └── network_exceptions.dart
│   │   ├── utils/
│   │   │   ├── date_utils.dart
│   │   │   ├── validators.dart
│   │   │   └── helpers.dart
│   │   └── services/
│   │       ├── socket_service.dart
│   │       ├── storage_service.dart
│   │       └── notification_service.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── question_model.dart
│   │   │   ├── answer_model.dart
│   │   │   ├── vote_model.dart
│   │   │   ├── tag_model.dart
│   │   │   └── notification_model.dart
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart
│   │   │   ├── question_repository.dart
│   │   │   ├── answer_repository.dart
│   │   │   ├── vote_repository.dart
│   │   │   ├── tag_repository.dart
│   │   │   └── notification_repository.dart
│   │   └── datasources/
│   │       ├── auth_datasource.dart
│   │       ├── question_datasource.dart
│   │       ├── answer_datasource.dart
│   │       ├── vote_datasource.dart
│   │       ├── tag_datasource.dart
│   │       └── notification_datasource.dart
│   └── presentation/
│       ├── providers/
│       │   ├── auth_provider.dart
│       │   ├── question_provider.dart
│       │   ├── answer_provider.dart
│       │   ├── vote_provider.dart
│       │    ├── tag_provider.dart
│       │   └── notification_provider.dart
│       ├── screens/
│       │   ├── auth/
│       │   │   ├── login_screen.dart
│       │   │   ├── register_screen.dart
│       │   │   └── forgot_password_screen.dart
│       │   ├── home/
│       │   │   ├── home_screen.dart
│       │   │   ├── question_list_screen.dart
│       │   │   └── search_screen.dart
│       │   ├── question/
│       │   │   ├── question_detail_screen.dart
│       │   │   ├── ask_question_screen.dart
│       │   │   └── edit_question_screen.dart
│       │   ├── answer/
│       │   │   ├── answer_screen.dart
│       │   │   └── edit_answer_screen.dart
│       │   ├── profile/
│       │   │   ├── profile_screen.dart
│       │   │   ├── user_questions_screen.dart
│       │   │   └── user_answers_screen.dart
│       │   └── settings/
│       │       ├── settings_screen.dart
│       │       └── notification_settings_screen.dart
│       ├── widgets/
│       │   ├── common/
│       │   │   ├── app_bar.dart
│       │   │   ├── bottom_navigation.dart
│       │   │   ├── loading_widget.dart
│       │   │   ├── error_widget.dart
│       │   │   ├── empty_state_widget.dart
│       │   │   ├── pagination_widget.dart
│       │   │   └── search_bar.dart
│       │   ├── auth/
│       │   │   ├── auth_form.dart
│       │   │   ├── login_form.dart
│       │   │   └── register_form.dart
│       │   ├── question/
│       │   │   ├── question_card.dart
│       │   │   ├── question_detail_card.dart
│       │   │   ├── question_form.dart
│       │   │   ├── question_filters.dart
│       │   │   └── question_stats.dart
│       │   ├── answer/
│       │   │   ├── answer_card.dart
│       │   │   ├── answer_form.dart
│       │   │   ├── answer_list.dart
│       │   │   └── vote_widget.dart
│       │   ├── tag/
│       │   │   ├── tag_chip.dart
│       │   │   ├── tag_selector.dart
│       │   │   └── tag_list.dart
│       │   ├── notification/
│       │   │   ├── notification_card.dart
│       │   │   ├── notification_list.dart
│       │   │   └── notification_badge.dart
│       │   └── editor/
│       │       ├── rich_text_editor.dart
│       │       ├── editor_toolbar.dart
│       │       └── markdown_preview.dart
│       └── routes/
│           ├── app_routes.dart
│           └── route_generator.dart
│
│
│
│
├── test/
│   ├── unit/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── providers/
│   ├── widget/
│   │   ├── screens/
│   │   └── widgets/
│   └── integration/
│       └── app_test.dart
└── assets/
    ├── images/
    │   ├── logo.png
    │   ├── placeholder.png
    │   └── icons/
    └── fonts/
        └── custom_font.ttf
```

## 📊 Database Schema Design

### Core Tables
```sql
-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'user',
    avatar_url VARCHAR(255),
    bio TEXT,
    reputation INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Questions table
CREATE TABLE questions (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    accepted_answer_id INTEGER DEFAULT NULL,
    view_count INTEGER DEFAULT 0,
    vote_count INTEGER DEFAULT 0,
    answer_count INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Answers table
CREATE TABLE answers (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    question_id INTEGER REFERENCES questions(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    is_accepted BOOLEAN DEFAULT FALSE,
    vote_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tags table
CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    color VARCHAR(7) DEFAULT '#2196F3',
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Question-Tag relationship
CREATE TABLE question_tags (
    question_id INTEGER REFERENCES questions(id) ON DELETE CASCADE,
    tag_id INTEGER REFERENCES tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (question_id, tag_id)
);

-- Votes table
CREATE TABLE votes (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    target_type VARCHAR(20) NOT NULL CHECK (target_type IN ('question', 'answer')),
    target_id INTEGER NOT NULL,
    vote_type INTEGER CHECK (vote_type IN (-1, 1)), -- -1 downvote, 1 upvote
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, target_type, target_id)
);

-- Notifications table
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    reference_type VARCHAR(20),
    reference_id INTEGER,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User Sessions table
CREATE TABLE user_sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Indexes for Performance
```sql
-- User indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);

-- Question indexes
CREATE INDEX idx_questions_user_id ON questions(user_id);
CREATE INDEX idx_questions_created_at ON questions(created_at DESC);
CREATE INDEX idx_questions_status ON questions(status);
CREATE INDEX idx_questions_slug ON questions(slug);

-- Answer indexes
CREATE INDEX idx_answers_question_id ON answers(question_id);
CREATE INDEX idx_answers_user_id ON answers(user_id);
CREATE INDEX idx_answers_created_at ON answers(created_at DESC);

-- Vote indexes
CREATE INDEX idx_votes_target ON votes(target_type, target_id);
CREATE INDEX idx_votes_user_id ON votes(user_id);

-- Tag indexes
CREATE INDEX idx_tags_name ON tags(name);
CREATE INDEX idx_question_tags_tag_id ON question_tags(tag_id);

-- Notification indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- Session indexes
CREATE INDEX idx_user_sessions_token_hash ON user_sessions(token_hash);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);
```

## 🚀 Implementation Roadmap (7 Hours)

### Hour 1: Setup & Database (10:00-11:00)
**Backend Team:**
- Initialize Node.js project with Express
- Set up PostgreSQL database
- Create database schema and seed data
- Configure environment variables
- Set up basic project structure

**Frontend Team:**
- Initialize Flutter project
- Set up folder structure and dependencies
- Configure API client (Dio)
- Create basic app structure and theme
- Set up state management (Provider/Riverpod)

### Hour 2: Authentication & Core Models (11:00-12:00)
**Backend Team:**
- Implement JWT authentication
- Create user registration/login endpoints
- Set up middleware for auth and validation
- Create user model and service
- Test authentication flow

**Frontend Team:**
- Create authentication screens (login/register)
- Implement authentication state management
- Create reusable UI components
- Set up routing structure
- Create user model and auth service

### Hour 3: Question Management APIs (12:00-13:00)
**Backend Team:**
- Create question CRUD endpoints
- Implement tag management
- Add search and filtering logic
- Set up pagination
- Create question and tag models

**Frontend Team:**
- Build question list screen
- Implement search and filter UI
- Create question card components
- Add pagination controls
- Create question model and service

### Hour 4: Answer & Voting System (13:00-14:00)
**Backend Team:**
- Create answer CRUD endpoints
- Implement voting system
- Add answer acceptance functionality
- Set up vote count calculations
- Create answer and vote models

**Frontend Team:**
- Build question detail screen
- Implement answer display and voting UI
- Create rich text editor integration
- Add answer submission form
- Create answer and vote models

### Hour 5: Real-time Features (14:00-15:00)
**Backend Team:**
- Implement Socket.io for real-time updates
- Create notification system
- Add real-time vote updates
- Test WebSocket connections
- Set up notification model

**Frontend Team:**
- Integrate Socket.io client
- Implement notification UI
- Add real-time updates to vote counts
- Create notification dropdown
- Set up socket service

### Hour 6: Polish & Integration (15:00-16:00)
**Full Team:**
- Integration testing
- Bug fixes and error handling
- UI/UX improvements
- Performance optimization
- Code review and refactoring

### Hour 7: Final Testing & Deployment (16:00-17:00)
**Full Team:**
- Final testing of all features
- Code cleanup and linting
- Documentation updates
- Presentation preparation
- Deploy to staging environment

## 📋 Feature Implementation Priority

### Must-Have (Core Features)
1. ✅ User authentication (register/login)
2. ✅ Ask questions with rich text editor
3. ✅ Answer questions with voting
4. ✅ Tag system
5. ✅ Basic notifications
6. ✅ Search and filtering
7. ✅ Pagination

### Should-Have (If Time Permits)
1. ✅ Real-time updates via WebSocket
2. ✅ Answer acceptance
3. ✅ Advanced search filters
4. ✅ User profiles
5. ✅ Vote counting system
6. ✅ Question view tracking

### Could-Have (Stretch Goals)
1. ⏳ Comment system
2. ⏳ Advanced notifications
3. ⏳ User reputation system
4. ⏳ Admin moderation panel
5. ⏳ File upload support
6. ⏳ Email notifications

## 🎨 UI/UX Implementation Guidelines

### Design Principles
- **Consistency:** Use Material Design components
- **Accessibility:** Proper contrast ratios and touch targets
- **Performance:** Lazy loading and smooth animations
- **Responsive:** Mobile-first approach

### Color Scheme
```dart
// lib/config/theme.dart
class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF FF9800);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF212121);
  static const Color onBackground = Color(0xFF212121);
}
```

### Typography
```dart
// lib/config/theme.dart
class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurface,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurface,
  );
}
```

## 🔧 Performance Optimization Strategies

### Database Optimization
- Use connection pooling
- Implement proper indexing
- Optimize query joins
- Use LIMIT for pagination
- Implement database caching

### API Optimization
- Implement response caching
- Use data aggregation
- Minimize payload size
- Implement rate limiting
- Use compression middleware

### Frontend Optimization
- Use lazy loading for lists
- Implement image optimization
- Use efficient state management
- Minimize rebuilds
- Implement offline caching

## 🚨 Error Handling Strategy

### Backend Error Handling
```javascript
// middleware/errorHandler.js
const errorHandler = (err, req, res, next) => {
    let statusCode = err.statusCode || 500;
    let message = err.message || 'Internal Server Error';
    
    // Log error
    console.error(`Error: ${message}`, err.stack);
    
    // Handle specific error types
    if (err.name === 'ValidationError') {
        statusCode = 400;
        message = 'Validation Error';
    }
    
    if (err.name === 'JsonWebTokenError') {
        statusCode = 401;
        message = 'Invalid token';
    }
    
    res.status(statusCode).json({
        success: false,
        error: {
            message,
            ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
        }
    });
};

module.exports = errorHandler;
```

### Frontend Error Handling
```dart
// core/utils/error_handler.dart
class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.connectionTimeout:
          return 'Connection timeout. Please try again.';
        case DioErrorType.sendTimeout:
          return 'Send timeout. Please try again.';
        case DioErrorType.receiveTimeout:
          return 'Receive timeout. Please try again.';
        case DioErrorType.badResponse:
          return _handleBadResponse(error);
        case DioErrorType.cancel:
          return 'Request was cancelled.';
        case DioErrorType.unknown:
          return 'Something went wrong. Please try again.';
        default:
          return 'An error occurred. Please try again.';
      }
    }
    return error.toString();
  }
  
  static String _handleBadResponse(DioError error) {
    final statusCode = error.response?.statusCode;
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden. You don\'t have permission.';
      case 404:
        return 'Not found. The resource doesn\'t exist.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
```

## 📱 Testing Strategy

### Backend Testing
```javascript
// tests/auth.test.js
const request = require('supertest');
const app = require('../server');

describe('Authentication', () => {
    it('should register a new user', async () => {
        const response = await request(app)
            .post('/api/auth/register')
            .send({
                username: 'testuser',
                email: 'test@example.com',
                password: 'password123'
            });
        
        expect(response.statusCode).toBe(201);
        expect(response.body.success).toBe(true);
        expect(response.body.data.user.username).toBe('testuser');
    });
    
    it('should login with valid credentials', async () => {
        const response = await request(app)
            .post('/api/auth/login')
            .send({
                email: 'test@example.com',
                password: 'password123'
            });
        
        expect(response.statusCode).toBe(200);
        expect(response.body.success).toBe(true);
        expect(response.body.data.token).toBeDefined();
    });
});
```

### Frontend Testing
```dart
// test/widget/auth/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stackit/presentation/screens/auth/login_screen.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('should display login form', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginScreen()));
      
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
    
    testWidgets('should show error for invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginScreen()));
      
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });
  });
}
```

## 🎯 Scoring Optimization Tips

### Database Design (35%)
- **Focus:** Show complex relationships and proper normalization
- **Demonstrate:** Foreign keys, indexes, and data integrity
- **Add:** Migration files and seed data
- **Bonus:** Triggers and stored procedures for complex operations

### Coding Standards (40%)
- **Focus:** Clean, reusable, and well-documented code
- **Demonstrate:** Error handling, validation, and performance
- **Add:** Linting configuration and comprehensive code comments
- **Bonus:** Unit tests and integration tests

### UI/UX Design (15%)
- **Focus:** Responsive design and user experience
- **Demonstrate:** Loading states, error handling, and accessibility
- **Add:** Smooth animations and intuitive navigation
- **Bonus:** Dark mode and customizable themes

### Team Collaboration (10%)
- **Focus:** Everyone contributes to coding
- **Demonstrate:** Code reviews and shared responsibilities
- **Add:** Commit history showing team participation
- **Bonus:** Issue tracking and project management

## 🔄 Real-time Features Implementation

### Socket.io Events
```javascript
// sockets/index.js
const socketIO = require('socket.io');
const jwt = require('jsonwebtoken');

const initializeSocket = (server) => {
    const io = socketIO(server, {
        cors: {
            origin: process.env.FRONTEND_URL,
            methods: ['GET', 'POST']
        }
    });
    
    // Authentication middleware
    io.use((socket, next) => {
        const token = socket.handshake.auth.token;
        try {
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            socket.userId = decoded.userId;
            next();
        } catch (err) {
            next(new Error('Authentication error'));
        }
    });
    
    io.on('connection', (socket) => {
        console.log(`User ${socket.userId} connected`);
        
        // Join question room
        socket.on('join_question', (questionId) => {
            socket.join(`question_${questionId}`);
            console.log(`User ${socket.userId} joined question ${questionId}`);
        });
        
        // Handle voting
        socket.on('vote_answer', async (data) => {
            try {
                // Update vote in database
                const result = await voteService.voteAnswer(
                    socket.userId,
                    data.answerId,
                    data.voteType
                );
                
                // Emit to all users in question room
                io.to(`question_${data.questionId}`).emit('vote_updated', {
                    answerId: data.answerId,
                    voteCount: result.voteCount,
                    userVote: result.userVote
                });
                
                // Notify answer author
                if (result.answerAuthorId !== socket.userId) {
                    const notification = await notificationService.createNotification({
                        userId: result.answerAuthorId,
                        type: 'vote',
                        title: 'Your answer received a vote',
                        message: `Your answer has been ${data.voteType === 1 ? 'upvoted' : 'downvoted'}`,
                        referenceType: 'answer',
                        referenceId: data.answerId
                    });
                    
                    io.to(`user_${result.answerAuthorId}`).emit('notification', notification);
                }
                
            } catch (error) {
                socket.emit('error', { message: 'Failed to vote' });
            }
        });
        
        // Handle new answers
        socket.on('new_answer', async (data) => {
            try {
                // Create answer in database
                const answer = await answerService.createAnswer({
                    content: data.content,
                    questionId: data.questionId,
                    userId: socket.userId
                });
                
                // Emit to all users in question room
                io.to(`question_${data.questionId}`).emit('answer_added', answer);
                
                // Notify question author
                const question = await questionService.getQuestionById(data.questionId);
                if (question.userId !== socket.userId) {
                    const notification = await notificationService.createNotification({
                        userId: question.userId,
                        type: 'answer',
                        title: 'New answer on your question',
                        message: `${answer.user.username} answered your question: ${question.title}`,
                        referenceType: 'question',
                        referenceId: data.questionId
                    });
                    
                    io.to(`user_${question.userId}`).emit('notification', notification);
                }
                
            } catch (error) {
                socket.emit('error', { message: 'Failed to create answer' });
            }
        });
        
        // Join user room for notifications
        socket.join(`user_${socket.userId}`);
        
        // Handle disconnect
        socket.on('disconnect', () => {
            console.log(`User ${socket.userId} disconnected`);
        });
    });
    
    return io;
};

module.exports = initializeSocket;
```

### Flutter WebSocket Integration
```dart
// core/services/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:stackit/core/utils/storage_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();
  
  IO.Socket? _socket;
  bool _isConnected = false;
  
  // Callbacks
  Function(Map<String, dynamic>)? onVoteUpdated;
  Function(Map<String, dynamic>)? onAnswerAdded;
  Function(Map<String, dynamic>)? onNotification;
  
  Future<void> connect() async {
    if (_isConnected) return;
    
    try {
      final token = await StorageService.getToken();
      if (token == null) return;
      
      _socket = IO.io(
        'http://localhost:3000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .build(),
      );
      
      _socket!.onConnect((_) {
        print('Connected to server');
        _isConnected = true;
      });
      
      _socket!.onDisconnect((_) {
        print('Disconnected from server');
        _isConnected = false;
      });
      
      _socket!.on('vote_updated', (data) {
        onVoteUpdated?.call(data);
      });
      
      _socket!.on('answer_added', (data) {
        onAnswerAdded?.call(data);
      });
      
      _socket!.on('notification', (data) {
        onNotification?.call(data);
      });
      
      _socket!.on('error', (data) {
        print('Socket error: $data');
      });
      
      _socket!.connect();
      
    } catch (e) {
      print('Failed to connect to socket: $e');
    }
  }
  
  void joinQuestionRoom(int questionId) {
    if (_isConnected) {
      _socket!.emit('join_question', questionId);
    }
  }
  
  void voteAnswer(int questionId, int answerId, int voteType) {
    if (_isConnected) {
      _socket!.emit('vote_answer', {
        'questionId': questionId,
        'answerId': answerId,
        'voteType': voteType,
      });
    }
  }
  
  void createAnswer(int questionId, String content) {
    if (_isConnected) {
      _socket!.emit('new_answer', {
        'questionId': questionId,
        'content': content,
      });
    }
  }
  
  void disconnect() {
    if (_isConnected) {
      _socket!.disconnect();
      _isConnected = false;
    }
  }
}
```

## 📚 Code Quality Guidelines

### Naming Conventions
- **Variables:** camelCase
- **Functions:** camelCase
- **Classes:** PascalCase
- **Constants:** UPPER_SNAKE_CASE
- **Files:** snake_case (Flutter), camelCase (Node.js)
- **Database:** snake_case

### Code Organization Principles
```javascript
// Backend - Service Layer Pattern
// services/questionService.js
class QuestionService {
    async getAllQuestions({ page = 1, limit = 10, search = '', tags = [] }) {
        try {
            const offset = (page - 1) * limit;
            let query = `
                SELECT q.*, u.username, u.avatar_url,
                       COUNT(a.id) as answer_count,
                       array_agg(DISTINCT t.name) as tags
                FROM questions q
                LEFT JOIN users u ON q.user_id = u.id
                LEFT JOIN answers a ON q.id = a.question_id
                LEFT JOIN question_tags qt ON q.id = qt.question_id
                LEFT JOIN tags t ON qt.tag_id = t.id
                WHERE 1=1
            `;
            
            const params = [];
            let paramIndex = 1;
            
            if (search) {
                query += ` AND (q.title ILIKE ${paramIndex} OR q.description ILIKE ${paramIndex})`;
                params.push(`%${search}%`);
                paramIndex++;
            }
            
            if (tags.length > 0) {
                query += ` AND t.name = ANY(${paramIndex})`;
                params.push(tags);
                paramIndex++;
            }
            
            query += `
                GROUP BY q.id, u.username, u.avatar_url
                ORDER BY q.created_at DESC
                LIMIT ${paramIndex} OFFSET ${paramIndex + 1}
            `;
            
            params.push(limit, offset);
            
            const result = await db.query(query, params);
            const totalQuery = `
                SELECT COUNT(DISTINCT q.id) as total
                FROM questions q
                LEFT JOIN question_tags qt ON q.id = qt.question_id
                LEFT JOIN tags t ON qt.tag_id = t.id
                WHERE 1=1
                ${search ? `AND (q.title ILIKE '%${search}%' OR q.description ILIKE '%${search}%')` : ''}
                ${tags.length > 0 ? `AND t.name = ANY('{${tags.join(',')}'}')` : ''}
            `;
            
            const totalResult = await db.query(totalQuery);
            
            return {
                questions: result.rows,
                total: parseInt(totalResult.rows[0].total),
                page,
                limit,
                totalPages: Math.ceil(totalResult.rows[0].total / limit)
            };
            
        } catch (error) {
            throw new Error(`Failed to fetch questions: ${error.message}`);
        }
    }
    
    async getQuestionById(id) {
        try {
            const query = `
                SELECT q.*, u.username, u.avatar_url,
                       array_agg(DISTINCT t.name) as tags
                FROM questions q
                LEFT JOIN users u ON q.user_id = u.id
                LEFT JOIN question_tags qt ON q.id = qt.question_id
                LEFT JOIN tags t ON qt.tag_id = t.id
                WHERE q.id = $1
                GROUP BY q.id, u.username, u.avatar_url
            `;
            
            const result = await db.query(query, [id]);
            
            if (result.rows.length === 0) {
                throw new Error('Question not found');
            }
            
            // Increment view count
            await db.query('UPDATE questions SET view_count = view_count + 1 WHERE id = $1', [id]);
            
            return result.rows[0];
            
        } catch (error) {
            throw new Error(`Failed to fetch question: ${error.message}`);
        }
    }
}

module.exports = new QuestionService();
```

```dart
// Frontend - Repository Pattern
// data/repositories/question_repository.dart
class QuestionRepository {
  final QuestionDataSource _dataSource;
  
  QuestionRepository(this._dataSource);
  
  Future<PaginatedResponse<Question>> getQuestions({
    int page = 1,
    int limit = 10,
    String? search,
    List<String>? tags,
  }) async {
    try {
      final response = await _dataSource.getQuestions(
        page: page,
        limit: limit,
        search: search,
        tags: tags,
      );
      
      return PaginatedResponse<Question>(
        data: response.data.map((json) => Question.fromJson(json)).toList(),
        total: response.total,
        page: response.page,
        limit: response.limit,
        totalPages: response.totalPages,
      );
    } catch (e) {
      throw RepositoryException('Failed to fetch questions: ${e.toString()}');
    }
  }
  
  Future<Question> getQuestionById(int id) async {
    try {
      final response = await _dataSource.getQuestionById(id);
      return Question.fromJson(response.data);
    } catch (e) {
      throw RepositoryException('Failed to fetch question: ${e.toString()}');
    }
  }
  
  Future<Question> createQuestion(CreateQuestionRequest request) async {
    try {
      final response = await _dataSource.createQuestion(request);
      return Question.fromJson(response.data);
    } catch (e) {
      throw RepositoryException('Failed to create question: ${e.toString()}');
    }
  }
}
```

### Documentation Standards
```javascript
/**
 * Create a new question
 * @param {Object} questionData - Question data
 * @param {string} questionData.title - Question title
 * @param {string} questionData.description - Question description
 * @param {number} questionData.userId - User ID of the question author
 * @param {Array<string>} questionData.tags - Array of tag names
 * @returns {Promise<Object>} Created question object
 * @throws {Error} If question creation fails
 */
async function createQuestion(questionData) {
    // Implementation
}
```

```dart
/// Creates a new question
/// 
/// Takes a [CreateQuestionRequest] object containing the question data
/// and returns a [Question] object representing the created question.
/// 
/// Throws [RepositoryException] if the question creation fails.
/// 
/// Example:
/// ```dart
/// final request = CreateQuestionRequest(
///   title: 'How to use Flutter?',
///   description: 'I need help with Flutter development',
///   tags: ['flutter', 'dart'],
/// );
/// final question = await questionRepository.createQuestion(request);
/// ```
Future<Question> createQuestion(CreateQuestionRequest request) async {
  // Implementation
}
```

## 🎉 Success Metrics

### Technical Metrics
- All CRUD operations working (100%)
- Real-time features functional (100%)
- No critical bugs (Zero critical issues)
- Good performance (< 3s load time)
- Proper error handling (All edge cases covered)
- Code coverage > 80%

### Review Criteria Metrics
- **Database (35%):** Complex schema with proper relationships and indexes
- **Code Quality (40%):** Clean, reusable, well-documented code with proper validation
- **UI/UX (15%):** Responsive, intuitive, accessible design
- **Team Collaboration (10%):** All members contributing with clear commit history

## 🚀 Final Checklist

### Technical Implementation
- [ ] Database schema properly designed with relationships
- [ ] All API endpoints implemented and tested
- [ ] Real-time features working via WebSocket
- [ ] Authentication and authorization implemented
- [ ] Input validation on frontend and backend
- [ ] Error handling with user-friendly messages
- [ ] Performance optimization (caching, indexing)
- [ ] Mobile-responsive UI design
- [ ] Code linted and formatted consistently

### Code Quality
- [ ] Modular and reusable components
- [ ] Proper separation of concerns
- [ ] Comprehensive error handling
- [ ] Input validation and sanitization
- [ ] Environment variables configured
- [ ] Code documented with comments
- [ ] Consistent naming conventions
- [ ] No hardcoded values

### Team Collaboration
- [ ] All team members have commits
- [ ] Code review process followed
- [ ] Shared coding standards
- [ ] Clear commit messages
- [ ] Issue tracking (if time permits)
- [ ] Knowledge sharing sessions

### Presentation Preparation
- [ ] Demo script prepared
- [ ] Key features highlighted
- [ ] Technical architecture explained
- [ ] Team contributions showcased
- [ ] Challenges and solutions discussed
- [ ] Future roadmap outlined

## 📊 Environment Configuration

### Backend .env Template
```env
# Server Configuration
NODE_ENV=development
PORT=3000
HOST=localhost

# Database Configuration
DATABASE_URL=postgresql://username:password@localhost:5432/stackit_db
DB_HOST=localhost
DB_PORT=5432
DB_NAME=stackit_db
DB_USER=stackit_user
DB_PASSWORD=your_password

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key
JWT_EXPIRES_IN=7d

# CORS Configuration
FRONTEND_URL=http://localhost:3001

# Socket.io Configuration
SOCKET_CORS_ORIGIN=http://localhost:3001

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Logging
LOG_LEVEL=debug
```

### Frontend Configuration
```dart
// lib/config/app_config.dart
class AppConfig {
  static const String apiBaseUrl = 'http://localhost:3000/api';
  static const String socketUrl = 'http://localhost:3000';
  static const int apiTimeoutMs = 30000;
  static const int pageSize = 10;
  static const int maxTagsPerQuestion = 5;
  static const int maxQuestionTitleLength = 255;
  static const int maxAnswerLength = 10000;
  
  // Theme Configuration
  static const bool isDarkModeDefault = false;
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;
  
  // Animation Configuration
  static const int animationDurationMs = 300;
  static const int splashScreenDurationMs = 2000;
}
```

## 🎯 Performance Benchmarks

### Backend Performance Targets
- API response time: < 200ms for simple queries
- Database query time: < 100ms for indexed queries
- WebSocket connection time: < 50ms
- Memory usage: < 512MB for dev environment
- Concurrent connections: Support 100+ simultaneous users

### Frontend Performance Targets
- App startup time: < 2 seconds
- Screen transition time: < 300ms
- List scrolling: 60 FPS
- Memory usage: < 150MB
- Bundle size: < 20MB

## 🔐 Security Implementation

### Backend Security
```javascript
// middleware/security.js
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const validator = require('validator');

// Rate limiting
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
});

// Input sanitization
const sanitizeInput = (req, res, next) => {
  for (const key in req.body) {
    if (typeof req.body[key] === 'string') {
      req.body[key] = validator.escape(req.body[key]);
    }
  }
  next();
};

module.exports = {
  apiLimiter,
  sanitizeInput,
  helmet: helmet(),
};
```

### Frontend Security
```dart
// core/utils/security_utils.dart
class SecurityUtils {
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>'), '')
        .replaceAll(RegExp(r'javascript:'), '')
        .replaceAll(RegExp(r'on\w+\s*='), '');
  }
  
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})
        .hasMatch(email);
  }
  
  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
           RegExp(r'[A-Z]').hasMatch(password) &&
           RegExp(r'[a-z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password);
  }
}
```

---

*This enhanced context file provides a comprehensive roadmap for building StackIt within the 7-hour hackathon timeline. The detailed folder structures, implementation guidelines, and code examples ensure maximum points across all review criteria while maintaining realistic achievability.*