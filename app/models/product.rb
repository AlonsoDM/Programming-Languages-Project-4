class Product < ApplicationRecord
  belongs_to :tax_rate
  has_many :stock_movements, dependent: :destroy
  has_many :invoice_items, dependent: :restrict_with_error

  validates :name, presence: true
  validates :sku, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :minimum_stock, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :low_stock, -> { where('stock_quantity <= minimum_stock') }
  scope :ordered, -> { order(:name) }

  # Check if product has low stock
  def low_stock?
    stock_quantity <= minimum_stock
  end

  # Update stock quantity
  def update_stock!(quantity, movement_type, notes = nil)
    transaction do
      case movement_type.to_s
      when 'in'
        increment!(:stock_quantity, quantity)
      when 'out'
        if stock_quantity < quantity
          raise StandardError, "Insufficient stock. Available: #{stock_quantity}"
        end
        decrement!(:stock_quantity, quantity)
      else
        raise ArgumentError, "Invalid movement type: #{movement_type}"
      end

      stock_movements.create!(
        movement_type: movement_type,
        quantity: quantity,
        notes: notes,
        movement_date: Time.current
      )
    end
  end

  def stock_history
    stock_movements.order(movement_date: :desc)
  end
end
