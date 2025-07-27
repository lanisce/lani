#!/bin/bash
set -e

# Fix for Rails 7.0.8.7 + concurrent-ruby compatibility issue
export RUBYOPT="-r logger"

# Ensure we're in the correct directory
cd /app

echo "Installing dependencies..."
bundle install --quiet

echo "Installing JavaScript dependencies..."
if [ -f "package.json" ]; then
    yarn install --silent
fi

echo "Waiting for database..."
sleep 5

echo "Starting Rails server directly with Puma..."
# Start Puma directly with basic configuration to bypass Rails CLI issues
exec bundle exec puma -b tcp://0.0.0.0:3000 -e development
