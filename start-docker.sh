#!/bin/bash

# Friend App - Docker Quick Start Script
# This script sets up and starts the Friend App development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check Docker is installed
check_docker() {
    print_header "Checking Prerequisites"
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        echo "Please install Docker from https://www.docker.com/get-started"
        exit 1
    fi
    print_success "Docker is installed"
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed"
        echo "Please install Docker Compose"
        exit 1
    fi
    print_success "Docker Compose is installed"
}

# Setup environment
setup_env() {
    print_header "Setting up Environment"
    
    if [ ! -f .env ]; then
        print_warning ".env file not found"
        if [ -f .env.example ]; then
            print_info "Copying .env.example to .env"
            cp .env.example .env
            print_success ".env file created"
            print_warning "Please update .env with your settings!"
        else
            print_error ".env.example not found"
            exit 1
        fi
    else
        print_success ".env file exists"
    fi
}

# Start Docker services
start_services() {
    print_header "Starting Docker Services"
    
    print_info "Building images (this may take a few minutes)..."
    docker-compose build
    
    print_info "Starting services..."
    docker-compose up -d
    
    print_success "Services started"
}

# Wait for services
wait_services() {
    print_header "Waiting for Services to Be Ready"
    
    print_info "Waiting for PostgreSQL..."
    for i in {1..30}; do
        if docker-compose exec postgres pg_isready -U frienduser &> /dev/null; then
            print_success "PostgreSQL is ready"
            break
        fi
        if [ $i -eq 30 ]; then
            print_error "PostgreSQL failed to start"
            exit 1
        fi
        echo -n "."
        sleep 1
    done
    
    print_info "Waiting for Redis..."
    for i in {1..30}; do
        if docker-compose exec redis redis-cli ping &> /dev/null; then
            print_success "Redis is ready"
            break
        fi
        if [ $i -eq 30 ]; then
            print_error "Redis failed to start"
            exit 1
        fi
        echo -n "."
        sleep 1
    done
    
    print_info "Waiting for API..."
    for i in {1..30}; do
        if curl -s http://localhost:3000/health > /dev/null; then
            print_success "API is ready"
            break
        fi
        if [ $i -eq 30 ]; then
            print_warning "API is still starting... check logs with: docker-compose logs api"
        fi
        echo -n "."
        sleep 1
    done
}

# Show status
show_status() {
    print_header "Services Status"
    docker-compose ps
}

# Show info
show_info() {
    print_header "Getting Started 🚀"
    
    echo ""
    print_info "Your Friend App is now running!"
    echo ""
    
    echo "📍 Services:"
    echo "  • API:              http://localhost:3000"
    echo "  • API Docs:         http://localhost:3000/api-docs"
    echo "  • PgAdmin:          http://localhost:5050 (admin@friend.local / admin123)"
    echo "  • Redis Commander:  http://localhost:8081"
    echo ""
    
    echo "🔌 Database Credentials:"
    echo "  • Host:     localhost"
    echo "  • Port:     5432"
    echo "  • User:     frienduser"
    echo "  • Password: friendpass123"
    echo "  • Database: friend_db"
    echo ""
    
    echo "📝 Useful Commands:"
    echo "  • View logs:        docker-compose logs -f api"
    echo "  • Stop services:    docker-compose stop"
    echo "  • Restart services: docker-compose restart"
    echo "  • View DB:          docker-compose exec postgres psql -U frienduser -d friend_db"
    echo "  • View cache:       docker-compose exec redis redis-cli"
    echo ""
    
    echo "📚 Documentation:"
    echo "  • Docker Setup:   DOCKER_SETUP_GUIDE.md"
    echo "  • API Docs:       PROJECT_DOCUMENTATION/03_API_ENDPOINTS.md"
    echo "  • Database:       database_schema/COMPLETE_DATABASE_SCHEMA.md"
    echo "  • Architecture:   PROJECT_DOCUMENTATION/01_ARCHITECTURE_OVERVIEW.md"
    echo ""
}

# Main execution
main() {
    echo ""
    print_header "Friend App - Docker Setup"
    echo ""
    
    check_docker
    echo ""
    
    setup_env
    echo ""
    
    start_services
    echo ""
    
    wait_services
    echo ""
    
    show_status
    echo ""
    
    show_info
    
    print_success "Setup Complete! 🎉"
}

# Run main function
main

# Exit successfully
exit 0
