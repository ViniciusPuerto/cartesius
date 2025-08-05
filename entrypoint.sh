#!/usr/bin/env bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Wait for Postgres to be ready
until pg_isready -h "$PGHOST" -U "$PGUSER" > /dev/null 2>&1; do
  echo "Waiting for Postgres..."
  sleep 1
done

exec "$@"
