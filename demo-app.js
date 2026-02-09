/**
 * Friend App - Full Stack Demo
 * Express server with Frontend HTML
 */

import express from 'express';
import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = 3000;

// Middleware
app.use(express.json());
app.use(express.static('public'));

// Mock data
const mockUsers = [
  { id: 1, name: 'Arun Kumar', username: 'arun', email: 'arun@friend.app', bio: 'Engineering Student', profilePic: '😊' },
  { id: 2, name: 'Priya Singh', username: 'priya', email: 'priya@friend.app', bio: 'Designer & Photographer', profilePic: '🎨' },
  { id: 3, name: 'Raj Patel', username: 'raj', email: 'raj@friend.app', bio: 'Full Stack Developer', profilePic: '💻' },
];

const mockFriends = [
  { id: 1, name: 'Priya Singh', status: 'online', profilePic: '🎨' },
  { id: 2, name: 'Raj Patel', status: 'offline', profilePic: '💻' },
  { id: 3, name: 'Maya Verma', status: 'online', profilePic: '📚' },
];

const mockChats = [
  { id: 1, name: 'Priya Singh', lastMessage: 'Project deadline क्या है?', time: '5 min ago', unread: 2, profilePic: '🎨' },
  { id: 2, name: 'Study Group', lastMessage: 'Meeting tomorrow 6 PM', time: '1 hour ago', unread: 0, profilePic: '👥' },
  { id: 3, name: 'Raj Patel', lastMessage: 'Code review done!', time: '2 hours ago', unread: 0, profilePic: '💻' },
];

const mockMessages = [
  { id: 1, sender: 'Priya Singh', message: 'Hi! कैसे हो?', time: '10:30 AM', isMine: false },
  { id: 2, sender: 'You', message: 'बहुत अच्छा! तुम कैसी हो?', time: '10:32 AM', isMine: true },
  { id: 3, sender: 'Priya Singh', message: 'Project deadline क्या है?', time: '10:35 AM', isMine: false },
  { id: 4, sender: 'You', message: 'Friday को submit करना है', time: '10:36 AM', isMine: true },
];

const mockNotes = [
  { id: 1, title: 'JavaScript Tips', content: 'Async/await का सही use करो', author: 'Raj Patel', likes: 24, saves: 12, profilePic: '💻' },
  { id: 2, title: 'Study Tips', content: 'रोज 2 घंटे consistent study करो', author: 'Priya Singh', likes: 45, saves: 28, profilePic: '🎨' },
  { id: 3, title: 'Web Design Trends', content: 'Dark mode को prefer किया जा रहा है', author: 'You', likes: 18, saves: 8, profilePic: '😊' },
];

const mockActivities = [
  { type: 'study', title: 'JavaScript Study', duration: '2 hours', date: 'Today', mood: '😊', score: 8 },
  { type: 'exercise', title: 'Morning Run', duration: '30 mins', date: 'Today', mood: '💪', score: 7 },
  { type: 'reading', title: 'React Documentation', duration: '1 hour', date: 'Yesterday', mood: '🤓', score: 9 },
];

// API Routes
app.get('/api/user', (req, res) => {
  res.json({
    id: 1,
    name: 'Arun Kumar',
    username: 'arun',
    email: 'arun@friend.app',
    profilePic: '😊',
    bio: 'Engineering Student | Developer | Coffee Lover ☕',
    joinDate: 'Jan 2024',
    stats: {
      friends: 156,
      notes: 24,
      activities: 89,
    }
  });
});

app.get('/api/friends', (req, res) => {
  res.json(mockFriends);
});

app.get('/api/chats', (req, res) => {
  res.json(mockChats);
});

app.get('/api/messages/:chatId', (req, res) => {
  res.json(mockMessages);
});

app.get('/api/notes', (req, res) => {
  res.json(mockNotes);
});

app.get('/api/activities', (req, res) => {
  res.json(mockActivities);
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Friend App is running! 🚀' });
});

// Serve frontend
app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════╗
║     FRIEND APP - Demo Running! 🎉         ║
╚════════════════════════════════════════════╝

🌐 Open your browser: http://localhost:3000

Features:
  ✓ User Dashboard
  ✓ Friends List
  ✓ Chat Interface
  ✓ Notes Feed
  ✓ Activity Tracker
  ✓ Real-time Updates

Press Ctrl+C to stop
  `);
});

export default app;
