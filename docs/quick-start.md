# Quick Start Guide

Get up and running with the Lani Platform in just a few minutes! This guide assumes you've already completed the [installation](installation.md).

## 🚀 First Steps

### 1. Access the Platform
Open your browser and navigate to:
- **Main Application**: http://localhost:3001
- **Admin Dashboard**: http://localhost:3001/admin (admin users only)

### 2. Log In
Use one of the default accounts:
- **Admin**: admin@lani.dev / password123
- **Project Manager**: pm@lani.dev / password123
- **Team Member**: alice@lani.dev / password123

## 📋 Create Your First Project

### 1. Navigate to Projects
- Click **"Projects"** in the main navigation
- Click **"New Project"** button

### 2. Fill Project Details
```
Name: My First Project
Description: Getting started with Lani Platform
Location: Click on map to set project location (optional)
Budget Limit: $10,000 (optional)
```

### 3. Add Team Members
- Click **"Add Member"** in the project view
- Select users and assign roles:
  - **Owner**: Full project control
  - **Member**: Can edit tasks and add expenses
  - **Viewer**: Read-only access

## ✅ Manage Tasks

### 1. Create Tasks
- In your project, click **"New Task"**
- Fill in task details:
  ```
  Title: Set up project infrastructure
  Description: Configure development environment
  Priority: High
  Due Date: Next week
  Assigned To: Select team member
  ```

### 2. Use Inline Editing (OpenProject-style)
- **Click any task title** to edit it directly
- **Click status badges** to change task status
- **Press Enter** to save, **Escape** to cancel
- Changes are saved automatically via API

### 3. Track Progress
- Use the project dashboard to see task completion
- Visual progress indicators show project status
- Filter tasks by status, priority, or assignee

## 💰 Financial Management

### 1. Create Budgets
- Navigate to **"Budget"** tab in your project
- Click **"New Budget"** and create categories:
  ```
  Materials Budget: $3,000
  Labor Budget: $5,000
  Equipment Budget: $2,000
  ```

### 2. Track Expenses
- Go to **"Transactions"** tab
- Click **"New Transaction"** to record expenses:
  ```
  Description: Office supplies
  Amount: $150
  Type: Expense
  Category: Materials
  Date: Today
  ```

### 3. Monitor Budget Health
- View **Maybe-style budget cards** with progress bars
- Color-coded status indicators:
  - 🟢 **Green**: Under 60% spent
  - 🟡 **Yellow**: 60-80% spent
  - 🟠 **Orange**: 80-100% spent
  - 🔴 **Red**: Over budget

## 📁 File Management

### 1. Upload Files
- Click **"Files"** tab in your project
- Drag and drop files or click **"Upload Files"**
- Supported formats: Documents, images, spreadsheets

### 2. Share with Team
- Click **"Share"** next to any file
- Files are automatically synced with Nextcloud (if configured)
- Team members get instant access

### 3. Organize Files
- Create folders for different project phases
- Use search to find files quickly
- Download files individually or in bulk

## 🔗 External Integrations

### 1. Sync with OpenProject
- Click **"Sync with OpenProject"** in project view
- Import existing projects and work packages
- Export local tasks to OpenProject
- Maintains bidirectional sync

### 2. Connect Maybe Finance
- Click **"Sync with Maybe"** in budget/transaction views
- Import financial data from Maybe
- Export local budgets and transactions
- Real-time financial sync

### 3. Enable Nextcloud Files
- Configure Nextcloud credentials in admin settings
- Automatic file sync and sharing
- Team collaboration on documents

## 🗺️ Geospatial Features

### 1. Set Project Location
- Use the interactive map in project forms
- Search for addresses or click to place markers
- Coordinates are automatically saved

### 2. View Project Map
- Projects with locations appear on the dashboard map
- Filter projects by geographic region
- Plan logistics and resource allocation

## 👥 Team Collaboration

### 1. Role-Based Access
- **Admin**: Full system access, user management
- **Project Manager**: Create projects, manage budgets
- **Member**: Edit tasks, add transactions
- **Viewer**: Read-only access to assigned projects

### 2. Real-Time Updates
- Changes appear instantly for all team members
- Hotwire technology provides seamless updates
- No page refreshes needed

### 3. Activity Tracking
- View project activity feeds
- Track who made what changes
- Monitor team productivity

## 📊 Reporting and Analytics

### 1. Project Dashboard
- Overview of all projects and their status
- Financial summaries and budget health
- Task completion rates and deadlines

### 2. Financial Reports
- Budget vs. actual spending analysis
- Category-wise expense breakdown
- Monthly spending trends

### 3. Team Performance
- Task completion rates by team member
- Project delivery timelines
- Resource utilization metrics

## 🔧 Customization

### 1. User Preferences
- Update your profile and notification settings
- Customize dashboard layout
- Set default project views

### 2. Project Settings
- Configure project-specific permissions
- Set up custom categories and labels
- Define project workflows

### 3. Integration Settings
- Configure external API connections
- Set up automatic sync schedules
- Customize data mapping rules

## 🆘 Need Help?

### Quick Tips
- **Hover over elements** to see tooltips and help text
- **Use keyboard shortcuts**: Enter to save, Escape to cancel
- **Check the status bar** for real-time feedback

### Resources
- [Feature Documentation](features/) - Detailed feature guides
- [API Reference](development/api-reference.md) - Technical documentation
- [Troubleshooting](troubleshooting.md) - Common issues and solutions

### Getting Support
- Create an issue on GitHub
- Check the FAQ for common questions
- Review application logs for error details

## 🎯 Next Steps

1. **Explore Advanced Features**: Try inline editing, API sync, and geospatial tools
2. **Invite Your Team**: Add real team members and start collaborating
3. **Configure Integrations**: Set up OpenProject, Maybe, and Nextcloud connections
4. **Customize Your Workflow**: Adapt the platform to your team's needs

Ready to dive deeper? Check out the [comprehensive feature documentation](features/) or explore the [integration guides](integrations/).

---

*Happy project managing! 🚀*
