class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :send_invoice, :pdf]

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
end
