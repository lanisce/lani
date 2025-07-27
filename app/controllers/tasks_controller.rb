class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  before_action :authorize_task, only: [:show, :edit, :update, :destroy]

  def index
    @tasks = policy_scope(@project.tasks).includes(:user)
    @tasks = @tasks.page(params[:page])
  end

  def show
  end

  def new
    @task = @project.tasks.build
    authorize @task
  end

  def create
    @task = @project.tasks.build(task_params)
    authorize @task

    if @task.save
      redirect_to [@project, @task], notice: 'Task was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      # Mark as completed if status changed to completed
      @task.update(completed_at: Time.current) if @task.completed? && @task.completed_at.nil?
      
      redirect_to [@project, @task], notice: 'Task was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to project_tasks_url(@project), notice: 'Task was successfully deleted.'
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
    authorize @project, :show?
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def authorize_task
    authorize @task
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :priority, :user_id, 
                                :due_date, :estimated_hours, :actual_hours)
  end
end
