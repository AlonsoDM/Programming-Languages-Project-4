class TaxRate < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :rate, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  def display_name
    "#{name} (#{rate}%)"
  end

  def rate_decimal
    rate / 100.0
  end
end
