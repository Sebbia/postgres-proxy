# Postgres Proxy

Using [`postgres_fdw`](https://www.postgresql.org/docs/current/postgres-fdw.html) to stitch several databases into one.

Usage in `docker-compose.yml`:

```yaml
  proxy_db:
    restart: always
    image: sebbia/postgres-proxy:10.5-alpine
    healthcheck:
      test: "pg_isready -q -h db -U postgres"
      interval: 3s
      timeout: 5s
      retries: 50
    environment:
      - DATABASES=users,events,files
      - SERVER_URL=db
```

Sources: https://github.com/Sebbia/postgres-proxy