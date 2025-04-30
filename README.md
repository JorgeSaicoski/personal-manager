# Personal Manager

A comprehensive personal management system built with a Go backend and Next.js frontend. This repository serves as the main project container using Git submodules to manage the different components.

This platform aims to be a central hub for personal organization, integrating multiple management modules:
- [x] Task management
- [ ] Time management
- [ ] Finance tracking
- [ ] Notes and personal documentation
- [ ] And more planned features

## Project Structure

This repository is organized as follows:

- `frontend/`: Next.js frontend application (Git submodule)
- `go-todo-list/`: Go backend service (Git submodule)
- `infra/`: Infrastructure configuration
  - `db/`: PostgreSQL database configuration
  - `sso/`: Keycloak SSO service configuration

## Prerequisites

- Git
- Docker and Docker Compose
- Go 1.23+ (for backend development)
- Node.js 18.17.0+ (for frontend development)

## Setup

### 1. Clone the Repository

Clone the repository including all submodules:

```bash
git clone --recurse-submodules git@github.com:YourUsername/personal-manager.git
cd personal-manager
```

If you already cloned the repository without submodules:

```bash
git submodule init
git submodule update
```

### 2. Docker Setup

First, create the required Docker network and volumes:

```bash
docker network create app-network
docker volume create postgres_data
docker volume create keycloak_data
```

### 3. Running with Docker

To run the entire stack (recommended for full application testing):

```bash
docker-compose up
```

This will start:
- PostgreSQL database (port 5432)
- Keycloak SSO (port 8080)
- Go backend (port 8000)
- Next.js frontend (port 3000)

Access the application at http://localhost:3000

### 4. Development Setup

For development, you can work with each component separately:

#### Frontend Development:

```bash
cd frontend
npm install
npm run dev
```

The frontend will be available at http://localhost:3000

#### Backend Development:

```bash
cd go-todo-list
go run cmd/server/main.go
```

The API will be available at http://localhost:8000

#### Running Individual Services:

You can also run individual components with Docker:

```bash
# Database only
docker-compose -f infra/db/docker-compose.yaml up

# SSO service only
docker-compose -f infra/sso/docker-compose.yaml up

# Database + Backend (good for frontend development)
docker-compose up db todo-list
```

## Current Features

The application currently includes:

- **Task Management**: Create, view, update, and track tasks with different status levels
- **Intuitive UI**: Clean, paper-like interface designed for pleasant user experience
- **RESTful API**: Backend service with endpoints for task management

Additional modules planned for future development:
- Time tracking and scheduling
- Financial management
- Notes and documentation
- Personal analytics and insights

## API Endpoints

The backend currently provides the following endpoints:

- **GET /tasks**: Get all tasks
- **POST /task**: Create a new task
- **PATCH /task/update/:id**: Update a task
- **GET /**: Frontend UI

## Environment Variables

### Frontend

Create a `.env.local` file in the `frontend/` directory:

```
NEXT_PUBLIC_TASK_SERVICE_URL=http://localhost:8000
```

### Backend

Environment variables are configured in the docker-compose files. For local development without Docker, set up the following environment variables:

```
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=yourpassword
POSTGRES_DB=shared_db
POSTGRES_SSLMODE=disable
ALLOWED_ORIGINS=http://localhost:3000
```

## License

This project is licensed under the MIT License.