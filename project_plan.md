# Lani Project Plan

This document outlines the steps to build and set up the Lani application environment, addressing the initial setup issues.

## Phase 1: Generate and Configure the Rails Application

1. **Clean Up Existing Files:**
    * The previous attempts created some configuration files before the Rails application was generated. These will be removed to ensure a clean slate.
    * Files to remove: `config/initializers/load_logger.rb`, `config/tailwind.config.js`, and the `config` directory itself.

2. **Generate the Rails Application:**
    * The core issue was that the Rails application was never generated. We will use `docker-compose run` to execute `rails new .` inside the `web` container.
    * We will use flags (`--force`, `--database=postgresql`, `--skip-bundle`) to overwrite the necessary files and configure it for PostgreSQL from the start.

3. **Reconcile Configuration:**
    * After generation, we will restore our custom `Dockerfile` to ensure it works with our setup.
    * We will merge our existing `Gemfile` dependencies into the newly generated one.

4. **Build and Run the Application:**
    * Rebuild the Docker image with the complete Rails application structure.
    * Start all services using `docker-compose up`.

5. **Initialize the Database:**
    * Create and migrate the database to prepare for development.

## Phase 2: Feature Implementation

Once the application is stable and running, we will proceed with the feature implementation as detailed in `implementation.md`, starting with:

1. **Project Representation and Management (OpenProject)**
2. **Map Integration (Mapbox)**
3. **Task Management (OpenProject)**
4. ...and so on.
