# Project POS Backend

NestJS API for Project POS. The backend serves the POS mobile client and external CRM/accounting integrations.

## Local development

```bash
npm install
cp .env.example .env
npm run start:dev
```

## Useful commands

```bash
npm run lint:check
npm run test -- --runInBand
npm run build
```

## Production Docker deployment

This repository ships with a production-oriented compose stack in `docker-compose.prod.yml`.

### Included services

- `backend`: NestJS API running from the production Docker image
- `postgres`: PostgreSQL 16 with a persistent named volume
- `redis`: Redis 7 with append-only persistence
- `nginx`: reverse proxy terminating TLS and forwarding traffic to the API

### Production environment file

Create `backend/.env.production` from `backend/.env.production.example` and set real secrets before deploy.

Important production defaults:

- `NODE_ENV=production`
- `DB_SYNC=false`
- `DB_LOGGING=false`
- `DB_HOST=postgres`
- `REDIS_HOST=redis`

### TLS certificates

Place PEM files in `backend/nginx/certs/`:

- `fullchain.pem`
- `privkey.pem`

Those paths are mounted read-only into the Nginx container and are ignored by git.

### Bring the stack up

```bash
cd backend
docker compose -f docker-compose.prod.yml --env-file .env.production up -d --build
```

The API is then available behind Nginx on ports `80` and `443`. Traffic on port `80` is redirected to HTTPS.

## CI

GitHub Actions workflow lives at `.github/workflows/ci.yml` and runs:

- backend lint, test, and build
- frontend `flutter analyze` and `flutter test`
