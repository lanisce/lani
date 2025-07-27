class Admin::DashboardController < Admin::ApplicationController
  def index
    @stats = {
      users: User.count,
      projects: Project.count,
      tasks: Task.count,
      active_projects: Project.active.count,
      completed_tasks: Task.completed.count,
      overdue_tasks: Task.overdue.count
    }
    
    @recent_users = User.order(created_at: :desc).limit(5)
    @recent_projects = Project.order(created_at: :desc).limit(5)
    @recent_tasks = Task.order(created_at: :desc).limit(5)
    
    @project_status_data = Project.group(:status).count
    @task_status_data = Task.group(:status).count
    @user_role_data = User.group(:role).count
  end
end
