# OpenProject Integration

The Lani Platform provides deep integration with OpenProject, directly reusing its proven UI patterns and connecting to the OpenProject API v3 for seamless project and task management.

## 🎨 UI/UX Integration

### Direct UI Component Reuse
Lani directly implements OpenProject's battle-tested interface patterns:

#### Inline Editing System
The platform replicates OpenProject's signature inline editing experience:

```javascript
// Stimulus Controller (inline_edit_controller.js)
export default class extends Controller {
  static targets = ["display", "edit", "input"]
  
  // Toggle between display and edit modes
  edit() {
    this.displayTarget.classList.add('hidden')
    this.editTarget.classList.remove('hidden')
    this.inputTarget.focus()
  }
  
  // Save changes via PATCH API
  async save() {
    const response = await fetch(this.data.get('url'), {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ [this.data.get('attribute')]: this.inputTarget.value })
    })
    // Handle response and update UI
  }
}
```

#### Key Features
- **Click-to-Edit**: Click any field to edit directly
- **Keyboard Shortcuts**: Enter to save, Escape to cancel
- **Real-time Updates**: PATCH API calls with instant feedback
- **Visual States**: Loading, success, and error indicators
- **Accessibility**: Full keyboard navigation support

### OpenProject-Style Components
- **Task Lists**: Identical layout and interaction patterns
- **Status Badges**: Same color coding and styling
- **Priority Indicators**: Consistent visual hierarchy
- **Progress Tracking**: Matching progress visualization

## 🔌 API Integration

### OpenProject API v3 Client
Complete integration with OpenProject's REST API:

```ruby
class OpenProjectClient
  include HTTParty
  
  def initialize
    @base_url = ENV['OPENPROJECT_BASE_URL']
    @api_key = ENV['OPENPROJECT_API_KEY']
    
    self.class.base_uri @base_url
    @options = {
      headers: {
        'Authorization' => "Basic #{Base64.encode64("apikey:#{@api_key}").chomp}",
        'Content-Type' => 'application/json'
      }
    }
  end
  
  def projects
    response = self.class.get('/api/v3/projects', @options)
    response.success? ? response.parsed_response['_embedded']['elements'] : []
  end
  
  def work_packages(project_id = nil)
    url = project_id ? "/api/v3/projects/#{project_id}/work_packages" : '/api/v3/work_packages'
    response = self.class.get(url, @options)
    response.success? ? response.parsed_response['_embedded']['elements'] : []
  end
end
```

### Supported Operations
- **Project Sync**: Import/export projects between systems
- **Work Package Management**: Bidirectional task synchronization
- **User Mapping**: Maintain user assignments across platforms
- **Status Synchronization**: Preserve task states and workflows

## ⚙️ Configuration

### Environment Setup
Add these variables to your `.env` file:

```bash
# OpenProject Configuration
OPENPROJECT_BASE_URL=https://your-openproject-instance.com
OPENPROJECT_API_KEY=your_api_key_here

# Optional: Custom API settings
OPENPROJECT_TIMEOUT=30
OPENPROJECT_RETRY_ATTEMPTS=3
```

### API Key Generation
1. Log into your OpenProject instance
2. Go to **My Account** → **Access Tokens**
3. Click **Generate** and copy the API key
4. Add the key to your Lani environment configuration

### Connection Testing
```ruby
# Test in Rails console
api_service = ExternalApiService.new
projects = api_service.openproject.projects
puts "Connected! Found #{projects.size} projects"
```

## 🔄 Data Synchronization

### Import from OpenProject
Sync existing OpenProject data into Lani:

```ruby
# Sync all projects
POST /sync/openproject

# Sync specific project
POST /sync/openproject?project_id=123
```

#### Data Mapping
```ruby
# OpenProject → Lani mapping
{
  'id' => external_id,
  'name' => name,
  'description' => description,
  'status' => project_status,
  'createdAt' => created_at
}

# Work Package → Task mapping
{
  'subject' => title,
  'description.raw' => description,
  'status.name' => mapped_status,
  'priority.name' => mapped_priority,
  'assignee.name' => assigned_user,
  'dueDate' => due_date
}
```

### Export to OpenProject
Push Lani data to OpenProject:

```ruby
# Export project tasks
POST /export/openproject/123

# Create work package
api_service.openproject.create_work_package(project_id, {
  title: task.title,
  description: task.description,
  status: task.status,
  priority: task.priority
})
```

### Status Mapping
Intelligent status conversion between systems:

| OpenProject Status | Lani Status | Description |
|-------------------|-------------|-------------|
| New, Open | todo | Not started |
| In Progress | in_progress | Currently working |
| Closed, Resolved, Done | completed | Finished |

### Priority Mapping
| OpenProject Priority | Lani Priority | Visual Indicator |
|---------------------|---------------|------------------|
| High, Urgent, Immediate | high | 🔴 Red badge |
| Normal, Medium | medium | 🟡 Yellow badge |
| Low | low | 🟢 Green badge |

## 🚀 Features

### Bidirectional Sync
- **Real-time Updates**: Changes sync automatically between platforms
- **Conflict Resolution**: Intelligent handling of conflicting updates
- **Selective Sync**: Choose which projects and tasks to synchronize
- **Batch Operations**: Bulk import/export capabilities

### Advanced Integration
- **Custom Field Mapping**: Map OpenProject custom fields to Lani attributes
- **Workflow Preservation**: Maintain OpenProject workflows in Lani
- **Attachment Sync**: Synchronize file attachments between systems
- **Comment Integration**: Sync comments and activity logs

### User Experience
- **Seamless Interface**: No learning curve for OpenProject users
- **Familiar Shortcuts**: Same keyboard shortcuts and interactions
- **Consistent Styling**: Matching visual design and layout
- **Progressive Enhancement**: Works with or without JavaScript

## 📊 Monitoring and Analytics

### Sync Status Tracking
- **Sync History**: Complete log of all synchronization operations
- **Error Reporting**: Detailed error messages and resolution steps
- **Performance Metrics**: Sync speed and success rates
- **Data Integrity**: Validation of synchronized data

### Usage Analytics
- **Feature Adoption**: Track which OpenProject features are most used
- **Performance Impact**: Monitor sync performance on system resources
- **User Behavior**: Analyze how users interact with OpenProject features
- **Error Patterns**: Identify common sync issues and solutions

## 🛠️ Troubleshooting

### Common Issues

#### Authentication Errors
```bash
# Error: 401 Unauthorized
# Solution: Verify API key and permissions
curl -H "Authorization: Basic $(echo -n 'apikey:YOUR_API_KEY' | base64)" \
     https://your-openproject.com/api/v3/projects
```

#### Connection Timeouts
```ruby
# Increase timeout in configuration
OPENPROJECT_TIMEOUT=60

# Check network connectivity
ping your-openproject-instance.com
```

#### Data Sync Issues
- **Missing Projects**: Check project permissions in OpenProject
- **Status Conflicts**: Review status mapping configuration
- **User Assignment**: Verify user exists in both systems
- **Custom Fields**: Ensure custom fields are properly mapped

### Debug Mode
Enable detailed logging for troubleshooting:

```ruby
# In Rails console
Rails.logger.level = :debug
api_service = ExternalApiService.new
api_service.openproject.projects
```

### Error Recovery
- **Retry Failed Syncs**: Automatic retry with exponential backoff
- **Manual Sync**: Force sync specific items through admin interface
- **Data Validation**: Verify data integrity after sync operations
- **Rollback Capability**: Undo problematic sync operations

## 🔒 Security Considerations

### API Security
- **HTTPS Only**: All API communications use encrypted connections
- **Token Management**: Secure storage of API keys in Rails credentials
- **Rate Limiting**: Respect OpenProject API rate limits
- **Access Logging**: Log all API access for security auditing

### Data Privacy
- **Selective Sync**: Only sync necessary data between systems
- **Data Encryption**: Encrypt sensitive data in transit and at rest
- **Access Controls**: Role-based access to sync operations
- **Audit Trail**: Complete audit log of all data synchronization

## 📈 Best Practices

### Setup Recommendations
1. **Test Environment**: Set up sync in development before production
2. **Gradual Rollout**: Start with a small subset of projects
3. **User Training**: Train team on inline editing and sync features
4. **Monitoring**: Set up alerts for sync failures and errors

### Ongoing Management
1. **Regular Sync**: Schedule regular synchronization operations
2. **Data Cleanup**: Periodically clean up orphaned or duplicate data
3. **Performance Monitoring**: Monitor sync performance and optimize as needed
4. **User Feedback**: Collect feedback on OpenProject integration features

### Performance Optimization
1. **Batch Processing**: Use batch operations for large data sets
2. **Incremental Sync**: Only sync changed data when possible
3. **Caching**: Cache frequently accessed OpenProject data
4. **Background Jobs**: Use background processing for large sync operations

## 🔮 Future Enhancements

### Planned Features
- **Real-time WebSocket Sync**: Instant updates between platforms
- **Advanced Workflow Mapping**: Support for complex OpenProject workflows
- **Custom Dashboard Widgets**: OpenProject data widgets in Lani dashboard
- **Mobile App Integration**: OpenProject features in mobile applications

### API Enhancements
- **GraphQL Support**: More efficient data querying
- **Webhook Integration**: Real-time event notifications
- **Bulk API Operations**: Improved performance for large operations
- **Advanced Filtering**: More sophisticated data filtering options

---

*For technical implementation details, see the [API Reference](../development/api-reference.md) and [Architecture Overview](../development/architecture.md).*
