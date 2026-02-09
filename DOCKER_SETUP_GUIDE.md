# 🐳 Docker Setup Guide

## Quick Start (30 seconds)

```bash
# 1. Copy environment template
cp .env.example .env

# 2. Start all services
docker-compose up -d

# 3. Check services are running
docker-compose ps

# Done! 🎉
```

---

## ✅ Verification

### Check Services Status
```bash
docker-compose ps
```

Expected output:
```
NAME                 STATUS
friend_postgres      Up (healthy)
friend_redis         Up (healthy)
friend_api           Up
friend_pgadmin       Up
friend_redis_commander Up
```

### Access Services

| Service | URL | Credentials |
|---------|-----|-------------|
| **API** | http://localhost:3000 | - |
| **PgAdmin** | http://localhost:5050 | admin@friend.local / admin123 |
| **Redis Commander** | http://localhost:8081 | - |
| **PostgreSQL** | localhost:5432 | frienduser / friendpass123 |
| **Redis** | localhost:6379 | - |

---

## 📝 First Steps

### 1. Check API Health
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

### 2. View API Documentation
```bash
curl http://localhost:3000/api-docs
```

### 3. Access PostgreSQL Database

**Via Docker:**
```bash
docker-compose exec postgres psql -U frienduser -d friend_db
```

**Via PgAdmin (Web):**
- Open http://localhost:5050
- Login: admin@friend.local / admin123
- Right-click "Servers" → "Register" → "Server"
  - Name: friend_db
  - Host: postgres
  - Port: 5432
  - Username: frienduser
  - Password: friendpass123

**Via Command Line (if PostgreSQL installed locally):**
```bash
psql -h localhost -U frienduser -d friend_db -W
```

### 4. Access Redis

**Via Docker:**
```bash
docker-compose exec redis redis-cli
```

**Via Redis Commander (Web):**
- Open http://localhost:8081
- Select "local" database

**Via Command Line (if Redis installed locally):**
```bash
redis-cli -h localhost -p 6379
```

---

## 🔧 Common Docker Commands

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f api
docker-compose logs -f postgres
docker-compose logs -f redis

# Last 100 lines
docker-compose logs --tail=100 api
```

### Stop Services
```bash
# Stop all
docker-compose stop

# Stop specific service
docker-compose stop api
```

### Restart Services
```bash
# Restart all
docker-compose restart

# Restart specific service
docker-compose restart api
```

### View Service Stats
```bash
docker stats friend_api friend_postgres friend_redis
```

### Access Container Shell
```bash
# API container
docker-compose exec api sh

# PostgreSQL container
docker-compose exec postgres sh
```

### Rebuild Container Image
```bash
# Rebuild API image
docker-compose build api

# Rebuild and restart
docker-compose up -d --build api
```

---

## 🗄️ Database Management

### Connect to Database
```bash
# Via Docker
docker-compose exec postgres psql -U frienduser -d friend_db

# Via local PostgreSQL client
psql -h localhost -U frienduser -d friend_db -W
```

### Run Database Queries
```bash
# View all tables
docker-compose exec postgres psql -U frienduser -d friend_db -c "\dt"

# View specific table structure
docker-compose exec postgres psql -U frienduser -d friend_db -c "\d users"

# Run SQL file
docker-compose exec postgres psql -U frienduser -d friend_db -f data.sql
```

### Backup Database
```bash
# Create backup
docker-compose exec postgres pg_dump -U frienduser friend_db > backup.sql

# Create compressed backup
docker-compose exec postgres pg_dump -U frienduser friend_db | gzip > backup.sql.gz
```

### Restore Database
```bash
# From backup
docker-compose exec postgres psql -U frienduser friend_db < backup.sql

# From compressed backup
gunzip < backup.sql.gz | docker-compose exec postgres psql -U frienduser friend_db
```

### Reset Database
```bash
# WARNING: This deletes all data!
docker-compose down -v
docker-compose up -d
```

---

## 🔐 Environment Configuration

### Using .env File
```bash
# Copy example
cp .env.example .env

# Edit with your values
nano .env  # or use your editor

# Reload services to apply changes
docker-compose restart api
```

### Important Variables
```bash
# Database
DATABASE_URL=postgres://frienduser:friendpass123@postgres:5432/friend_db

# JWT
JWT_SECRET=your_super_secret_key_here
JWT_REFRESH_SECRET=your_refresh_secret_here

# Redis
REDIS_URL=redis://redis:6379

# CORS
CORS_ORIGIN=http://localhost:3001,http://localhost:8080

# Email (for production)
SMTP_HOST=smtp.gmail.com
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password
```

---

## 📦 Volume Management

### View Volumes
```bash
docker volume ls | grep friend
```

### Inspect Volume
```bash
docker volume inspect friend_postgres_data
```

### Clean Up Unused Volumes
```bash
docker volume prune
```

### Mount Local Directory for Development
Edit `docker-compose.yml`:
```yaml
volumes:
  - ./backend:/app
  - /app/node_modules  # Keep node_modules in container
```

---

## 🚀 Development Workflow

### 1. Initial Setup
```bash
cp .env.example .env
docker-compose up -d
docker-compose logs -f api
```

### 2. Make Changes
```bash
# Edit your code in ./backend/src/
# Changes are auto-detected due to volumes and nodemon
```

### 3. Test Changes
```bash
curl http://localhost:3000/health
```

### 4. View Database
```bash
# Via PgAdmin: http://localhost:5050
# Or command line: docker-compose exec postgres psql -U frienduser -d friend_db
```

### 5. Stop When Done
```bash
docker-compose stop
```

---

## 🐛 Troubleshooting

### Port Already in Use

**Error:** `Bind for 0.0.0.0:3000 failed`

**Solution:**
```bash
# Find process using port 3000
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows

# Kill process
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows

# Or use different port in docker-compose.yml
# Change "3000:3000" to "3001:3000"
```

### Database Connection Failed

**Error:** `Error: connect ECONNREFUSED 127.0.0.1:5432`

**Solution:**
```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Check logs
docker-compose logs postgres

# Restart
docker-compose restart postgres
```

### Redis Connection Failed

**Error:** `Error: connect ECONNREFUSED 127.0.0.1:6379`

**Solution:**
```bash
# Check Redis is running
docker-compose ps redis

# Check logs
docker-compose logs redis

# Restart
docker-compose restart redis
```

### Permission Denied

**Error:** `permission denied while trying to connect to the Docker daemon`

**Solution:**
```bash
# Add user to docker group (Linux)
sudo usermod -aG docker $USER
newgrp docker

# Or use sudo
sudo docker-compose up -d
```

### Container Won't Start

**Error:** Service constantly restarting

**Solution:**
```bash
# Check logs
docker-compose logs <service_name>

# Rebuild
docker-compose down
docker-compose up -d --build

# Check for dependency issues
docker-compose logs postgres
docker-compose logs redis
```

### Out of Disk Space

**Error:** `No space left on device`

**Solution:**
```bash
# Clean up Docker
docker system prune -a

# Remove unused volumes
docker volume prune
```

---

## 📊 Monitoring & Health Checks

### API Health
```bash
curl http://localhost:3000/health
```

### Database Health
```bash
docker-compose exec postgres pg_isready -U frienduser -h postgres -p 5432
```

### Redis Health
```bash
docker-compose exec redis redis-cli ping
```

### Docker Resources
```bash
docker stats
```

---

## 🔄 Updating Services

### Update Docker Images
```bash
# Pull latest images
docker-compose pull

# Restart services
docker-compose up -d
```

### Update Code
```bash
# If using git
git pull origin main

# Rebuild
docker-compose build api
docker-compose up -d api
```

---

## 🛑 Cleanup

### Stop Services
```bash
docker-compose stop
```

### Remove Containers
```bash
docker-compose down
```

### Remove Everything (Including Volumes)
```bash
# WARNING: This deletes all data!
docker-compose down -v
```

### Remove Images
```bash
docker-compose down --rmi all
```

---

## 📚 Next Steps

1. **Access the API**: http://localhost:3000
2. **Check API Docs**: http://localhost:3000/api-docs
3. **Access Database**: http://localhost:5050 (PgAdmin)
4. **View Cache**: http://localhost:8081 (Redis Commander)
5. **Read the docs**: See [07_GETTING_STARTED.md](../PROJECT_DOCUMENTATION/07_GETTING_STARTED.md)

---

## 💡 Pro Tips

1. **Hot Reload**: Changes in `backend/src/` automatically reload (via nodemon)
2. **Database Persistence**: Data persists in Docker volumes even after `docker-compose down`
3. **Environment Variables**: Reload with `docker-compose restart api`
4. **Development**: Keep `docker-compose logs -f` open in another terminal
5. **Performance**: On Windows/Mac, Docker runs in a VM - may be slower

---

## Need Help?

- **API Documentation**: See [03_API_ENDPOINTS.md](../PROJECT_DOCUMENTATION/03_API_ENDPOINTS.md)
- **Database Schema**: See [COMPLETE_DATABASE_SCHEMA.md](../database_schema/COMPLETE_DATABASE_SCHEMA.md)
- **Full Setup Guide**: See [07_GETTING_STARTED.md](../PROJECT_DOCUMENTATION/07_GETTING_STARTED.md)
- **Architecture**: See [01_ARCHITECTURE_OVERVIEW.md](../PROJECT_DOCUMENTATION/01_ARCHITECTURE_OVERVIEW.md)
