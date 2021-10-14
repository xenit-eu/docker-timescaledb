#!/bin/bash

if [[ -v DB_NAME ]]; then
  echo "psql -h localhost -U postgres -c \"CREATE DATABASE $DB_NAME;\""
  psql -h localhost -U postgres -c "CREATE DATABASE $DB_NAME;"

  echo "psql -h localhost -U postgres -d $DB_NAME -c \"CREATE EXTENSION IF NOT EXISTS timescaledb WITH VERSION '$TIMESCALEDB_VERSION' CASCADE;\""
  psql -h localhost -U postgres -d $DB_NAME -c "CREATE EXTENSION IF NOT EXISTS timescaledb WITH VERSION '$TIMESCALEDB_VERSION' CASCADE;"

else
  echo "psql \"$@\" -c \"CREATE EXTENSION IF NOT EXISTS timescaledb WITH VERSION '$TIMESCALEDB_VERSION' CASCADE;\""
  psql "$@" -c "CREATE EXTENSION IF NOT EXISTS timescaledb WITH VERSION '$TIMESCALEDB_VERSION' CASCADE;"
fi

if [[ -v DB_ADMIN ]]; then
  echo "psql -h localhost -U postgres -d ${DB_NAME:-postgres} -c \"CREATE USER $DB_ADMIN WITH PASSWORD '<password>';\""
  psql -h localhost -U postgres -d ${DB_NAME:-postgres} -c "CREATE USER $DB_ADMIN WITH PASSWORD '$DB_PW';"

  echo "psql -h localhost -U postgres -d ${DB_NAME:-postgres} -c \"GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME:-postgres} TO $DB_ADMIN;\""
  psql -h localhost -U postgres -d ${DB_NAME:-postgres} -c "GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME:-postgres} TO $DB_ADMIN;"

fi

if [[ -v PROMSCALE_INIT ]]; then
  # initialize promscale db
  echo "promscale -db-uri \"postgres://postgres@localhost/${DB_NAME:-postgres}?sslmode=allow\" -migrate only"
  promscale -db-uri "postgres://postgres@localhost/${DB_NAME:-postgres}?sslmode=allow" -migrate only

  if [[ -v DB_ADMIN ]]; then
    echo "psql -h localhost -U postgres -d ${DB_NAME:-postgres} -c \"GRANT prom_admin TO $DB_ADMIN;\""
    psql -h localhost -U postgres -d ${DB_NAME:-postgres} -c "GRANT prom_admin TO $DB_ADMIN;"
  fi

  if [[ -v PROMSCALE_DEFAULT_RETENTION_PERIOD ]]; then
    # default set by promscale is '90 days'
    echo "psql -h localhost -U postgres -d ${DB_NAME:-postgres} -c \"SELECT prom_api.set_default_retention_period(INTERVAL '$PROMSCALE_DEFAULT_RETENTION_PERIOD' );\""
    psql -h localhost -U postgres -d ${DB_NAME:-postgres} -c "SELECT prom_api.set_default_retention_period(INTERVAL '$PROMSCALE_DEFAULT_RETENTION_PERIOD' );"
  fi

  if [[ -v PROMSCALE_DEFAULT_CHUNK_INTERVAL ]]; then
    # default set by promscale is '8 hours'
    echo "psql -h localhost -U postgres -d ${DB_NAME:-postgres} -c \"SELECT prom_api.set_default_chunk_interval(INTERVAL '$PROMSCALE_DEFAULT_CHUNK_INTERVAL' );\""
    psql -h localhost -U postgres -d ${DB_NAME:-postgres} -c "SELECT prom_api.set_default_chunk_interval(INTERVAL '$PROMSCALE_DEFAULT_CHUNK_INTERVAL' );"
  fi
fi

