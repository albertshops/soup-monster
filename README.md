# Supabase Docker

This is a minimal Docker Compose setup for self-hosting Supabase AUTH + DB ONLY.

##

- Replace 'name' in docker-compose file with project name
- Replace POSTGRES_PORT, KONG_HTTP_PORT, KONG_HTTPS_PORT with unused ports
  - check if port is in use with `lsof` eg. `lsof -i :16000`

##

- might also need to change API_EXTERNAL_URL and SUPABASE_PUBLIC_URL to same port as KONG_HTTP_PORT
