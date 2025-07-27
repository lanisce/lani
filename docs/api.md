---
layout: default
title: "API Reference"
description: "Complete REST API documentation for Lani Platform"
---

# API Reference

The Lani Platform provides a comprehensive REST API for integrating with external systems and building custom applications.

## Authentication

All API requests require authentication using API tokens or session-based authentication.

### API Token Authentication

```bash
# Include the Authorization header
curl -H "Authorization: Bearer YOUR_API_TOKEN" \
     https://api.lani.yourdomain.com/api/v1/projects
```

### Session Authentication

```bash
# Login to get session cookie
curl -X POST https://api.lani.yourdomain.com/api/v1/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email": "user@example.com", "password": "password"}'
```

## Base URL

```
https://api.lani.yourdomain.com/api/v1
```

## Rate Limiting

- **Rate Limit**: 1000 requests per hour per API token
- **Headers**: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

## Response Format

All API responses follow a consistent JSON format:

```json
{
  "data": {...},
  "meta": {
    "page": 1,
    "per_page": 25,
    "total": 100,
    "total_pages": 4
  },
  "links": {
    "self": "https://api.lani.yourdomain.com/api/v1/projects?page=1",
    "next": "https://api.lani.yourdomain.com/api/v1/projects?page=2",
    "last": "https://api.lani.yourdomain.com/api/v1/projects?page=4"
  }
}
```

## Error Handling

Error responses include detailed information:

```json
{
  "error": {
    "code": "validation_failed",
    "message": "Validation failed",
    "details": {
      "name": ["can't be blank"],
      "email": ["is invalid"]
    }
  }
}
```

## Projects API

### List Projects

```http
GET /api/v1/projects
```

**Parameters:**
- `page` (integer): Page number (default: 1)
- `per_page` (integer): Items per page (default: 25, max: 100)
- `status` (string): Filter by status (`active`, `completed`, `archived`)
- `search` (string): Search projects by name or description

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Website Redesign",
      "description": "Complete redesign of company website",
      "status": "active",
      "budget": 50000.00,
      "start_date": "2024-01-15",
      "end_date": "2024-06-15",
      "location": {
        "latitude": 37.7749,
        "longitude": -122.4194,
        "address": "San Francisco, CA"
      },
      "created_at": "2024-01-10T10:00:00Z",
      "updated_at": "2024-01-20T15:30:00Z",
      "owner": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com"
      },
      "team_members": [
        {
          "id": 2,
          "name": "Jane Smith",
          "email": "jane@example.com",
          "role": "manager"
        }
      ]
    }
  ]
}
```

### Get Project

```http
GET /api/v1/projects/:id
```

### Create Project

```http
POST /api/v1/projects
```

**Request Body:**
```json
{
  "project": {
    "name": "New Project",
    "description": "Project description",
    "status": "active",
    "budget": 25000.00,
    "start_date": "2024-02-01",
    "end_date": "2024-05-01",
    "location_attributes": {
      "latitude": 37.7749,
      "longitude": -122.4194,
      "address": "San Francisco, CA"
    }
  }
}
```

### Update Project

```http
PATCH /api/v1/projects/:id
```

### Delete Project

```http
DELETE /api/v1/projects/:id
```

## Tasks API

### List Tasks

```http
GET /api/v1/projects/:project_id/tasks
```

**Parameters:**
- `status` (string): Filter by status (`pending`, `in_progress`, `completed`)
- `assigned_to` (integer): Filter by assigned user ID
- `due_date_from` (date): Filter tasks due after this date
- `due_date_to` (date): Filter tasks due before this date

### Create Task

```http
POST /api/v1/projects/:project_id/tasks
```

**Request Body:**
```json
{
  "task": {
    "title": "Design homepage mockup",
    "description": "Create initial design mockups for the homepage",
    "status": "pending",
    "priority": "high",
    "due_date": "2024-02-15",
    "assigned_to": 2,
    "estimated_hours": 8
  }
}
```

## Users API

### List Users

```http
GET /api/v1/users
```

### Get Current User

```http
GET /api/v1/users/me
```

### Update User Profile

```http
PATCH /api/v1/users/:id
```

## Budgets API

### Get Project Budget

```http
GET /api/v1/projects/:project_id/budget
```

### Update Budget

```http
PATCH /api/v1/projects/:project_id/budget
```

**Request Body:**
```json
{
  "budget": {
    "total_amount": 60000.00,
    "categories": [
      {
        "name": "Development",
        "amount": 40000.00
      },
      {
        "name": "Design",
        "amount": 20000.00
      }
    ]
  }
}
```

## Transactions API

### List Transactions

```http
GET /api/v1/projects/:project_id/transactions
```

### Create Transaction

```http
POST /api/v1/projects/:project_id/transactions
```

**Request Body:**
```json
{
  "transaction": {
    "amount": 1500.00,
    "transaction_type": "expense",
    "category": "Development",
    "description": "Frontend development work",
    "date": "2024-01-20"
  }
}
```

## Files API

### List Project Files

```http
GET /api/v1/projects/:project_id/files
```

### Upload File

```http
POST /api/v1/projects/:project_id/files
```

**Request Body (multipart/form-data):**
```
file: [binary data]
description: "Project specification document"
```

### Download File

```http
GET /api/v1/projects/:project_id/files/:file_id/download
```

## Reports API

### Project Reports

```http
GET /api/v1/projects/:project_id/reports
```

**Parameters:**
- `type` (string): Report type (`overview`, `financial`, `tasks`, `team`)
- `format` (string): Response format (`json`, `pdf`)
- `date_from` (date): Start date for report data
- `date_to` (date): End date for report data

### System Analytics

```http
GET /api/v1/reports/analytics
```

## Webhooks

### Register Webhook

```http
POST /api/v1/webhooks
```

**Request Body:**
```json
{
  "webhook": {
    "url": "https://your-app.com/webhooks/lani",
    "events": ["project.created", "task.completed", "budget.updated"],
    "secret": "your_webhook_secret"
  }
}
```

### Webhook Events

Available webhook events:

- `project.created`
- `project.updated`
- `project.deleted`
- `task.created`
- `task.updated`
- `task.completed`
- `budget.updated`
- `transaction.created`
- `user.invited`
- `file.uploaded`

### Webhook Payload

```json
{
  "event": "project.created",
  "timestamp": "2024-01-20T15:30:00Z",
  "data": {
    "project": {
      "id": 1,
      "name": "New Project",
      "status": "active"
    }
  }
}
```

## SDKs and Libraries

### Official SDKs

- **Ruby**: `gem install lani-api`
- **JavaScript**: `npm install @lani/api-client`
- **Python**: `pip install lani-api-client`
- **PHP**: `composer require lani/api-client`

### Ruby SDK Example

```ruby
require 'lani-api'

client = Lani::Client.new(
  api_token: 'your_api_token',
  base_url: 'https://api.lani.yourdomain.com'
)

# List projects
projects = client.projects.list(status: 'active')

# Create project
project = client.projects.create(
  name: 'New Project',
  description: 'Project description',
  budget: 25000.00
)

# Create task
task = client.tasks.create(
  project_id: project.id,
  title: 'Design homepage',
  status: 'pending'
)
```

### JavaScript SDK Example

```javascript
import { LaniClient } from '@lani/api-client';

const client = new LaniClient({
  apiToken: 'your_api_token',
  baseUrl: 'https://api.lani.yourdomain.com'
});

// List projects
const projects = await client.projects.list({ status: 'active' });

// Create project
const project = await client.projects.create({
  name: 'New Project',
  description: 'Project description',
  budget: 25000.00
});

// Create task
const task = await client.tasks.create(project.id, {
  title: 'Design homepage',
  status: 'pending'
});
```

## Testing

### Sandbox Environment

Use the sandbox environment for testing:

```
https://sandbox-api.lani.yourdomain.com/api/v1
```

### Test Data

The sandbox includes test data:
- Test projects with various statuses
- Sample tasks and users
- Mock financial data
- Test webhook endpoints

### API Testing Tools

**Postman Collection:**
[![Run in Postman](https://run.pstmn.io/button.svg)](https://app.getpostman.com/run-collection/lani-api)

**OpenAPI Specification:**
- [Download OpenAPI 3.0 Spec](https://api.lani.yourdomain.com/api/v1/openapi.json)
- [Interactive API Explorer](https://api.lani.yourdomain.com/api/docs)

## Support

- **API Documentation**: [https://api.lani.yourdomain.com/docs](https://api.lani.yourdomain.com/docs)
- **Status Page**: [https://status.lani.yourdomain.com](https://status.lani.yourdomain.com)
- **Support**: [api-support@lani.yourdomain.com](mailto:api-support@lani.yourdomain.com)
- **GitHub Issues**: [Report API Issues](https://github.com/your-org/lani/issues)

---

<div class="footer-cta">
  <h2>Start building with our API</h2>
  <p>Get your API token and start integrating Lani into your applications.</p>
  <a href="https://api.lani.yourdomain.com/docs" class="btn btn-primary">Interactive API Docs</a>
</div>
