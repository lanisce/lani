# Onboarding controller for user wizard and guided tours
class OnboardingController < ApplicationController
  before_action :authenticate_user!
  before_action :check_onboarding_status, except: [:start, :complete, :skip]
  
  ONBOARDING_STEPS = %w[
    welcome
    profile_setup
    first_project
    team_invitation
    integrations
    features_tour
    completion
  ].freeze
  
  def start
    # Reset onboarding progress
    current_user.update!(
      onboarding_step: 'welcome',
      onboarding_completed: false,
      onboarding_started_at: Time.current
    )
    
    redirect_to onboarding_step_path('welcome')
  end
  
  def show
    @step = params[:step]
    @step_index = ONBOARDING_STEPS.index(@step) || 0
    @total_steps = ONBOARDING_STEPS.size
    @progress_percentage = ((@step_index + 1).to_f / @total_steps * 100).round
    
    unless ONBOARDING_STEPS.include?(@step)
      redirect_to onboarding_step_path('welcome')
      return
    end
    
    # Update user's current step
    current_user.update!(onboarding_step: @step)
    
    case @step
    when 'welcome'
      @user_name = current_user.name.present? ? current_user.name.split.first : 'there'
    when 'profile_setup'
      # Profile setup data is handled in the view
    when 'first_project'
      @project = current_user.projects.build
    when 'team_invitation'
      @project = current_user.projects.first || current_user.projects.build(name: 'My First Project')
      @invitation_emails = []
    when 'integrations'
      @available_integrations = [
        {
          name: 'OpenProject',
          description: 'Sync tasks and work packages',
          icon: 'briefcase',
          configured: openproject_configured?,
          setup_url: '#'
        },
        {
          name: 'Maybe Finance',
          description: 'Budget and transaction management',
          icon: 'currency-dollar',
          configured: maybe_configured?,
          setup_url: '#'
        },
        {
          name: 'Nextcloud',
          description: 'File sharing and collaboration',
          icon: 'cloud',
          configured: nextcloud_configured?,
          setup_url: '#'
        },
        {
          name: 'Mapbox',
          description: 'Interactive project maps',
          icon: 'map',
          configured: mapbox_configured?,
          setup_url: '#'
        }
      ]
    when 'features_tour'
      @key_features = [
        {
          title: 'Project Management',
          description: 'Create and manage projects with OpenProject-style task management',
          icon: 'clipboard-list',
          demo_url: projects_path
        },
        {
          title: 'Financial Tracking',
          description: 'Budget management with Maybe Finance-inspired interface',
          icon: 'chart-bar',
          demo_url: '#'
        },
        {
          title: 'Team Collaboration',
          description: 'Invite team members and manage project access',
          icon: 'users',
          demo_url: '#'
        },
        {
          title: 'File Management',
          description: 'Share files and collaborate via Nextcloud integration',
          icon: 'folder',
          demo_url: '#'
        },
        {
          title: 'Analytics Dashboard',
          description: 'Comprehensive reporting and project insights',
          icon: 'chart-pie',
          demo_url: reports_path
        },
        {
          title: 'E-commerce Marketplace',
          description: 'Browse and purchase project-related products',
          icon: 'shopping-cart',
          demo_url: products_path
        }
      ]
    when 'completion'
      # Completion step data handled in view
    end
    
    render "onboarding/steps/#{@step}"
  end
  
  def update
    @step = params[:step]
    
    case @step
    when 'profile_setup'
      if current_user.update(profile_params)
        redirect_to_next_step
      else
        @step_index = ONBOARDING_STEPS.index(@step) || 0
        @total_steps = ONBOARDING_STEPS.size
        @progress_percentage = ((@step_index + 1).to_f / @total_steps * 100).round
        render "onboarding/steps/#{@step}"
      end
    when 'first_project'
      @project = current_user.projects.build(project_params)
      @project.owner = current_user
      
      if @project.save
        # Create default project membership for owner
        @project.project_memberships.create!(
          user: current_user,
          role: 'project_manager'
        )
        
        # Create sample tasks
        create_sample_tasks(@project)
        
        redirect_to_next_step
      else
        @step_index = ONBOARDING_STEPS.index(@step) || 0
        @total_steps = ONBOARDING_STEPS.size
        @progress_percentage = ((@step_index + 1).to_f / @total_steps * 100).round
        render "onboarding/steps/#{@step}"
      end
    when 'team_invitation'
      @project = current_user.projects.first
      emails = params[:invitation_emails]&.split(',')&.map(&:strip)&.reject(&:blank?) || []
      
      if emails.any?
        emails.each do |email|
          # In a real app, you'd send invitation emails here
          # For now, we'll just create a placeholder
          Rails.logger.info "Would send invitation to: #{email}"
        end
        
        flash[:notice] = "Invitations would be sent to #{emails.size} team members."
      end
      
      redirect_to_next_step
    when 'integrations'
      # Handle integration setup (placeholder for now)
      selected_integrations = params[:integrations] || []
      
      if selected_integrations.any?
        flash[:notice] = "Integration setup initiated for: #{selected_integrations.join(', ')}"
      end
      
      redirect_to_next_step
    else
      redirect_to_next_step
    end
  end
  
  def complete
    current_user.update!(
      onboarding_completed: true,
      onboarding_completed_at: Time.current,
      onboarding_step: 'completed'
    )
    
    redirect_to root_path, notice: 'Welcome to Lani! Your onboarding is complete.'
  end
  
  def skip
    current_user.update!(
      onboarding_completed: true,
      onboarding_completed_at: Time.current,
      onboarding_step: 'skipped'
    )
    
    redirect_to root_path, notice: 'Onboarding skipped. You can restart it anytime from your profile.'
  end
  
  private
  
  def check_onboarding_status
    if current_user.onboarding_completed?
      redirect_to root_path, notice: 'Onboarding already completed.'
    end
  end
  
  def redirect_to_next_step
    current_step_index = ONBOARDING_STEPS.index(params[:step]) || 0
    next_step_index = current_step_index + 1
    
    if next_step_index >= ONBOARDING_STEPS.size
      redirect_to complete_onboarding_path
    else
      next_step = ONBOARDING_STEPS[next_step_index]
      redirect_to onboarding_step_path(next_step)
    end
  end
  
  def profile_params
    params.require(:user).permit(:name, :email, :bio, :timezone, :notification_preferences)
  end
  
  def project_params
    params.require(:project).permit(:name, :description, :status, :latitude, :longitude)
  end
  
  def create_sample_tasks(project)
    sample_tasks = [
      {
        title: 'Project Planning',
        description: 'Define project scope and objectives',
        priority: 'high',
        status: 'pending'
      },
      {
        title: 'Team Setup',
        description: 'Invite team members and assign roles',
        priority: 'medium',
        status: 'pending'
      },
      {
        title: 'Initial Budget Planning',
        description: 'Set up project budget and financial tracking',
        priority: 'medium',
        status: 'pending'
      }
    ]
    
    sample_tasks.each do |task_attrs|
      project.tasks.create!(
        task_attrs.merge(
          assigned_user: current_user,
          due_date: 1.week.from_now
        )
      )
    end
  end
  
  def openproject_configured?
    Rails.application.credentials.openproject&.base_url.present? ||
      ENV['OPENPROJECT_BASE_URL'].present?
  end
  
  def maybe_configured?
    Rails.application.credentials.maybe&.base_url.present? ||
      ENV['MAYBE_BASE_URL'].present?
  end
  
  def nextcloud_configured?
    Rails.application.credentials.nextcloud&.base_url.present? ||
      ENV['NEXTCLOUD_BASE_URL'].present?
  end
  
  def mapbox_configured?
    Rails.application.credentials.mapbox_access_token.present? ||
      ENV['MAPBOX_ACCESS_TOKEN'].present?
  end
end
