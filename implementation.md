This project plan outlines a phased, sprint-based approach to building the Lani platform. The core strategy is to build a modular Ruby on Rails monolith that integrates external services via a dedicated API layer.

A critical refinement to the original plan is the approach to code reuse from OpenProject and Maybe. Instead of forking these large codebases and attempting to directly reuse their view components—a process fraught with complexity and maintenance challenges—this plan advocates for using them as architectural blueprints and headless backends where possible. We will re-implement the necessary UI in our clean Rails/Hotwire/Tailwind stack, ensuring a consistent user experience and a more maintainable application.

Phase 0: Foundation & Setup (Sprint 0 - 2 Weeks)
The goal of this phase is to establish the development environment, core application structure, and CI/CD pipeline.

To-Do List:

[ ] Repository & Version Control:

Initialize a new Git repository on GitHub.

Establish branching strategy (e.g., GitFlow with main, develop, and feature/ branches).

[ ] Local Development Environment:

Create a docker-compose.yml file to containerize:

Ruby on Rails 7.x application (lani-app).

PostgreSQL 15+ database (lani-db).

Redis for caching and Sidekiq (lani-redis).

Sidekiq worker process.

Write setup scripts for developers (bin/setup, bin/dev).

[ ] Core Application Setup:

Initialize a new Rails 7 application: rails new lani --database=postgresql --css=tailwind --javascript=importmap.

Add essential gems to the Gemfile: devise, pundit, omniauth, omniauth-keycloak, sidekiq, rspec-rails, factory_bot_rails.

Run bundle install.

[ ] Authentication & Authorization Foundation:

Install and configure Devise: rails g devise:install.

Generate the User model with Devise: rails g devise User.

Install and configure Pundit: rails g pundit:install. This creates the ApplicationPolicy.

Set up a development instance of Keycloak via Docker for future SSO integration.

[ ] CI/CD Pipeline:

Set up a basic GitHub Actions workflow (.github/workflows/ci.yml) that triggers on push to develop to:

Bundle install dependencies.

Run RSpec tests.

Run a static code analyzer like RuboCop.

Phase 1: Core MVP - Project & User Management (Sprints 1-4 - 8 Weeks)
The goal is to deliver a working application where users can sign up, log in, and perform basic project management actions based on their roles.

To-Do List:

[ ] User Roles & Permissions:

Add a role column to the User model (e.g., integer enum for admin, project_manager, member, viewer).

Define default roles and permissions in a Pundit-aware location (e.g., a config/roles.yml or a database table).

[ ] Project Scaffolding:

Generate the Project model and associated controller/views: rails g scaffold Project name:string description:text status:integer.

Create the ProjectPolicy with Pundit: rails g pundit:policy Project.

[ ] Implement Role-Based Views (Pundit):

In ProjectsController#index, use Pundit's policy_scope: @projects = policy_scope(Project).

In projects/index.html.erb, wrap action buttons in Pundit policy checks:

Code snippet

<% if policy(project).update? %>
  <%= link_to 'Edit', edit_project_path(project) %>
<% end %>
Write RSpec feature tests using Capybara to verify that a viewer cannot see the 'Edit' button while a project_manager can.

[ ] Task Management (Inspired by OpenProject):

Generate a Task model belonging to a Project: rails g model Task title:string project:references status:integer.

Create a nested resource in config/routes.rb: resources :projects do resources :tasks end.

Implement the TaskPolicy to control who can create, update, or view tasks.

Build a simple task list view within the project's show page.

[ ] Admin Dashboard:

Create a separate namespace for administrators (namespace :admin do ... end).

Build a basic dashboard for user management and global settings, accessible only to users with the admin role (enforced via Pundit).

Deliverable: A user can log in, be assigned a role, and see a list of projects. They can create/edit projects and tasks only if their role permits.

Phase 2: Collaboration & Geospatial Features (Sprints 5-7 - 6 Weeks)
The goal is to integrate Nextcloud for file management and Mapbox for visualizing project locations.

To-Do List:

[ ] Mapbox Integration:

Add a location field (e.g., latitude, longitude) to the Project model.

Add mapbox-gl-js to the frontend via importmap.

Create a Stimulus controller (app/javascript/controllers/map_controller.js) to initialize the Mapbox map and display project pins.

Create a Rails partial (_map.html.erb) to render the map container.

Use Pundit policies to determine if the map is interactive (editable by a project_manager) or static (view-only for a viewer).

[ ] Nextcloud API Integration (Files):

Create a NextcloudService in app/services/ to encapsulate API calls for file listing, uploading, and generating share links.

Store Nextcloud API credentials securely using Rails encrypted credentials.

On the project's show page, add a "Files" tab that uses this service to display a list of files associated with the project in Nextcloud.

Use Pundit policies to show/hide the "Upload File" button.

[ ] Nextcloud Talk Integration (Communication):

Extend NextcloudService to handle creating and retrieving Nextcloud Talk rooms via its API.

Associate a Talk room with each Lani project.

Display a "Join Chat" link on the project page that directs users to the appropriate Nextcloud Talk room.

Deliverable: Projects can have a location displayed on an interactive map. Users can view and manage project-related files hosted on Nextcloud directly from the Lani interface.

Phase 3: Financials & Commerce (Sprints 8-10 - 6 Weeks)
The goal is to implement budgeting features inspired by Maybe and integrate Medusa for e-commerce.

To-Do List:

[ ] Budgeting Module (Inspired by Maybe):

Generate Budget and Transaction models (Budget belongs to Project).

Implement BudgetPolicy and TransactionPolicy with Pundit.

Build UI for admins/project managers to create budgets and log transactions.

Create read-only summary views for members/viewers.

Use Hotwire (Turbo Frames/Streams) for dynamic updates to budget summaries without page reloads.

[ ] Medusa API Integration (E-commerce):

Set up a headless Medusa instance.

Create a MedusaService in app/services/ to handle API calls for fetching products.

Build a product storefront in Rails using ERB templates styled with Tailwind CSS.

Implement a product index and show page.

[ ] Shopping Cart & Checkout Flow:

Implement a client-side shopping cart using Stimulus or a simple session-based cart on the Rails backend.

Use the MedusaService to interact with Medusa's Cart and Order APIs.

Integrate a payment provider like Stripe, leveraging Medusa's existing plugins.

Deliverable: Projects have a budgeting section. A storefront for local products exists, allowing users to browse and purchase items.

Phase 4: Reporting, Onboarding & Polish (Sprints 11-12 - 4 Weeks)
The goal is to add reporting, create a smooth onboarding experience, and prepare for launch.

To-Do List:

[ ] Reporting Engine:

Create a reporting dashboard for admins.

Use the prawn gem to generate PDF reports for project summaries and budgets.

Use a library like Chart.js (via importmap) to create visual charts for budget allocation and task completion.

Ensure all reports are governed by Pundit policies.

[ ] User Onboarding Flow:

Create a multi-step onboarding wizard for new users after their first login.

Use a boolean flag like onboarding_completed on the User model to track progress.

Guide users through setting up their profile and understanding the UI.

[ ] Final Polish & Optimization:

Conduct a full UI/UX review and address inconsistencies.

Implement caching strategies (view, fragment, Redis) for performance.

Perform a security audit (check for common vulnerabilities like SQLi, XSS, CSRF).

Write comprehensive documentation and host it within the app or on Nextcloud.

Deliverable: A production-ready platform with reporting, a guided onboarding flow, and performance optimizations.

Key Design Implementations & Restraints
Constraint: Avoid Direct Forking of OpenProject/Maybe.

Reasoning: Forking and integrating large, mature codebases is extremely complex. It creates a massive maintenance burden, locks you into their upgrade path, and pollutes your application with code you don't need.

Implementation: Treat OpenProject and Maybe as headless services or reference architectures. We will build our own models (Project, Task, Budget) that are lean and fit our exact needs. If we need to sync with an actual OpenProject instance, we will do it via its API, not by sharing a database or forking its code.

Implementation: The API Gateway Pattern.

All external API interactions (Nextcloud, Medusa, Mapbox) will be encapsulated within dedicated service objects in app/services/. For example, NextcloudService.new(current_user).get_files(project).

Restraint: Controllers should never make direct HTTP calls. They delegate to a service object. This keeps controllers thin, simplifies testing, and centralizes external logic.

Implementation: Seamless UI via Pundit and Hotwire.

Pundit controls what data is loaded (via policy_scope) and which UI elements are rendered (via policy(record).action?).

Hotwire (Turbo) provides the seamless feel. For example, when a task is updated, a Turbo Stream broadcast can update the task on the page, the project's progress bar, and a notification panel simultaneously, all without a full page reload. This dynamic behavior will still respect Pundit policies on the server side before broadcasting.