# Personal Manager

A comprehensive personal management system built with microservices architecture. This platform serves as a central hub for personal organization, integrating multiple management modules through a unified API gateway.

## 🏗️ Architecture

```
Browser → Nginx Gateway (Port 80) → Microservices:
├── /                   → Next.js Frontend (Port 3000)
├── /api/tasks/*        → Go Task Service (Port 8000)
├── /api/auth/*         → Keycloak SSO (Port 8080)
├── /admin/[secret]/    → pgAdmin (Port 5050)
└── /health            → Health Check
```

## 📋 Current Features

- ✅ **Task Management**: Create, update, delete, and track tasks with different status levels
- ✅ **Authentication**: Keycloak SSO integration for secure user management
- ✅ **API Gateway**: Nginx reverse proxy for unified access
- ✅ **Database**: PostgreSQL with pgAdmin for administration

## 🔮 Planned Features

- [ ] **Finance Management**: Transaction tracking and budgeting
- [ ] **Calendar Integration**: Scheduling and time management
- [ ] **Notes System**: Personal documentation and notes
- [ ] **Analytics Dashboard**: Personal insights and metrics

## 📁 Project Structure

```
personal-manager/
├── frontend/                 # Next.js frontend application
├── go-todo-list/            # Go task management service
├── infra/
│   ├── nginx/               # API gateway configuration
│   ├── db/                  # Database and pgAdmin setup
│   └── sso/                 # Keycloak authentication service
├── docker-compose.yaml      # Main orchestration file
└── README.md               # This file
```

## 🚀 Quick Start

### Prerequisites

- Podman & Podman Compose (or Docker)
- Git

### 1. Clone the Repository

```bash
git clone --recurse-submodules https://github.com/JorgeSaicoski/personal-manager.git
cd personal-manager
```

### 2. Create Podman Network and Volumes

```bash
podman network create app-network
podman volume create postgres_data
podman volume create keycloak_data
```

### 3. Set Admin Security (Important!)

```bash
# Navigate to nginx directory
cd infra/nginx

# Fix file permissions for containers
chmod 644 nginx.conf

# Create password file for admin access
htpasswd -c .htpasswd admin
# Enter a secure password when prompted

# Set correct permissions for password file
chmod 644 .htpasswd
```


### 4. Configure Production Security

Before deploying to production, update `infra/nginx/nginx.conf`:

```nginx
# Change this secret path:
location /admin/db-a1b2c3d4e5f6/ {
# To something like:
location /admin/db-[your-random-string]/ {
```

### 5. Deploy

```bash
# Development
podman compose up

# If need to update the backend
podman compose up -d --build

# Production  
podman compose up -d
```
If using Docker change to "docker-compose"

## 🌐 Access Points

- **Application**: http://localhost
- **API Documentation**: http://localhost/api/tasks
- **Admin Panel**: http://localhost/admin/db-a1b2c3d4e5f6/ (change this!)
- **Health Check**: http://localhost/health

## 🔧 Development

### Individual Service Development

Each microservice can be developed independently:

```bash
# Task service only
cd go-todo-list
podman compose up

# Frontend only  
cd frontend
npm run dev

# Database only
cd infra/db
podman compose up
```

### Adding New Services

1. Create service directory: `my-new-service/`
2. Add docker-compose.yaml for the service
3. Update `infra/nginx/nginx.conf` with new routes:
   ```nginx
   location /api/mynewservice/ {
       proxy_pass http://my-new-service:8001/;
       # ... proxy headers
   }
   ```
4. Add service to main `docker-compose.yaml`

## 🔒 Security

### Production Checklist

- [ ] Change admin route in `nginx.conf`
- [ ] Set strong passwords for all services
- [ ] Configure IP restrictions for admin access
- [ ] Enable HTTPS with SSL certificates
- [ ] Update default Keycloak admin credentials
- [ ] Review and update CORS settings

### Default Credentials (Change in Production!)

- **pgAdmin**: admin@admin.com / admin
- **Keycloak**: admin / admin
- **Nginx Basic Auth**: Set during setup

## 📖 Documentation

- [Frontend Documentation](frontend/README.md)
- [Task Service Documentation](go-todo-list/README.md)
- [Nginx Gateway Documentation](infra/nginx/README.md)
- [Database Documentation](infra/db/README.md)
- [Authentication Documentation](infra/sso/README.md)

## 🔧 Custom Libraries & Ecosystem

This project leverages and contributes to a growing ecosystem of reusable Go libraries:

### Available Libraries
- ✅ **[pgconnect](https://github.com/JorgeSaicoski/pgconnect)** - Generic PostgreSQL repository pattern with GORM
- [ ] **keycloak-auth** - JWT validation middleware with automatic JWKS key rotation
- [ ] **go-api-gateway** - HTTP routing and proxy utilities for API gateway services
- [ ] **microservice-commons** - Shared utilities for microservice architecture (middleware, logging, config)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For issues and questions:
1. Check the documentation in each service directory
2. Review the GitHub issues
3. Create a new issue with detailed information