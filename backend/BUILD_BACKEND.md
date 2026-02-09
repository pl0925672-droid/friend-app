// Backend Starter Code

// ============================================
// src/models/User.js (Sequelize ORM)
// ============================================

const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const User = sequelize.define('User', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    email: {
      type: DataTypes.STRING(255),
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true,
      },
    },
    username: {
      type: DataTypes.STRING(100),
      allowNull: false,
      unique: true,
      validate: {
        len: [3, 20],
      },
    },
    password_hash: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    full_name: {
      type: DataTypes.STRING(255),
    },
    profile_photo_url: {
      type: DataTypes.TEXT,
    },
    study_focus: {
      type: DataTypes.STRING(100),
    },
    bio: {
      type: DataTypes.TEXT,
    },
    is_online: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    last_seen_at: {
      type: DataTypes.DATE,
    },
    is_verified: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
    is_deleted: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    preferences: {
      type: DataTypes.JSONB,
      defaultValue: {
        theme: 'light',
        notifications: true,
      },
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    updated_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
      onUpdate: DataTypes.NOW,
    },
    deleted_at: {
      type: DataTypes.DATE,
    },
  }, {
    tableName: 'users',
    timestamps: false,
    underscored: true,
  });

  User.associate = (models) => {
    User.hasMany(models.Message, {
      foreignKey: 'from_user_id',
      as: 'sentMessages',
    });
    User.hasMany(models.Note, {
      foreignKey: 'author_id',
      as: 'notes',
    });
    User.hasMany(models.DailyActivity, {
      foreignKey: 'user_id',
      as: 'activities',
    });
  };

  return User;
};


// ============================================
// src/services/authService.js
// ============================================

const bcrypt = require('bcryptjs');
const JWTService = require('../config/jwt');
const { User } = require('../models');
const redis = require('../config/redis');

class AuthService {
  static async signup(email, password, username, fullName, studyFocus) {
    // Check if email exists
    const existingEmail = await User.findOne({ where: { email } });
    if (existingEmail) {
      const error = new Error('Email already exists');
      error.statusCode = 400;
      throw error;
    }

    // Check if username exists
    const existingUsername = await User.findOne({ where: { username } });
    if (existingUsername) {
      const error = new Error('Username already exists');
      error.statusCode = 400;
      throw error;
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 12);

    // Create user
    const user = await User.create({
      email,
      username,
      password_hash: passwordHash,
      full_name: fullName,
      study_focus: studyFocus,
      is_verified: false,
    });

    // Generate verification code
    const verificationCode = Math.random().toString().slice(2, 8);
    await redis.setex(
      `verify:${email}`,
      3600, // 1 hour
      verificationCode
    );

    // TODO: Send verification email

    return {
      success: true,
      message: 'Account created. Check your email.',
      user: user.toJSON(),
    };
  }

  static async login(email, password) {
    // Find user
    const user = await User.findOne({ where: { email } });
    if (!user) {
      const error = new Error('Invalid email or password');
      error.statusCode = 401;
      throw error;
    }

    // Verify password
    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid) {
      const error = new Error('Invalid email or password');
      error.statusCode = 401;
      throw error;
    }

    // Check verification
    if (!user.is_verified) {
      const error = new Error('Email not verified');
      error.statusCode = 401;
      throw error;
    }

    // Generate tokens
    const accessToken = JWTService.generateAccessToken({
      userId: user.id,
      email: user.email,
    });

    const refreshToken = JWTService.generateRefreshToken({
      userId: user.id,
    });

    // Store refresh token in Redis
    await redis.setex(
      `refresh:${user.id}`,
      7 * 24 * 3600, // 7 days
      refreshToken
    );

    // Update last seen
    user.last_seen_at = new Date();
    await user.save();

    // Set online status
    await redis.setex(`online:${user.id}`, 300, 'true');

    return {
      user: user.toJSON(),
      token: {
        accessToken,
        refreshToken,
        expiresIn: 86400,
      },
    };
  }

  static async refreshToken(refreshToken) {
    // Verify token
    const decoded = JWTService.verifyRefreshToken(refreshToken);

    // Check in Redis
    const storedToken = await redis.get(`refresh:${decoded.userId}`);
    if (storedToken !== refreshToken) {
      const error = new Error('Refresh token revoked');
      error.statusCode = 401;
      throw error;
    }

    // Get user
    const user = await User.findByPk(decoded.userId);
    if (!user) {
      const error = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }

    // Generate new access token
    const newAccessToken = JWTService.generateAccessToken({
      userId: user.id,
      email: user.email,
    });

    return {
      accessToken: newAccessToken,
      refreshToken,
      expiresIn: 86400,
    };
  }
}

module.exports = AuthService;


// ============================================
// src/routes/auth.js
// ============================================

const express = require('express');
const router = express.Router();
const AuthService = require('../services/authService');
const { validateSignup, validateLogin } = require('../middleware/validation');

// Signup
router.post('/signup', validateSignup, async (req, res, next) => {
  try {
    const { email, password, username, fullName, studyFocus } = req.body;
    const result = await AuthService.signup(
      email,
      password,
      username,
      fullName,
      studyFocus
    );
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
});

// Login
router.post('/login', validateLogin, async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const result = await AuthService.login(email, password);
    res.status(200).json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
});

// Refresh Token
router.post('/refresh', async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(400).json({ error: 'Refresh token required' });
    }
    const result = await AuthService.refreshToken(refreshToken);
    res.status(200).json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
});

module.exports = router;


// ============================================
// src/middleware/validation.js
// ============================================

const joi = require('joi');

const validateSignup = (req, res, next) => {
  const schema = joi.object({
    email: joi.string().email().required(),
    password: joi
      .string()
      .min(8)
      .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/) // min 8, 1 uppercase, 1 lowercase, 1 number
      .required(),
    username: joi.string().alphanum().min(3).max(20).required(),
    fullName: joi.string().required(),
    studyFocus: joi.string().optional(),
  });

  const { error, value } = schema.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  
  req.body = value;
  next();
};

const validateLogin = (req, res, next) => {
  const schema = joi.object({
    email: joi.string().email().required(),
    password: joi.string().required(),
  });

  const { error, value } = schema.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  
  req.body = value;
  next();
};

module.exports = {
  validateSignup,
  validateLogin,
};


// ============================================
// src/config/redis.js
// ============================================

const redis = require('redis');

const client = redis.createClient({
  url: process.env.REDIS_URL || 'redis://localhost:6379',
});

client.on('error', (err) => {
  console.error('Redis Client Error:', err);
});

client.connect().catch(console.error);

module.exports = client;


// ============================================
// src/config/database.js
// ============================================

const { Sequelize } = require('sequelize');

const sequelize = new Sequelize(process.env.DATABASE_URL, {
  logging: console.log,
  ssl: true,
  dialectOptions: {
    ssl: {
      require: true,
      rejectUnauthorized: false,
    },
  },
});

module.exports = sequelize;


// ============================================
// src/socket/index.js (Socket.io Setup)
// ============================================

const socketIo = require('socket.io');
const JWTService = require('../config/jwt');

const setupSocket = (server) => {
  const io = socketIo(server, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST'],
    },
  });

  // Middleware: Authenticate socket
  io.use((socket, next) => {
    const token = socket.handshake.auth.token;
    try {
      const decoded = JWTService.verifyAccessToken(token);
      socket.userId = decoded.userId;
      socket.email = decoded.email;
      next();
    } catch (err) {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`User ${socket.userId} connected`);

    // Join user's room
    socket.join(`user:${socket.userId}`);

    // Send message
    socket.on('message_send', (data) => {
      // Validate and save message
      io.to(`chat:${data.chatRoomId}`).emit('message_received', {
        ...data,
        fromUserId: socket.userId,
        createdAt: new Date(),
      });
    });

    // User typing
    socket.on('user_typing', (data) => {
      socket.to(`chat:${data.chatRoomId}`).emit('user_typing', {
        userId: socket.userId,
        chatRoomId: data.chatRoomId,
      });
    });

    // Disconnect
    socket.on('disconnect', () => {
      console.log(`User ${socket.userId} disconnected`);
    });
  });

  return io;
};

module.exports = setupSocket;
