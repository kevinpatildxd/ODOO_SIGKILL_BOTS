# StackIt Frontend Context - Quick Navigation Guide
*Flutter Project Structure & Task-Based Navigation*

## 📁 Project Structure Overview

```
stackit_frontend/
├── lib/
│   ├── main.dart                    # 🚀 App entry point
│   ├── app.dart                     # 🏗️ Main app configuration
│   ├── config/                      # ⚙️ App configuration
│   ├── core/                        # 🧩 Core utilities & services
│   ├── data/                        # 📊 Data layer (models, repos)
│   └── presentation/                # 🎨 UI layer (screens, widgets)
├── pubspec.yaml                     # 📦 Dependencies
├── analysis_options.yaml           # 🔍 Linting rules
└── assets/                         # 🖼️ Images, fonts, etc.
```

## 🎯 Task-Based Navigation Guide

### 🚀 **App Startup & Configuration**
**Where to go:** `lib/main.dart`, `lib/app.dart`, `lib/config/`

```
📍 TASK: Configure app theme, routes, or global settings
├── lib/main.dart              # App initialization
├── lib/app.dart               # Root widget setup
├── lib/config/app_config.dart # API URLs, constants
├── lib/config/theme.dart      # Colors, text styles
└── lib/config/constants.dart  # App-wide constants
```

**Quick Reference:**
- **App constants:** `lib/config/app_config.dart`
- **Theme colors:** `lib/config/theme.dart`
- **Route setup:** `lib/presentation/routes/`

---

### 🔐 **Authentication Features**
**Where to go:** `lib/presentation/screens/auth/`, `lib/data/repositories/auth_repository.dart`

```
📍 TASK: Login, register, password reset functionality
├── lib/presentation/screens/auth/
│   ├── login_screen.dart          # Login UI
│   ├── register_screen.dart       # Registration UI
│   └── forgot_password_screen.dart # Password reset
├── lib/presentation/widgets/auth/
│   ├── login_form.dart            # Reusable login form
│   └── register_form.dart         # Reusable register form
├── lib/presentation/providers/auth_provider.dart  # Auth state
├── lib/data/repositories/auth_repository.dart     # Auth logic
└── lib/data/models/user_model.dart               # User data structure
```

**Quick Reference:**
- **Login UI:** `lib/presentation/screens/auth/login_screen.dart`
- **Auth state:** `lib/presentation/providers/auth_provider.dart`
- **User model:** `lib/data/models/user_model.dart`

---

### ❓ **Question Management**
**Where to go:** `lib/presentation/screens/question/`, `lib/presentation/screens/home/`

```
📍 TASK: Display, create, edit, search questions
├── lib/presentation/screens/home/
│   ├── home_screen.dart           # Main feed
│   ├── question_list_screen.dart  # Question listing
│   └── search_screen.dart         # Search functionality
├── lib/presentation/screens/question/
│   ├── question_detail_screen.dart # Single question view
│   ├── ask_question_screen.dart    # Create new question
│   └── edit_question_screen.dart   # Edit existing question
├── lib/presentation/widgets/question/
│   ├── question_card.dart          # Question list item
│   ├── question_form.dart          # Question creation form
│   ├── question_filters.dart       # Filter options
│   └── question_stats.dart         # Vote/view counts
├── lib/presentation/providers/question_provider.dart # Question state
└── lib/data/repositories/question_repository.dart   # Question logic
```

**Quick Reference:**
- **Question feed:** `lib/presentation/screens/home/home_screen.dart`
- **Ask question:** `lib/presentation/screens/question/ask_question_screen.dart`
- **Question card:** `lib/presentation/widgets/question/question_card.dart`

---

### 💬 **Answer Management**
**Where to go:** `lib/presentation/screens/answer/`, `lib/presentation/widgets/answer/`

```
📍 TASK: Display, create, edit answers and voting
├── lib/presentation/screens/answer/
│   ├── answer_screen.dart         # Answer creation
│   └── edit_answer_screen.dart    # Answer editing
├── lib/presentation/widgets/answer/
│   ├── answer_card.dart           # Individual answer display
│   ├── answer_form.dart           # Answer creation form
│   ├── answer_list.dart           # List of answers
│   └── vote_widget.dart           # Upvote/downvote buttons
├── lib/presentation/providers/answer_provider.dart   # Answer state
└── lib/data/repositories/answer_repository.dart     # Answer logic
```

**Quick Reference:**
- **Answer UI:** `lib/presentation/widgets/answer/answer_card.dart`
- **Voting:** `lib/presentation/widgets/answer/vote_widget.dart`
- **Answer state:** `lib/presentation/providers/answer_provider.dart`

---

### 🏷️ **Tag System**
**Where to go:** `lib/presentation/widgets/tag/`, `lib/data/repositories/tag_repository.dart`

```
📍 TASK: Tag display, selection, filtering
├── lib/presentation/widgets/tag/
│   ├── tag_chip.dart              # Individual tag display
│   ├── tag_selector.dart          # Tag selection widget
│   └── tag_list.dart              # Tag listing
├── lib/presentation/providers/tag_provider.dart     # Tag state
└── lib/data/repositories/tag_repository.dart       # Tag logic
```

**Quick Reference:**
- **Tag chips:** `lib/presentation/widgets/tag/tag_chip.dart`
- **Tag selection:** `lib/presentation/widgets/tag/tag_selector.dart`

---

### 🔔 **Notifications**
**Where to go:** `lib/presentation/widgets/notification/`, `lib/core/services/notification_service.dart`

```
📍 TASK: Real-time notifications, notification history
├── lib/presentation/widgets/notification/
│   ├── notification_card.dart     # Individual notification
│   ├── notification_list.dart     # Notification history
│   └── notification_badge.dart    # Notification counter
├── lib/core/services/notification_service.dart  # Notification logic
└── lib/data/repositories/notification_repository.dart # Notification data
```

**Quick Reference:**
- **Notification UI:** `lib/presentation/widgets/notification/notification_card.dart`
- **Notification service:** `lib/core/services/notification_service.dart`

---

### 👤 **User Profile**
**Where to go:** `lib/presentation/screens/profile/`

```
📍 TASK: User profile, user's questions/answers
├── lib/presentation/screens/profile/
│   ├── profile_screen.dart        # User profile view
│   ├── user_questions_screen.dart # User's questions
│   └── user_answers_screen.dart   # User's answers
```

**Quick Reference:**
- **Profile view:** `lib/presentation/screens/profile/profile_screen.dart`

---

### 🌐 **API Integration**
**Where to go:** `lib/core/network/`, `lib/data/datasources/`

```
📍 TASK: API calls, network configuration, error handling
├── lib/core/network/
│   ├── api_client.dart            # HTTP client setup
│   ├── api_endpoints.dart         # API URL endpoints
│   └── network_exceptions.dart    # Error handling
├── lib/data/datasources/
│   ├── auth_datasource.dart       # Auth API calls
│   ├── question_datasource.dart   # Question API calls
│   ├── answer_datasource.dart     # Answer API calls
│   └── [other]_datasource.dart    # Other API calls
```

**Quick Reference:**
- **API client:** `lib/core/network/api_client.dart`
- **API endpoints:** `lib/core/network/api_endpoints.dart`
- **Error handling:** `lib/core/network/network_exceptions.dart`

---

### 🔌 **Real-time Features**
**Where to go:** `lib/core/services/socket_service.dart`

```
📍 TASK: WebSocket connections, real-time updates
├── lib/core/services/socket_service.dart     # WebSocket management
└── lib/core/services/notification_service.dart # Real-time notifications
```

**Quick Reference:**
- **WebSocket:** `lib/core/services/socket_service.dart`
- **Real-time updates:** Integrated in respective providers

---

### 📝 **Rich Text Editor**
**Where to go:** `lib/presentation/widgets/editor/`

```
📍 TASK: Rich text editing for questions/answers
├── lib/presentation/widgets/editor/
│   ├── rich_text_editor.dart      # Main editor widget
│   ├── editor_toolbar.dart        # Editor controls
│   └── markdown_preview.dart      # Preview mode
```

**Quick Reference:**
- **Text editor:** `lib/presentation/widgets/editor/rich_text_editor.dart`

---

### 🎨 **Common UI Components**
**Where to go:** `lib/presentation/widgets/common/`

```
📍 TASK: Reusable UI components, loading states, navigation
├── lib/presentation/widgets/common/
│   ├── app_bar.dart               # Custom app bar
│   ├── bottom_navigation.dart     # Bottom navigation
│   ├── loading_widget.dart        # Loading indicators
│   ├── error_widget.dart          # Error displays
│   ├── empty_state_widget.dart    # Empty state UI
│   ├── pagination_widget.dart     # Pagination controls
│   └── search_bar.dart            # Search input
```

**Quick Reference:**
- **Loading states:** `lib/presentation/widgets/common/loading_widget.dart`
- **Error handling:** `lib/presentation/widgets/common/error_widget.dart`
- **Search:** `lib/presentation/widgets/common/search_bar.dart`

---

### 🗂️ **Data Models**
**Where to go:** `lib/data/models/`

```
📍 TASK: Data structures, JSON serialization
├── lib/data/models/
│   ├── user_model.dart            # User data structure
│   ├── question_model.dart        # Question data structure
│   ├── answer_model.dart          # Answer data structure
│   ├── vote_model.dart            # Vote data structure
│   ├── tag_model.dart             # Tag data structure
│   └── notification_model.dart    # Notification structure
```

**Quick Reference:**
- **User data:** `lib/data/models/user_model.dart`
- **Question data:** `lib/data/models/question_model.dart`

---

### 🔧 **Utilities & Helpers**
**Where to go:** `lib/core/utils/`

```
📍 TASK: Utility functions, validation, date formatting
├── lib/core/utils/
│   ├── validators.dart            # Input validation
│   ├── date_utils.dart            # Date formatting
│   ├── helpers.dart               # General utilities
│   └── error_handler.dart         # Error handling utils
```

**Quick Reference:**
- **Validation:** `lib/core/utils/validators.dart`
- **Date formatting:** `lib/core/utils/date_utils.dart`

---

### 🧭 **Navigation & Routing**
**Where to go:** `lib/presentation/routes/`

```
📍 TASK: App navigation, route management
├── lib/presentation/routes/
│   ├── app_routes.dart            # Route definitions
│   └── route_generator.dart       # Route generation logic
```

**Quick Reference:**
- **Route setup:** `lib/presentation/routes/app_routes.dart`
- **Navigation:** `lib/presentation/routes/route_generator.dart`

---

### 🔄 **State Management**
**Where to go:** `lib/presentation/providers/`

```
📍 TASK: App state, data flow, state updates
├── lib/presentation/providers/
│   ├── auth_provider.dart         # Authentication state
│   ├── question_provider.dart     # Question state
│   ├── answer_provider.dart       # Answer state
│   ├── vote_provider.dart         # Voting state
│   ├── tag_provider.dart          # Tag state
│   └── notification_provider.dart # Notification state
```

**Quick Reference:**
- **Auth state:** `lib/presentation/providers/auth_provider.dart`
- **Question state:** `lib/presentation/providers/question_provider.dart`

---

## 🚀 Quick Start Commands

### Development Setup
```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Build for release
flutter build apk --release

# Run tests
flutter test

# Analyze code
flutter analyze
```

### Code Generation
```bash
# Generate model classes (if using json_annotation)
flutter packages pub run build_runner build

# Clean and rebuild
flutter clean && flutter pub get
```

## 📋 Common Development Tasks

### 🔧 **Adding a New Feature**
1. **Model:** Create in `lib/data/models/`
2. **API:** Add datasource in `lib/data/datasources/`
3. **Repository:** Create in `lib/data/repositories/`
4. **Provider:** Add state management in `lib/presentation/providers/`
5. **UI:** Create screens in `lib/presentation/screens/`
6. **Widgets:** Add reusable components in `lib/presentation/widgets/`

### 🐛 **Debugging Issues**
1. **Network issues:** Check `lib/core/network/`
2. **State issues:** Check `lib/presentation/providers/`
3. **UI issues:** Check `lib/presentation/screens/` and `lib/presentation/widgets/`
4. **Data issues:** Check `lib/data/models/` and `lib/data/repositories/`

### 🎨 **UI/UX Updates**
1. **Theme changes:** `lib/config/theme.dart`
2. **New screens:** `lib/presentation/screens/`
3. **Reusable components:** `lib/presentation/widgets/common/`
4. **Specific widgets:** `lib/presentation/widgets/[feature]/`

### 🔌 **API Integration**
1. **Add endpoint:** `lib/core/network/api_endpoints.dart`
2. **Create datasource:** `lib/data/datasources/`
3. **Update repository:** `lib/data/repositories/`
4. **Update provider:** `lib/presentation/providers/`

## 📱 Key Dependencies

```yaml
# pubspec.yaml essentials
dependencies:
  flutter:
    sdk: flutter
  dio:                     # HTTP client
  provider:             # State management
  socket_io_client:  # WebSocket client
  shared_preferences:   # Local storage
  flutter_quill:        # Rich text editor
  go_router:         # Navigation
  json_annotation:       # JSON serialization
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: 
  json_serializable: 
  flutter_lints: 
```

## 🎯 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │   Screens    │  │   Widgets    │  │      Providers       │   │
│  │              │  │              │  │   (State Mgmt)       │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATA LAYER                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │ Repositories │  │ Datasources  │  │       Models         │   │
│  │              │  │  (API Calls) │  │   (Data Structures)  │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      CORE LAYER                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │   Network    │  │   Services   │  │       Utils          │   │
│  │  (API Setup) │  │  (Business)  │  │    (Helpers)         │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

*This context file provides a task-oriented navigation guide for the StackIt Flutter frontend. Use the "Where to go" sections to quickly locate files for specific development tasks.*