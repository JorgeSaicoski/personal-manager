# Personal Manager - Deployment Guide

Complete step-by-step guide for deploying Personal Manager from development to production.

## 🚀 Quick Deployment

### Prerequisites

```bash
# Install Docker/Podman
# Install htpasswd (usually in apache2-utils package)
sudo apt install apache2-utils

# Clone repository
git clone --recurse-submodules https://github.com/YourUsername/personal-manager.git
cd personal-manager
```

### 1. Infrastructure Setup

```bash
# Create Docker network and volumes
podman network create app-network
podman volume create postgres_data
podman volume create keycloak_data
```

### 2. Security Configuration

```bash
# Set admin panel password
cd infra/nginx

# Fix file permissions for rootless containers
chmod 644 nginx.conf

# Create admin password
htpasswd -c .htpasswd admin
chmod 644 .htpasswd

# Generate random admin route
ADMIN_SECRET=$(openssl rand -hex 8)
echo "Your admin route will be: /admin/db-${ADMIN_SECRET}/"
```

**Update nginx.conf:**
```bash
# Edit the admin route
nano nginx.conf
# Change: /admin/db-a1b2c3d4e5f6/
# To: /admin/db-[your-generated-secret]/
```

### 3. Change Default Passwords

**Database (infra/db/docker-compose.yaml):**
```yaml
environment:
  POSTGRES_PASSWORD: YOUR_SECURE_DB_PASSWORD
  PGADMIN_DEFAULT_EMAIL: your-email@domain.com
  PGADMIN_DEFAULT_PASSWORD: YOUR_SECURE_PGADMIN_PASSWORD
```

**Keycloak (infra/sso/docker-compose.yaml):**
```yaml
environment:
  KEYCLOAK_ADMIN_PASSWORD: YOUR_SECURE_KEYCLOAK_PASSWORD
  DB_PASSWORD: YOUR_SECURE_DB_PASSWORD  # Must match database password
```

**Backend (go-todo-list/docker-compose.yaml):**
```yaml
environment:
  POSTGRES_PASSWORD: YOUR_SECURE_DB_PASSWORD  # Must match database password
```

### 4. Deploy

```bash
# Development
docker-compose up

# Production (detached)
docker-compose up -d
```

## 🔒 Production Security Checklist

### Before Going Live

- [ ] **Change admin route** in `nginx.conf`
- [ ] **Set strong passwords** for all services
- [ ] **Configure SSL/HTTPS** for your domain
- [ ] **Set up IP restrictions** for admin access
- [ ] **Review CORS settings** in backend
- [ ] **Enable proper logging**
- [ ] **Set up monitoring**
- [ ] **Configure automated backups**

### SSL/HTTPS Setup

1. **Get SSL Certificate** (Let's Encrypt recommended):
```bash
# Install certbot
sudo apt install certbot

# Get certificate
sudo certbot certonly --standalone -d yourdomain.com
```

2. **Update nginx.conf** for HTTPS:
```nginx
server {
    listen 443 ssl http2;
    server_name yourdomain.com;
    
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    
    # ... rest of your configuration
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}
```

3. **Mount SSL certificates**:
```yaml
# nginx/docker-compose.yaml
volumes:
  - ./nginx.conf:/etc/nginx/conf.d/default.conf
  - ./.htpasswd:/etc/nginx/.htpasswd
  - /etc/letsencrypt:/etc/letsencrypt:ro  # Add this
```

## 🔧 Environment-Specific Configuration

### Development Environment

```bash
# Use localhost URLs
NEXT_PUBLIC_TASK_SERVICE_URL=/api
NEXT_PUBLIC_KEYCLOAK_URL=/api/auth

# Enable detailed logging
GIN_MODE=debug
```

### Production Environment

```bash
# Use production domain
NEXT_PUBLIC_TASK_SERVICE_URL=https://yourdomain.com/api
NEXT_PUBLIC_KEYCLOAK_URL=https://yourdomain.com/api/auth

# Production optimizations
GIN_MODE=release
NODE_ENV=production
```

## 🏗️ Advanced Deployment Options

### Using Environment Files

Create `.env` files for each service:

**Main .env:**
```env
DOMAIN_NAME=yourdomain.com
ADMIN_ROUTE_SECRET=your-secret-here
DB_PASSWORD=your-db-password
```

**Frontend .env:**
```env
NEXT_PUBLIC_TASK_SERVICE_URL=/api
NEXT_PUBLIC_KEYCLOAK_URL=/api/auth
NODE_ENV=production
```

### Using Docker Secrets (Swarm)

```yaml
# docker-compose.prod.yaml
version: '3.8'
services:
  db:
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password

secrets:
  db_password:
    external: true
```

### Health Checks and Monitoring

Add comprehensive health checks:

```yaml
# Each service should have:
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

## 📊 Monitoring and Maintenance

### Log Management

```bash
# View logs
podman compose logs -f [service_name]

# Rotate logs
podman compose restart nginx

# Clean old logs
podman system prune -f
```

### Backup Strategy

```bash
#!/bin/bash
# backup.sh
DATE=$(date +%Y%m%d_%H%M%S)

# Database backup
podman exec shared-db pg_dump -U postgres shared_db | gzip > "db_backup_${DATE}.sql.gz"

# Configuration backup
tar -czf "config_backup_${DATE}.tar.gz" infra/

# Keep only last 30 days
find . -name "*backup*.gz" -mtime +30 -delete
```

### Update Strategy

```bash
# 1. Backup current state
./backup.sh

# 2. Pull latest code
git pull origin main
git submodule update --remote

# 3. Rebuild and restart
podman compose build --no-cache
podman compose up -d

# 4. Verify everything works
curl https://yourdomain.com/health
```

## 🔧 Troubleshooting

### Common Issues

**Services can't connect:**
```bash
# Check network
podman network ls | grep app-network

# Check service status
podman ps

# Check logs
podman compose logs [service]
```

**Permission denied:**
```bash
# Fix file permissions
chmod +x scripts/*.sh
chown -R $USER:$USER .
```

**Out of disk space:**
```bash
# Clean Docker
podman system prune -a -f
podman volume prune -f
```

### Emergency Recovery

```bash
# Quick restart everything
podman compose down
podman compose up -d

# Reset to known good state
git checkout HEAD~1
podman compose down
podman compose up -d --build
```

## 📞 Support

For deployment issues:

1. Check service logs: `podman compose logs [service]`
2. Verify configuration files match templates
3. Ensure all passwords are consistent across services
4. Check network connectivity between containers
5. Review security settings (firewall, SELinux, etc.)

---

**Remember**: Always test deployment in a staging environment before production!