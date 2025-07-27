# API Synchronization Controller
# Handles syncing data with external APIs (OpenProject, Maybe, etc.)
class ApiSyncController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin_or_project_manager
  
  # Sync project data with OpenProject API
  def sync_openproject
    project = Project.find(params[:project_id]) if params[:project_id]
    authorize project if project
    
    begin
      api_service = ExternalApiService.new
      openproject_data = api_service.openproject.projects
      
      synced_count = 0
      openproject_data.each do |op_project|
        # Create or update local project based on OpenProject data
        local_project = Project.find_or_initialize_by(external_id: op_project['id'])
        local_project.assign_attributes(
          name: op_project['name'],
          description: op_project['description'] || '',
          external_source: 'openproject'
        )
        
        if local_project.new_record?
          local_project.user = current_user
        end
        
        if local_project.save
          synced_count += 1
          
          # Sync work packages as tasks
          work_packages = api_service.openproject.work_packages(op_project['id'])
          work_packages.each do |wp|
            task = local_project.tasks.find_or_initialize_by(external_id: wp['id'])
            task.assign_attributes(
              title: wp['subject'],
              description: wp.dig('description', 'raw') || '',
              status: map_openproject_status(wp.dig('status', 'name')),
              priority: map_openproject_priority(wp.dig('priority', 'name')),
              due_date: wp['dueDate'] ? Date.parse(wp['dueDate']) : nil,
              external_source: 'openproject'
            )
            
            if task.new_record?
              task.user = current_user
            end
            
            task.save
          end
        end
      end
      
      flash[:notice] = "Successfully synced #{synced_count} projects from OpenProject"
      Rails.logger.info "OpenProject sync completed: #{synced_count} projects synced"
      
    rescue => e
      flash[:alert] = "Failed to sync with OpenProject: #{e.message}"
      Rails.logger.error "OpenProject sync failed: #{e.class} - #{e.message}"
    end
    
    redirect_back(fallback_location: project ? project_path(project) : projects_path)
  end
  
  # Sync budget and transaction data with Maybe API
  def sync_maybe
    project = Project.find(params[:project_id]) if params[:project_id]
    authorize project if project
    
    begin
      api_service = ExternalApiService.new
      maybe_budgets = api_service.maybe.budgets
      maybe_transactions = api_service.maybe.transactions
      
      synced_budgets = 0
      synced_transactions = 0
      
      # Sync budgets
      maybe_budgets.each do |mb_budget|
        target_project = project || Project.first # Use specified project or default
        next unless target_project
        
        budget = target_project.budgets.find_or_initialize_by(external_id: mb_budget['id'])
        budget.assign_attributes(
          name: mb_budget['name'],
          amount: mb_budget['amount'] || 0,
          category: map_maybe_category(mb_budget['category']),
          description: mb_budget['description'] || '',
          period_start: mb_budget['period_start'] ? Date.parse(mb_budget['period_start']) : Date.current.beginning_of_month,
          period_end: mb_budget['period_end'] ? Date.parse(mb_budget['period_end']) : Date.current.end_of_month,
          external_source: 'maybe'
        )
        
        if budget.save
          synced_budgets += 1
        end
      end
      
      # Sync transactions
      maybe_transactions.each do |mb_transaction|
        target_project = project || Project.first
        next unless target_project
        
        transaction = target_project.transactions.find_or_initialize_by(external_id: mb_transaction['id'])
        transaction.assign_attributes(
          description: mb_transaction['description'],
          amount: mb_transaction['amount'] || 0,
          transaction_type: mb_transaction['transaction_type'] || 'expense',
          category: map_maybe_category(mb_transaction['category']),
          transaction_date: mb_transaction['transaction_date'] ? Date.parse(mb_transaction['transaction_date']) : Date.current,
          notes: mb_transaction['notes'] || '',
          external_source: 'maybe',
          user: current_user
        )
        
        if transaction.save
          synced_transactions += 1
        end
      end
      
      flash[:notice] = "Successfully synced #{synced_budgets} budgets and #{synced_transactions} transactions from Maybe"
      Rails.logger.info "Maybe sync completed: #{synced_budgets} budgets, #{synced_transactions} transactions synced"
      
    rescue => e
      flash[:alert] = "Failed to sync with Maybe: #{e.message}"
      Rails.logger.error "Maybe sync failed: #{e.class} - #{e.message}"
    end
    
    redirect_back(fallback_location: project ? project_budgets_path(project) : projects_path)
  end
  
  # Export local data to external APIs
  def export_to_openproject
    project = Project.find(params[:project_id])
    authorize project
    
    begin
      api_service = ExternalApiService.new
      
      # Export tasks as work packages
      exported_count = 0
      project.tasks.where(external_source: [nil, 'local']).each do |task|
        result = api_service.openproject.create_work_package(
          project.external_id || 1, # Use external project ID or default
          {
            title: task.title,
            description: task.description
          }
        )
        
        if result
          task.update(external_id: result['id'], external_source: 'openproject')
          exported_count += 1
        end
      end
      
      flash[:notice] = "Successfully exported #{exported_count} tasks to OpenProject"
      Rails.logger.info "OpenProject export completed: #{exported_count} tasks exported"
      
    rescue => e
      flash[:alert] = "Failed to export to OpenProject: #{e.message}"
      Rails.logger.error "OpenProject export failed: #{e.class} - #{e.message}"
    end
    
    redirect_to project_path(project)
  end
  
  # Export budget data to Maybe
  def export_to_maybe
    project = Project.find(params[:project_id])
    authorize project
    
    begin
      api_service = ExternalApiService.new
      
      exported_budgets = 0
      exported_transactions = 0
      
      # Export budgets
      project.budgets.where(external_source: [nil, 'local']).each do |budget|
        result = api_service.maybe.create_budget({
          name: budget.name,
          amount: budget.amount,
          category: budget.category,
          period_start: budget.period_start,
          period_end: budget.period_end
        })
        
        if result
          budget.update(external_id: result['id'], external_source: 'maybe')
          exported_budgets += 1
        end
      end
      
      # Export transactions
      project.transactions.where(external_source: [nil, 'local']).each do |transaction|
        result = api_service.maybe.create_transaction({
          description: transaction.description,
          amount: transaction.amount,
          transaction_type: transaction.transaction_type,
          category: transaction.category,
          transaction_date: transaction.transaction_date
        })
        
        if result
          transaction.update(external_id: result['id'], external_source: 'maybe')
          exported_transactions += 1
        end
      end
      
      flash[:notice] = "Successfully exported #{exported_budgets} budgets and #{exported_transactions} transactions to Maybe"
      Rails.logger.info "Maybe export completed: #{exported_budgets} budgets, #{exported_transactions} transactions exported"
      
    rescue => e
      flash[:alert] = "Failed to export to Maybe: #{e.message}"
      Rails.logger.error "Maybe export failed: #{e.class} - #{e.message}"
    end
    
    redirect_to project_budgets_path(project)
  end
  
  private
  
  def ensure_admin_or_project_manager
    unless current_user.admin? || current_user.project_manager?
      flash[:alert] = "You don't have permission to sync external APIs"
      redirect_to root_path
    end
  end
  
  def map_openproject_status(op_status)
    case op_status&.downcase
    when 'new', 'open' then 'todo'
    when 'in progress', 'in_progress' then 'in_progress'
    when 'closed', 'resolved', 'done' then 'completed'
    else 'todo'
    end
  end
  
  def map_openproject_priority(op_priority)
    case op_priority&.downcase
    when 'high', 'urgent', 'immediate' then 'high'
    when 'normal', 'medium' then 'medium'
    when 'low' then 'low'
    else 'medium'
    end
  end
  
  def map_maybe_category(maybe_category)
    # Map Maybe categories to our budget categories
    case maybe_category&.downcase
    when 'materials', 'supplies' then 'materials'
    when 'labor', 'payroll', 'salary' then 'labor'
    when 'equipment', 'tools' then 'equipment'
    when 'services', 'consulting' then 'services'
    when 'travel', 'transportation' then 'travel'
    when 'marketing', 'advertising' then 'marketing'
    else 'other'
    end
  end
end
