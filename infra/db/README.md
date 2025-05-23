# Database Infrastructure

PostgreSQL database setup with pgAdmin for administration, shared across all microservices.

## 📁 Files

```
infra/db/
├── docker-compose.yaml    # Database and pgAdmin containers
└── README.md             # This documentation
```

## 🗄️ Services

### PostgreSQL Database
- **Container**: `shared-db`
- **Port**: 5432 (internal only)
- **Database**: `shared_db`
- **User**: `postgres`
- **Password**: `yourpassword` (change this!)

### pgAdmin
- **Container**: `pgadmin`
- **Access**: `http://localhost/admin/db-[secret]/`
- **Email**: `admin@admin.com`
- **Password**: `admin` (change this!)

## 🚀 Quick Start

```bash
cd infra/db
podman compose up -d
```

## ⚙️ Configuration

### Environment Variables

Update credentials in `podman compose.yaml`:

```yaml
environment:
  POSTGRES_USER: your_username
  POSTGRES_PASSWORD: your_secure_password
  POSTGRES_DB: your_database_name
  
  PGADMIN_DEFAULT_EMAIL: your_email@domain.com
  PGADMIN_DEFAULT_PASSWORD: your_secure_password
```

### Health Check

The database includes automatic health monitoring:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U postgres"]
  interval: 5s
  timeout: 5s
  retries: 5
```

## 🔧 Access and Management

### Via pgAdmin Web Interface

1. Go to `http://localhost/admin/db-[secret]/`
2. Login with pgAdmin credentials
3. Add server connection:
   - **Host**: `shared-db`
   - **Port**: `5432`
   - **Database**: `shared_db`
   - **Username**: `postgres`
   - **Password**: Your database password

### Direct Connection (Development)

```bash
# Using psql
podman exec -it shared-db psql -U postgres -d shared_db

# Using external tools (when ports exposed)
psql -h localhost -p 5432 -U postgres -d shared_db
```

## 💾 Backup and Restore

### Manual Backup

```bash
# Full database dump
podman exec shared-db pg_dump -U postgres shared_db > backup.sql

# Compressed backup
podman exec shared-db pg_dump -U postgres shared_db | gzip > backup.sql.gz
```

### Restore

```bash
# From SQL file
podman exec -i shared-db psql -U postgres shared_db < backup.sql

# From compressed backup
gunzip -c backup.sql.gz | podman exec -i shared-db psql -U postgres shared_db
```

### Automated Backups (Optional)

Create backup script:

```bash
#!/bin/bash
# backup.sh
DATE=$(date +%Y%m%d_%H%M%S)
podman exec shared-db pg_dump -U postgres shared_db | gzip > "backup_${DATE}.sql.gz"

# Keep only last 7 backups
find . -name "backup_*.sql.gz" -mtime +7 -delete
```

## 🔒 Security Notes

- Change default passwords before production
- Consider using environment files for sensitive data
- Implement regular backup strategies
- Monitor database logs for suspicious activity

## 📊 Monitoring

### Check Database Status

```bash
# Container status
podman ps | grep shared-db

# Database logs
podman logs shared-db

# Connection test
podman exec shared-db pg_isready -U postgres
```