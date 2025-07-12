# StackIt Backend

Node.js REST API with Socket.io for real-time features.

## Setup
1. Install dependencies: 
pm install
2. Set up environment variables: cp .env.example .env
3. Set up PostgreSQL database
4. Run migrations: 
pm run migrate
5. Start development server: 
pm run dev

## API Endpoints
- /api/auth - Authentication
- /api/questions - Question management
- /api/answers - Answer management
- /api/votes - Voting system
- /api/tags - Tag management
- /api/notifications - Notification system

## Real-time Features
- WebSocket connections via Socket.io
- Real-time voting updates
- Live notifications
- Question/Answer updates
