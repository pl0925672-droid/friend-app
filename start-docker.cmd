@echo off
REM Friend App - Docker Quick Start Script for Windows
REM This script sets up and starts the Friend App development environment

setlocal enabledelayedexpansion

REM Check Docker is installed
echo.
echo ===================================================
echo Checking Prerequisites
echo ===================================================

where docker >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo X Docker is not installed
    echo Please install Docker from https://www.docker.com/get-started
    pause
    exit /b 1
)
echo [OK] Docker is installed

where docker-compose >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo X Docker Compose is not installed
    echo Please install Docker Compose
    pause
    exit /b 1
)
echo [OK] Docker Compose is installed

REM Setup environment
echo.
echo ===================================================
echo Setting up Environment
echo ===================================================

if not exist .env (
    echo [!] .env file not found
    if exist .env.example (
        echo [+] Copying .env.example to .env
        copy .env.example .env
        echo [OK] .env file created
        echo [!] Please update .env with your settings!
    ) else (
        echo X .env.example not found
        pause
        exit /b 1
    )
) else (
    echo [OK] .env file exists
)

REM Start Docker services
echo.
echo ===================================================
echo Starting Docker Services
echo ===================================================
echo.
echo [+] Building images (this may take a few minutes)...
docker-compose build
if %ERRORLEVEL% NEQ 0 (
    echo X Failed to build images
    pause
    exit /b 1
)

echo [+] Starting services...
docker-compose up -d
if %ERRORLEVEL% NEQ 0 (
    echo X Failed to start services
    pause
    exit /b 1
)
echo [OK] Services started

REM Show status
echo.
echo ===================================================
echo Services Status
echo ===================================================
docker-compose ps

REM Wait a moment for services to start
echo.
echo [+] Waiting for services to be ready...
timeout /t 5 /nobreak

REM Show info
echo.
echo ===================================================
echo Getting Started - Friend App is Running!
echo ===================================================
echo.
echo Services:
echo   . API:              http://localhost:3000
echo   . API Docs:         http://localhost:3000/api-docs
echo   . PgAdmin:          http://localhost:5050 (admin@friend.local / admin123)
echo   . Redis Commander:  http://localhost:8081
echo.
echo Database Credentials:
echo   . Host:     localhost
echo   . Port:     5432
echo   . User:     frienduser
echo   . Password: friendpass123
echo   . Database: friend_db
echo.
echo Useful Commands:
echo   . View logs:        docker-compose logs -f api
echo   . Stop services:    docker-compose stop
echo   . Restart services: docker-compose restart
echo.
echo Documentation:
echo   . Docker Setup:     DOCKER_SETUP_GUIDE.md
echo   . API Docs:         PROJECT_DOCUMENTATION/03_API_ENDPOINTS.md
echo   . Database:         database_schema/COMPLETE_DATABASE_SCHEMA.md
echo.
echo =================================================== 
echo Setup Complete! 
echo =================================================== 
echo.

pause
