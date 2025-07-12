-- Seed data for StackIt database

-- Clear existing data in reverse order to avoid foreign key conflicts
TRUNCATE TABLE user_sessions CASCADE;
TRUNCATE TABLE notifications CASCADE;
TRUNCATE TABLE votes CASCADE;
TRUNCATE TABLE question_tags CASCADE;
TRUNCATE TABLE tags CASCADE;
TRUNCATE TABLE answers CASCADE;
TRUNCATE TABLE questions CASCADE;
TRUNCATE TABLE users CASCADE;

-- Reset sequences
ALTER SEQUENCE users_id_seq RESTART WITH 1;
ALTER SEQUENCE questions_id_seq RESTART WITH 1;
ALTER SEQUENCE answers_id_seq RESTART WITH 1;
ALTER SEQUENCE tags_id_seq RESTART WITH 1;
ALTER SEQUENCE votes_id_seq RESTART WITH 1;
ALTER SEQUENCE notifications_id_seq RESTART WITH 1;
ALTER SEQUENCE user_sessions_id_seq RESTART WITH 1;

-- Seed Users (password_hash is bcrypt hash of 'password123')
INSERT INTO users (username, email, password_hash, role, bio, avatar_url) VALUES
('johndoe', 'john@example.com', '$2a$12$4cW9iRQwFjUZywJbdUAG.e9Y9u0Z5S6F99ZG4ENfHXJJOkSIG4SHG', 'admin', 'Full stack developer with 5 years experience', 'https://randomuser.me/api/portraits/men/1.jpg'),
('janedoe', 'jane@example.com', '$2a$12$4cW9iRQwFjUZywJbdUAG.e9Y9u0Z5S6F99ZG4ENfHXJJOkSIG4SHG', 'user', 'Frontend developer passionate about UI/UX', 'https://randomuser.me/api/portraits/women/1.jpg'),
('bobsmith', 'bob@example.com', '$2a$12$4cW9iRQwFjUZywJbdUAG.e9Y9u0Z5S6F99ZG4ENfHXJJOkSIG4SHG', 'user', 'Backend engineer specialized in Node.js', 'https://randomuser.me/api/portraits/men/2.jpg'),
('alicejones', 'alice@example.com', '$2a$12$4cW9iRQwFjUZywJbdUAG.e9Y9u0Z5S6F99ZG4ENfHXJJOkSIG4SHG', 'moderator', 'DevOps engineer with AWS expertise', 'https://randomuser.me/api/portraits/women/2.jpg'),
('samwilson', 'sam@example.com', '$2a$12$4cW9iRQwFjUZywJbdUAG.e9Y9u0Z5S6F99ZG4ENfHXJJOkSIG4SHG', 'user', 'Mobile app developer focusing on Flutter', 'https://randomuser.me/api/portraits/men/3.jpg');

-- Seed Tags
INSERT INTO tags (name, description, color) VALUES
('javascript', 'For questions regarding programming in ECMAScript and its various dialects/implementations.', '#F7DF1E'),
('react', 'For questions about the React JavaScript library for building user interfaces.', '#61DAFB'),
('node.js', 'For questions about Node.js, an event-driven, non-blocking I/O model using JavaScript.', '#339933'),
('postgresql', 'For questions about the PostgreSQL database management system.', '#336791'),
('flutter', 'For questions about Google''s UI toolkit for building applications for mobile, web, and desktop.', '#02569B'),
('docker', 'For questions about Docker, the platform for developing, shipping, and running applications in containers.', '#2496ED'),
('aws', 'For questions about Amazon Web Services, the cloud computing platform by Amazon.', '#FF9900'),
('git', 'For questions about Git, the distributed version control system.', '#F05032'),
('typescript', 'For questions about TypeScript, a typed superset of JavaScript that compiles to plain JavaScript.', '#3178C6'),
('express', 'For questions about Express.js, a web application framework for Node.js.', '#000000');

-- Seed Questions
INSERT INTO questions (title, description, slug, user_id, view_count, status) VALUES
('How to optimize React rendering performance?', 'I have a React application with complex components that re-render too often. What are the best practices to optimize rendering performance?', 'how-to-optimize-react-rendering-performance', 1, 120, 'active'),
('Best practices for Node.js error handling', 'What are the recommended ways to handle errors in a Node.js application? Should I use try/catch blocks or error-first callbacks?', 'best-practices-for-nodejs-error-handling', 2, 95, 'active'),
('PostgreSQL vs MongoDB for a REST API', 'I am building a RESTful API and I am trying to decide between PostgreSQL and MongoDB. What are the pros and cons of each for this use case?', 'postgresql-vs-mongodb-for-a-rest-api', 3, 210, 'active'),
('How to implement JWT authentication in Express?', 'I need to add JWT-based authentication to my Express application. What is the recommended way to implement this?', 'how-to-implement-jwt-authentication-in-express', 4, 180, 'active'),
('Flutter state management solutions comparison', 'There are many state management solutions for Flutter like Provider, Bloc, Redux, MobX. Which one is recommended for complex applications?', 'flutter-state-management-solutions-comparison', 5, 150, 'active'),
('Docker compose vs Kubernetes for small projects', 'For a small to medium project with 5-10 microservices, is Docker Compose sufficient or should I invest in learning Kubernetes?', 'docker-compose-vs-kubernetes-for-small-projects', 1, 90, 'active'),
('How to handle CORS issues in Node.js?', 'I am getting CORS errors when making requests from my frontend to my Node.js backend. How can I properly configure CORS?', 'how-to-handle-cors-issues-in-nodejs', 2, 130, 'active'),
('TypeScript vs JavaScript for large projects', 'For a large-scale web application, what are the advantages of using TypeScript over vanilla JavaScript?', 'typescript-vs-javascript-for-large-projects', 3, 220, 'active'),
('Best practices for Git workflow in a team', 'What is the recommended Git workflow for a team of 5-10 developers working on the same project?', 'best-practices-for-git-workflow-in-a-team', 4, 160, 'active'),
('AWS Lambda vs EC2 for Node.js applications', 'I am deploying a Node.js application to AWS. Should I use Lambda or EC2? What are the trade-offs?', 'aws-lambda-vs-ec2-for-nodejs-applications', 5, 100, 'active');

-- Seed Question Tags
INSERT INTO question_tags (question_id, tag_id) VALUES
(1, 1), (1, 2), -- React performance: javascript, react
(2, 3), -- Node.js error handling: node.js
(3, 4), -- PostgreSQL vs MongoDB: postgresql
(4, 3), (4, 10), -- JWT in Express: node.js, express
(5, 5), -- Flutter state management: flutter
(6, 6), -- Docker vs Kubernetes: docker
(7, 3), (7, 10), -- CORS in Node.js: node.js, express
(8, 1), (8, 9), -- TypeScript vs JavaScript: javascript, typescript
(9, 8), -- Git workflow: git
(10, 7), (10, 3); -- AWS Lambda vs EC2: aws, node.js

-- Seed Answers
INSERT INTO answers (content, question_id, user_id, is_accepted) VALUES
-- Answers for Question 1: React rendering performance
('To optimize React rendering performance, you should:\n\n1. Use React.memo for functional components that render often but with the same props\n2. Implement shouldComponentUpdate for class components\n3. Use the useCallback hook to memoize functions\n4. Use the useMemo hook to memoize expensive calculations\n5. Avoid anonymous functions in render methods\n6. Use virtualization for long lists with react-window or react-virtualized\n7. Split complex components into smaller ones\n8. Use the Chrome Performance tab to identify bottlenecks', 1, 2, TRUE),
('Another important technique is to avoid unnecessary re-renders by carefully structuring your component hierarchy and state management. Consider using a state management library like Redux with proper normalization of your data.', 1, 3, FALSE),

-- Answers for Question 2: Node.js error handling
('For Node.js error handling, I recommend:\n\n1. Use async/await with try/catch blocks for modern code\n2. Create a centralized error handling middleware for Express apps\n3. Use custom error classes to differentiate error types\n4. Always handle promise rejections with .catch() or try/catch\n5. Use the "error-first" callback pattern for callback-based APIs\n6. Consider a library like express-async-errors to catch async errors automatically\n7. Never ignore errors or simply log them without proper handling\n8. Add a global unhandledRejection and uncaughtException listeners for process-level errors', 2, 1, TRUE),
('To add to the above answer, you should also consider implementing circuit breakers for external service calls. Libraries like Opossum can help with this.', 2, 4, FALSE),

-- Answers for Question 3: PostgreSQL vs MongoDB
('PostgreSQL pros:\n- Strong consistency and ACID compliance\n- Powerful query capabilities and JOINs\n- Great for structured data with clear relationships\n- Built-in support for JSON if you need some flexibility\n\nMongoDB pros:\n- Schema flexibility for evolving data structures\n- Horizontally scalable by design\n- JSON-like document model matches application objects\n- Often simpler to start with for JavaScript developers\n\nFor a REST API, I would recommend PostgreSQL if:\n- Your data has clear relationships\n- You need transaction support\n- Data consistency is critical\n- Your schema is relatively stable\n\nChoose MongoDB if:\n- Your data structure might change frequently\n- You don\'t have complex relationships between entities\n- You need horizontal scaling from the start\n- Your data is document-oriented by nature', 3, 5, TRUE),
('I would add that PostgreSQL has improved significantly with JSON support. You can use JSONB columns to get the best of both worlds - schema flexibility when you need it and strong relationships for the rest of your data.', 3, 1, FALSE),

-- More answers for remaining questions
('For JWT authentication in Express, I recommend using the jsonwebtoken library along with passport.js. Here\'s a basic implementation:\n\n```javascript\nconst jwt = require(\'jsonwebtoken\');\nconst passport = require(\'passport\');\nconst JwtStrategy = require(\'passport-jwt\').Strategy;\nconst ExtractJwt = require(\'passport-jwt\').ExtractJwt;\n\n// Configure strategy\nconst jwtOptions = {\n  jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),\n  secretOrKey: process.env.JWT_SECRET\n};\n\npassport.use(new JwtStrategy(jwtOptions, async (payload, done) => {\n  try {\n    // Find user from payload\n    const user = await User.findById(payload.id);\n    if (!user) return done(null, false);\n    return done(null, user);\n  } catch (err) {\n    return done(err, false);\n  }\n}));\n\n// Login route\napp.post(\'/login\', async (req, res) => {\n  // Verify credentials\n  const user = await User.findOne({email: req.body.email});\n  if (!user || !await user.comparePassword(req.body.password)) {\n    return res.status(401).json({message: \'Invalid credentials\'});\n  }\n  \n  // Generate token\n  const token = jwt.sign({id: user.id}, process.env.JWT_SECRET, {expiresIn: \'7d\'});\n  return res.json({token});\n});\n\n// Protected route\napp.get(\'/protected\', passport.authenticate(\'jwt\', {session: false}), (req, res) => {\n  res.json({user: req.user});\n});\n```\n\nDon\'t forget to store your JWT_SECRET in environment variables and implement proper error handling.', 4, 3, TRUE),

-- Answers continued for remaining questions
('For Flutter state management, Provider is a good starting point for most applications due to its simplicity and official support. BLoC/Cubit provides more structure for complex apps with many events. Here\'s a comparison:\n\n1. Provider: Simple, intuitive, good for small to medium apps\n2. BLoC/Cubit: More structured, separates UI from business logic, great for complex apps\n3. Riverpod: Evolution of Provider with improved API and compile-time safety\n4. GetX: All-in-one solution (state, navigation, dependency injection)\n5. MobX: Reactive programming approach\n\nMy recommendation is to start with Provider/Riverpod and move to BLoC if you need more structure as your app grows.', 5, 2, TRUE),
('In my experience, Docker Compose is sufficient for small to medium projects with 5-10 services. Kubernetes adds significant complexity that isn\'t justified unless you need features like:\n\n1. Advanced auto-scaling\n2. Rolling updates with zero downtime\n3. Complex service discovery\n4. Multi-region deployment\n5. Self-healing infrastructure\n\nWith Docker Compose, you get:\n1. Simple configuration with docker-compose.yml\n2. Easy local development setup\n3. Basic service discovery\n4. Volume management\n5. Network isolation\n\nConsider Kubernetes only when your application outgrows these capabilities or you specifically need Kubernetes features.', 6, 4, FALSE),
('To handle CORS issues in Node.js, use the cors middleware package:\n\n```javascript\nconst express = require(\'express\');\nconst cors = require(\'cors\');\nconst app = express();\n\n// Basic CORS setup - allows all origins\napp.use(cors());\n\n// Or with specific configuration\napp.use(cors({\n  origin: \'https://yourfrontend.com\',  // specify allowed origin\n  methods: [\'GET\', \'POST\', \'PUT\', \'DELETE\'], // allowed methods\n  allowedHeaders: [\'Content-Type\', \'Authorization\'], // allowed headers\n  credentials: true // allow cookies\n}));\n\n// For route-specific CORS:\napp.get(\'/api/public\', cors(), (req, res) => {\n  // This route has default CORS enabled\n});\n\n// Different CORS for specific route\nconst specificCors = cors({\n  origin: \'https://special-client.com\'\n});\n\napp.get(\'/api/protected\', specificCors, (req, res) => {\n  // This route has specific CORS policy\n});\n```\n\nMake sure your API server responds to OPTIONS requests (preflight) correctly.', 7, 5, TRUE),
('TypeScript offers significant advantages over JavaScript for large projects:\n\n1. Static typing catches errors at compile-time instead of runtime\n2. Better IDE support with autocomplete and refactoring tools\n3. Explicit interfaces improve code documentation\n4. Generics allow for type-safe reusable components\n5. Advanced type features like discriminated unions and type guards\n6. Easier maintenance and refactoring of large codebases\n7. Better collaboration in teams due to explicit contracts\n8. Gradual adoption - can mix with JavaScript\n\nThe initial learning curve and setup time is offset by reduced bugs and maintenance costs. For large projects, the investment pays off quickly.', 8, 1, FALSE),
('For a team of 5-10 developers, I recommend GitFlow or a simplified version of it:\n\n1. `main` branch - always production-ready\n2. `develop` branch - integration branch for features\n3. Feature branches - named like `feature/user-authentication`\n4. Release branches - for preparing releases\n5. Hotfix branches - for emergency production fixes\n\nWorkflow:\n1. Developers create feature branches from `develop`\n2. Use pull/merge requests for code reviews\n3. Merge features to `develop` after approval\n4. Create release branches from `develop` when ready\n5. Test on release branch and fix issues there\n6. Merge release to `main` AND back to `develop`\n7. Tag releases on `main`\n\nAdd automated CI/CD and branch protection rules. Consider using conventional commits for automated versioning.', 9, 3, TRUE),
('When choosing between AWS Lambda and EC2 for Node.js apps:\n\nLambda is better for:\n- Event-driven workloads\n- APIs with variable or sporadic traffic\n- Microservices architecture\n- Reduced operational overhead\n- Lower costs for low/intermittent traffic\n- Automatic scaling\n\nEC2 is better for:\n- Long-running processes\n- Applications with consistent high traffic\n- Workloads requiring specific CPU/memory configurations\n- Applications needing full control over the environment\n- Legacy applications not designed for serverless\n\nI recommend starting with Lambda for new Node.js applications unless you have specific requirements that Lambda can\'t meet. You can also use a hybrid approach - Lambda for API endpoints and EC2 for background workers.', 10, 2, TRUE);

-- Update vote counts based on seed votes
UPDATE questions SET vote_count = (SELECT COUNT(*) FROM votes WHERE target_type = 'question' AND target_id = questions.id);
UPDATE answers SET vote_count = (SELECT COUNT(*) FROM votes WHERE target_type = 'answer' AND target_id = answers.id);

-- Update answer_count for questions
UPDATE questions SET answer_count = (SELECT COUNT(*) FROM answers WHERE question_id = questions.id);

-- Update accepted_answer_id for questions with accepted answers
UPDATE questions q
SET accepted_answer_id = a.id
FROM answers a
WHERE a.question_id = q.id AND a.is_accepted = TRUE;

-- Seed votes
INSERT INTO votes (user_id, target_type, target_id, vote_type) VALUES
-- Votes for Question 1
(2, 'question', 1, 1), -- Jane upvotes Question 1
(3, 'question', 1, 1), -- Bob upvotes Question 1
(4, 'question', 1, 1), -- Alice upvotes Question 1
(5, 'question', 1, 1), -- Sam upvotes Question 1

-- Votes for Question 2
(1, 'question', 2, 1), -- John upvotes Question 2
(3, 'question', 2, 1), -- Bob upvotes Question 2
(4, 'question', 2, 1), -- Alice upvotes Question 2

-- Votes for various other questions
(1, 'question', 3, 1),
(2, 'question', 3, 1),
(1, 'question', 4, 1),
(3, 'question', 5, 1),
(4, 'question', 6, 1),
(5, 'question', 7, 1),
(1, 'question', 8, 1),
(2, 'question', 9, 1),
(3, 'question', 10, 1),

-- Votes for Answer 1 (to Question 1)
(1, 'answer', 1, 1), -- John upvotes Answer 1
(3, 'answer', 1, 1), -- Bob upvotes Answer 1
(4, 'answer', 1, 1), -- Alice upvotes Answer 1
(5, 'answer', 1, 1), -- Sam upvotes Answer 1

-- Votes for Answer 2 (to Question 1)
(1, 'answer', 2, 1), -- John upvotes Answer 2
(5, 'answer', 2, 1), -- Sam upvotes Answer 2

-- Votes for various other answers
(2, 'answer', 3, 1),
(5, 'answer', 3, 1),
(1, 'answer', 4, 1),
(2, 'answer', 5, 1),
(4, 'answer', 6, 1),
(1, 'answer', 7, 1),
(3, 'answer', 8, 1),
(4, 'answer', 9, 1),
(5, 'answer', 10, 1);

-- Update vote counts (again after adding votes)
UPDATE questions SET vote_count = (
    SELECT COALESCE(SUM(vote_type), 0)
    FROM votes
    WHERE target_type = 'question' AND target_id = questions.id
);

UPDATE answers SET vote_count = (
    SELECT COALESCE(SUM(vote_type), 0)
    FROM votes
    WHERE target_type = 'answer' AND target_id = answers.id
);

-- Seed Notifications
INSERT INTO notifications (user_id, type, title, message, reference_type, reference_id) VALUES
(1, 'answer', 'New Answer to Your Question', 'Jane Doe has answered your question about React rendering performance.', 'question', 1),
(2, 'vote', 'Your Answer Received an Upvote', 'Your answer about React rendering performance received an upvote.', 'answer', 1),
(3, 'answer', 'New Answer to Your Question', 'John Doe has answered your question about PostgreSQL vs MongoDB.', 'question', 3),
(4, 'vote', 'Your Answer Received an Upvote', 'Your answer about Git workflow received an upvote.', 'answer', 9),
(5, 'answer', 'New Answer to Your Question', 'Alice Jones has answered your question about AWS Lambda vs EC2.', 'question', 10);
