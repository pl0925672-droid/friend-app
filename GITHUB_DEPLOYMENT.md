# 🚀 GitHub Deployment Guide

## Step 1: Initialize Git Repository

```bash
# Navigate to project directory
cd c:\Users\skris\Desktop\friend

# Initialize git
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Friend App with authentication and real database"

# Check git status
git status
```

## Step 2: Create GitHub Repository

1. Go to https://github.com/new
2. **Repository name**: `friend-app` (or your preferred name)
3. **Description**: "Study • Connect • Grow - A social learning platform"
4. **Public** or **Private** (your choice)
5. **Do NOT** initialize with README (we already have one)
6. Click "Create repository"

## Step 3: Push to GitHub

```bash
# Add remote origin (replace with your repo URL)
git remote add origin https://github.com/yourusername/friend-app.git

# Rename branch to main if needed
git branch -M main

# Push to GitHub
git push -u origin main
```

## Step 4: Deploy Backend + Frontend

### Option A: Deploy to Render (Recommended - Free tier available)

1. **Go to**: https://render.com
2. **Sign up** with GitHub account
3. **Create Web Service**:
   - Select: "Connect GitHub account"
   - Choose: `friend-app` repository
   - Environment: `Node`
   - Build command: `npm install`
   - Start command: `npm start`
   - Add ENV variables from `.env.example`:
     ```
     JWT_SECRET = (generate a strong secret)
     NODE_ENV = production
     PORT = 3000
     ```
4. Click "Create Web Service"
5. **Deployment starts automatically!**

After deployment, your app will be at: `https://your-app.onrender.com`

### Option B: Deploy to Railway (Free with GitHub)

1. **Go to**: https://railway.app
2. **Login with GitHub**
3. **Create Project** → Select your `friend-app` repo
4. **Railway auto-detects** Node.js project
5. **Add Variables** (in Railway dashboard):
   ```
   JWT_SECRET = (strong secret)
   NODE_ENV = production
   ```
6. **Deploy** - happens automatically!

Your app will be at: `https://your-app.railway.app`

### Option C: Deploy to Heroku

```bash
# Install Heroku CLI
npm install -g heroku

# Login with GitHub
heroku login

# Create app
heroku create friend-app-yourname

# Add buildpack for Node.js
heroku buildpacks:set heroku/nodejs

# Set environment variables
heroku config:set JWT_SECRET="your_secret_here"
heroku config:set NODE_ENV="production"

# Deploy from GitHub
git push heroku main

# View live app
heroku open

# See logs
heroku logs --tail
```

## Step 5: Generate Strong JWT Secret

```bash
# Generate a strong random secret
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Copy output and set as JWT_SECRET in your deployment platform
```

## Step 6: Setup Custom Domain (Optional)

### On Render:
1. Go to your Web Service settings
2. Click "Custom Domain"
3. Add your domain name
4. Copy the CNAME record
5. Update DNS in your domain registrar

### On Railway:
1. Generate a domain in "Public Networking"
2. Or use custom domain with DNS settings

## Step 7: Enable HTTPS

All deployment platforms (Render, Railway, Heroku) provide **free SSL certificates** automatically. You get HTTPS for free! ✅

## Step 8: Frontend Routing

Update your login page to use the production URL:

```javascript
// In public/login.html
const API_BASE = window.location.origin; // Uses current domain
// Or explicitly:
// const API_BASE = 'https://your-app.onrender.com';
```

## Step 9: Monitor & Debug

### View Logs:

**Render**:
- Dashboard → Logs tab (real-time)

**Railway**:
- Dashboard → View logs

**Heroku**:
```bash
heroku logs --tail
heroku logs -n 50  # Last 50 lines
```

### Common Issues:

**Port error**:
```
Add to platform env: PORT=3000
```

**Database locked**:
- Database resets on Render free tier with redeploys
- Add persistent volume for production

**CORS errors**:
```javascript
// Update server-real.js:
app.use(cors({
    origin: 'https://your-deployed-url.com',
    credentials: true
}));
```

## Step 10: Setup Auto-Deploy

### GitHub Actions (Automatic Deployment)

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Render

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Trigger Render deploy
        run: curl https://api.render.com/deploy/srv-... 
        # Get webhook URL from Render dashboard
```

## Production Checklist ✅

- [ ] `.env` file added to `.gitignore`
- [ ] Strong `JWT_SECRET` generated and set
- [ ] `NODE_ENV=production` set on server
- [ ] CORS configured for your domain
- [ ] Database URL configured (SQLite works on all platforms)
- [ ] Logs being monitored
- [ ] Health check endpoint working: `/health`
- [ ] Login page redirects to dashboard after auth
- [ ] Token persists in localStorage

## 📊 Monitoring & Analytics

### Add Error Tracking (Sentry)

1. Go to https://sentry.io
2. Create free account
3. Create project for Node.js
4. Install:
```bash
npm install @sentry/node
```

5. Add to `server-real.js`:
```javascript
import * as Sentry from "@sentry/node";

Sentry.init({
    dsn: "your_sentry_dsn",
    environment: process.env.NODE_ENV
});
```

## 🔄 Future Enhancements

- [ ] Add database backups
- [ ] Setup monitoring alerts
- [ ] Add CDN for static files
- [ ] Implement rate limiting
- [ ] Add API documentation (Swagger)
- [ ] Setup staging environment

## 📞 Need Help?

- **Render Support**: https://render.com/docs
- **Railway Help**: https://railway.app/docs
- **Heroku Docs**: https://devcenter.heroku.com/

---

## Commands Quick Reference

```bash
# Local development
npm install
npm run dev

# Check git status
git status

# Push changes
git add .
git commit -m "Your message"
git push

# View deployment logs
# (Use platform-specific commands above)

# Test API locally before deployment
curl http://localhost:3000/health
```

**Your app should now be live! 🎉**
