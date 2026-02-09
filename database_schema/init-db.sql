-- ==========================================
-- FRIEND APP - Database Initialization
-- ==========================================
-- This script initializes the database schema
-- It's automatically run when PostgreSQL starts

-- ==========================================
-- CREATE EXTENSIONS
-- ==========================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "ltree";

-- ==========================================
-- CREATE ENUM TYPES
-- ==========================================
CREATE TYPE user_role AS ENUM ('user', 'admin', 'moderator');
CREATE TYPE friend_request_status AS ENUM ('pending', 'accepted', 'rejected');
CREATE TYPE message_status AS ENUM ('sent', 'delivered', 'read');
CREATE TYPE notification_type AS ENUM ('friend_request', 'message', 'note_like', 'mention', 'system');
CREATE TYPE activity_type AS ENUM ('study', 'exercise', 'reading', 'work', 'break', 'other');
CREATE TYPE note_visibility AS ENUM ('private', 'friends_only', 'public');

-- ==========================================
-- CREATE TABLES
-- ==========================================

-- Users Table
CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID UNIQUE NOT NULL DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  username VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(255),
  bio TEXT,
  profile_picture_url VARCHAR(512),
  cover_image_url VARCHAR(512),
  phone_number VARCHAR(20),
  date_of_birth DATE,
  location VARCHAR(255),
  website_url VARCHAR(512),
  is_email_verified BOOLEAN DEFAULT false,
  email_verified_at TIMESTAMP,
  is_active BOOLEAN DEFAULT true,
  last_login_at TIMESTAMP,
  role user_role DEFAULT 'user',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_username ON users(username) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_user_id ON users(user_id);
CREATE INDEX idx_users_created_at ON users(created_at DESC);

-- Friend Requests Table
CREATE TABLE IF NOT EXISTS friend_requests (
  id BIGSERIAL PRIMARY KEY,
  request_id UUID UNIQUE NOT NULL DEFAULT uuid_generate_v4(),
  requester_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  recipient_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status friend_request_status DEFAULT 'pending',
  message TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT no_self_request CHECK (requester_id != recipient_id),
  CONSTRAINT unique_request UNIQUE (requester_id, recipient_id)
);

CREATE INDEX idx_friend_requests_requester ON friend_requests(requester_id);
CREATE INDEX idx_friend_requests_recipient ON friend_requests(recipient_id);
CREATE INDEX idx_friend_requests_status ON friend_requests(status);
CREATE INDEX idx_friend_requests_created_at ON friend_requests(created_at DESC);

-- Friends Table (Denormalized for fast queries)
CREATE TABLE IF NOT EXISTS friends (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  friend_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT no_self_friend CHECK (user_id != friend_id),
  CONSTRAINT unique_friendship UNIQUE (user_id, friend_id)
);

CREATE INDEX idx_friends_user_id ON friends(user_id);
CREATE INDEX idx_friends_friend_id ON friends(friend_id);

-- Chat Rooms Table
CREATE TABLE IF NOT EXISTS chat_rooms (
  id BIGSERIAL PRIMARY KEY,
  room_id UUID UNIQUE NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255),
  description TEXT,
  is_group BOOLEAN DEFAULT false,
  creator_id BIGINT NOT NULL REFERENCES users(id) ON DELETE SET NULL,
  avatar_url VARCHAR(512),
  settings JSONB DEFAULT '{}',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

CREATE INDEX idx_chat_rooms_creator_id ON chat_rooms(creator_id);
CREATE INDEX idx_chat_rooms_is_group ON chat_rooms(is_group);
CREATE INDEX idx_chat_rooms_created_at ON chat_rooms(created_at DESC);

-- Chat Room Members Table
CREATE TABLE IF NOT EXISTS chat_room_members (
  id BIGSERIAL PRIMARY KEY,
  room_id BIGINT NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role VARCHAR(50) DEFAULT 'member',
  joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_read_message_id BIGINT,
  is_muted BOOLEAN DEFAULT false,
  CONSTRAINT unique_member UNIQUE (room_id, user_id)
);

CREATE INDEX idx_chat_room_members_room_id ON chat_room_members(room_id);
CREATE INDEX idx_chat_room_members_user_id ON chat_room_members(user_id);

-- Messages Table
CREATE TABLE IF NOT EXISTS messages (
  id BIGSERIAL PRIMARY KEY,
  message_id UUID UNIQUE NOT NULL DEFAULT uuid_generate_v4(),
  room_id BIGINT NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
  sender_id BIGINT NOT NULL REFERENCES users(id) ON DELETE SET NULL,
  content TEXT NOT NULL,
  message_type VARCHAR(50) DEFAULT 'text',
  media_urls TEXT[],
  is_edited BOOLEAN DEFAULT false,
  is_deleted BOOLEAN DEFAULT false,
  status message_status DEFAULT 'sent',
  delivered_at TIMESTAMP,
  read_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_messages_room_id ON messages(room_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX idx_messages_status ON messages(status);

-- Notes Table
CREATE TABLE IF NOT EXISTS notes (
  id BIGSERIAL PRIMARY KEY,
  note_id UUID UNIQUE NOT NULL DEFAULT uuid_generate_v4(),
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  description TEXT,
  tags TEXT[],
  visibility note_visibility DEFAULT 'private',
  thumbnail_url VARCHAR(512),
  likes_count INT DEFAULT 0,
  saves_count INT DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

CREATE INDEX idx_notes_user_id ON notes(user_id);
CREATE INDEX idx_notes_visibility ON notes(visibility) WHERE deleted_at IS NULL;
CREATE INDEX idx_notes_created_at ON notes(created_at DESC);
CREATE INDEX idx_notes_tags ON notes USING GIN(tags);

-- Note Likes Table
CREATE TABLE IF NOT EXISTS note_likes (
  id BIGSERIAL PRIMARY KEY,
  note_id BIGINT NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT unique_like UNIQUE (note_id, user_id)
);

CREATE INDEX idx_note_likes_note_id ON note_likes(note_id);
CREATE INDEX idx_note_likes_user_id ON note_likes(user_id);

-- Note Saves Table
CREATE TABLE IF NOT EXISTS note_saves (
  id BIGSERIAL PRIMARY KEY,
  note_id BIGINT NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT unique_save UNIQUE (note_id, user_id)
);

CREATE INDEX idx_note_saves_note_id ON note_saves(note_id);
CREATE INDEX idx_note_saves_user_id ON note_saves(user_id);

-- Daily Activities Table
CREATE TABLE IF NOT EXISTS daily_activities (
  id BIGSERIAL PRIMARY KEY,
  activity_id UUID UNIQUE NOT NULL DEFAULT uuid_generate_v4(),
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type activity_type NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  duration_minutes INT,
  location VARCHAR(255),
  notes TEXT,
  mood VARCHAR(50),
  productivity_score INT CHECK (productivity_score >= 1 AND productivity_score <= 10),
  date DATE NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_daily_activities_user_id ON daily_activities(user_id);
CREATE INDEX idx_daily_activities_date ON daily_activities(date DESC);
CREATE INDEX idx_daily_activities_type ON daily_activities(type);

-- Goals Table
CREATE TABLE IF NOT EXISTS goals (
  id BIGSERIAL PRIMARY KEY,
  goal_id UUID UNIQUE NOT NULL DEFAULT uuid_generate_v4(),
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  category VARCHAR(100),
  target_value DECIMAL(10, 2),
  current_value DECIMAL(10, 2) DEFAULT 0,
  unit VARCHAR(50),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status VARCHAR(50) DEFAULT 'in_progress',
  priority VARCHAR(50) DEFAULT 'medium',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT valid_dates CHECK (end_date > start_date)
);

CREATE INDEX idx_goals_user_id ON goals(user_id);
CREATE INDEX idx_goals_status ON goals(status);

-- Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
  id BIGSERIAL PRIMARY KEY,
  notification_id UUID UNIQUE NOT NULL DEFAULT uuid_generate_v4(),
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type notification_type NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT,
  related_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
  related_note_id BIGINT REFERENCES notes(id) ON DELETE SET NULL,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP,
  action_url VARCHAR(512),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- Weekly Reports Table
CREATE TABLE IF NOT EXISTS weekly_reports (
  id BIGSERIAL PRIMARY KEY,
  report_id UUID UNIQUE NOT NULL DEFAULT uuid_generate_v4(),
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  week_start_date DATE NOT NULL,
  total_activities INT DEFAULT 0,
  total_duration_minutes INT DEFAULT 0,
  total_productivity_score INT DEFAULT 0,
  average_mood VARCHAR(50),
  top_activity_type activity_type,
  goals_completed INT DEFAULT 0,
  notes_created INT DEFAULT 0,
  data JSONB,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT unique_weekly_report UNIQUE (user_id, week_start_date)
);

CREATE INDEX idx_weekly_reports_user_id ON weekly_reports(user_id);
CREATE INDEX idx_weekly_reports_week_start_date ON weekly_reports(week_start_date DESC);

-- Monthly Reports Table
CREATE TABLE IF NOT EXISTS monthly_reports (
  id BIGSERIAL PRIMARY KEY,
  report_id UUID UNIQUE NOT NULL DEFAULT uuid_generate_v4(),
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  year INT NOT NULL,
  month INT NOT NULL,
  total_activities INT DEFAULT 0,
  total_duration_minutes INT DEFAULT 0,
  average_productivity_score DECIMAL(5, 2) DEFAULT 0,
  most_active_day VARCHAR(20),
  top_activity_type activity_type,
  goals_completed INT DEFAULT 0,
  notes_created INT DEFAULT 0,
  data JSONB,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT valid_month CHECK (month >= 1 AND month <= 12),
  CONSTRAINT unique_monthly_report UNIQUE (user_id, year, month)
);

CREATE INDEX idx_monthly_reports_user_id ON monthly_reports(user_id);

-- ==========================================
-- CREATE FUNCTIONS
-- ==========================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- CREATE TRIGGERS
-- ==========================================

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chat_rooms_updated_at BEFORE UPDATE ON chat_rooms
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notes_updated_at BEFORE UPDATE ON notes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_daily_activities_updated_at BEFORE UPDATE ON daily_activities
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_goals_updated_at BEFORE UPDATE ON goals
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_friend_requests_updated_at BEFORE UPDATE ON friend_requests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==========================================
-- SET PERMISSIONS
-- ==========================================

-- Grant privileges to frienduser
GRANT CONNECT ON DATABASE friend_db TO frienduser;
GRANT USAGE ON SCHEMA public TO frienduser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO frienduser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO frienduser;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO frienduser;
