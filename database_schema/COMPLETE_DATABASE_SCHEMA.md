# Complete Database Schema

## 📋 Table-by-Table Breakdown

---

## 1️⃣ USERS Table

**Purpose**: Store user authentication and profile information

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    
    -- Profile Information
    full_name VARCHAR(255),
    profile_photo_url TEXT,
    study_focus VARCHAR(100),
    bio TEXT,
    
    -- Status Tracking
    is_online BOOLEAN DEFAULT FALSE,
    last_seen_at TIMESTAMP WITH TIME ZONE,
    
    -- Account Management
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Metadata
    country VARCHAR(100),
    language VARCHAR(50) DEFAULT 'en',
    preferences JSONB DEFAULT '{}'
);

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_is_online ON users(is_online);
CREATE INDEX idx_users_created_at ON users(created_at DESC);
```

**Fields Explanation:**
- `email`: For login and verification
- `username`: Unique identifier visible to other users
- `password_hash`: Never store plain passwords; use bcrypt
- `profile_photo_url`: URL to Firebase Cloud Storage
- `study_focus`: E.g., "Computer Science", "Medicine"
- `is_online`: Real-time status (managed via Redis in production)
- `preferences`: JSONB for extensibility (theme, notifications, etc.)

---

## 2️⃣ FRIEND_REQUESTS Table

**Purpose**: Manage friendship request lifecycle

```sql
CREATE TABLE friend_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- User Relations
    sender_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Status
    status VARCHAR(50) DEFAULT 'pending',
    -- Values: pending, accepted, rejected, cancelled
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT sender_not_receiver CHECK (sender_user_id != receiver_user_id),
    CONSTRAINT unique_request UNIQUE (sender_user_id, receiver_user_id)
);

-- Indexes
CREATE INDEX idx_friend_requests_receiver ON friend_requests(receiver_user_id, status);
CREATE INDEX idx_friend_requests_sender ON friend_requests(sender_user_id, status);
CREATE INDEX idx_friend_requests_created_at ON friend_requests(created_at DESC);
```

**Status Lifecycle:**
```
pending → accepted (both are friends now)
pending → rejected (dismissed)
pending → cancelled (sender cancels)
```

---

## 3️⃣ FRIENDS Table

**Purpose**: Store confirmed friendships (denormalized for performance)

```sql
CREATE TABLE friends (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- User Relations (always userId < friendId for avoiding duplicates)
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    friend_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Metadata
    status VARCHAR(50) DEFAULT 'active', -- active, blocked, unfriended
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT user_not_friend CHECK (user_id != friend_id),
    CONSTRAINT user_id_less_than_friend_id CHECK (user_id < friend_id),
    CONSTRAINT unique_friendship UNIQUE (user_id, friend_id)
);

-- Indexes
CREATE INDEX idx_friends_user_id ON friends(user_id, status);
CREATE INDEX idx_friends_friend_id ON friends(friend_id, status);
CREATE INDEX idx_friends_created_at ON friends(created_at DESC);
```

**Why denormalized?:**
Fast O(1) lookup for "are these two friends?" queries. Used heavily in chat authorization.

---

## 4️⃣ CHAT_ROOMS Table

**Purpose**: Store chat room metadata (both group and private)

```sql
CREATE TABLE chat_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Basic Info
    name VARCHAR(255) NOT NULL,
    description TEXT,
    chat_type VARCHAR(50) NOT NULL, -- 'group', 'private'
    
    -- Relationships
    created_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
    
    -- Photo
    room_photo_url TEXT,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Metadata
    member_count INTEGER DEFAULT 1,
    last_message_at TIMESTAMP WITH TIME ZONE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_chat_rooms_type ON chat_rooms(chat_type);
CREATE INDEX idx_chat_rooms_created_by ON chat_rooms(created_by_user_id);
CREATE INDEX idx_chat_rooms_is_active ON chat_rooms(is_active);
CREATE INDEX idx_chat_rooms_updated_at ON chat_rooms(updated_at DESC);
```

**Types:**
- `group`: Study Community (all users, master chat)
- `private`: One-to-one chats (created on first message)

---

## 5️⃣ CHAT_ROOM_MEMBERS Table

**Purpose**: Track which users are in which chat rooms

```sql
CREATE TABLE chat_room_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relationships
    chat_room_id UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Member Info
    role VARCHAR(50) DEFAULT 'member', -- 'member', 'moderator', 'admin'
    is_muted BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT unique_member UNIQUE (chat_room_id, user_id)
);

-- Indexes
CREATE INDEX idx_chat_room_members_chat_room ON chat_room_members(chat_room_id);
CREATE INDEX idx_chat_room_members_user ON chat_room_members(user_id);
```

---

## 6️⃣ MESSAGES Table

**Purpose**: Store all chat messages with delivery tracking

```sql
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Sender
    from_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Chat Context
    chat_room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
    
    -- Message Content
    content TEXT,
    message_type VARCHAR(50) DEFAULT 'text', -- 'text', 'image', 'file', 'note_share'
    attachment_url TEXT, -- For images, files
    
    -- Delivery Status
    is_delivered BOOLEAN DEFAULT FALSE,
    is_read BOOLEAN DEFAULT FALSE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,
    
    -- Editing
    is_edited BOOLEAN DEFAULT FALSE,
    edited_at TIMESTAMP WITH TIME ZONE,
    
    -- Deletion (soft delete)
    is_deleted BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT content_required CHECK (
        (message_type = 'text' AND content IS NOT NULL) OR
        (message_type IN ('image', 'file', 'note_share') AND attachment_url IS NOT NULL)
    )
);

-- Indexes (critical for chat performance)
CREATE INDEX idx_messages_chat_room ON messages(chat_room_id, created_at DESC);
CREATE INDEX idx_messages_from_user ON messages(from_user_id, created_at DESC);
CREATE INDEX idx_messages_is_read ON messages(chat_room_id, is_read);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);

-- For finding latest unread message for a user
CREATE INDEX idx_messages_latest_unread ON messages(chat_room_id, is_read, created_at DESC);
```

**Delivery Flow:**
```
Message Created → is_delivered=FALSE → is_read=FALSE
         ↓ (received by client)
      is_delivered=TRUE, delivered_at set
         ↓ (user opens chat)
      is_read=TRUE, read_at set
```

---

## 7️⃣ NOTES Table

**Purpose**: Store user-created notes for public sharing

```sql
CREATE TABLE notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Author
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Content
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    preview TEXT, -- First 200 chars for feed display
    
    -- Metadata
    subject VARCHAR(100), -- E.g., "Mathematics", "Biology"
    tags JSONB DEFAULT '[]', -- Array of tags: ["calculus", "derivatives"]
    
    -- Visibility & Engagement
    is_public BOOLEAN DEFAULT TRUE,
    likes_count INTEGER DEFAULT 0,
    saves_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    views_count INTEGER DEFAULT 0,
    
    -- Status
    is_deleted BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Indexes
CREATE INDEX idx_notes_author_id ON notes(author_id, created_at DESC);
CREATE INDEX idx_notes_is_public ON notes(is_public, created_at DESC);
CREATE INDEX idx_notes_subject ON notes(subject);
CREATE INDEX idx_notes_tags ON notes USING GIN(tags); -- JSONB index for search
CREATE INDEX idx_notes_created_at ON notes(created_at DESC);

-- Full-text search index
CREATE INDEX idx_notes_search ON notes USING GIN(
    to_tsvector('english', title || ' ' || content)
);
```

**Note Engagement Flow:**
- Users can like notes (updates `likes_count`)
- Users can save notes (updates `saves_count`)
- Users can share notes in chat (updates `shares_count`)
- Page views tracked (updates `views_count`)

---

## 8️⃣ NOTE_LIKES Table

**Purpose**: Track which users liked which notes

```sql
CREATE TABLE note_likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relationships
    note_id UUID NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT unique_like UNIQUE (note_id, user_id)
);

-- Indexes
CREATE INDEX idx_note_likes_note ON note_likes(note_id);
CREATE INDEX idx_note_likes_user ON note_likes(user_id);
```

---

## 9️⃣ NOTE_SAVES Table

**Purpose**: Track saved notes (bookmarking)

```sql
CREATE TABLE note_saves (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relationships
    note_id UUID NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT unique_save UNIQUE (note_id, user_id)
);

-- Indexes
CREATE INDEX idx_note_saves_user ON note_saves(user_id, created_at DESC);
```

---

## 🔟 DAILY_ACTIVITIES Table

**Purpose**: Track daily productivity and wellness data

```sql
CREATE TABLE daily_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- User & Date
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_date DATE NOT NULL,
    
    -- Study Data
    study_hours_total DECIMAL(5, 2) DEFAULT 0,
    subject_studied VARCHAR(100),
    study_notes TEXT,
    
    -- Sleep Data
    sleep_hours DECIMAL(5, 2),
    sleep_quality VARCHAR(50), -- 'poor', 'average', 'good', 'excellent'
    
    -- Mood Tracking
    mood_emoji VARCHAR(10), -- Unicode emoji
    mood_text TEXT,
    
    -- Additional Data
    tags JSONB DEFAULT '[]', -- User-defined tags
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraint
    CONSTRAINT unique_daily_activity UNIQUE (user_id, activity_date)
);

-- Indexes
CREATE INDEX idx_activities_user_date ON daily_activities(user_id, activity_date DESC);
CREATE INDEX idx_activities_date_range ON daily_activities(
    user_id, 
    activity_date
) WHERE activity_date >= CURRENT_DATE - INTERVAL '90 days';
```

**Sample Data:**
```
user_id: uuid
activity_date: 2024-02-09
study_hours_total: 5.5
subject_studied: 'React, Node.js'
study_notes: 'Completed auth module and started chat feature'
sleep_hours: 7.5
sleep_quality: 'good'
mood_emoji: '😊'
mood_text: 'Productive day, feeling great'
tags: ["productive", "networking"]
```

---

## 1️⃣1️⃣ GOALS Table

**Purpose**: Store weekly and monthly goals with progress tracking

```sql
CREATE TABLE goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- User
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Goal Details
    title VARCHAR(255) NOT NULL,
    description TEXT,
    goal_type VARCHAR(50) NOT NULL, -- 'weekly', 'monthly'
    
    -- Timeline
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    
    -- Progress
    target_value DECIMAL(10, 2), -- E.g., 40 for "40 hours of study"
    target_unit VARCHAR(50), -- 'hours', 'pages', 'chapters', 'count'
    current_progress DECIMAL(10, 2) DEFAULT 0,
    
    -- Status
    status VARCHAR(50) DEFAULT 'active',
    -- Values: active, completed, failed, cancelled
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Indexes
CREATE INDEX idx_goals_user_status ON goals(user_id, status);
CREATE INDEX idx_goals_user_date_range ON goals(
    user_id, 
    start_date, 
    end_date
);
CREATE INDEX idx_goals_end_date ON goals(end_date) WHERE status = 'active';
```

---

## 1️⃣2️⃣ NOTIFICATIONS Table

**Purpose**: Store user notifications (push + in-app)

```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Recipient
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Content
    notification_type VARCHAR(50) NOT NULL,
    -- Types: message, friend_request, goal_reminder, ai_summary, note_like
    
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    
    -- Link/Reference
    related_entity_type VARCHAR(50), -- 'message', 'friend_request', 'note', etc.
    related_entity_id UUID,
    
    -- Deep Link
    deep_link_path VARCHAR(255), -- Route to open when tapped
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Auto-cleanup (30 days)
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP + INTERVAL '30 days'
);

-- Indexes
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_user_created ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_expires_at ON notifications(expires_at);
```

---

## 1️⃣3️⃣ WEEKLY_REPORTS Table

**Purpose**: Cache generated weekly reports for quick retrieval

```sql
CREATE TABLE weekly_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- User & Period
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    week_start_date DATE NOT NULL,
    week_end_date DATE NOT NULL,
    
    -- Aggregated Data
    total_study_hours DECIMAL(10, 2),
    average_sleep_hours DECIMAL(5, 2),
    subjects_studied JSONB, -- Array: ["Math: 10 hrs", "Physics: 8 hrs"]
    goal_completion_rate DECIMAL(5, 2), -- Percentage
    
    -- Mood Summary
    average_mood_score DECIMAL(3, 2), -- 1-5
    best_day DATE,
    worst_day DATE,
    
    -- Report Data (JSON for flexibility)
    report_data JSONB, -- Full report details
    
    -- Timestamps
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraint
    CONSTRAINT unique_weekly_report UNIQUE (user_id, week_start_date)
);

-- Indexes
CREATE INDEX idx_weekly_reports_user ON weekly_reports(user_id, week_start_date DESC);
```

---

## 1️⃣4️⃣ MONTHLY_REPORTS Table

**Purpose**: Cache generated monthly reports

```sql
CREATE TABLE monthly_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- User & Period
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    month DATE NOT NULL, -- First day of month
    
    -- Aggregated Data
    total_study_hours DECIMAL(10, 2),
    study_consistency_percentage DECIMAL(5, 2),
    average_daily_sleep DECIMAL(5, 2),
    
    -- Goals
    monthly_goals_count INTEGER,
    monthly_goals_completed INTEGER,
    
    -- Best/Worst Days
    best_day DATE,
    worst_day DATE,
    
    -- Insights (Generated by AI)
    ai_insights JSONB,
    -- Example: {
    --   "productivity_trend": "improving",
    --   "sleep_health": "needs_attention",
    --   "recommendations": ["Sleep earlier", "Study in batches"]
    -- }
    
    -- Timestamps
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraint
    CONSTRAINT unique_monthly_report UNIQUE (user_id, month)
);

-- Indexes
CREATE INDEX idx_monthly_reports_user ON monthly_reports(user_id, month DESC);
```

---

## 1️⃣5️⃣ FRIEND_BLOCKS Table

**Purpose**: Manage user blocking (future feature)

```sql
CREATE TABLE friend_blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relationships
    blocker_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blocked_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Reason
    reason TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraint
    CONSTRAINT blocker_not_blocked CHECK (blocker_user_id != blocked_user_id),
    CONSTRAINT unique_block UNIQUE (blocker_user_id, blocked_user_id)
);

-- Indexes
CREATE INDEX idx_friend_blocks_blocker ON friend_blocks(blocker_user_id);
CREATE INDEX idx_friend_blocks_blocked ON friend_blocks(blocked_user_id);
```

---

## 📊 Database Statistics

```
Tables: 15
Total Fields: ~150
Relationships: 12 foreign keys
Indexes: 50+
Estimated Storage per 1M users: ~500GB
```

---

## 🔄 Query Patterns & Optimization

### Common Query: Get User's Friends List
```sql
SELECT u.id, u.username, u.profile_photo_url, u.is_online
FROM users u
INNER JOIN friends f ON (
    (f.user_id = $1 AND f.friend_id = u.id) OR
    (f.friend_id = $1 AND f.user_id = u.id)
)
WHERE f.status = 'active'
ORDER BY u.is_online DESC, u.username ASC;
```

### Common Query: Get Unread Messages for a Chat
```sql
SELECT * FROM messages
WHERE chat_room_id = $1 
AND is_read = FALSE
AND from_user_id != $2
ORDER BY created_at DESC
LIMIT 100;
```

### Common Query: Get User's Daily Activity for a Date Range
```sql
SELECT * FROM daily_activities
WHERE user_id = $1
AND activity_date BETWEEN $2 AND $3
ORDER BY activity_date DESC;
```

### Common Query: Weekly Report Sum
```sql
SELECT 
    COALESCE(SUM(study_hours_total), 0) as total_hours,
    COALESCE(AVG(sleep_hours), 0) as avg_sleep,
    ARRAY_AGG(DISTINCT subject_studied) as subjects
FROM daily_activities
WHERE user_id = $1
AND activity_date BETWEEN $2 AND $3;
```

---

## 🔐 Data Privacy & GDPR

### Soft Delete Implementation
```sql
-- Instead of DELETE, use:
UPDATE users SET is_deleted = TRUE, deleted_at = NOW() 
WHERE id = $1;

-- Always filter in queries:
SELECT * FROM users WHERE is_deleted = FALSE;
```

### Right to be Forgotten
```sql
-- Archive user data before deletion
INSERT INTO user_data_archive SELECT * FROM users WHERE id = $1;

-- Then soft delete
UPDATE users SET is_deleted = TRUE, deleted_at = NOW() WHERE id = $1;

-- Hard delete after 90 days
DELETE FROM users WHERE deleted_at < NOW() - INTERVAL '90 days';
```

---

## 📈 Scaling Strategies

### For 1M+ Users:
1. **Sharding**: Partition by `user_id` (hash-based)
2. **Read Replicas**: For analytics queries
3. **Partitioning**: `daily_activities` by month
4. **Archiving**: Old messages (> 1 year) to cold storage

### Schema Partitioning Example
```sql
-- Partition messages by date
CREATE TABLE messages_2024_01 PARTITION OF messages
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

This schema is production-grade and handles millions of operations efficiently.
