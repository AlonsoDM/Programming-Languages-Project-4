class Invoice < ApplicationRecord
  belongs_to :client
  has_many :invoice_items, dependent: :destroy
  has_many :products, through: :invoice_items

  # Add this line to accept nested attributes
  accepts_nested_attributes_for :invoice_items, allow_destroy: true,
                               reject_if: proc { |attributes| attributes['product_id'].blank? }

  validates :invoice_number, presence: true, uniqueness: true
  validates :invoice_date, presence: true
  validates :status, inclusion: { in: %w[draft sent paid cancelled] }

  scope :recent, -> { order(invoice_date: :desc) }
  scope :by_status, ->(status) { where(status: status) }

  before_validation :generate_invoice_number, on: :create
  after_update :update_product_stock, if: :saved_change_to_status?

  # Calculate totals based on invoice items
  def calculate_totals!
    self.subtotal = invoice_items.reject(&:marked_for_destruction?).sum(&:line_total_before_tax)
    self.tax_amount = invoice_items.reject(&:marked_for_destruction?).sum(&:calculate_tax_amount)
    self.total = subtotal + tax_amount
    save!
  end

  def status_display
    status.humanize
  end

  def can_be_edited?
    draft?
  end

  def draft?
    status == 'draft'
  end

  def sent?
    status == 'sent'
  end

  def paid?
    status == 'paid'
  end

  def cancelled?
    status == 'cancelled'
  end

  # Mark invoice as sent and update stock
  def mark_as_sent!
    return false unless draft?

    transaction do
      invoice_items.each do |item|
        item.product.update_stock!(
          item.quantity,
          'out',
          "Invoice ##{invoice_number}"
        )
      end
      update!(status: 'sent')
    end
    true
  rescue StandardError => e
    errors.add(:base, e.message)
    false
  end

  private

  def generate_invoice_number
    return if invoice_number.present?

    last_invoice = Invoice.order(:invoice_number).last
    if last_invoice&.invoice_number&.match(/\A(\d+)\z/)
      self.invoice_number = (last_invoice.invoice_number.to_i + 1).to_s.rjust(6, '0')
    else
      self.invoice_number = '000001'
    end
  end

  def update_product_stock
    return unless sent? && status_previously_was == 'draft'
    # Stock update is handled in mark_as_sent! method
  end
end
