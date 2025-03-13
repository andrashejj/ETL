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
info "Removing .env file..."


# Confirm .env file creation
if [ -f ".env" ]; then
  info "✅ Removing .env file."
  rm -rf .env
else
  echo "❌ .env file not exists."
fi


info "Uninstalling Airbyte..."
if abctl local uninstall ; then
  info "✅ Airbyte uninstalled."
else
  echo "❌ Failed to uninstall Airbyte."
fi

# Stop Docker Compose
info "Stopping Docker Compose..."
if docker compose down; then
  info "✅ Docker Compose stopped."
else
  echo "❌ Failed to stop Docker Compose."
  exit 1
fi
