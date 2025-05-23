# Nginx API Gateway

The Nginx service acts as the unified entry point for the Personal Manager system, routing requests to appropriate microservices and providing security layers.

## 🏗️ Architecture

```
Client Request → Nginx Gateway → Backend Services
├── /                   → Frontend (Next.js)
├── /api/tasks/*        → Task Service (Go)
├── /api/auth/*         → Keycloak SSO
└── /admin/[secret]/*   → Admin Tools (pgAdmin)
```

## 📁 Files

```
infra/nginx/
├── nginx.conf           # Main configuration file
├── docker-compose.yaml  # Container definition
├── .htpasswd           # Basic auth passwords (create this)
└── README.md           # This documentation
```

## ⚙️ Configuration

### Basic Setup

The `nginx.conf` file contains all routing rules and proxy configurations. Key sections:

1. **Frontend Routing**: Serves the Next.js application
2. **API Routing**: Proxies API calls to backend services
3. **Admin Routing**: Secured access to admin tools
4. **Security Rules**: IP restrictions and auth requirements

### Adding New Services

To add a new microservice route:

```nginx
# Add to nginx.conf
location /api/newservice/ {
    proxy_pass http://newservice:8001/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

## 🔒 Security Configuration

### 1. Admin Route Security

**⚠️ CRITICAL: Change before production!**

Update the secret admin path in `nginx.conf`:

```nginx
# CHANGE THIS PATH:
location /admin/db-a1b2c3d4e5f6/ {
# TO SOMETHING RANDOM:
location /admin/db-$(openssl rand -hex 8)/ {
```

### 2. Basic Authentication Setup

Create password file for admin access:

```bash
cd infra/nginx

# Method 1: Interactive
htpasswd -c .htpasswd admin
# Enter password when prompted

# Method 2: Command line
echo "admin:$(openssl passwd -apr1 your_password)" > .htpasswd

# Method 3: Multiple users
htpasswd -c .htpasswd admin      # First user
htpasswd .htpasswd developer     # Additional users
```

### 3. IP Restrictions (Optional)

Add IP whitelist to admin routes:

```nginx
location /admin/your-secret-path/ {
    # Allow specific IPs
    allow 192.168.1.0/24;    # Local network
    allow 10.0.0.0/8;        # VPN range
    allow 203.0.113.0/24;    # Office IP range
    deny all;                # Deny everyone else
    
    # ... rest of proxy config
}
```

### 4. SSL/HTTPS (Production)

For production with SSL certificates:

```nginx
server {
    listen 443 ssl http2;
    server_name yourdomain.com;
    
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/private.key;
    
    # ... rest of configuration
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}
```

## 🚀 Deployment

### Development

```bash
cd infra/nginx
podman compose up
```

### Production

1. **Update security settings**:
   ```bash
   # Change admin route
   nano nginx.conf
   
   # Set strong passwords
   htpasswd -c .htpasswd admin
   ```

2. **Deploy**:
   ```bash
   podman compose up -d
   ```

### Environment Variables

Create `.env` file for environment-specific configs:

```env
# nginx/.env
ADMIN_ROUTE_SECRET=your-random-string-here
DOMAIN_NAME=yourdomain.com
SSL_CERT_PATH=/etc/nginx/ssl/cert.pem
SSL_KEY_PATH=/etc/nginx/ssl/private.key
```

## 🔧 Troubleshooting

### Common Issues

**1. 502 Bad Gateway**
```bash
# Check if backend services are running
podman ps | grep -E "(frontend|todo-list|keycloak)"

# Check nginx logs
podman logs api-gateway
```

**2. WebSocket connection failed (Next.js hot reload)**
```nginx
# Ensure WebSocket headers are set
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection 'upgrade';
```

**3. CORS issues**
```nginx
# Add CORS headers if needed
add_header Access-Control-Allow-Origin *;
add_header Access-Control-Allow-Methods "GET, POST, OPTIONS, PUT, DELETE";
```

**4. Admin panel 404**
```bash
# Verify secret path matches in nginx.conf
# Check .htpasswd file exists
ls -la .htpasswd

# Test basic auth
curl -u admin:password http://localhost/admin/your-secret-path/
```

### Debug Mode

Enable nginx debug logging:

```nginx
# Add to nginx.conf
error_log /var/log/nginx/error.log debug;
access_log /var/log/nginx/access.log;
```

View logs:
```bash
podman exec api-gateway tail -f /var/log/nginx/error.log
```

## 📊 Monitoring

### Health Checks

```bash
# Gateway health
curl http://localhost/health

# Service-specific health (through gateway)
curl http://localhost/api/tasks/health
```

### Performance Monitoring

Add monitoring endpoints:

```nginx
# nginx.conf
location /nginx-status {
    stub_status on;
    access_log off;
    allow 127.0.0.1;
    deny all;
}
```

## 🔄 Updates and Maintenance

### Configuration Reload

```bash
# Reload nginx config without downtime
podman exec api-gateway nginx -s reload
```

### Backup Configuration

```bash
# Backup current config
cp nginx.conf nginx.conf.backup.$(date +%Y%m%d)
```

### Log Rotation

```bash
# Rotate logs
podman exec api-gateway nginx -s reopen
```

## 📚 Advanced Configuration

### Rate Limiting

```nginx
# Add to nginx.conf
http {
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    
    server {
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            # ... proxy config
        }
    }
}
```

### Caching

```nginx
# Cache static assets
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### Load Balancing (Future)

```nginx
upstream backend_tasks {
    server task-service-1:8000;
    server task-service-2:8000;
    server task-service-3:8000;
}

location /api/tasks/ {
    proxy_pass http://backend_tasks;
    # ... proxy headers
}
```

---

**Security Reminder**: Always change default passwords and secret paths before production deployment!