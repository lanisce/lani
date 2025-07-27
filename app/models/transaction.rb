class Transaction < ApplicationRecord
  belongs_to :project
  belongs_to :budget, optional: true
  belongs_to :user

  validates :description, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_type, presence: true, inclusion: { in: %w[income expense] }
  validates :transaction_date, presence: true

  scope :expenses, -> { where(transaction_type: 'expense') }
  scope :income, -> { where(transaction_type: 'income') }
  scope :recent, -> { order(transaction_date: :desc, created_at: :desc) }
  scope :by_date_range, ->(start_date, end_date) { where(transaction_date: start_date..end_date) }
  scope :by_category, ->(category) { joins(:budget).where(budgets: { category: category }) }

  before_save :set_defaults

  def expense?
    transaction_type == 'expense'
  end

  def income?
    transaction_type == 'income'
  end

  def formatted_amount
    ActionController::Base.helpers.number_to_currency(amount)
  end

  def category
    budget&.category || 'uncategorized'
  end

  def affects_budget?
    budget.present? && expense?
  end

  def over_budget_impact
    return 0 unless affects_budget?
    
    budget_remaining = budget.remaining_amount
    return 0 if budget_remaining >= 0
    
    -budget_remaining
  end

  private

  def set_defaults
    self.transaction_date ||= Date.current
  end
end
