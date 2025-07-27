class Budget < ApplicationRecord
  belongs_to :project
  has_many :transactions, dependent: :destroy

  validates :name, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true
  validates :period_start, presence: true
  validates :period_end, presence: true

  validate :period_end_after_start

  CATEGORIES = [
    'materials',
    'labor',
    'equipment',
    'services',
    'travel',
    'marketing',
    'other'
  ].freeze

  scope :active, -> { where('period_end >= ?', Date.current) }
  scope :by_category, ->(category) { where(category: category) }

  def spent_amount
    transactions.where(transaction_type: 'expense').sum(:amount)
  end

  def remaining_amount
    amount - spent_amount
  end

  def percentage_used
    return 0 if amount.zero?
    (spent_amount / amount * 100).round(2)
  end

  def over_budget?
    spent_amount > amount
  end

  def status
    if over_budget?
      'over_budget'
    elsif percentage_used >= 90
      'warning'
    elsif percentage_used >= 75
      'caution'
    else
      'good'
    end
  end

  def status_color
    case status
    when 'over_budget'
      'red'
    when 'warning'
      'orange'
    when 'caution'
      'yellow'
    else
      'green'
    end
  end

  def active?
    Date.current.between?(period_start, period_end)
  end

  def days_remaining
    return 0 if period_end < Date.current
    (period_end - Date.current).to_i
  end

  private

  def period_end_after_start
    return unless period_start && period_end
    
    errors.add(:period_end, "must be after start date") if period_end <= period_start
  end
end
