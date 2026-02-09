# Getting Started - Development Setup Guide

## 🚀 Quick Start (Local Development)

### Prerequisites
```
- Node.js 18+ (LTS)
- PostgreSQL 13+
- Redis 6+
- Flutter 3.0+ (for mobile)
- Git
- Docker & Docker Compose (optional)
```

---

## ⚡ Option 1: Docker Setup (Recommended)

### 1. Clone/Initialize Repository
```bash
cd friend
mkdir -p backend frontend database_schema
```

### 2. Create docker-compose.yml
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: friend_postgres
    environment:
      POSTGRES_USER: frienduser
      POSTGRES_PASSWORD: friendpass123
      POSTGRES_DB: friend_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U frienduser"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: friend_redis
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: friend_api
    environment:
      NODE_ENV: development
      DATABASE_URL: postgres://frienduser:friendpass123@postgres:5432/friend_db
      REDIS_URL: redis://redis:6379
      JWT_SECRET: your_jwt_secret_here_change_in_production
      JWT_REFRESH_SECRET: your_refresh_secret_here_change_in_production
    ports:
      - "3000:3000"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ./backend:/app
      - /app/node_modules
    command: npm run dev

volumes:
  postgres_data:
```

### 3. Start Services
```bash
docker-compose up -d

# Check logs
docker-compose logs -f api

# Access services
# PostgreSQL: localhost:5432 (psql -U frienduser -h localhost -d friend_db)
# Redis: localhost:6379 (redis-cli)
# API: http://localhost:3000
```

---

## 🛠️ Option 2: Manual Setup

### Backend Setup

#### 1. Initialize Node.js Project
```bash
cd backend
npm init -y

# Core dependencies
npm install express cors helmet dotenv morgan uuid
npm install pg redis socket.io bull

# Authentication
npm install jsonwebtoken bcryptjs passport passport-jwt

# Database
npm install sequelize sequelize-cli
npm install pg pg-hstore

# Validation
npm install joi class-validator class-transformer
npm install express-validator

# File upload
npm install multer sharp

# Error tracking & logging
npm install winston sentry-node

# Development
npm install --save-dev nodemon jest supertest
npm install --save-dev @types/node
```

#### 2. Create .env File
```env
# Server
NODE_ENV=development
PORT=3000
API_URL=http://localhost:3000

# Database
DATABASE_URL=postgres://frienduser:friendpass123@localhost:5432/friend_db
DB_HOST=localhost
DB_PORT=5432
DB_NAME=friend_db
DB_USER=frienduser
DB_PASSWORD=friendpass123

# Redis
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=your_super_secret_jwt_key_change_in_production
JWT_REFRESH_SECRET=your_refresh_secret_key
JWT_EXPIRY=24h
JWT_REFRESH_EXPIRY=7d

# Firebase (for file upload & push notifications)
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com
FIREBASE_API_KEY=your_api_key

# OpenAI (for AI features)
OPENAI_API_KEY=your_openai_api_key

# Email Service
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password

# Sentry
SENTRY_DSN=your_sentry_dsn

# Logging
LOG_LEVEL=debug
```

#### 3. Create Server File (src/app.js)
```javascript
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const app = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/api/v1/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date() });
});

// Routes placeholder
app.use('/api/v1/auth', require('./routes/auth'));
app.use('/api/v1/users', require('./routes/users'));
app.use('/api/v1/friends', require('./routes/friends'));
app.use('/api/v1/chats', require('./routes/chats'));
app.use('/api/v1/notes', require('./routes/notes'));
app.use('/api/v1/activities', require('./routes/activities'));
app.use('/api/v1/analytics', require('./routes/analytics'));

// 404 Handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Error Handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.statusCode || 500).json({
    error: {
      message: err.message,
      statusCode: err.statusCode || 500
    }
  });
});

module.exports = app;
```

#### 4. Create Server Entry (src/server.js)
```javascript
const http = require('http');
const app = require('./app');
const socketIoSetup = require('./socket');

const PORT = process.env.PORT || 3000;
const server = http.createServer(app);

// Setup Socket.io
socketIoSetup(server);

server.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
```

#### 5. Create package.json scripts
```json
{
  "scripts": {
    "start": "node src/server.js",
    "dev": "nodemon src/server.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "db:migrate": "sequelize-cli db:migrate",
    "db:seed": "sequelize-cli db:seed:all"
  }
}
```

### Frontend Setup

#### 1. Create Flutter Project
```bash
cd frontend
flutter create friend --org com.friendapp
cd friend
```

#### 2. Update pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.0.0
  riverpod: ^2.0.0
  
  # HTTP & WebSocket
  dio: ^5.0.0
  socket_io_client: ^2.0.0
  
  # Local Storage
  shared_preferences: ^2.0.0
  hive: ^2.2.0
  secure_storage: ^1.0.0 # flutter_secure_storage for iOS/Android
  
  # Navigation
  go_router: ^6.0.0
  
  # UI & Themes
  google_fonts: ^4.0.0
  flutter_svg: ^2.0.0
  
  # Date & Time
  intl: ^0.18.0
  
  # Image Processing
  image_picker: ^0.8.0
  image_compress: ^1.0.0
  cached_network_image: ^3.2.0
  
  # Notifications
  firebase_messaging: ^14.0.0
  flutter_local_notifications: ^14.0.0
  
  # Charts
  fl_chart: ^0.60.0
  charts_flutter: ^0.12.0
  
  # Rich Text Editor
  flutter_quill: ^8.0.0
  
  # Analytics
  firebase_analytics: ^10.0.0
  sentry_flutter: ^7.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
  mockito: ^5.3.0
  bloc_test: ^9.0.0
```

#### 3. Create Main App File (lib/main.dart)
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase, local storage, analytics, etc.
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Add other providers here
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'Friend App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
```

---

## 🗄️ Database Setup

### 1. Create PostgreSQL Database
```bash
# Using command line
psql -U postgres -c "CREATE USER frienduser WITH PASSWORD 'friendpass123';"
psql -U postgres -c "CREATE DATABASE friend_db OWNER frienduser;"

# Or using Docker
docker exec friend_postgres psql -U postgres -c "CREATE USER frienduser WITH PASSWORD 'friendpass123';"
docker exec friend_postgres psql -U postgres -c "CREATE DATABASE friend_db OWNER frienduser;"
```

### 2. Run Database Schema
```bash
# Create tables (copy from 05_COMPLETE_DATABASE_SCHEMA.md and run)
psql -U frienduser -h localhost -d friend_db -f database_schema.sql
```

### 3. Create Database Migration
```bash
cd backend
npx sequelize-cli init
npx sequelize-cli model:generate --name User --attributes email:string,username:string,passwordHash:string,fullName:string

# Run migrations
npm run db:migrate
```

---

## 🔐 Authentication Setup

### 1. JWT Configuration
```javascript
// src/config/jwt.js
const jwt = require('jsonwebtoken');

class JWTService {
  static generateAccessToken(payload) {
    return jwt.sign(payload, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRY || '24h'
    });
  }

  static generateRefreshToken(payload) {
    return jwt.sign(payload, process.env.JWT_REFRESH_SECRET, {
      expiresIn: process.env.JWT_REFRESH_EXPIRY || '7d'
    });
  }

  static verifyAccessToken(token) {
    try {
      return jwt.verify(token, process.env.JWT_SECRET);
    } catch (err) {
      throw new Error('Invalid token');
    }
  }

  static verifyRefreshToken(token) {
    try {
      return jwt.verify(token, process.env.JWT_REFRESH_SECRET);
    } catch (err) {
      throw new Error('Invalid refresh token');
    }
  }
}

module.exports = JWTService;
```

### 2. Authentication Middleware
```javascript
// src/middleware/auth.js
const JWTService = require('../config/jwt');

const authMiddleware = (req, res, next) => {
  const token = req.headers.authorization?.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  try {
    const decoded = JWTService.verifyAccessToken(token);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
};

module.exports = authMiddleware;
```

---

## 📱 Mobile Setup

### Flutter Folder Structure
```
lib/
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── config/
│   ├── routes.dart
│   ├── theme.dart
│   └── constants.dart
├── models/
│   ├── user_model.dart
│   ├── message_model.dart
│   └── ...
├── providers/
│   ├── auth_provider.dart
│   ├── chat_provider.dart
│   └── ...
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── ...
│   ├── dashboard/
│   ├── chat/
│   ├── friends/
│   └── ...
├── services/
│   ├── api_service.dart
│   ├── notification_service.dart
│   └── ...
├── widgets/
│   ├── common/
│   ├── chat/
│   └── ...
└── main.dart
```

### Run Mobile App
```bash
cd frontend
flutter pub get
flutter run # Development
flutter run --release # Production
```

---

## 🧪 Testing

### Backend Unit Tests
```bash
cd backend
npm test

# With coverage
npm run test:coverage
```

### Example Test File (src/services/auth.test.js)
```javascript
const bcrypt = require('bcryptjs');
const JWTService = require('../config/jwt');
const AuthService = require('../services/authService');

describe('AuthService', () => {
  describe('signup', () => {
    it('should create new user', async () => {
      const result = await AuthService.signup(
        'test@example.com',
        'TestPass123!',
        'testuser',
        'Test User'
      );

      expect(result.success).toBe(true);
      expect(result.user.email).toBe('test@example.com');
    });

    it('should reject duplicate email', async () => {
      expect(() => AuthService.signup(
        'existing@example.com',
        'Pass123!',
        'newuser',
        'New User'
      )).rejects.toThrow('Email already exists');
    });
  });
});
```

---

## 🚀 Deployment

### Build Docker Image
```bash
# Create Dockerfile in backend/
docker build -t friend-api:1.0.0 .
docker run -p 3000:3000 --env-file .env friend-api:1.0.0
```

### Deploy to AWS EC2
```bash
# 1. SSH into instance
ssh -i key.pem ubuntu@your-instance-ip

# 2. Clone repository
git clone https://github.com/youruser/friend-app.git
cd friend-app

# 3. Setup environment
cp .env.example .env
# Edit .env with production values

# 4. Start with Docker Compose
docker-compose up -d

# 5. Setup SSL with Let's Encrypt
sudo apt install certbot python3-certbot-nginx
sudo certbot certonly --standalone -d yourdomain.com
```

### Mobile Build & Release

**Android:**
```bash
flutter build apk --release
# or
flutter build appbundle --release

# Upload to Google Play Console
```

**iOS:**
```bash
flutter build ios --release
# Archive in Xcode
# Upload to App Store Connect
```

---

## 📝 File Checklist

Before launch, ensure these files exist:

**Backend**
- [ ] src/app.js
- [ ] src/server.js
- [ ] src/config/jwt.js
- [ ] src/config/database.js
- [ ] src/middleware/auth.js
- [ ] src/models/User.js
- [ ] src/services/authService.js
- [ ] src/routes/auth.js
- [ ] .env
- [ ] docker-compose.yml
- [ ] Dockerfile
- [ ] package.json

**Frontend**
- [ ] lib/main.dart
- [ ] lib/config/routes.dart
- [ ] lib/config/theme.dart
- [ ] lib/providers/auth_provider.dart
- [ ] lib/screens/auth/login_screen.dart
- [ ] lib/services/api_service.dart
- [ ] pubspec.yaml

**Documentation**
- [ ] 01_ARCHITECTURE_OVERVIEW.md
- [ ] 02_TECH_STACK_RECOMMENDATION.md
- [ ] 03_API_ENDPOINTS.md
- [ ] 04_UI_UX_SPECIFICATIONS.md
- [ ] 05_FEATURE_SPECIFICATIONS.md
- [ ] 06_FUTURE_ROADMAP.md
- [ ] README.md (getting started guide)

---

## 🆘 Troubleshooting

### Issue: PostgreSQL Connection Refused
```bash
# Check if PostgreSQL is running
sudo service postgresql status

# Restart PostgreSQL
sudo service postgresql restart

# Check connection
psql -U frienduser -h localhost -d friend_db
```

### Issue: Redis Connection Failed
```bash
# Check Redis status
redis-cli ping
# Should return: PONG

# Restart Redis
sudo service redis-server restart
```

### Issue: Node modules Issues
```bash
rm -rf node_modules package-lock.json
npm install
```

### Issue: Flutter Dependencies
```bash
flutter pub get
flutter pub upgrade
flutter clean
flutter pub get
```

---

## 📚 Next Steps

1. **Fork/Clone** this repository
2. **Setup** local environment using Docker (recommended)
3. **Create** Firebase project (for storage & notifications)
4. **Configure** .env with your credentials
5. **Run** `docker-compose up -d`
6. **Test** API: `curl http://localhost:3000/api/v1/health`
7. **Start** developing features!

Refer to individual feature documentation for implementation details.

Happy coding! 🚀
