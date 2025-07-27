class Admin::UsersController < Admin::ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :activate, :deactivate]

  def index
    @users = User.includes(:owned_projects, :project_memberships)
                 .order(:last_name, :first_name)
                 .page(params[:page])
    
    if params[:search].present?
      @users = @users.where(
        "first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?",
        "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%"
      )
    end
    
    if params[:role].present?
      @users = @users.where(role: params[:role])
    end
    
    if params[:status].present?
      @users = @users.where(active: params[:status] == 'active')
    end
  end

  def show
    @owned_projects = @user.owned_projects.order(:name)
    @member_projects = @user.projects.where.not(owner: @user).order(:name)
    @recent_tasks = @user.tasks.order(created_at: :desc).limit(10)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @user.owned_projects.any?
      redirect_to admin_user_path(@user), 
                  alert: 'Cannot delete user who owns projects. Transfer ownership first.'
    else
      @user.destroy
      redirect_to admin_users_path, notice: 'User was successfully deleted.'
    end
  end

  def activate
    @user.update(active: true)
    redirect_to admin_user_path(@user), notice: 'User has been activated.'
  end

  def deactivate
    @user.update(active: false)
    redirect_to admin_user_path(@user), notice: 'User has been deactivated.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :role, :active, :onboarding_completed)
  end
end
