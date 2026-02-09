# Complete API Endpoints Documentation

## 🔐 Authentication Endpoints

### 1. Sign Up (Register)
```
POST /api/v1/auth/signup
Content-Type: application/json

Request Body:
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "passwordConfirm": "SecurePass123!",
  "username": "john_doe",
  "fullName": "John Doe"
}

Response: 201 Created
{
  "success": true,
  "message": "Account created. Please verify your email.",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "username": "john_doe",
    "fullName": "John Doe"
  },
  "token": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "expiresIn": 86400
  }
}

Error Responses:
- 400: Email already exists
- 400: Username already exists
- 400: Invalid email format
- 400: Password too weak
- 422: Validation failed
```

### 2. Email Verification
```
POST /api/v1/auth/verify-email
Content-Type: application/json

Request Body:
{
  "email": "user@example.com",
  "verificationCode": "123456"
}

Response: 200 OK
{
  "success": true,
  "message": "Email verified successfully"
}
```

### 3. Login
```
POST /api/v1/auth/login
Content-Type: application/json

Request Body:
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}

Response: 200 OK
{
  "success": true,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "username": "john_doe",
    "fullName": "John Doe",
    "profilePhotoUrl": "https://...",
    "isOnline": true
  },
  "token": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "expiresIn": 86400
  }
}

Error Responses:
- 401: Invalid email or password
- 401: Email not verified
- 403: Account disabled
```

### 4. Refresh Token
```
POST /api/v1/auth/refresh
Content-Type: application/json

Request Body:
{
  "refreshToken": "eyJhbGc..."
}

Response: 200 OK
{
  "success": true,
  "token": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "expiresIn": 86400
  }
}
```

### 5. Logout
```
POST /api/v1/auth/logout
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "message": "Logged out successfully"
}
```

### 6. Forgot Password
```
POST /api/v1/auth/forgot-password
Content-Type: application/json

Request Body:
{
  "email": "user@example.com"
}

Response: 200 OK
{
  "success": true,
  "message": "Password reset email sent"
}
```

### 7. Reset Password
```
POST /api/v1/auth/reset-password
Content-Type: application/json

Request Body:
{
  "resetToken": "token_from_email",
  "newPassword": "NewSecure123!",
  "confirmPassword": "NewSecure123!"
}

Response: 200 OK
{
  "success": true,
  "message": "Password reset successfully"
}
```

---

## 👤 User Profile Endpoints

### 8. Get User Profile
```
GET /api/v1/users/{userId}
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "username": "john_doe",
    "fullName": "John Doe",
    "profilePhotoUrl": "https://...",
    "studyFocus": "Computer Science",
    "bio": "Passionate about learning",
    "isOnline": true,
    "lastSeenAt": "2024-02-09T10:30:00Z",
    "createdAt": "2024-01-15T08:00:00Z"
  }
}
```

### 9. Update Profile
```
PUT /api/v1/users/{userId}
Authorization: Bearer {accessToken}
Content-Type: application/json

Request Body:
{
  "fullName": "John William Doe",
  "studyFocus": "Full Stack Development",
  "bio": "Learning Flutter and Node.js",
  "profilePhotoUrl": "https://..." (optional, new URL)
}

Response: 200 OK
{
  "success": true,
  "user": { updated user object }
}
```

### 10. Upload Profile Photo
```
POST /api/v1/users/{userId}/upload-photo
Authorization: Bearer {accessToken}
Content-Type: multipart/form-data

Request Body:
- file: (image file, max 5MB)

Response: 200 OK
{
  "success": true,
  "photoUrl": "https://..."
}
```

### 11. Change Password
```
POST /api/v1/users/{userId}/change-password
Authorization: Bearer {accessToken}
Content-Type: application/json

Request Body:
{
  "currentPassword": "OldPass123!",
  "newPassword": "NewPass123!",
  "confirmPassword": "NewPass123!"
}

Response: 200 OK
{
  "success": true,
  "message": "Password changed successfully"
}
```

---

## 👥 Friend System Endpoints

### 12. Get Friends List
```
GET /api/v1/friends?userId={userId}&limit=50&offset=0
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "data": {
    "friends": [
      {
        "id": "uuid",
        "username": "alice_smith",
        "fullName": "Alice Smith",
        "profilePhotoUrl": "https://...",
        "studyFocus": "Medicine",
        "isOnline": true,
        "lastSeenAt": "2024-02-09T10:30:00Z"
      },
      { ...more friends }
    ],
    "total": 45,
    "limit": 50,
    "offset": 0
  }
}
```

### 13. Get Friend Requests (Received)
```
GET /api/v1/friend-requests/received?status=pending
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "data": {
    "requests": [
      {
        "id": "uuid",
        "fromUser": {
          "id": "uuid",
          "username": "bob_jones",
          "fullName": "Bob Jones",
          "profilePhotoUrl": "https://..."
        },
        "status": "pending",
        "createdAt": "2024-02-08T15:30:00Z"
      },
      { ...more requests }
    ],
    "total": 12,
    "unreadCount": 3
  }
}
```

### 14. Send Friend Request
```
POST /api/v1/friend-requests/send
Authorization: Bearer {accessToken}
Content-Type: application/json

Request Body:
{
  "toUserId": "uuid"
}

Response: 201 Created
{
  "success": true,
  "request": {
    "id": "uuid",
    "status": "pending",
    "createdAt": "2024-02-09T10:30:00Z"
  }
}

Error Responses:
- 400: Already friends
- 400: Request already sent
- 400: User blocked
- 404: User not found
```

### 15. Accept Friend Request
```
POST /api/v1/friend-requests/{requestId}/accept
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "message": "Friend request accepted",
  "friend": { user object }
}
```

### 16. Reject Friend Request
```
POST /api/v1/friend-requests/{requestId}/reject
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "message": "Friend request rejected"
}
```

### 17. Cancel Friend Request
```
POST /api/v1/friend-requests/{requestId}/cancel
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "message": "Friend request cancelled"
}
```

### 18. Unfriend
```
DELETE /api/v1/friends/{friendId}
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "message": "Friend removed"
}
```

### 19. Discover Friends (Get All Users)
```
GET /api/v1/users/discover?search=john&limit=20&offset=0
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "uuid",
        "username": "john_dev",
        "fullName": "John Developer",
        "profilePhotoUrl": "https://...",
        "studyFocus": "Computer Science",
        "isOnline": true,
        "friendshipStatus": "not_friends" // OR "pending", "accepted"
      }
    ],
    "total": 15,
    "limit": 20,
    "offset": 0
  }
}
```

---

## 💬 Chat Endpoints

### 20. Get Chat List
```
GET /api/v1/chats?limit=50&offset=0
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "data": {
    "chats": [
      {
        "id": "uuid",
        "name": "Study Community",
        "type": "group",
        "roomPhotoUrl": "https://...",
        "lastMessage": {
          "content": "Anyone free for study session?",
          "fromUserId": "uuid",
          "fromUsername": "alice",
          "createdAt": "2024-02-09T10:30:00Z"
        },
        "unreadCount": 5,
        "memberCount": 150
      },
      {
        "id": "uuid",
        "name": "Bob Johnson",
        "type": "private",
        "roomPhotoUrl": "https://...",
        "lastMessage": { ...same structure },
        "unreadCount": 2,
        "otherUserId": "uuid"
      }
    ],
    "total": 23
  }
}
```

### 21. Get Messages from Chat
```
GET /api/v1/chats/{chatRoomId}/messages?limit=50&offset=0
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "data": {
    "messages": [
      {
        "id": "uuid",
        "fromUser": {
          "id": "uuid",
          "username": "alice",
          "profilePhotoUrl": "https://..."
        },
        "content": "Great study session yesterday!",
        "type": "text",
        "isRead": true,
        "isDelivered": true,
        "readAt": "2024-02-09T10:35:00Z",
        "deliveredAt": "2024-02-09T10:31:00Z",
        "createdAt": "2024-02-09T10:30:00Z"
      },
      { ...more messages }
    ],
    "total": 450,
    "hasMore": true,
    "limit": 50,
    "offset": 0
  }
}
```

### 22. Send Message
```
POST /api/v1/chats/{chatRoomId}/messages
Authorization: Bearer {accessToken}
Content-Type: application/json

Request Body:
{
  "content": "Let's study together tomorrow!",
  "type": "text"
}

// For sharing files:
{
  "type": "image",
  "attachmentUrl": "https://...",
  "content": "Study notes diagram"
}

Response: 201 Created
{
  "success": true,
  "message": {
    "id": "uuid",
    "content": "Let's study together tomorrow!",
    "type": "text",
    "fromUser": { current user },
    "isRead": false,
    "isDelivered": false,
    "createdAt": "2024-02-09T10:50:00Z"
  }
}

// Real-time: Message broadcast via WebSocket to all chat members
```

### 23. Mark Messages as Read
```
PUT /api/v1/chats/{chatRoomId}/mark-read
Authorization: Bearer {accessToken}
Content-Type: application/json

Request Body:
{
  "messageIds": ["uuid1", "uuid2", "uuid3"]
}

Response: 200 OK
{
  "success": true,
  "message": "Messages marked as read"
}

// Real-time: Broadcast "user read message" event via WebSocket
```

### 24. Start Private Chat
```
POST /api/v1/chats/start-private
Authorization: Bearer {accessToken}
Content-Type: application/json

Request Body:
{
  "userId": "uuid_of_friend"
}

Response: 201 Created OR 200 OK (if already exists)
{
  "success": true,
  "chatRoom": {
    "id": "uuid",
    "name": "Bob Johnson",
    "type": "private",
    "otherUserId": "uuid",
    "otherUser": { user object }
  }
}
```

### 25. Search Messages
```
GET /api/v1/chats/{chatRoomId}/search?query=study&limit=20
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "data": {
    "messages": [ messages matching query ],
    "total": 15
  }
}
```

---

## 📝 Notes Endpoints

### 26. Get Notes Feed (Public)
```
GET /api/v1/notes/feed?limit=20&offset=0&sort=latest
Authorization: Bearer {accessToken}

Query Parameters:
- sort: latest, trending, topLiked
- subject: filter by subject (e.g., mathematics)
- search: full-text search

Response: 200 OK
{
  "success": true,
  "data": {
    "notes": [
      {
        "id": "uuid",
        "title": "React Hooks Guide",
        "preview": "Complete guide to React Hooks including useState, useEffect...",
        "author": {
          "id": "uuid",
          "username": "alice",
          "profilePhotoUrl": "https://..."
        },
        "subject": "React",
        "tags": ["react", "hooks", "javascript"],
        "likesCount": 125,
        "savesCount": 45,
        "viewsCount": 500,
        "createdAt": "2024-02-07T10:30:00Z",
        "isLikedByCurrentUser": false,
        "isSavedByCurrentUser": false
      }
    ],
    "total": 1200,
    "limit": 20,
    "offset": 0,
    "hasMore": true
  }
}
```

### 27. Get User's Notes
```
GET /api/v1/notes/user/{userId}?limit=20&offset=0
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "data": {
    "notes": [ notes array ],
    "total": 12,
    "userName": "alice",
    "userFollowersCount": 150 // future feature
  }
}
```

### 28. Create Note
```
POST /api/v1/notes
Authorization: Bearer {accessToken}
Content-Type: application/json

Request Body:
{
  "title": "React Hooks Guide",
  "content": "## useState Hook\nThe useState hook allows you to...",
  "subject": "React",
  "tags": ["react", "hooks", "javascript"],
  "isPublic": true
}

Response: 201 Created
{
  "success": true,
  "note": {
    "id": "uuid",
    "title": "React Hooks Guide",
    "content": "...",
    "subject": "React",
    "tags": ["react", "hooks", "javascript"],
    "author": { current user },
    "likesCount": 0,
    "savesCount": 0,
    "viewsCount": 1,
    "isPublic": true,
    "createdAt": "2024-02-09T10:50:00Z"
  }
}
```

### 29. Update Note
```
PUT /api/v1/notes/{noteId}
Authorization: Bearer {accessToken}
Content-Type: application/json

Request Body:
{
  "title": "Updated Title",
  "content": "Updated content",
  "subject": "Updated subject",
  "tags": ["updated", "tags"]
}

Response: 200 OK
{
  "success": true,
  "note": { updated note }
}

Error Responses:
- 403: Only author can update
```

### 30. Delete Note
```
DELETE /api/v1/notes/{noteId}
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "message": "Note deleted"
}
```

### 31. Like Note
```
POST /api/v1/notes/{noteId}/like
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "liked": true,
  "likesCount": 126
}
```

### 32. Unlike Note
```
DELETE /api/v1/notes/{noteId}/like
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "liked": false,
  "likesCount": 125
}
```

### 33. Save Note
```
POST /api/v1/notes/{noteId}/save
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "saved": true,
  "savesCount": 46
}
```

### 34. Share Note in Chat
```
POST /api/v1/notes/{noteId}/share
Authorization: Bearer {accessToken}
Content-Type: application/json

Request Body:
{
  "chatRoomId": "uuid",
  "message": "Check out this note!" // optional
}

Response: 200 OK
{
  "success": true,
  "message": {
    "id": "uuid",
    "type": "note_share",
    "content": "Check out this note!",
    "attachment": { note details }
  }
}
```

---

## 📊 Activity Tracking Endpoints

### 35. Log Daily Activity
```
POST /api/v1/activities/daily
Authorization: Bearer {accessToken}
Content-Type: application/json

Request Body:
{
  "activityDate": "2024-02-09",
  "studyHoursTotal": 5.5,
  "subjectStudied": "React and Node.js",
  "sleepHours": 8,
  "sleepQuality": "good",
  "moodEmoji": "😊",
  "moodText": "Productive and energized",
  "tags": ["productive", "networking"]
}

Response: 201 Created
{
  "success": true,
  "activity": {
    "id": "uuid",
    "date": "2024-02-09",
    "studyHoursTotal": 5.5,
    // ... all the data
  }
}
```

### 36. Get Daily Activities
```
GET /api/v1/activities/daily?startDate=2024-01-01&endDate=2024-02-09&limit=50
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "data": {
    "activities": [
      {
        "id": "uuid",
        "date": "2024-02-09",
        "studyHoursTotal": 5.5,
        "subjectStudied": "React",
        "sleepHours": 8,
        "sleepQuality": "good",
        "moodEmoji": "😊",
        "moodText": "Great day",
        // ... all fields
      }
    ],
    "total": 40,
    "totalStudyHours": 185,
    "averageDailySleep": 7.5
  }
}
```

### 37. Update Daily Activity
```
PUT /api/v1/activities/daily/{activityId}
Authorization: Bearer {accessToken}
Content-Type: application/json

Request Body:
{
  "studyHoursTotal": 6.5,
  "sleepHours": 7.5,
  "moodText": "Updated mood"
}

Response: 200 OK
{
  "success": true,
  "activity": { updated activity }
}
```

### 38. Delete Daily Activity
```
DELETE /api/v1/activities/daily/{activityId}
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "message": "Activity deleted"
}
```

---

## 🎯 Goals Endpoints

### 39. Create Goal
```
POST /api/v1/goals
Authorization: Bearer {accessToken}
Content-Type: application/json

Request Body:
{
  "title": "Complete React Course",
  "description": "Finish advanced React patterns course",
  "goalType": "weekly", // or "monthly"
  "startDate": "2024-02-09",
  "endDate": "2024-02-16",
  "targetValue": 40,
  "targetUnit": "hours"
}

Response: 201 Created
{
  "success": true,
  "goal": {
    "id": "uuid",
    "title": "Complete React Course",
    "goalType": "weekly",
    "startDate": "2024-02-09",
    "endDate": "2024-02-16",
    "targetValue": 40,
    "targetUnit": "hours",
    "currentProgress": 0,
    "status": "active",
    "createdAt": "2024-02-09T10:50:00Z"
  }
}
```

### 40. Get Goals
```
GET /api/v1/goals?goalType=weekly&status=active
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "data": {
    "goals": [
      {
        "id": "uuid",
        "title": "50 hours study",
        "goalType": "weekly",
        "startDate": "2024-02-09",
        "endDate": "2024-02-16",
        "targetValue": 50,
        "targetUnit": "hours",
        "currentProgress": 20.5,
        "progressPercentage": 41,
        "status": "active",
        "daysRemaining": 3,
        "createdAt": "2024-02-09T10:50:00Z"
      }
    ],
    "total": 3,
    "completedCount": 2,
    "activeCount": 3
  }
}
```

### 41. Update Goal Progress
```
PUT /api/v1/goals/{goalId}/progress
Authorization: Bearer {accessToken}
Content-Type: application/json

Request Body:
{
  "progressIncrement": 1.5 // Add 1.5 hours
}

Response: 200 OK
{
  "success": true,
  "goal": { updated goal with new progress }
}
```

### 42. Mark Goal Complete
```
POST /api/v1/goals/{goalId}/complete
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "goal": {
    "status": "completed",
    "completedAt": "2024-02-16T23:59:00Z",
    // ...rest of data
  }
}
```

### 43. Delete Goal
```
DELETE /api/v1/goals/{goalId}
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "message": "Goal deleted"
}
```

---

## 📈 Analytics Endpoints

### 44. Get Weekly Report
```
GET /api/v1/analytics/weekly?weekStartDate=2024-02-05
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "report": {
    "weekStartDate": "2024-02-05",
    "weekEndDate": "2024-02-11",
    "totalStudyHours": 42.5,
    "averageSleepHours": 7.8,
    "subjectsStudied": [
      { "subject": "React", "hours": 15 },
      { "subject": "Node.js", "hours": 12.5 },
      { "subject": "Docker", "hours": 15 }
    ],
    "goalsCompletionRate": 85, // percentage
    "bestDay": {
      "date": "2024-02-09",
      "studyHours": 8.5,
      "mood": "😊"
    },
    "worstDay": {
      "date": "2024-02-06",
      "studyHours": 4,
      "mood": "😔"
    },
    "averageMoodScore": 3.8, // out of 5
    "consistency": "Excellent",
    "createdAt": "2024-02-11T23:59:00Z"
  }
}
```

### 45. Get Monthly Report
```
GET /api/v1/analytics/monthly?month=2024-02
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "report": {
    "month": "February 2024",
    "totalStudyHours": 165.5,
    "averageDailySleep": 7.9,
    "studyConsistency": 92, // percentage of days studied
    "monthlyGoalsCompletedCount": 3,
    "monthlyGoalsTotalCount": 4,
    "completionRate": 75,
    "bestDay": "2024-02-09",
    "worstDay": "2024-02-02",
    "aiInsights": {
      "productivityTrend": "improving",
      "sleepHealth": "excellent",
      "recommendations": [
        "Your study consistency is great! Keep it up.",
        "Consider more diverse subjects next month.",
        "Sleep schedule is perfect, maintain it."
      ],
      "predictions": [
        "If you maintain this pace, you'll exceed March goals by 20%"
      ]
    },
    "chartsData": {
      "dailyStudyHours": [...data for chart],
      "subjectsBreakdown": [...data for chart],
      "moodTrend": [...data for chart]
    }
  }
}
```

### 46. Get Analytics Dashboard
```
GET /api/v1/analytics/dashboard
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "dashboard": {
    "thisWeekStudyHours": 42.5,
    "lastWeekStudyHours": 38.2,
    "weekTrendPercentage": 11,
    "thisMonthStudyHours": 165.5,
    "thisMonthGoalProgress": 75,
    "totalFriendsCount": 45,
    "unreadMessagesCount": 7,
    "pendingFriendRequestsCount": 2,
    "todayStudyHours": 6.5,
    "todayMood": "😊",
    "nextGoal": {
      "id": "uuid",
      "title": "50 hours study",
      "daysRemaining": 3,
      "progressPercentage": 75
    },
    "recentActivity": [
      { mostproductive day, time, mood, etc }
    ]
  }
}
```

---

## 🔔 Notifications Endpoints

### 47. Get Notifications
```
GET /api/v1/notifications?limit=20&offset=0&unreadOnly=false
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "uuid",
        "type": "message",
        "title": "New message from Alice",
        "content": "Are you free for study session?",
        "relatedEntityType": "message",
        "relatedEntityId": "uuid",
        "deepLinkPath": "/chat/uuid",
        "isRead": false,
        "createdAt": "2024-02-09T10:50:00Z"
      }
    ],
    "total": 23,
    "unreadCount": 7
  }
}
```

### 48. Mark Notification as Read
```
PUT /api/v1/notifications/{notificationId}/read
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "notification": { updated notification }
}
```

### 49. Mark All Notifications as Read
```
PUT /api/v1/notifications/read-all
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "message": "All notifications marked as read"
}
```

### 50. Delete Notification
```
DELETE /api/v1/notifications/{notificationId}
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "message": "Notification deleted"
}
```

---

## 🌐 WebSocket Events (Real-time)

### Socket.io Connection
```javascript
// Client Connect
socket.on('connect', () => {
  socket.emit('user_online', { userId: 'uuid' });
});

// Server broadcasts user online
socket.on('user_status_changed', (data) => {
  // { userId, isOnline: true, timestamp }
});
```

### Chat Events
```javascript
// Send message (emit)
socket.emit('message_send', {
  chatRoomId: 'uuid',
  content: 'Hello!',
  type: 'text'
});

// Receive message (listen)
socket.on('message_received', (data) => {
  // { id, fromUser, content, createdAt, ... }
});

// Message delivered (listen)
socket.on('message_delivered', (data) => {
  // { messageId, deliveredAt }
});

// Message read (emit)
socket.emit('message_read', {
  messageIds: ['uuid1', 'uuid2']
});

// User read message (listen)
socket.on('message_read_by', (data) => {
  // { messageId, userId, readAt }
});

// Typing indicator (emit)
socket.emit('user_typing', {
  chatRoomId: 'uuid'
});

// User is typing (listen)
socket.on('user_typing', (data) => {
  // { chatRoomId, userId, username }
});

// User stopped typing (listen)
socket.on('user_stopped_typing', (data) => {
  // { chatRoomId, userId }
});
```

### Notification Events
```javascript
// Friend request received (listen)
socket.on('friend_request_received', (data) => {
  // { id, fromUser: {...}, createdAt }
});

// Friend request accepted (listen)
socket.on('friend_request_accepted', (data) => {
  // { userId, friend: {...} }
});

// Note liked (listen)
socket.on('note_liked', (data) => {
  // { noteId, userId, likesCount }
});
```

---

## 🔒 Security & Rate Limiting

All endpoints implement:
- **JWT Authentication**: Bearer token required
- **Rate Limiting**: 
  - 100 requests/minute for users
  - 1000 requests/minute for premium users
  - 10 requests/minute for unauth endpoints
- **HTTPS/TLS**: All endpoints encrypted
- **CORS**: Configured for web/mobile domains
- **Request Validation**: Input sanitization on all endpoints

---

## 📞 Error Response Format

All errors follow this format:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "User-friendly error message",
    "statusCode": 400,
    "details": {
      "field": ["Error reason"]
    },
    "timestamp": "2024-02-09T10:50:00Z"
  }
}
```

**Common Error Codes:**
- `VALIDATION_ERROR`: Input validation failed
- `AUTH_ERROR`: Authentication failed
- `FORBIDDEN`: Permission denied
- `NOT_FOUND`: Resource not found
- `CONFLICT`: Resource already exists
- `RATE_LIMIT`: Too many requests
- `INTERNAL_ERROR`: Server error

---

## 📊 API Metrics

- **Total Endpoints**: 50+
- **Authentication Methods**: JWT
- **Rate Limits**: Implemented (see above)
- **Response Time Target**: < 200ms for 95% requests
- **Availability Target**: 99.9% uptime
- **API Versioning**: /api/v1 (future: v2, v3)

This API is designed to support 100k+ concurrent users with proper caching and optimization strategies.
