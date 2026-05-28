# milesbellaire.com Deployment Orchestration

This repository contains the deployment orchestration for the milesbellaire.com web application. It uses Docker Compose to manage frontend, backend, and database services.

## Architecture

The deployment consists of three main services:

- **Frontend**: Serves the web application (ports defined in `.env`)
- **Backend**: Handles API requests (port `8080`)
- **MySQL**: Database for persistent storage
- **Swagger**: Access Backend API when in development

## Source Repositories

- **Frontend**: https://github.com/milesbellaire/milesbellaireFE
- **Backend**: https://github.com/milesbellaire/milesbellaireBE

## CI/CD Pipeline

The frontend and backend source code are automatically built and pushed to GitHub Container Registry (ghcr.io) when changes are pushed to their respective repositories:

| Repo | Branch | Image Tag |
|------|--------|-----------|
| milesbellaireFE | master | ghcr.io/milesbellaire/milesbellairefe:latest |
| milesbellaireBE | main | ghcr.io/milesbellaire/milesbellairebe:latest |

The deployment workflow in each repo (`.github/workflows/deploy.yml`) automatically:
1. Builds the Docker image
2. Pushes it to ghcr.io using the GitHub Actions runner
3. Tags the image as `latest`

Production deployment in `milesbellaireIO` pulls these pre-built images from ghcr.io, avoiding the need for manual image builds during deployment.

## Prerequisites

- Docker and Docker Compose installed
- `.env` file configured with required variables (see `.env.example`)

## Configuration

The `.env` file contains the following variables:

```bash
MYSQL_ROOT_PASSWORD=      # Root password for MySQL
MYSQL_PASSWORD=           # Application database password
DB_USER=                  # Database username
DB_NAME=                  # Database name
FRONTEND_PORT=            # Frontend port mapping
TUNNEL_TOKEN=             # CloudFlare tunnel token (for tunnel profile)
ENABLE_TUNNEL=            # Enable CloudFlare tunnel (true/false)
```

## Quick Start

### Production Deployment

```bash
./deploy.sh
```

or for continuous deployment, add the following line as a cron job

```
* * * * * /home/deploy/milesbellaireIO/deploy.sh >> /home/deploy/milesbellaireIO/deploy.log 2>&1
```

The deployment script will:
1. Pull the latest orchestration files from the repo
2. Pull the latest Docker images from GHCR
3. Apply the changes to running containers
4. Clean up old images

### Development Setup

```bash
docker compose -f milesbellaireIO/docker-compose.yml -f milesbellaireIO/docker-compose.dev.yml up --build
```

This uses local images built from the source code in `../milesbellaireFE` and `../milesbellaireBE`.

For frontend development, enable hot updates by mounting the frontend source code and using an in-browser HMR server. The docker-compose.dev.yml profile typically configures volumes for hot reload and a separate dev server for client-side updates.

## CloudFlare Tunneling

To enable tunneling, set `ENABLE_TUNNEL=true` in `.env` and start the service with the `tunnel` profile:

```bash
docker compose --profile tunnel up -d
```

## Usage

### View Logs

```bash
docker compose logs -f
```

### Stop Services

```bash
docker compose down
```

### Restart Services

```bash
docker compose restart
```

## Volume Persistence

MySQL data is stored in a Docker volume named `mysql_data`. To view volume info:

```bash
docker volume ls | grep mysql_data
docker volume inspect mysql_data
```