#!/bin/bash

# install airbyte ctl

curl -LsfS https://get.airbyte.com | bash -

# Create .env file with required variables
cat > .env << EOL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
SUPERSET_ADMIN=admin
SUPERSET_PASSWORD=admin
SUPERSET_SECRET_KEY=ChangeMeToARandomStringChangeMeToARandomStringChangeMeTo
EOL

# start airbyte (in low resource mode < 4 CPU)
abctl local install --low-resource-mode

# check credentials
abctl local credentials

# Start docker compose
docker compose up --build