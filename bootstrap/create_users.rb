# Create test users for Lani platform
puts 'Creating test users...'

# Helper method to create or find user
def create_or_find_user(attributes)
  email = attributes[:email]
  user = User.find_by(email: email)
  
  if user
    puts "User already exists: #{email}"
    user
  else
    user = User.create!(attributes)
    puts "Created user: #{email}"
    user
  end
end

# Admin user
admin = create_or_find_user(
  email: 'admin@lani.dev',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Admin',
  last_name: 'User',
  role: :admin,
  active: true,
  onboarding_completed: true
)

# Project Manager
pm = create_or_find_user(
  email: 'pm@lani.dev',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Project',
  last_name: 'Manager',
  role: :project_manager,
  active: true,
  onboarding_completed: true
)

# Team Member
alice = create_or_find_user(
  email: 'alice@lani.dev',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Alice',
  last_name: 'Smith',
  role: :member,
  active: true,
  onboarding_completed: true
)

# Viewer user
viewer = create_or_find_user(
  email: 'viewer@lani.dev',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'View',
  last_name: 'Only',
  role: :viewer,
  active: true,
  onboarding_completed: true
)

puts "\nBootstrap complete! Test users are ready."
puts "You can sign in with any of these accounts:"
puts "- admin@lani.dev (Admin)"
puts "- pm@lani.dev (Project Manager)"
puts "- alice@lani.dev (Team Member)"
puts "- viewer@lani.dev (Viewer)"
puts "Password for all accounts: password123"
