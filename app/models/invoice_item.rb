class InvoiceItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :tax_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_save :calculate_totals

  def line_total_before_tax
    (quantity || 0) * (unit_price || 0)
  end

  def calculate_tax_amount
    line_total_before_tax * ((tax_rate || 0) / 100.0)
  end

  def line_total_with_tax
    line_total_before_tax + calculate_tax_amount
  end

  private

  def calculate_totals
    self.line_total = line_total_before_tax
    self.tax_amount = calculate_tax_amount
  end
end
