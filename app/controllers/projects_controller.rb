class ProjectsController < ApplicationController
  include Pundit::Authorization
  include PerformanceOptimized
  
  before_action :authenticate_user!
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized
  
  # Configure caching for performance
  cache_action :index, expires_in: 15.minutes, vary_by: [:current_user]
  cache_action :show, expires_in: 30.minutes, vary_by: [:project, :current_user]

  def index
    authorize Project
    @projects = policy_scope(Project).includes(:owner, :members, :tasks)
    @projects = @projects.page(params[:page])
  end

  def show
    authorize @project
    @tasks = policy_scope(@project.tasks).includes(:user)
    @recent_tasks = @tasks.limit(5).order(created_at: :desc)
    @project_members = @project.members.includes(:user)
  end

  def new
    @project = Project.new
    authorize @project
  end

  def create
    @project = Project.new(project_params)
    @project.owner = current_user
    authorize @project

    if @project.save
      # Add the owner as a member
      @project.project_memberships.create!(user: current_user)
      
      redirect_to @project, notice: 'Project was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @project
  end

  def update
    authorize @project
    if @project.update(project_params)
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @project
    @project.destroy
    redirect_to projects_url, notice: 'Project was successfully deleted.'
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def authorize_project
    authorize @project
  end

  def project_params
    params.require(:project).permit(:name, :description, :status, :start_date, :end_date, 
                                   :budget_limit, :latitude, :longitude, :location_name)
  end
end
