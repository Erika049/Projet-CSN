#!/bin/sh
exec java \
  -Dspring.datasource.url="$DATABASE_URL" \
  -Dspring.datasource.username="$DATABASE_USERNAME" \
  -Dspring.datasource.password="$DATABASE_PASSWORD" \
  -Djwt.secret="$JWT_SECRET" \
  -Djwt.expiration="${JWT_EXPIRATION:-86400000}" \
  -Dhospital.allowed-networks="${ALLOWED_NETWORKS:-127.0.0.1}" \
  -jar app.jar