/**
 * Friend App - Real Backend with Database
 * Using SQLite (no setup needed) + JWT Auth
 */

import express from 'express';
import { createServer } from 'http';
import cors from 'cors';
import sqlite3 from 'sqlite3';
import bcryptjs from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const httpServer = createServer(app);
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret_key_change_this';

// Database setup
const db = new sqlite3.Database('./data/friend.db', (err) => {
    if (err) console.error('Database error:', err);
    else console.log('✅ SQLite database connected');
});

// Initialize database tables
db.serialize(() => {
    db.run(`
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            fullName TEXT,
            bio TEXT,
            profilePic TEXT,
            createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `);

    db.run(`
        CREATE TABLE IF NOT EXISTS activities (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER NOT NULL,
            type TEXT,
            title TEXT,
            duration INTEGER,
            mood TEXT,
            score INTEGER,
            date TEXT,
            createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(userId) REFERENCES users(id)
        )
    `);

    db.run(`
        CREATE TABLE IF NOT EXISTS goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER NOT NULL,
            title TEXT,
            description TEXT,
            category TEXT,
            target INTEGER,
            current INTEGER DEFAULT 0,
            deadline TEXT,
            createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(userId) REFERENCES users(id)
        )
    `);

    db.run(`
        CREATE TABLE IF NOT EXISTS messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            senderId INTEGER NOT NULL,
            receiverId INTEGER NOT NULL,
            message TEXT,
            createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(senderId) REFERENCES users(id),
            FOREIGN KEY(receiverId) REFERENCES users(id)
        )
    `);

    console.log('✅ Database tables initialized');
});

// Middleware
app.use(express.json());
app.use(cors({
    origin: ['http://localhost:3000', 'http://localhost:5173'],
    credentials: true
}));
app.use(express.static('public'));

// Auth Middleware
function verifyToken(req, res, next) {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ error: 'No token provided' });
    
    jwt.verify(token, JWT_SECRET, (err, decoded) => {
        if (err) return res.status(401).json({ error: 'Invalid token' });
        req.userId = decoded.id;
        next();
    });
}

// ==========================================
// AUTH ROUTES
// ==========================================

// Sign Up
app.post('/api/auth/signup', async (req, res) => {
    const { username, email, password, fullName } = req.body;
    
    if (!username || !email || !password) {
        return res.status(400).json({ error: 'Missing fields' });
    }

    try {
        const hashedPassword = await bcryptjs.hash(password, 10);

        db.run(
            'INSERT INTO users (username, email, password, fullName) VALUES (?, ?, ?, ?)',
            [username, email, hashedPassword, fullName],
            function(err) {
                if (err) {
                    if (err.message.includes('UNIQUE constraint failed')) {
                        return res.status(400).json({ error: 'Username or email already exists' });
                    }
                    return res.status(500).json({ error: 'Signup failed' });
                }

                const token = jwt.sign({ id: this.lastID }, JWT_SECRET, { expiresIn: '7d' });
                res.json({ 
                    success: true, 
                    token, 
                    user: { id: this.lastID, username, email, fullName }
                });
            }
        );
    } catch (error) {
        res.status(500).json({ error: 'Signup failed' });
    }
});

// Login
app.post('/api/auth/login', (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ error: 'Missing email or password' });
    }

    db.get('SELECT * FROM users WHERE email = ?', [email], async (err, user) => {
        if (err || !user) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        const isValidPassword = await bcryptjs.compare(password, user.password);
        if (!isValidPassword) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        const token = jwt.sign({ id: user.id }, JWT_SECRET, { expiresIn: '7d' });
        res.json({
            success: true,
            token,
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                fullName: user.fullName,
                bio: user.bio,
                profilePic: user.profilePic
            }
        });
    });
});

// Get Current User
app.get('/api/auth/me', verifyToken, (req, res) => {
    db.get('SELECT id, username, email, fullName, bio, profilePic FROM users WHERE id = ?', 
        [req.userId], (err, user) => {
        if (err || !user) {
            return res.status(404).json({ error: 'User not found' });
        }
        res.json(user);
    });
});

// ==========================================
// ACTIVITY ROUTES
// ==========================================

// Add Activity
app.post('/api/activities', verifyToken, (req, res) => {
    const { type, title, duration, mood, score, date } = req.body;

    db.run(
        'INSERT INTO activities (userId, type, title, duration, mood, score, date) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [req.userId, type, title, duration, mood, score, date],
        function(err) {
            if (err) return res.status(500).json({ error: 'Failed to add activity' });
            res.json({ success: true, id: this.lastID });
        }
    );
});

// Get User Activities
app.get('/api/activities', verifyToken, (req, res) => {
    db.all('SELECT * FROM activities WHERE userId = ? ORDER BY date DESC', [req.userId], (err, activities) => {
        if (err) return res.status(500).json({ error: 'Failed to fetch activities' });
        res.json(activities || []);
    });
});

// ==========================================
// GOALS ROUTES
// ==========================================

// Add Goal
app.post('/api/goals', verifyToken, (req, res) => {
    const { title, description, category, target, deadline } = req.body;

    db.run(
        'INSERT INTO goals (userId, title, description, category, target, deadline) VALUES (?, ?, ?, ?, ?, ?)',
        [req.userId, title, description, category, target, deadline],
        function(err) {
            if (err) return res.status(500).json({ error: 'Failed to create goal' });
            res.json({ success: true, id: this.lastID });
        }
    );
});

// Get User Goals
app.get('/api/goals', verifyToken, (req, res) => {
    db.all('SELECT * FROM goals WHERE userId = ? ORDER BY deadline', [req.userId], (err, goals) => {
        if (err) return res.status(500).json({ error: 'Failed to fetch goals' });
        res.json(goals || []);
    });
});

// ==========================================
// MESSAGES ROUTES
// ==========================================

// Send Message
app.post('/api/messages', verifyToken, (req, res) => {
    const { receiverId, message } = req.body;

    db.run(
        'INSERT INTO messages (senderId, receiverId, message) VALUES (?, ?, ?)',
        [req.userId, receiverId, message],
        function(err) {
            if (err) return res.status(500).json({ error: 'Failed to send message' });
            res.json({ success: true, id: this.lastID });
        }
    );
});

// Get Messages
app.get('/api/messages/:otherUserId', verifyToken, (req, res) => {
    const { otherUserId } = req.params;

    db.all(
        'SELECT * FROM messages WHERE (senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?) ORDER BY createdAt',
        [req.userId, otherUserId, otherUserId, req.userId],
        (err, messages) => {
            if (err) return res.status(500).json({ error: 'Failed to fetch messages' });
            res.json(messages || []);
        }
    );
});

// ==========================================
// HEALTH CHECK
// ==========================================

app.get('/health', (req, res) => {
    res.json({ status: 'ok', database: 'SQLite' });
});

app.get('/api/v1', (req, res) => {
    res.json({ 
        name: 'Friend App API',
        version: '1.0.0',
        auth: 'JWT Token Required',
        database: 'SQLite'
    });
});

// ==========================================
// START SERVER
// ==========================================

httpServer.listen(PORT, '0.0.0.0', () => {
    console.log(`
╔════════════════════════════════════════════╗
║     FRIEND APP - Backend Running! 🚀      ║
╚════════════════════════════════════════════╝

🌐 Server:     http://localhost:${PORT}
📊 Database:   SQLite (/data/friend.db)
🔐 Auth:       JWT Tokens
📚 API Docs:   http://localhost:${PORT}/api/v1

Available Routes:
  POST   /api/auth/signup      - Register
  POST   /api/auth/login       - Login
  GET    /api/auth/me          - Get current user
  POST   /api/activities       - Add activity
  GET    /api/activities       - Get activities
  POST   /api/goals            - Add goal
  GET    /api/goals            - Get goals
  POST   /api/messages         - Send message
  GET    /api/messages/:userId - Get messages

Ready! 📱
    `);
});

process.on('SIGINT', () => {
    db.close();
    process.exit(0);
});

export { app, httpServer };
