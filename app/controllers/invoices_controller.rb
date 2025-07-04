class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :send_invoice, :mark_as_paid, :pdf]

  def index
    @invoices = Invoice.includes(:client).recent.page(params[:page]).per(20)
    @invoices = @invoices.by_status(params[:status]) if params[:status].present?
  end

  def show
    @invoice_items = @invoice.invoice_items.includes(:product)
  end

  def new
    @invoice = Invoice.new(invoice_date: Date.current)
    @invoice.invoice_items.build  # Build at least one invoice item
    @clients = Client.active.ordered
    @products = Product.active.ordered
  end

  def create
    @invoice = Invoice.new(invoice_params)
    @clients = Client.active.ordered
    @products = Product.active.ordered

    # Populate unit_price and tax_rate from products before validation
    populate_item_attributes

    if @invoice.save
      @invoice.calculate_totals!
      set_flash_message(:notice, 'Invoice was successfully created.')
      redirect_to @invoice
    else
      # Ensure we have at least one invoice item for the form if validation fails
      @invoice.invoice_items.build if @invoice.invoice_items.empty?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    return redirect_to(@invoice) unless @invoice.can_be_edited?

    # Ensure we have at least one invoice item for the form
    @invoice.invoice_items.build if @invoice.invoice_items.empty?

    @clients = Client.active.ordered
    @products = Product.active.ordered
  end

  def update
    return redirect_to(@invoice) unless @invoice.can_be_edited?

    @clients = Client.active.ordered
    @products = Product.active.ordered

    # Populate unit_price and tax_rate from products before validation
    populate_item_attributes

    if @invoice.update(invoice_params)
      @invoice.calculate_totals!
      set_flash_message(:notice, 'Invoice was successfully updated.')
      redirect_to @invoice
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @invoice.draft?
      @invoice.destroy
      set_flash_message(:notice, 'Invoice was successfully deleted.')
    else
      set_flash_message(:alert, 'Cannot delete non-draft invoice.')
    end
    redirect_to invoices_url
  end

  def send_invoice
    if @invoice.mark_as_sent!
      set_flash_message(:notice, 'Invoice was successfully sent.')
    else
      set_flash_message(:alert, @invoice.errors.full_messages.join(', '))
    end
    redirect_to @invoice
  end

  # Mark sent invoices as paid
  def mark_as_paid
    if @invoice.sent? && @invoice.update(status: 'paid')
      set_flash_message(:notice, 'Invoice was successfully marked as paid.')
    else
      if @invoice.paid?
        set_flash_message(:alert, 'Invoice is already marked as paid.')
      elsif !@invoice.sent?
        set_flash_message(:alert, 'Only sent invoices can be marked as paid.')
      else
        set_flash_message(:alert, 'Unable to mark invoice as paid.')
      end
    end
    redirect_to @invoice
  end

  def pdf
    pdf_service = InvoicePdfService.new(@invoice)
    pdf_content = pdf_service.generate

    send_data pdf_content,
              filename: "invoice_#{@invoice.invoice_number}.pdf",
              type: 'application/pdf',
              disposition: 'attachment'
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(
      :client_id, :invoice_date, :due_date, :notes,
      invoice_items_attributes: [
        :id, :product_id, :quantity, :unit_price, :tax_rate, :_destroy
      ]
    )
  end

  # Automatically set unit_price and tax_rate based on selected products
  def populate_item_attributes
    return unless params[:invoice] && params[:invoice][:invoice_items_attributes]

    params[:invoice][:invoice_items_attributes].each do |_index, item_attrs|
      next if item_attrs[:product_id].blank? || item_attrs[:_destroy] == '1'

      product = Product.find_by(id: item_attrs[:product_id])
      next unless product

      # Set unit_price and tax_rate if they're blank or zero
      if item_attrs[:unit_price].blank? || item_attrs[:unit_price].to_f.zero?
        item_attrs[:unit_price] = product.price.to_s
      end

      if item_attrs[:tax_rate].blank? || item_attrs[:tax_rate].to_f.zero?
        item_attrs[:tax_rate] = product.tax_rate.rate.to_s
      end
    end
  end
end
