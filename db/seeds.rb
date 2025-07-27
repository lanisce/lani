# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# Create admin user
admin = User.create!(
  email: 'admin@lani.dev',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Admin',
  last_name: 'User',
  role: 'admin'
)

# Create regular users
project_manager = User.create!(
  email: 'pm@lani.dev',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Project',
  last_name: 'Manager',
  role: 'project_manager'
)

member1 = User.create!(
  email: 'alice@lani.dev',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Alice',
  last_name: 'Johnson',
  role: 'member'
)

member2 = User.create!(
  email: 'bob@lani.dev',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Bob',
  last_name: 'Smith',
  role: 'member'
)

viewer = User.create!(
  email: 'viewer@lani.dev',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Viewer',
  last_name: 'User',
  role: 'viewer'
)

puts "✅ Created #{User.count} users"

# Create sample projects
project1 = Project.create!(
  name: 'Community Garden Initiative',
  description: 'A collaborative project to create sustainable community gardens in urban areas. This project involves planning, designing, and implementing green spaces that bring communities together while promoting local food production.',
  status: 'active',
  owner: project_manager,
  location_name: 'Downtown Community Center',
  latitude: 40.7128,
  longitude: -74.0060,
  start_date: 1.month.ago,
  end_date: 6.months.from_now,
  budget_limit: 15000.00
)

project2 = Project.create!(
  name: 'Local Business Directory App',
  description: 'Developing a mobile and web application to help community members discover and support local businesses. Features include business listings, reviews, events, and local commerce integration.',
  status: 'planning',
  owner: admin,
  location_name: 'Tech Hub Coworking Space',
  latitude: 40.7589,
  longitude: -73.9851,
  start_date: 2.weeks.from_now,
  end_date: 8.months.from_now,
  budget_limit: 25000.00
)

project3 = Project.create!(
  name: 'Neighborhood Clean-up Campaign',
  description: 'Monthly organized clean-up events to maintain and beautify our neighborhood. Includes coordination with local authorities, volunteer management, and environmental impact tracking.',
  status: 'completed',
  owner: member1,
  location_name: 'Riverside Park',
  latitude: 40.7829,
  longitude: -73.9654,
  start_date: 3.months.ago,
  end_date: 1.month.ago,
  budget_limit: 2500.00
)

puts "✅ Created #{Project.count} projects"

# Add project memberships
ProjectMembership.create!([
  { user: admin, project: project1 },
  { user: member1, project: project1 },
  { user: member2, project: project1 },
  { user: viewer, project: project1 },
  
  { user: project_manager, project: project2 },
  { user: member1, project: project2 },
  { user: member2, project: project2 },
  
  { user: admin, project: project3 },
  { user: project_manager, project: project3 },
  { user: member2, project: project3 }
])

puts "✅ Created #{ProjectMembership.count} project memberships"

# Create sample tasks
Task.create!([
  # Community Garden Initiative tasks
  {
    title: 'Site Survey and Soil Testing',
    description: 'Conduct comprehensive site analysis including soil quality testing, drainage assessment, and sunlight mapping to determine optimal garden layout.',
    status: 'completed',
    priority: 'high',
    project: project1,
    user: member1,
    due_date: 3.weeks.ago,
    completed_at: 3.weeks.ago,
    estimated_hours: 8,
    actual_hours: 10
  },
  {
    title: 'Design Garden Layout',
    description: 'Create detailed garden design including plot assignments, pathways, composting area, and tool storage. Incorporate accessibility features and community gathering spaces.',
    status: 'completed',
    priority: 'high',
    project: project1,
    user: project_manager,
    due_date: 2.weeks.ago,
    completed_at: 2.weeks.ago,
    estimated_hours: 12,
    actual_hours: 15
  },
  {
    title: 'Procure Gardening Supplies',
    description: 'Purchase seeds, tools, soil amendments, irrigation supplies, and raised bed materials. Coordinate with local suppliers for bulk discounts.',
    status: 'in_progress',
    priority: 'medium',
    project: project1,
    user: member2,
    due_date: 1.week.from_now,
    estimated_hours: 6,
    actual_hours: 3
  },
  {
    title: 'Organize Community Planting Day',
    description: 'Plan and coordinate community event for initial planting. Arrange volunteers, refreshments, and educational activities for families.',
    status: 'todo',
    priority: 'medium',
    project: project1,
    user: member1,
    due_date: 3.weeks.from_now,
    estimated_hours: 10
  },
  
  # Local Business Directory App tasks
  {
    title: 'Market Research and Requirements Gathering',
    description: 'Conduct surveys with local businesses and community members to understand needs, preferences, and feature requirements for the directory app.',
    status: 'todo',
    priority: 'high',
    project: project2,
    user: project_manager,
    due_date: 1.month.from_now,
    estimated_hours: 20
  },
  {
    title: 'UI/UX Design and Prototyping',
    description: 'Create user interface designs and interactive prototypes for both mobile and web versions of the application.',
    status: 'todo',
    priority: 'high',
    project: project2,
    user: member1,
    due_date: 6.weeks.from_now,
    estimated_hours: 25
  },
  {
    title: 'Set up Development Environment',
    description: 'Configure development tools, CI/CD pipeline, and testing frameworks for the application development process.',
    status: 'todo',
    priority: 'medium',
    project: project2,
    user: member2,
    due_date: 3.weeks.from_now,
    estimated_hours: 8
  },
  
  # Neighborhood Clean-up Campaign tasks (completed project)
  {
    title: 'Coordinate with City Parks Department',
    description: 'Establish partnership with local authorities for waste disposal, permits, and safety guidelines for clean-up events.',
    status: 'completed',
    priority: 'high',
    project: project3,
    user: member1,
    due_date: 4.months.ago,
    completed_at: 4.months.ago,
    estimated_hours: 4,
    actual_hours: 6
  },
  {
    title: 'Recruit and Train Volunteers',
    description: 'Build volunteer base through community outreach and provide safety training and orientation for clean-up activities.',
    status: 'completed',
    priority: 'medium',
    project: project3,
    user: member2,
    due_date: 3.months.ago,
    completed_at: 3.months.ago,
    estimated_hours: 12,
    actual_hours: 14
  },
  {
    title: 'Monthly Clean-up Events (March)',
    description: 'Organize and execute monthly neighborhood clean-up event with focus on Riverside Park and surrounding areas.',
    status: 'completed',
    priority: 'medium',
    project: project3,
    user: member1,
    due_date: 2.months.ago,
    completed_at: 2.months.ago,
    estimated_hours: 6,
    actual_hours: 5
  }
])

puts "✅ Created #{Task.count} tasks"

puts "\n🎉 Database seeding completed successfully!"
puts "\n📊 Summary:"
puts "   Users: #{User.count}"
puts "   Projects: #{Project.count}"
puts "   Project Memberships: #{ProjectMembership.count}"
puts "   Tasks: #{Task.count}"

puts "\n🔑 Test Accounts:"
puts "   Admin: admin@lani.dev / password123"
puts "   Project Manager: pm@lani.dev / password123"
puts "   Member (Alice): alice@lani.dev / password123"
puts "   Member (Bob): bob@lani.dev / password123"
puts "   Viewer: viewer@lani.dev / password123"

puts "\n🌐 Access the application at: http://localhost:3000"
