# Reports controller for advanced analytics and reporting
class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:project_overview, :project_financial, :project_tasks, :project_team]
  before_action :authorize_report_access!
  
  def index
    @user_projects = current_user.projects.includes(:tasks, :budgets, :transactions, :project_memberships)
    @total_projects = @user_projects.count
    @active_projects = @user_projects.where(status: 'active').count
    @total_tasks = Task.joins(:project).where(projects: { id: @user_projects.ids }).count
    @completed_tasks = Task.joins(:project).where(projects: { id: @user_projects.ids }, status: 'completed').count
    
    # Financial overview
    @total_budget = Budget.joins(:project).where(projects: { id: @user_projects.ids }).sum(:amount_cents)
    @total_spent = Transaction.joins(:project).where(projects: { id: @user_projects.ids }, transaction_type: 'expense').sum(:amount_cents)
    @budget_utilization = @total_budget > 0 ? ((@total_spent.to_f / @total_budget) * 100).round(1) : 0
    
    # Recent activity
    @recent_tasks = Task.joins(:project)
                       .where(projects: { id: @user_projects.ids })
                       .order(updated_at: :desc)
                       .limit(5)
                       .includes(:project, :assigned_user)
    
    @recent_transactions = Transaction.joins(:project)
                                    .where(projects: { id: @user_projects.ids })
                                    .order(created_at: :desc)
                                    .limit(5)
                                    .includes(:project)
    
    # Charts data
    @projects_by_status = @user_projects.group(:status).count
    @tasks_by_priority = Task.joins(:project)
                            .where(projects: { id: @user_projects.ids })
                            .group(:priority)
                            .count
    
    @monthly_spending = Transaction.joins(:project)
                                 .where(projects: { id: @user_projects.ids }, transaction_type: 'expense')
                                 .where('created_at >= ?', 6.months.ago)
                                 .group_by_month(:created_at)
                                 .sum(:amount_cents)
  end
  
  def project_overview
    @tasks_stats = {
      total: @project.tasks.count,
      completed: @project.tasks.where(status: 'completed').count,
      in_progress: @project.tasks.where(status: 'in_progress').count,
      pending: @project.tasks.where(status: 'pending').count
    }
    
    @financial_stats = {
      total_budget: @project.budgets.sum(:amount_cents),
      total_spent: @project.transactions.where(transaction_type: 'expense').sum(:amount_cents),
      total_income: @project.transactions.where(transaction_type: 'income').sum(:amount_cents)
    }
    
    @team_stats = {
      total_members: @project.project_memberships.count,
      active_members: @project.project_memberships.joins(:user).where(users: { last_sign_in_at: 1.week.ago.. }).count
    }
    
    # Timeline data
    @task_completion_timeline = @project.tasks
                                       .where(status: 'completed')
                                       .where('completed_at >= ?', 3.months.ago)
                                       .group_by_week(:completed_at)
                                       .count
    
    @spending_timeline = @project.transactions
                                .where(transaction_type: 'expense')
                                .where('created_at >= ?', 3.months.ago)
                                .group_by_week(:created_at)
                                .sum(:amount_cents)
  end
  
  def project_financial
    @budgets = @project.budgets.includes(:transactions)
    @transactions = @project.transactions.order(created_at: :desc).limit(50)
    
    @budget_performance = @budgets.map do |budget|
      spent = budget.transactions.where(transaction_type: 'expense').sum(:amount_cents)
      {
        budget: budget,
        spent: spent,
        remaining: budget.amount_cents - spent,
        utilization: budget.amount_cents > 0 ? ((spent.to_f / budget.amount_cents) * 100).round(1) : 0
      }
    end
    
    @expense_categories = @project.transactions
                                 .where(transaction_type: 'expense')
                                 .group(:category)
                                 .sum(:amount_cents)
    
    @monthly_cash_flow = @project.transactions
                                .where('created_at >= ?', 12.months.ago)
                                .group_by_month(:created_at)
                                .group(:transaction_type)
                                .sum(:amount_cents)
  end
  
  def project_tasks
    @tasks = @project.tasks.includes(:assigned_user)
    
    @task_metrics = {
      completion_rate: @project.tasks.count > 0 ? ((@project.tasks.where(status: 'completed').count.to_f / @project.tasks.count) * 100).round(1) : 0,
      average_completion_time: calculate_average_completion_time,
      overdue_tasks: @project.tasks.where('due_date < ? AND status != ?', Date.current, 'completed').count
    }
    
    @tasks_by_assignee = @project.tasks.joins(:assigned_user)
                                      .group('users.name')
                                      .group(:status)
                                      .count
    
    @tasks_by_priority = @project.tasks.group(:priority).count
    @tasks_by_status = @project.tasks.group(:status).count
    
    @upcoming_deadlines = @project.tasks
                                 .where('due_date BETWEEN ? AND ?', Date.current, 2.weeks.from_now)
                                 .where.not(status: 'completed')
                                 .order(:due_date)
                                 .limit(10)
  end
  
  def project_team
    @memberships = @project.project_memberships.includes(:user)
    
    @team_metrics = {
      total_members: @memberships.count,
      active_members: @memberships.joins(:user).where(users: { last_sign_in_at: 1.week.ago.. }).count,
      role_distribution: @memberships.group(:role).count
    }
    
    @member_activity = @memberships.map do |membership|
      user_tasks = @project.tasks.where(assigned_user: membership.user)
      {
        membership: membership,
        total_tasks: user_tasks.count,
        completed_tasks: user_tasks.where(status: 'completed').count,
        active_tasks: user_tasks.where.not(status: 'completed').count,
        last_activity: [
          user_tasks.maximum(:updated_at),
          membership.user.last_sign_in_at
        ].compact.max
      }
    end
  end
  
  def export_pdf
    @project = current_user.projects.find(params[:project_id]) if params[:project_id]
    
    respond_to do |format|
      format.pdf do
        pdf = generate_project_report_pdf(@project)
        send_data pdf.render,
                  filename: "#{@project&.name || 'dashboard'}_report_#{Date.current}.pdf",
                  type: 'application/pdf',
                  disposition: 'attachment'
      end
    end
  end
  
  private
  
  def set_project
    @project = current_user.projects.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to reports_path, alert: 'Project not found.'
  end
  
  def authorize_report_access!
    case action_name
    when 'index'
      # All authenticated users can view their dashboard
      return
    when 'project_overview', 'project_financial', 'project_tasks', 'project_team', 'export_pdf'
      unless @project && (current_user.admin? || @project.project_memberships.exists?(user: current_user))
        redirect_to reports_path, alert: 'Access denied.'
      end
    end
  end
  
  def calculate_average_completion_time
    completed_tasks = @project.tasks.where(status: 'completed').where.not(completed_at: nil)
    return 0 if completed_tasks.empty?
    
    total_days = completed_tasks.sum do |task|
      (task.completed_at.to_date - task.created_at.to_date).to_i
    end
    
    (total_days.to_f / completed_tasks.count).round(1)
  end
  
  def generate_project_report_pdf(project)
    require 'prawn'
    
    Prawn::Document.new do |pdf|
      # Header
      pdf.text "Project Report: #{project&.name || 'Dashboard Overview'}", size: 24, style: :bold
      pdf.text "Generated on #{Date.current.strftime('%B %d, %Y')}", size: 12
      pdf.move_down 20
      
      if project
        # Project Overview
        pdf.text "Project Overview", size: 18, style: :bold
        pdf.move_down 10
        
        pdf.text "Status: #{project.status.humanize}"
        pdf.text "Created: #{project.created_at.strftime('%B %d, %Y')}"
        pdf.text "Team Members: #{project.project_memberships.count}"
        pdf.text "Total Tasks: #{project.tasks.count}"
        pdf.text "Completed Tasks: #{project.tasks.where(status: 'completed').count}"
        
        pdf.move_down 20
        
        # Financial Summary
        pdf.text "Financial Summary", size: 18, style: :bold
        pdf.move_down 10
        
        total_budget = project.budgets.sum(:amount_cents)
        total_spent = project.transactions.where(transaction_type: 'expense').sum(:amount_cents)
        
        pdf.text "Total Budget: #{Money.new(total_budget, 'usd').format}"
        pdf.text "Total Spent: #{Money.new(total_spent, 'usd').format}"
        pdf.text "Remaining: #{Money.new(total_budget - total_spent, 'usd').format}"
        
        if total_budget > 0
          utilization = ((total_spent.to_f / total_budget) * 100).round(1)
          pdf.text "Budget Utilization: #{utilization}%"
        end
      else
        # Dashboard summary
        pdf.text "Dashboard Summary", size: 18, style: :bold
        pdf.move_down 10
        pdf.text "This would contain overall statistics across all projects."
      end
    end
  end
end
