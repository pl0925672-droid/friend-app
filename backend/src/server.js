/**
 * Friend App - Main Server Entry Point
 * Initializes Express server and WebSocket
 */

import express from 'express';
import { createServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import compression from 'compression';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

// Load environment variables
dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const httpServer = createServer(app);
const io = new SocketIOServer(httpServer, {
  cors: {
    origin: process.env.CORS_ORIGIN?.split(',') || ['http://localhost:3000'],
    credentials: true,
  },
  transports: ['websocket', 'polling'],
});

const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';

// ========================================
// MIDDLEWARE
// ========================================

// Security middleware
app.use(helmet());
app.use(compression());

// CORS
app.use(cors({
  origin: process.env.CORS_ORIGIN?.split(',') || ['http://localhost:3000'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Body parsing
app.use(express.json({ limit: process.env.FILE_UPLOAD_LIMIT || '50mb' }));
app.use(express.urlencoded({ limit: process.env.FILE_UPLOAD_LIMIT || '50mb', extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'),
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});

if (process.env.RATE_LIMIT_ENABLED !== 'false') {
  app.use('/api/', limiter);
}

// ========================================
// ROUTES
// ========================================

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: NODE_ENV,
  });
});

// API version
app.get('/api/v1', (req, res) => {
  res.json({
    name: 'Friend App API',
    version: '1.0.0',
    environment: NODE_ENV,
    documentation: 'http://localhost:3000/api-docs',
  });
});

// Status endpoint
app.get('/status', (req, res) => {
  res.json({
    status: 'online',
    service: 'friend-api',
    timestamp: new Date().toISOString(),
  });
});

// API documentation placeholder
app.get('/api-docs', (req, res) => {
  res.json({
    message: 'API Documentation',
    note: 'See PROJECT_DOCUMENTATION/03_API_ENDPOINTS.md for full API specification',
    endpoints: {
      auth: '/api/v1/auth',
      users: '/api/v1/users',
      friends: '/api/v1/friends',
      chat: '/api/v1/chat',
      notes: '/api/v1/notes',
      activities: '/api/v1/activities',
      goals: '/api/v1/goals',
      notifications: '/api/v1/notifications',
    },
  });
});

// Default 404 handler
app.use((req, res) => {
  res.status(404).json({
    status: 'error',
    message: 'Endpoint not found',
    path: req.path,
    method: req.method,
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    status: 'error',
    message: err.message || 'Internal Server Error',
    ...(NODE_ENV === 'development' && { stack: err.stack }),
  });
});

// ========================================
// WEBSOCKET SETUP
// ========================================

io.on('connection', (socket) => {
  console.log(`[WebSocket] Client connected: ${socket.id}`);

  // Socket.io handlers will be implemented in production
  socket.on('disconnect', () => {
    console.log(`[WebSocket] Client disconnected: ${socket.id}`);
  });

  // Example: message event
  socket.on('message', (data) => {
    console.log(`[WebSocket] Message received:`, data);
    socket.broadcast.emit('message', data);
  });
});

// ========================================
// SERVER STARTUP
// ========================================

httpServer.listen(PORT, '0.0.0.0', () => {
  console.log(`
╔════════════════════════════════════════════╗
║        Friend App API Server              ║
║        Status: Running ✓                  ║
╚════════════════════════════════════════════╝

📍 Server:     http://0.0.0.0:${PORT}
🔧 Environment: ${NODE_ENV}
📚 Docs:       http://localhost:${PORT}/api-docs
🏥 Health:     http://localhost:${PORT}/health

WebSocket:     Ready
Database:      Connecting...
Redis:         Connecting...

Ready to accept connections 🚀
  `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully...');
  httpServer.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully...');
  httpServer.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

export { app, httpServer, io };
