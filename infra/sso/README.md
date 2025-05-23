# Keycloak SSO Authentication

Keycloak provides centralized authentication and authorization for all Personal Manager services.

## 📁 Files

```
infra/sso/
├── docker-compose.yaml    # Keycloak container configuration
└── README.md             # This documentation
```

## 🔑 Service Details

- **Container**: `keycloak`
- **Access**: `http://localhost/api/auth/`
- **Admin Console**: `http://localhost/api/auth/admin/`
- **Admin User**: `admin`
- **Admin Password**: `admin` (change this!)

## 🚀 Quick Start

```bash
cd infra/sso
podman compose up -d
```

## ⚙️ Initial Configuration

### 1. Access Admin Console

1. Go to `http://localhost/api/auth/admin/`
2. Login with `admin` / `admin`
3. **Immediately change the admin password!**

### 2. Create Realm (Optional)

For production, create a dedicated realm:

1. Click "Add realm"
2. Name: `personal-manager`
3. Enable the realm

### 3. Create Client Application

1. Go to Clients → Create
2. **Client ID**: `frontend-app`
3. **Client Protocol**: `openid-connect`
4. **Access Type**: `public`
5. **Valid Redirect URIs**: `http://localhost/*`

### 4. Configure Users

1. Go to Users → Add user
2. Set username and email
3. Go to Credentials tab
4. Set password (turn off "Temporary")

## 🔧 Environment Variables

Update credentials in `docker-compose.yaml`:

```yaml
environment:
  KEYCLOAK_ADMIN: your_admin_username
  KEYCLOAK_ADMIN_PASSWORD: your_secure_password
  # Database connection remains the same
```

## 🔒 Security Configuration

### Production Checklist

- [ ] Change default admin credentials
- [ ] Create dedicated realm for production
- [ ] Configure proper redirect URIs
- [ ] Enable HTTPS for production
- [ ] Set up email configuration
- [ ] Configure session timeouts
- [ ] Review and configure security policies

### SSL Configuration (Production)

```yaml
environment:
  KC_HOSTNAME: yourdomain.com
  KC_HOSTNAME_STRICT: true
  KC_PROXY: edge
```

## 📊 Monitoring

### Health Check

```bash
# Check container status
podman ps | grep keycloak

# View logs
podman logs keycloak

# Test authentication endpoint
curl http://localhost/api/auth/realms/master
```

### Common Issues

**1. Database Connection Issues**
- Ensure database is running before Keycloak
- Check database credentials in environment variables

**2. Slow Startup**
- Keycloak takes time to initialize
- Check logs for startup progress

**3. Redirect URI Issues**
- Verify client redirect URIs match your domain
- Use wildcards for development: `http://localhost/*`