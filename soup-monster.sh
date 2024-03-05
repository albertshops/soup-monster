#!/bin/bash

# Check if a project name is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <project-name>"
    exit 1
fi

PROJECT_NAME="$1"
REPO_URL="https://github.com/albertshops/soup-monster"
CLONE_DIR="docker"

# Function to find unused ports - Placeholder implementation
find_unused_ports() {
    local ports=()
    for i in {1..3}; do
        while : ; do
            port=$(shuf -i 2000-65000 -n 1)
            if ! netstat -tuln | grep -q ":$port "; then
                ports+=($port)
                break
            fi
        done
    done
    echo "${ports[@]}"
}

# Clone the repo if the directory doesn't exist
if [ ! -d "$CLONE_DIR" ]; then
    git clone "$REPO_URL" "$CLONE_DIR"
else
    echo "Directory $CLONE_DIR already exists, skipping clone."
fi

# Navigate to the docker directory
cd "$CLONE_DIR"

# Replace the first line in docker-compose.yml, adjusting for macOS compatibility
sed -i '' "1s/.*/name: $PROJECT_NAME/" docker-compose.yml

# Copy .env.example to .env if .env doesn't already exist
if [ ! -f ".env" ]; then
    cp .env.example .env
else
    echo ".env file already exists, skipping copy."
fi

# Find unused ports
read -r POSTGRES_PORT KONG_HTTPS_PORT KONG_HTTP_PORT <<< $(find_unused_ports)

# Replace ports in .env
sed -i '' "s/POSTGRES_PORT=5432/POSTGRES_PORT=$POSTGRES_PORT/" .env
sed -i '' "s/KONG_HTTPS_PORT=8443/KONG_HTTPS_PORT=$KONG_HTTPS_PORT/" .env
sed -i '' "s/KONG_HTTP_PORT=8000/KONG_HTTP_PORT=$KONG_HTTP_PORT/" .env

# Since SUPABASE_PUBLIC_URL and API_EXTERNAL_URL depend on KONG_HTTP_PORT, update them too
sed -i '' "s/SUPABASE_PUBLIC_URL=http:\/\/localhost:8000/SUPABASE_PUBLIC_URL=http:\/\/localhost:$KONG_HTTP_PORT/" .env
sed -i '' "s/API_EXTERNAL_URL=http:\/\/localhost:8000/API_EXTERNAL_URL=http:\/\/localhost:$KONG_HTTP_PORT/" .env

echo "Supabase URL: http://localhost:${KONG_HTTP_PORT}"
