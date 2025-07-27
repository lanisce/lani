class ProjectBudgetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_budget, only: [:show, :edit, :update, :destroy]

  def index
    authorize @project, :show?
    @budgets = @project.budgets.includes(:transactions).order(:period_start)
    @total_budget = @budgets.sum(:amount)
    @total_spent = @project.transactions.expenses.sum(:amount)
    @budget_categories = Budget::CATEGORIES
  end

  def show
    authorize @budget
    @transactions = @budget.transactions.includes(:user).recent.limit(10)
    @monthly_spending = calculate_monthly_spending
  end

  def new
    authorize @project, :edit?
    @budget = @project.budgets.build
    @budget.period_start = Date.current.beginning_of_month
    @budget.period_end = Date.current.end_of_month
  end

  def create
    authorize @project, :edit?
    @budget = @project.budgets.build(budget_params)

    if @budget.save
      redirect_to project_budgets_path(@project), notice: 'Budget was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @budget
  end

  def update
    authorize @budget

    if @budget.update(budget_params)
      redirect_to project_budget_path(@project, @budget), notice: 'Budget was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @budget
    @budget.destroy
    redirect_to project_budgets_path(@project), notice: 'Budget was successfully deleted.'
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_budget
    @budget = @project.budgets.find(params[:id])
  end

  def budget_params
    params.require(:budget).permit(:name, :description, :amount, :category, :period_start, :period_end, :active)
  end

  def calculate_monthly_spending
    return [] unless @budget

    # Get spending data for the last 6 months
    start_date = 6.months.ago.beginning_of_month
    end_date = Date.current.end_of_month

    spending_by_month = @budget.transactions.expenses
                               .where(transaction_date: start_date..end_date)
                               .group_by { |t| t.transaction_date.beginning_of_month }
                               .transform_values { |transactions| transactions.sum(&:amount) }

    # Fill in missing months with 0
    (start_date.to_date..end_date.to_date).select { |d| d.day == 1 }.map do |month|
      {
        month: month.strftime('%b %Y'),
        amount: spending_by_month[month] || 0
      }
    end
  end
end
