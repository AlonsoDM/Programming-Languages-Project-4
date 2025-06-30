class Client < ApplicationRecord
  has_many :invoices, dependent: :restrict_with_error

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  def display_name
    email.present? ? "#{name} (#{email})" : name
  end
end
