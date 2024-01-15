#!/usr/bin/env bash

set -e

echo "Hello from proxy postgres entrypoint"
echo "Parameters: $*"
echo "Databases: ${DATABASES}"
echo "Database server: ${SERVER_URL}"

export SERVER_PORT="${SERVER_PORT:-5432}"
export POSTGRES_USER="${POSTGRES_USER:-postgres}"
export POSTGRES_DB="${POSTGRES_DB:-POSTGRES_USER}"

echo "Database port: ${SERVER_PORT}"
echo "Database user: ${POSTGRES_USER}"
echo "Database password: ${POSTGRES_PASSWORD}"

initDatabases() {

    export PGUSER="${POSTGRES_USER}"

    until psql -l | awk '{print $1}' | grep "^${POSTGRES_DB}\$" &>/dev/null
    do
        echo "Waiting for postgres start and create db... "
        sleep 1
    done

    psql <<- EOSQL
    CREATE EXTENSION IF NOT EXISTS postgres_fdw;
EOSQL

    IFS=',' read -ra DBS <<< "${DATABASES}"
    for DB_NAME in "${DBS[@]}"; do
        if ! psql -U "${POSTGRES_USER}" -l | awk '{print $1}' | grep "^${DB_NAME}\$" &>/dev/null; then
            echo "Connect to server: ${DB_NAME}"
            psql <<- EOSQL
            DROP SERVER IF EXISTS ${DB_NAME} CASCADE;
            DROP SCHEMA IF EXISTS ${DB_NAME} CASCADE;
            CREATE SERVER IF NOT EXISTS ${DB_NAME}
            FOREIGN DATA WRAPPER postgres_fdw
            OPTIONS (host '${SERVER_URL}', dbname '${DB_NAME}', port '${SERVER_PORT}', updatable 'false');

            CREATE USER MAPPING IF NOT EXISTS FOR ${POSTGRES_USER}
            SERVER ${DB_NAME}
            OPTIONS (user '${DB_NAME}', password '${DB_NAME}');

            CREATE SCHEMA IF NOT EXISTS ${DB_NAME};

            IMPORT FOREIGN SCHEMA public
            EXCEPT (flyway_schema_history)
            FROM SERVER ${DB_NAME} INTO ${DB_NAME};
EOSQL
        fi
    done
}

initDatabases &

/docker-entrypoint.sh $*
