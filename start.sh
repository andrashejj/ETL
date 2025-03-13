#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to handle errors
error_exit() {
  echo "❌ Error on line $1. Exiting."
  exit 1
}
trap 'error_exit $LINENO' ERR

# Function to print info messages
info() {
  echo "ℹ️  $1"
}

# Install Airbyte CLI
info "Installing Airbyte CLI..."
if curl -LsfS https://get.airbyte.com | bash -; then
  info "✅ Airbyte CLI installed successfully."
else
  echo "❌ Failed to install Airbyte CLI."
  exit 1
fi

# Create .env file with required variables
info "Creating .env file with required environment variables..."
cat > .env << EOL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
SUPERSET_ADMIN=admin
SUPERSET_PASSWORD=admin
SUPERSET_SECRET_KEY=ChangeMeToARandomStringChangeMeToARandomStringChangeMeTo
MINIO_ROOT_USER=minio
MINIO_ROOT_PASSWORD=minio123
MINIO_ACCESS_KEY=Vjv9f77CpkKRDAKa
MINIO_SECRET_KEY=bKe3EwTUcv7PMCOaUY3AZfaorV+Hk3QH
EOL

# Confirm .env file creation
if [ -f ".env" ]; then
  info "✅ .env file created successfully."
else
  echo "❌ Failed to create .env file."
  exit 1
fi

# Start Airbyte in low resource mode (< 4 CPU)
info "Starting Airbyte in low resource mode..."
if abctl local install --low-resource-mode; then
  info "✅ Airbyte started successfully in low resource mode."
else
  echo "❌ Failed to start Airbyte."
  exit 1
fi

# Export environment variables from .env file
info "Exporting environment variables from .env file..."
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
  info "✅ Environment variables exported successfully."
else
  echo "❌ .env file not found."
  exit 1
fi

# Start Docker Compose
info "Starting Docker Compose..."
if docker compose up --build -d; then
  info "✅ Docker Compose started successfully."
else
  echo "❌ Failed to start Docker Compose."
  exit 1
fi


if curl https://dl.min.io/client/mc/release/linux-amd64/mc -o ./mc; then
  chmod +x ./mc
  info "✅ Minio client installed successfully."
else
  echo "❌ Failed to install Minio client."
  exit 1
fi

if ./mc alias set etl-minio http://localhost:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD; then
  chmod +x ./mc
  info "✅ Minio client configuresed successfully."
else
  echo "❌ Failed to configure Minio client. Maybe connection already exists."
fi

if ./mc admin user add minio $MINIO_ACCESS_KEY $MINIO_SECRET_KEY; then
  chmod +x ./mc
  info "✅ Minio user created successfully."
else
  echo "❌ Failed to create Minio user. Maybe its already exists."
fi

if ./mc mb etl-minio/etl-source ; then
  chmod +x ./mc
  info "✅ Minio bucket etl-source created successfully."
else
  echo "❌ Failed to create Minio bucket etl-source. Maybe its already exists."
fi

if ./mc mb etl-minio/etl-destination ; then
  chmod +x ./mc
  info "✅ Minio bucket etl-destination created successfully."
else
  echo "❌ Failed to create Minio bucket etl-destination. Maybe its already exists."
fi

info "Airbyte access..."
echo "🚀 Use http://127.0.0.1:8000 to access Airbyte UI"
echo "🚀 "`abctl local credentials | grep -e "Email"`
echo "🚀 "`abctl local credentials | grep -e "Password"`

info "Superset access..."
echo "🚀 Use http://127.0.0.1:8088 to access Superset UI"
echo "🚀 Username: "`grep SUPERSET_ADMIN .env | awk -F '=' {'print $2'}`
echo "🚀 Password: "`grep SUPERSET_PASSWORD .env | awk -F '=' {'print $2'}`

info "Dagster access..."
echo "🚀 Use http://127.0.0.1:3000 to access Dagster UI (admin/admin)"

info "PostgreSQL access..."
echo "🚀 Use 127.0.0.1:5432 to access PostgreSQL"
echo "🚀 Username: "`grep POSTGRES_USER .env | awk -F '=' {'print $2'}`
echo "🚀 Password: "`grep POSTGRES_PASSWORD .env | awk -F '=' {'print $2'}`

info "Minio access..."
info "🚀 Use http://127.0.0.1:9001 to access Minio UI"
info "🚀 Use http://127.0.0.1:9000 to access Minio API"
info "🚀 Username: "`grep MINIO_ROOT_USER .env | awk -F '=' {'print $2'}`
info "🚀 Password: "`grep MINIO_ROOT_PASSWORD .env | awk -F '=' {'print $2'}`
info "🚀 Minio Access Key: $MINIO_ACCESS_KEY"
info "🚀 Minio Secret Key: $MINIO_SECRET_KEY"

