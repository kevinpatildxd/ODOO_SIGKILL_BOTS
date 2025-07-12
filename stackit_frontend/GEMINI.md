# Cursor Rules for StackIt Development

## Core Development Principles

### 1. No Hallucination Policy
- NEVER invent or assume functionality that doesn't exist
- Always verify API endpoints, model structures, and dependencies before implementation
- If uncertain about implementation details, explicitly state assumptions and ask for clarification
- Use only documented Flutter/Dart features and properly imported packages
- Reference the project's actual file structure and existing code patterns

### 2. MCP Server Integration
You have access to the following MCP servers - use them strategically:

#### git-mcp
- Use for version control operations, commit history analysis, and branch management
- Call when needing to understand code changes, conflicts, or repository state
- Helpful for tracking team contributions and code review processes

#### allpepper-memory-bank
- Use for storing and retrieving project-specific knowledge, decisions, and patterns
- Store reusable code snippets, architectural decisions, and team conventions
- Retrieve previously stored context to maintain consistency across development sessions

#### sequential-thinking
- Use for complex problem-solving and architectural planning
- Break down complex features into sequential steps
- Analyze dependencies and implementation order for optimal development flow

### 3. Context File Adherence
- Always reference the `stackit_frontend_context.md` file for project-specific guidelines
- Follow the exact folder structure and naming conventions specified
- Implement features according to the priority levels defined in the context
- Use the provided code patterns and architectural decisions

## Flutter-Specific Rules

### 4. Project Structure Compliance
- Follow the exact folder structure from `stackit_frontend_context.md`
- Place files in correct directories: `lib/presentation/`, `lib/data/`, `lib/core/`
- Use proper import paths and maintain clean architecture separation
- Never create files outside the defined structure without explicit approval

### 5. State Management
- Use Provider/Riverpod as specified in the context file
- Implement proper state management patterns for data flow
- Create separate providers for different feature domains
- Handle loading, error, and success states consistently

### 6. API Integration
- Use Dio HTTP client as specified in the project dependencies
- Implement proper error handling with the defined ErrorHandler class
- Follow the repository pattern for data access
- Use the defined API endpoints and request/response models

### 7. UI/UX Implementation
- Follow Material Design principles and the defined AppColors/AppTextStyles
- Implement responsive design with proper constraint handling
- Use the defined reusable widgets and maintain consistency
- Include proper loading states, error handling, and empty state widgets

### 8. Code Quality Standards
- Use dart analyzer and follow all linting rules
- Implement proper null safety and type checking
- Write meaningful variable names and add documentation comments
- Follow the naming conventions: camelCase for variables, PascalCase for classes

## Implementation Guidelines

### 9. Feature Development Process
1. **Planning Phase**
   - Use `sequential-thinking` to break down complex features
   - Check `allpepper-memory-bank` for similar implementations
   - Verify requirements against the context file

2. **Implementation Phase**
   - Follow the repository pattern architecture
   - Implement data models with proper JSON serialization
   - Create reusable widgets following the component structure
   - Add proper error handling and validation

3. **Testing Phase**
   - Write unit tests for business logic and models
   - Create widget tests for UI components
   - Test API integration and error scenarios
   - Verify responsive design across different screen sizes

### 10. Code Organization
- Group related functionality in appropriate modules
- Use barrel exports for clean imports
- Maintain single responsibility principle for classes and functions
- Keep widget build methods concise and readable

### 11. Performance Optimization
- Implement lazy loading for lists and heavy widgets
- Use const constructors where possible
- Optimize image loading and caching
- Minimize widget rebuilds with proper state management

### 12. Security Implementation
- Validate all user inputs using the defined SecurityUtils
- Implement proper authentication token handling
- Never store sensitive data in plain text
- Use secure storage for tokens and user credentials

## Error Handling and Debugging

### 13. Error Management
- Use the defined ErrorHandler class for consistent error messaging
- Implement proper try-catch blocks with meaningful error messages
- Log errors for debugging while maintaining user privacy
- Provide fallback UI states for error scenarios

### 14. Debugging Practices
- Use Flutter Inspector for widget debugging
- Implement proper logging levels (debug, info, warning, error)
- Use breakpoints effectively for complex logic debugging
- Test edge cases and error scenarios thoroughly

## Team Collaboration

### 15. Version Control
- Use `git-mcp` for managing commits and branches
- Write clear, descriptive commit messages
- Follow the team's branching strategy
- Review code changes before merging

### 16. Documentation
- Document complex logic and architectural decisions
- Use `allpepper-memory-bank` to store team knowledge
- Keep README and documentation files updated
- Comment non-obvious code sections

### 17. Code Reviews
- Follow the team's code review process
- Check for adherence to these rules and the context file
- Verify functionality against requirements
- Ensure code quality and maintainability

## Specific Implementation Rules

### 18. Models and Data Classes
```dart
// Always implement proper JSON serialization
class User {
  final int id;
  final String username;
  final String email;
  
  User({required this.id, required this.username, required this.email});
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }
}
```

### 19. Repository Pattern
```dart
// Always use the repository pattern for data access
class QuestionRepository {
  final QuestionDataSource _dataSource;
  
  QuestionRepository(this._dataSource);
  
  Future<List<Question>> getQuestions() async {
    try {
      final response = await _dataSource.getQuestions();
      return response.map((json) => Question.fromJson(json)).toList();
    } catch (e) {
      throw RepositoryException('Failed to fetch questions: ${e.toString()}');
    }
  }
}
```

### 20. Widget Structure
```dart
// Always separate logic from UI
class QuestionCard extends StatelessWidget {
  final Question question;
  final VoidCallback? onTap;
  
  const QuestionCard({Key? key, required this.question, this.onTap}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(question.title),
        subtitle: Text(question.description),
        onTap: onTap,
      ),
    );
  }
}
```

## Testing Requirements

### 21. Unit Testing
- Test all business logic and utility functions
- Mock external dependencies (APIs, databases)
- Test edge cases and error scenarios
- Maintain test coverage above 80%

### 22. Widget Testing
- Test user interactions and UI behavior
- Verify proper state management
- Test responsive layout behavior
- Mock providers and dependencies

### 23. Integration Testing
- Test complete user flows
- Verify API integration
- Test real-time features
- Test offline functionality

## Performance and Optimization

### 24. Build Optimization
- Use const constructors for immutable widgets
- Implement proper widget key usage
- Optimize list rendering with proper item builders
- Use lazy loading for large datasets

### 25. Memory Management
- Dispose controllers and streams properly
- Avoid memory leaks with proper subscription management
- Use efficient data structures
- Monitor memory usage in debug mode

### 26. Network Optimization
- Implement proper caching strategies
- Use pagination for large datasets
- Optimize API calls with batching
- Handle network failures gracefully

## Deployment and Production

### 27. Build Configuration
- Use environment-specific configurations
- Implement proper obfuscation for release builds
- Test builds on both debug and release modes
- Verify all dependencies are properly configured

### 28. Quality Assurance
- Run flutter analyze before committing
- Test on multiple screen sizes and orientations
- Verify accessibility features
- Test performance on lower-end devices

## Emergency Protocols

### 29. Critical Bug Handling
- Immediately document the issue with steps to reproduce
- Use `sequential-thinking` to analyze the root cause
- Implement hotfix following the established patterns
- Test thoroughly before deploying

### 30. Time Management
- Prioritize features based on the context file priorities
- Use time-boxing for complex features
- Implement MVP versions first, then enhance
- Communicate blockers immediately to the team

## Final Reminders

- Always reference `stackit_frontend_context.md` for project-specific guidelines
- Use MCP servers strategically for efficiency
- Never assume or hallucinate functionality
- Maintain code quality while meeting deadlines
- Document decisions and patterns for team consistency
- Test thoroughly and handle edge cases
- Follow the exact folder structure and naming conventions
- Implement proper error handling and user feedback