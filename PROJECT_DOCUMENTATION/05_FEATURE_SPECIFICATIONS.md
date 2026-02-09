# Feature Specifications & Core Logic Flow

## 🔐 Feature 1: Authentication & User System

### Feature Specification

**Signup Flow**
```
User Input → Form Validation → Email Verification → Profile Setup → Dashboard

Steps:
1. User enters email, password, username, full name
2. Form validation:
   - Email format valid (RFC 5322)
   - Password strong (min 8 chars, uppercase, number, symbol)
   - Username unique and alphanumeric (3-20 chars)
   - Full name not empty
3. Backend check:
   - Email doesn't exist in database
   - Username doesn't exist
4. Create user record:
   - Hash password with bcrypt (salt rounds: 12)
   - Store user in PostgreSQL
   - Create default settings in preferences JSON
5. Send verification email with code
6. User enters verification code
7. Mark email as verified
8. Generate JWT tokens (access + refresh)
9. Redirect to profile setup (optional study focus)
10. Store tokens in secure storage
11. Redirect to dashboard
```

**Login Flow**
```
Credentials → Database Check → Token Generation → Secure Storage

Steps:
1. User enters email & password
2. Find user by email in database
3. Compare entered password with stored hash
   - Use bcryptjs.compare()
   - Return 401 if mismatch
4. Check email verification status
   - Return 401 if not verified
5. Check account active status
   - Return 403 if disabled
6. Generate tokens:
   - Access Token (JWT, 24-hour expiry)
   - Refresh Token (JWT, 7-day expiry)
7. Store refresh token in Redis with TTL
8. Store tokens in mobile secure storage
   - Flutter: flutter_secure_storage
   - Encrypt tokens at rest
9. Update user's last_seen_at timestamp
10. Set user online status in Redis
11. Fetch user profile and return
12. Connect to WebSocket for real-time updates
```

**Password Reset Flow**
```
Email → Verification Code → New Password → Confirm

Steps:
1. User requests password reset with email
2. Check if user exists
   - Return success for security (don't leak user existence)
3. Generate reset token (6-digit code or JWT)
4. Store token with expiry (15 minutes) in Redis
   - Key: reset_token:${email}
   - Value: hash(token)
5. Send email with reset link/code
6. User clicks link or enters code
7. Validate token hasn't expired
8. User enters new password
9. Validate password strength
10. Hash new password
11. Update user password in database
12. Invalidate all existing sessions
13. Delete reset token
14. Send confirmation email
15. Redirect to login
```

**Token Refresh Flow**
```
Expired Access Token → Refresh Token → New Access Token

Steps:
1. API request returns 401 (token expired)
2. Client extracts refresh token from storage
3. Send refresh request with refresh token
4. Backend validates refresh token:
   - Verify JWT signature
   - Check expiry time
   - Check if in Redis (not revoked)
5. Generate new access token
6. Return new token pair
7. Client stores new tokens
8. Retry original request with new token
9. If refresh token also expired → Logout user
```

### Code Logic (Node.js Example)

```javascript
// authService.js
class AuthService {
  async signup(email, password, username, fullName, studyFocus) {
    // 1. Validation
    this.validateEmail(email);
    this.validatePassword(password);
    this.validateUsername(username);
    
    // 2. Check existence
    const existingEmail = await User.findOne({ email });
    if (existingEmail) throw new Error('Email already exists');
    
    const existingUser = await User.findOne({ username });
    if (existingUser) throw new Error('Username already exists');
    
    // 3. Hash password
    const passwordHash = await bcrypt.hash(password, 12);
    
    // 4. Create user
    const user = await User.create({
      email,
      password_hash: passwordHash,
      username,
      full_name: fullName,
      study_focus: studyFocus,
      is_verified: false,
      preferences: { theme: 'light', notifications: true }
    });
    
    // 5. Generate verification code
    const verificationCode = crypto.randomInt(100000, 999999).toString();
    await redis.setex(`verify:${email}`, 3600, verificationCode); // 1 hour
    
    // 6. Send email
    await emailService.sendVerificationEmail(email, verificationCode);
    
    return { success: true, message: 'Check your email' };
  }
  
  async login(email, password) {
    // 1. Find user
    const user = await User.findOne({ email });
    if (!user) throw new Error('Invalid email or password');
    
    // 2. Verify password
    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid) throw new Error('Invalid email or password');
    
    // 3. Check verification
    if (!user.is_verified) throw new Error('Email not verified');
    
    // 4. Check account active
    if (!user.is_active) throw new Error('Account disabled');
    
    // 5. Generate tokens
    const accessToken = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );
    
    const refreshToken = jwt.sign(
      { userId: user.id, tokenVersion: user.tokenVersion },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: '7d' }
    );
    
    // 6. Store refresh token in Redis
    await redis.setex(
      `refresh:${user.id}`,
      7 * 24 * 3600, // 7 days
      refreshToken
    );
    
    // 7. Update user status
    user.last_seen_at = new Date();
    await user.save();
    
    // 8. Set online status
    await redis.setex(`online:${user.id}`, 300, 'true'); // 5 min TTL
    
    return {
      user: user.toJSON(),
      token: {
        accessToken,
        refreshToken,
        expiresIn: 86400
      }
    };
  }
  
  async refreshToken(refreshToken) {
    // Verify token
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    
    // Check in Redis (not revoked)
    const storedToken = await redis.get(`refresh:${decoded.userId}`);
    if (!storedToken || storedToken !== refreshToken) {
      throw new Error('Refresh token revoked');
    }
    
    // Get user
    const user = await User.findById(decoded.userId);
    if (!user) throw new Error('User not found');
    
    // Generate new tokens
    const newAccessToken = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );
    
    return {
      accessToken: newAccessToken,
      refreshToken,
      expiresIn: 86400
    };
  }
}
```

---

## 👥 Feature 2: Friend System

### Feature Specification

**Friend Request Flow**
```
User A → Send Request → User B → Accept/Reject → Friend Status

Steps:
1. User A clicks "Add Friend" on User B's profile
2. System checks:
   - A and B not already friends
   - B hasn't blocked A
   - Request not already sent
3. Create FriendRequest record:
   - sender_user_id: A
   - receiver_user_id: B
   - status: 'pending'
4. Send notification to B
5. Show status: "Request Sent"
6. User B receives notification
7. B clicks "Accept":
   - Update request status to 'accepted'
   - Create Friends record (with A-id < B-id)
   - Clear Redis cache for both users' friend lists
   - Send notification to A: "X accepted your request"
8. Both users now see each other in their friend list
9. Both can now:
   - See each other's online status
   - Start 1-to-1 chat
   - View profiles
```

**Unfriend Flow**
```
Remove Friendship → Delete Relationship → Update UI

Steps:
1. User A clicks "Unfriend" on User B
2. Show confirmation dialog
3. On confirm:
   - Delete Friends record
   - Soft delete Messages (mark as deleted)
   - Close active chat
   - Clear Redis cache
4. User A no longer sees B in friend list
5. Both users can still see past messages (or delete them)
6. They can send new friend request
```

**Online Status Tracking**
```
User Joins/Leaves → Redis Update → Broadcast to Friends

Steps:
1. User logs in:
   - Set Redis key: online:${userId} = true with 5-min TTL
   - Broadcast to all friends via WebSocket: "User is online"
2. User navigates app:
   - Every 2 minutes: Refresh TTL of online key
   - Keep user "online" status alive
3. User minimizes app/locks screen:
   - On pause event: Delete online key
   - Broadcast to friends: "User is offline"
   - Set last_seen_at timestamp
4. Friend views friend list:
   - Check Redis for online:${friendId}
   - If exists → Show "Online"
   - If not → Show "Offline" with last_seen_at
5. App closes ungracefully:
   - TTL expires after 5 minutes
   - User automatically marked offline
```

### Code Logic (Friends Logic)

```javascript
// friendService.js
class FriendService {
  async sendFriendRequest(fromUserId, toUserId) {
    // Check constraints
    const existing = await FriendRequest.findOne({
      sender_user_id: fromUserId,
      receiver_user_id: toUserId
    });
    if (existing) throw new Error('Request already sent');
    
    const friendship = await Friends.findOne({
      user_id: Math.min(fromUserId, toUserId),
      friend_id: Math.max(fromUserId, toUserId)
    });
    if (friendship) throw new Error('Already friends');
    
    // Create request
    const request = await FriendRequest.create({
      sender_user_id: fromUserId,
      receiver_user_id: toUserId,
      status: 'pending'
    });
    
    // Send notification
    await notificationService.createNotification({
      userId: toUserId,
      type: 'friend_request',
      title: `New friend request from ${fromUser.username}`,
      relatedEntityId: request.id
    });
    
    // Emit WebSocket event
    io.to(`user:${toUserId}`).emit('friend_request_received', {
      id: request.id,
      fromUser: { id, username, profilePhoto }
    });
    
    return request;
  }
  
  async acceptFriendRequest(requestId, userId) {
    // Get request
    const request = await FriendRequest.findById(requestId);
    if (request.receiver_user_id !== userId) {
      throw new Error('Unauthorized');
    }
    
    // Update request
    request.status = 'accepted';
    request.responded_at = new Date();
    await request.save();
    
    const { sender_user_id, receiver_user_id } = request;
    
    // Create friendship (normalized: smaller ID first)
    const [userId1, userId2] = [sender_user_id, receiver_user_id].sort();
    
    await Friends.create({
      user_id: userId1,
      friend_id: userId2,
      status: 'active'
    });
    
    // Invalidate caches
    await redis.del(`friends:${userId1}`);
    await redis.del(`friends:${userId2}`);
    
    // Notifications
    await notificationService.createNotification({
      userId: sender_user_id,
      type: 'friend_request_accepted',
      title: `${receiverUser.username} accepted your request`
    });
    
    // WebSocket
    io.to(`user:${sender_user_id}`).emit('friend_request_accepted', {
      friend: receiverUserData
    });
    
    return { success: true };
  }
  
  async getFriendsList(userId, limit = 50, offset = 0) {
    // Try cache first
    let cached = await redis.get(`friends:${userId}`);
    if (cached) return JSON.parse(cached);
    
    // Query database
    const friends = await Friends.findAll({
      where: {
        [Op.or]: [
          { user_id: userId },
          { friend_id: userId }
        ],
        status: 'active'
      },
      include: [
        {
          model: User,
          as: 'friend',
          attributes: ['id', 'username', 'full_name', 'profile_photo_url', 'study_focus']
        }
      ]
    });
    
    // Normalize results (extract other user from both directions)
    const friendsList = friends.map(f => {
      const friend = f.user_id === userId ? f.friend : f.user;
      return friend;
    });
    
    // Add online status from Redis
    const withStatus = await Promise.all(
      friendsList.map(async (friend) => {
        const isOnline = await redis.exists(`online:${friend.id}`);
        const lastSeen = friend.last_seen_at;
        return { ...friend, isOnline: isOnline === 1, lastSeenAt: lastSeen };
      })
    );
    
    // Cache for 30 minutes
    await redis.setex(`friends:${userId}`, 1800, JSON.stringify(withStatus));
    
    // Pagination
    const paginatedFriends = withStatus.slice(offset, offset + limit);
    
    return {
      friends: paginatedFriends,
      total: withStatus.length,
      limit,
      offset
    };
  }
}
```

---

## 💬 Feature 3: Chat System

### Feature Specification

**Message Send Flow**
```
User Types → Send Button → Validation → Database → WebSocket → Delivery → Read Receipt

Steps:
1. User types message in input
2. On send button click:
   - Validate message not empty
   - Validate user has access to chat
3. Create Message record:
   - from_user_id: current user
   - chat_room_id: target chat
   - content: message text
   - is_delivered: false
   - is_read: false
   - created_at: now
4. Return message with optimistic UI (show immediately)
5. Emit WebSocket event to all chat members:
   ```javascript
   socket.emit('message_sent', {
     id, content, fromUser, chatRoomId, createdAt
   });
   ```
6. All connected clients receive message instantly
7. Receiving client marks as delivered:
   - Update message.is_delivered = true
   - Emit: message_delivered event
8. Original sender shows: ✓ (delivered)
9. User opens chat / scrolls to message:
   - Emit: messages_read event with message IDs
10. Backend updates all messages:
    - is_read: true
    - read_at: timestamp
11. Sending user sees: ✓✓ (read) with timestamp
```

**Typing Indicator**
```
User Starts Typing → Broadcast → Show "X is typing" → Timeout

Steps:
1. User starts typing in message input
2. Emit WebSocket event: user_typing (debounced, max once per 1 sec):
   ```javascript
   socket.emit('user_typing', { chatRoomId, userId });
   ```
3. Server broadcasts to room:
   ```javascript
   socket.to(`chat:${chatRoomId}`).emit('user_typing', {
     userId, username, timestamp
   });
   ```
4. Show in chat: "Alice is typing..."
5. User doesn't emit for 2 seconds:
   - Automatically emit: user_stopped_typing
6. Broadcast and remove typing indicator

Benefits:
- Debounced to reduce event spam
- Auto-timeout after 2 seconds
- Creates more natural conversation
```

**Real-time Message Status**
```
Message created → Delivered (socket) → Read (user opens chat)

Database fields:
- is_delivered: When message reaches recipient device
- delivered_at: Timestamp when delivered
- is_read: When user views message
- read_at: Timestamp when read

Display:
- ⏱️ Sending... (optimistic UI)
- ✓ Sent (saved to database)
- ✓ Delivered (received receipt)
- ✓✓ Seen HH:MM (read confirmation)
```

### Code Logic (Chat Service)

```javascript
// chatService.js
class ChatService {
  async sendMessage(userId, chatRoomId, content, messageType = 'text') {
    // 1. Validate access
    const member = await ChatRoomMember.findOne({
      chat_room_id: chatRoomId,
      user_id: userId
    });
    if (!member) throw new Error('Not in this chat');
    
    // 2. Validate content
    if (!content || content.trim().length === 0) {
      throw new Error('Message cannot be empty');
    }
    
    // 3. Create message
    const message = await Message.create({
      from_user_id: userId,
      chat_room_id: chatRoomId,
      content: content.trim(),
      message_type: messageType,
      is_delivered: false,
      is_read: false
    });
    
    // 4. Broadcast via WebSocket
    const messageData = {
      id: message.id,
      fromUser: {
        id: userId,
        username: currentUser.username,
        profilePhotoUrl: currentUser.profile_photo_url
      },
      content: message.content,
      type: messageType,
      createdAt: message.created_at,
      isDelivered: false,
      isRead: false
    };
    
    // Emit to all users in chat room
    io.to(`chat:${chatRoomId}`).emit('message_sent', messageData);
    
    // 5. Update chat room's last_message_at
    await ChatRoom.update(
      { last_message_at: new Date() },
      { where: { id: chatRoomId } }
    );
    
    return messageData;
  }
  
  async markMessagesAsDelivered(chatRoomId, userId, messageIds) {
    // Update database
    await Message.update(
      { is_delivered: true, delivered_at: new Date() },
      { where: { id: messageIds, chat_room_id: chatRoomId } }
    );
    
    // Broadcast delivery status
    io.to(`chat:${chatRoomId}`).emit('messages_delivered', {
      messageIds,
      deliveredAt: new Date()
    });
  }
  
  async markMessagesAsRead(chatRoomId, userId, messageIds) {
    // Update database
    const readTime = new Date();
    await Message.update(
      { is_read: true, read_at: readTime },
      { where: { id: messageIds, chat_room_id: chatRoomId } }
    );
    
    // Broadcast read status
    io.to(`chat:${chatRoomId}`).emit('messages_read', {
      messageIds,
      userId,
      readAt: readTime
    });
  }
  
  async getMessages(chatRoomId, userId, limit = 50, before = null) {
    // Check access
    const member = await ChatRoomMember.findOne({
      chat_room_id: chatRoomId,
      user_id: userId
    });
    if (!member) throw new Error('Not in this chat');
    
    // Build query
    let query = { chat_room_id: chatRoomId, is_deleted: false };
    if (before) {
      query.created_at = { [Op.lt]: new Date(before) };
    }
    
    // Fetch messages
    const messages = await Message.findAll({
      where: query,
      include: [
        {
          model: User,
          as: 'fromUser',
          attributes: ['id', 'username', 'profile_photo_url']
        }
      ],
      order: [['created_at', 'DESC']],
      limit,
      raw: true
    });
    
    // Return in chronological order
    return messages.reverse();
  }
}

// Socket.io handlers
io.on('connection', (socket) => {
  const userId = socket.handshake.auth.userId;
  
  // Join user's personal room
  socket.join(`user:${userId}`);
  
  // Join chat rooms user is member of
  const memberRooms = await ChatRoomMember.findAll({
    where: { user_id: userId }
  });
  memberRooms.forEach(m => {
    socket.join(`chat:${m.chat_room_id}`);
  });
  
  // Handle typing
  socket.on('user_typing', (data) => {
    socket.to(`chat:${data.chatRoomId}`).emit('user_typing', {
      userId,
      username: socket.data.username,
      timestamp: new Date()
    });
  });
  
  // Handle typing stop
  socket.on('user_stopped_typing', (data) => {
    socket.to(`chat:${data.chatRoomId}`).emit('user_stopped_typing', {
      userId
    });
  });
  
  // Handle message read
  socket.on('messages_read', async (data) => {
    await chatService.markMessagesAsRead(
      data.chatRoomId,
      userId,
      data.messageIds
    );
  });
});
```

---

## 📝 Feature 4: Notes Sharing System

### Feature Specification

**Create/Publish Note Flow**
```
Draft → Publish → Public Feed → Engagement

Steps:
1. User clicks "New Note"
2. Opens rich-text editor with:
   - Title input
   - Rich text content (supports markdown)
   - Subject selector
   - Tags input
   - Publish/Save Draft buttons
3. Auto-save every 10 seconds:
   - Save to local storage as draft
   - Show "Saved" indicator
4. User publishes:
   - Validate title and content not empty
   - Create Note record
   - is_public: true
   - Generate preview (first 200 chars)
   - Add to public feed
5. Note appears in:
   - User's own profile
   - Global feed (sorted by latest)
   - Searchable
6. Other users can:
   - Like the note
   - Save the note
   - Share in chat
   - View author profile
7. Engagement stats:
   - likes_count incremented
   - views_count on each view
   - shares_count when shared
```

**Search & Discovery**
```
User searches → Elasticsearch (or DB full-text) → Results → Tap to view

Indexing:
- Title
- Content
- Tags
- Author username

Search Features:
- Full-text search by title/content
- Filter by subject
- Filter by author
- Filter by date range
- Sort by newest, trending, popular

Ranking:
- Recency (for newest)
- Engagement (likes + views) for popular
- Trending (likes + shares in last 7 days)
```

---

## 📊 Feature 5: Productivity Tracking

### Feature Specification

**Daily Activity Logging**
```
User logs:
1. Study Hours (decimal): 5.5
2. Subject(s): React, Node.js
3. Sleep Hours: 8
4. Sleep Quality: good, average, poor
5. Mood: Emoji + text
6. Tags: [productive, networking]

Data Validation:
- Study hours: 0-24, decimal
- Sleep hours: 0-24, decimal
- Mood emoji: Valid emoji
- Subject: From predefined list + custom

On Save:
- Check if activity exists for that date
- If exists: Update
- If new: Create
- Store with timezone consideration
- Auto-calculate aggregates for the week

Auto-triggers:
- Update weekly totals
- Update monthly totals
- Check against weekly goals
- Generate daily AI summary (optional)
```

**Goal Check-in**
```
Goals can be updated:
1. By manual input: +2 hours study
2. By auto-aggregation:
   - Weekly: Sum of daily activities for week
   - Monthly: Sum of daily activities for month
3. Goal completion check:
   - If current_progress >= target_value:
   - Mark as: completed
   - Set status: completed
   - Record completed_at timestamp

Notifications:
- When goal completed: "Congratulations!"
- When goal about to expire: "1 day left"
- When goal failed: "Goal incomplete"
```

---

## 📈 Feature 6: Analytics & Reports

### Feature Specification

**Weekly Report Generation**
```
Trigger: Every Sunday 11:59 PM + Manual request

Data Collection:
1. Get all daily activities for the week
2. Sum study hours
3. Calculate average sleep
4. Aggregate subjects
5. Get goal completion rate
6. Analyze mood trend
7. Identify best/worst days

Calculations:
```
totalStudyHours = SUM(daily_activities.study_hours_total) for week
averageSleepHours = AVG(daily_activities.sleep_hours) for week
subjects = DISTINCT(subject_studied)
bestDay = day with max study_hours
worstDay = day with min study_hours
moodScore = AVG(mood converted to 1-5 scale)
goalCompletionRate = Completed goals / Total goals * 100
```

Storage:
- Cache in PostgreSQL weekly_reports table
- Also cache in Redis for quick retrieval
- TTL Redis: 1 week

API Response includes:
- All aggregated data
- Charts data (JSON for frontend to render)
- Comparison vs previous week
- AI-generated insights (optional)
```

**Monthly Report Generation**
```
Trigger: Last day of month + Manual request

Data Collection:
1. Aggregate all weekly reports for the month
2. Calculate consistency (days studied / days in month)
3. Analyze best/worst days
4. Track goal completion
5. Sleep vs study correlation
6. Mood trend analysis

AI Integration:
1. Call OpenAI API with user data
2. Prompt asks for:
   - Productivity trend analysis
   - Sleep health assessment
   - Recommendations for next month
   - Predictions if current pace continues
3. Store generated insights in JSONB

Example Prompt:
```
Analyze this student data and provide insights:
- Studied 165 hours this month
- 92% consistency (28/30 days)
- Average 7.8 hours sleep
- Mood improved from 😐 to 😊
- Most studied: React (45 hrs)
- Goal completion: 75% (3/4)

Provide:
1. Productivity trend (improving/stable/declining)
2. Health assessment
3. 3 specific recommendations
4. Prediction for next month
```

Storage: Cache monthly report with insights
```

---

## 🤖 Feature 7: AI Features

### Feature Specification

**Daily AI Summary**
```
Trigger: 8:00 AM every morning (configurable)

Data Used:
1. Previous day's activity:
   - Total study hours
   - Sleep hours
   - Mood
   - Subjects
   - Goals progress
2. Last 7 days average
3. User's trends

OpenAI Prompt Template:
```
User studied {hours} hours yesterday on {subjects}.
Slept {sleep_hours} hours.
Mood: {mood}.
Weekly average: {weekly_hours} hrs.
Monthly goal progress: {goal_progress}%.

Generate a concise (50-100 words) personalized summary and one specific tip.
Format as JSON: { summary: "", tip: "" }
```

Delivery:
- Send as push notification
- Show in dashboard
- Store in notifications table
- User can read full version
```

**Smart Suggestions**
```
Trigger: Weekly, after report generation

Types of Suggestions:
1. Productivity Optimization
   - "Your best time is 6-8 PM. Try scheduling harder tasks then."
   - "Take 5-min breaks every 45 mins. Studies show 20% better retention."

2. Sleep & Health
   - "You're sleeping 1 hour less than optimal. Try 10 PM bedtime."
   - "Your sleep quality drops on Tuesdays. Any stress?"

3. Learning Recommendations
   - "You spent most time on React but weak on testing. Try 'Testing Library'."
   - "Your consistency is 85% - need 3 more study days to hit 90%."

4. Goal Suggestions
   - "Complete {subject} course by {date} to boost specialization."
   - "Based on pace, you'll finish {goal} 2 days early."

Algorithm:
1. Calculate metrics
2. Compare against user's baselines
3. If deviation found: Generate suggestion
4. Rank by relevance
5. Show top 3 suggestions

No Generic Motivation:
- All suggestions backed by user's actual data
- Show "based on your data" for transparency
- Include specific metrics
```

---

## 🔔 Feature 8: Notifications

### Feature Specification

**Notification Types**
```
1. Message Notifications
   - New message in group chat
   - New private message
   - User mentioned in chat

2. Friend Notifications
   - Friend request received
   - Friend request accepted
   - Friend came online

3. Goal Notifications
   - Goal completed
   - Goal about to expire (1 day left)
   - Goal failed
   - Weekly report ready

4. Engagement Notifications
   - Your note got a like
   - Your note got saved
   - Someone shared your note

5. System Notifications
   - Daily AI summary ready
   - Weekly report ready
   - Monthly report ready
```

**Push Notification Flow**
```
Event Triggered → Create Notification Record → Get Device Token → Send via FCM → Broadcast via WebSocket

1. Event occurs (e.g., message received):
   - Create Notifications table record
   - Type: message
   - Related entity: messageId

2. Get user's device tokens from Firebase
   - One user can have multiple devices
   - Fetch all active tokens

3. Craft FCM payload:
```json
{
  "notification": {
    "title": "New message from Alice",
    "body": "Are you free for study session?",
    "image": "https://..."
  },
  "data": {
    "deepLinkPath": "/chat/chatRoomId",
    "type": "message",
    "entityId": "messageId"
  },
  "apns": { "alert": {...}, "sound": "default" }
}
```

4. Send via Firebase Cloud Messaging (FCM)
   - App closed: Shows system notification
   - App running: Custom notification handler
   - User taps notification: Deep link to chat

5. Also broadcast via WebSocket if user online:
   - Instant in-app notification
   - Toast/snackbar style
   - Dismiss action

6. Notification state:
   - Created
   - Delivered
   - Read (when user reads within app)
   - Archived (manual)
```

**Notification Delivery Guarantee**
```
Implementation:
1. Store notification in queue (Redis)
2. Try to send via FCM
3. If failed: Retry with exponential backoff
   - Retry 1: 1 minute later
   - Retry 2: 5 minutes later
   - Retry 3: 30 minutes later
4. If 3 retries fail: Don't retry further
5. User will see notification when opens app (via polling)

Polling Mechanism:
- On app open: GET /api/v1/notifications?unreadOnly=true
- Fetch any missed notifications
- Display them as a batch
```

---

## Core Logic Flow Diagrams

### Authentication Flow
```
START
  ↓
[User Opens App] → Check if token in storage
  ↓
Is token valid?
  ├─ YES → Refresh token → Continue to Dashboard
  ├─ NO → Redirect to Login
  └─ EXPIRED → Try refresh token
           ├─ Success → Update token, go to Dashboard
           └─ Fail → Clear storage, go to Login
  ↓
END
```

### Message Flow
```
[User Types & Hits Send]
  ↓
[Validate Input]
  ├─ Empty? → Show error toast
  └─ OK → Continue
  ↓
[Create Message Record in DB] → Optimistic UI Update (show immediately)
  ↓
[Emit WebSocket Event] → All room members receive
  ↓
[Receiving Devices] → Save to local DB → Update UI
  ↓
[Auto Mark Delivered] → Update DB → Broadcast
  ↓
[User Opens Chat/Scrolls to Message]
  ↓
[Emit Message Read Event] → DB Update → Broadcast
  ↓
[Sender Sees] ✓✓ Read at [time]
  ↓
END
```

### Daily Activity Flow
```
[User Clicks "Log Activity"]
  ↓
[Show Logger Screen] ← Pre-fill Yesterday's date
  ↓
[User Fills Data]:
  - Study hours
  - Subject
  - Sleep hours
  - Mood
  ↓
[On Save]:
  ├─ Validate all fields
  ├─ Check date not in future
  ├─ Create/Update DailyActivity
  └─ Invalidate cache
  ↓
[Auto-trigger Calculations]:
  ├─ Update weekly totals (Redis)
  ├─ Check weekly goals
  └─ If week complete, trigger report
  ↓
[Show Success] → Next activity logged X days ago
  ↓
END
```

---

## Database Transaction Examples

### Creating Friendship (Atomic)
```javascript
const transaction = await sequelize.transaction();
try {
  // 1. Update request
  await FriendRequest.update(
    { status: 'accepted' },
    { where: { id: requestId }, transaction }
  );
  
  // 2. Create friendship
  await Friends.create({
    user_id: Math.min(userId1, userId2),
    friend_id: Math.max(userId1, userId2),
    status: 'active'
  }, { transaction });
  
  // 3. Clear caches
  await redis.del(`friends:${userId1}`);
  await redis.del(`friends:${userId2}`);
  
  await transaction.commit();
} catch (error) {
  await transaction.rollback();
  throw error;
}
```

---

This covers ALL major features with realistic, production-ready logic flows.
