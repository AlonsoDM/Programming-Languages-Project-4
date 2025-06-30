class StockMovement < ApplicationRecord
  belongs_to :product

  validates :movement_type, presence: true, inclusion: { in: %w[in out] }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :movement_date, presence: true

  scope :incoming, -> { where(movement_type: 'in') }
  scope :outgoing, -> { where(movement_type: 'out') }
  scope :recent, -> { order(movement_date: :desc) }

  def incoming?
    movement_type == 'in'
  end

  def outgoing?
    movement_type == 'out'
  end

  def movement_type_display
    incoming? ? 'Stock In' : 'Stock Out'
  end
end
