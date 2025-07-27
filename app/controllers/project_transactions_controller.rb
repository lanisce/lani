class ProjectTransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]

  def index
    authorize @project, :show?
    @transactions = @project.transactions.includes(:user, :budget).recent
    @transactions = @transactions.where(transaction_type: params[:type]) if params[:type].present?
    @transactions = @transactions.joins(:budget).where(budgets: { category: params[:category] }) if params[:category].present?
    @transactions = @transactions.page(params[:page]).per(20)
    
    @total_income = @project.transactions.income.sum(:amount)
    @total_expenses = @project.transactions.expenses.sum(:amount)
    @net_amount = @total_income - @total_expenses
    
    @budgets = @project.budgets.active.order(:name)
    @categories = Budget::CATEGORIES
  end

  def show
    authorize @transaction
  end

  def new
    authorize @project, :show?
    @transaction = @project.transactions.build
    @transaction.user = current_user
    @transaction.transaction_type = params[:type] || 'expense'
    @budgets = @project.budgets.active.order(:name)
  end

  def create
    authorize @project, :show?
    @transaction = @project.transactions.build(transaction_params)
    @transaction.user = current_user

    if @transaction.save
      redirect_to project_transactions_path(@project), notice: 'Transaction was successfully created.'
    else
      @budgets = @project.budgets.active.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @transaction
    @budgets = @project.budgets.active.order(:name)
  end

  def update
    authorize @transaction

    if @transaction.update(transaction_params)
      redirect_to project_transaction_path(@project, @transaction), notice: 'Transaction was successfully updated.'
    else
      @budgets = @project.budgets.active.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @transaction
    @transaction.destroy
    redirect_to project_transactions_path(@project), notice: 'Transaction was successfully deleted.'
  end

  def summary
    authorize @project, :show?
    
    # Date range for analysis
    @start_date = params[:start_date]&.to_date || 3.months.ago.to_date
    @end_date = params[:end_date]&.to_date || Date.current
    
    # Summary statistics
    transactions = @project.transactions.by_date_range(@start_date, @end_date)
    @summary = {
      total_income: transactions.income.sum(:amount),
      total_expenses: transactions.expenses.sum(:amount),
      transaction_count: transactions.count,
      average_transaction: transactions.average(:amount) || 0
    }
    @summary[:net_amount] = @summary[:total_income] - @summary[:total_expenses]
    
    # Spending by category
    @category_spending = @project.budgets.joins(:transactions)
                                .where(transactions: { transaction_date: @start_date..@end_date, transaction_type: 'expense' })
                                .group(:category)
                                .sum('transactions.amount')
    
    # Monthly trends
    @monthly_trends = transactions.group_by { |t| t.transaction_date.beginning_of_month }
                                 .transform_values do |month_transactions|
                                   {
                                     income: month_transactions.select(&:income?).sum(&:amount),
                                     expenses: month_transactions.select(&:expense?).sum(&:amount)
                                   }
                                 end
                                 .sort_by { |month, _| month }
    
    # Budget performance
    @budget_performance = @project.budgets.includes(:transactions)
                                 .where('period_start <= ? AND period_end >= ?', @end_date, @start_date)
                                 .map do |budget|
                                   {
                                     budget: budget,
                                     spent: budget.spent_amount,
                                     remaining: budget.remaining_amount,
                                     percentage: budget.percentage_used
                                   }
                                 end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_transaction
    @transaction = @project.transactions.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(:description, :amount, :transaction_type, :transaction_date, :notes, :budget_id, :receipt_url)
  end
end
