# 🛠️ Manual Setup Guide - Without Docker

**Language: Hindi/English mixed**

---

## 📋 Prerequisites Install करने हैं

### 1️⃣ **Node.js 18+ LTS**
- Download: https://nodejs.org/ (18+ LTS version)
- Install करो normal way से
- Verify करो:
```bash
node --version
npm --version
```

### 2️⃣ **PostgreSQL 13+**
- Download: https://www.postgresql.org/download/windows/
- Install करते time याद रखो:
  - Username: `postgres`
  - Password: set कर देना (याद रखना!)
  - Port: 5432 (default)
- Verify करो:
```bash
psql --version
```

### 3️⃣ **Redis**
- Download: https://github.com/microsoftarchive/redis/releases
- Windows के लिए pre-built binary download करो
- Or use: Memurai (better for Windows): https://www.memurai.com/
- Verify करो:
```bash
redis-cli --version
```

---

## ⚙️ Step-by-Step Setup

### Step 1: Database Setup

**PostgreSQL में आना:**
```bash
psql -U postgres
```

**यह commands run करो:**
```sql
-- Create user
CREATE USER frienduser WITH PASSWORD 'friendpass123';

-- Create database
CREATE DATABASE friend_db OWNER frienduser;

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE friend_db TO frienduser;

-- Exit
\q
```

**Database schema load करो:**
```bash
cd c:\Users\skris\Desktop\friend
psql -U frienduser -d friend_db -f database_schema/init-db.sql
```

**Check करो कि tables बन गई हैं:**
```bash
psql -U frienduser -d friend_db -c "\dt"
```

---

### Step 2: Backend Setup

**Project folder में जाओ:**
```bash
cd c:\Users\skris\Desktop\friend\backend
```

**Dependencies install करो:**
```bash
npm install
```

**Environment file create करो:**
```bash
# .env file already है, check करो:
cat ../.env
```

**अगर कुछ missing हो तो edit करो:**
```
DATABASE_URL=postgres://frienduser:friendpass123@localhost:5432/friend_db
REDIS_URL=redis://localhost:6379
```

---

### Step 3: Services Start करो

**Three terminal खोल (या tabs में):**

**Terminal 1 - Redis शुरू करो:**
```bash
redis-server
```
(या अगर Memurai है:)
```bash
memurai-server
```

**Terminal 2 - Backend API शुरू करो:**
```bash
cd c:\Users\skris\Desktop\friend\backend
npm run dev
```

**Terminal 3 - Command/Test के लिए:**
```bash
# यहाँ commands चलाएगा
```

---

## ✅ Verify करो सब कुछ काम कर रहा है

### API Check करो:
```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2024-02-09T10:00:00.000Z",
  "uptime": 12.345,
  "environment": "development"
}
```

### Database Check करो:
```bash
psql -U frienduser -d friend_db -c "SELECT COUNT(*) FROM users;"
```

### Redis Check करो:
```bash
redis-cli ping
```

Output: `PONG`

---

## 🎯 Final Setup

अब तुम्हारे पास है:
- ✅ PostgreSQL database (port 5432)
- ✅ Redis cache (port 6379)
- ✅ Node.js API server (port 3000)

---

## 📊 Database को Manage करो

### GUI से (pgAdmin - optional)
```bash
# pgAdmin download करो: https://www.pgadmin.org/download/pgadmin-4-windows/
# Install करो
# Server add करो:
# - Host: localhost
# - Port: 5432
# - Username: frienduser
# - Password: friendpass123
# - Database: friend_db
```

### Command line से:
```bash
psql -U frienduser -d friend_db
```

Useful commands:
```sql
-- All tables देखो
\dt

-- User table structure
\d users

-- Query किसी table को
SELECT * FROM users LIMIT 5;

-- Exit
\q
```

---

## 🚀 अब क्या करें?

1. **[NEXT] Backend develop करो** - `PROJECT_DOCUMENTATION/05_FEATURE_SPECIFICATIONS.md`
2. **API test करो** - `PROJECT_DOCUMENTATION/03_API_ENDPOINTS.md`
3. **Database समझो** - `database_schema/COMPLETE_DATABASE_SCHEMA.md`

---

## 🐛 Common Issues

### Issue: PostgreSQL connection failed
```
Error: connect ECONNREFUSED 127.0.0.1:5432
```

**Fix:**
```bash
# PostgreSQL service running है या नहीं check करो
# Windows Services में देखो या:
pg_isready -h localhost -p 5432
```

### Issue: Redis connection failed
```
Error: connect ECONNREFUSED 127.0.0.1:6379
```

**Fix:**
```bash
# Redis running है या नहीं:
redis-cli ping
# अगर connection refused तो redis-server शुरू करो
```

### Issue: npm install fail हो रहा है
```bash
# Cache clear करो
npm cache clean --force

# फिर try करो
npm install
```

### Issue: Port already in use
```
Error: EADDRINUSE: address already in use :::3000
```

**Fix:**
```bash
# Which process is using port 3000
netstat -ano | findstr :3000

# Kill करो (PID से)
taskkill /PID <PID> /F
```

---

## 📝 Useful Windows Commands

```bash
# Services check करो
Get-Service PostgreSQL*
Get-Service Redis*

# Service start करो
Start-Service PostgreSQL
Start-Service Redis

# Service stop करो
Stop-Service PostgreSQL
Stop-Service Redis

# Port usage check करो
netstat -ano | findstr :3000
netstat -ano | findstr :5432
netstat -ano | findstr :6379
```

---

## 🎯 Summary

| Service | Port | Start Command |
|---------|------|---|
| **PostgreSQL** | 5432 | `psql -U postgres` |
| **Redis** | 6379 | `redis-server` |
| **API** | 3000 | `npm run dev` |

**तीनों service running होने चाहिए development के लिए।**

---

## 💡 Pro Tips

1. **हर terminal में title दे दो** ताकि confuse न हो
   ```bash
   title Redis Server
   title PostgreSQL
   title API Server
   ```

2. **Logs देखते रहो** - troubleshooting आसान हो जाएगी

3. **Database backup ले लो** पहले:
   ```bash
   pg_dump -U frienduser friend_db > backup.sql
   ```

4. **Redis को persistent बनाओ** अगर data save करना हो:
   ```bash
   # Redis config में: appendonly yes
   ```

---

## ❓ Need Help?

- API Docs: `PROJECT_DOCUMENTATION/03_API_ENDPOINTS.md`
- Database Schema: `database_schema/COMPLETE_DATABASE_SCHEMA.md`
- Architecture: `PROJECT_DOCUMENTATION/01_ARCHITECTURE_OVERVIEW.md`

Good luck! 🚀
