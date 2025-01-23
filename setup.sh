# Check and install airbyte ctl if not already installed
if ! command -v abctl &> /dev/null; then
    echo "Installing airbyte ctl..."
    curl -LsfS https://get.airbyte.com | bash -
else
    echo "airbyte ctl already installed"
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cat > .env << EOL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
SUPERSET_ADMIN=admin
SUPERSET_PASSWORD=admin
SUPERSET_SECRET_KEY=ChangeMeToARandomStringChangeMeToARandomStringChangeMeTo
EOL
else
    echo ".env file already exists"
fi

# Check if airbyte is running before starting
if ! docker ps --format '{{.Names}}' | grep -q 'airbyte'; then
    echo "Starting airbyte in low resource mode..."
    abctl local install --low-resource-mode
else
    echo "airbyte already running"
fi

# Check if docker containers are running before starting compose
if ! docker ps -q &> /dev/null; then
    echo "Starting docker compose..."
    docker compose up --build
else
    echo "Docker containers already running"
fi

# Check credentials only if airbyte is running and accessible
if docker ps --format '{{.Names}}' | grep -q 'airbyte'; then
    echo "Checking airbyte health..."
    max_retries=5
    retry_count=0
    health_check_success=false
    
    # Try to get the mapped port
    airbyte_port=$(docker port $(docker ps -q --filter "name=airbyte") 8000/tcp 2>/dev/null | cut -d: -f2)
    
    if [ -z "$airbyte_port" ]; then
        echo "Could not determine airbyte port, trying common ports..."
        # Try common airbyte ports
        for port in 8000 8001 8002 8003 8004; do
            if curl -s --max-time 1 http://localhost:$port/api/v1/health > /dev/null; then
                airbyte_port=$port
                break
            fi
        done
        
        if [ -z "$airbyte_port" ]; then
            echo "Could not determine airbyte port, trying default 8000"
            airbyte_port=8000
        fi
    fi

    while [ $retry_count -lt $max_retries ]; do
        if curl -s --max-time 5 http://localhost:$airbyte_port/api/v1/health > /dev/null; then
            health_check_success=true
            break
        fi
        echo "Retrying health check on port $airbyte_port... ($((retry_count + 1))/$max_retries)"
        sleep 5
        retry_count=$((retry_count + 1))
    done

    if $health_check_success; then
        echo "Checking airbyte credentials..."
        abctl local credentials || echo "Failed to check credentials, airbyte might not be ready yet"
    else
        echo "airbyte not accessible after $max_retries attempts on port $airbyte_port, skipping credentials check"
        echo "Check if airbyte is running and accessible at http://localhost:$airbyte_port"
    fi
else
    echo "airbyte not running, skipping credentials check"
fi