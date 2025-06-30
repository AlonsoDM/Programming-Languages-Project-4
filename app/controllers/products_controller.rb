class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :stock_movement]

  def index
    @products = Product.active.includes(:tax_rate)
                      .page(params[:page])
                      .per(20)
    @low_stock_products = Product.active.low_stock
  end

  def show
    @stock_movements = @product.stock_history.limit(20)
  end

  def new
    @product = Product.new
    @tax_rates = TaxRate.active.ordered
  end

  def create
    @product = Product.new(product_params)
    @tax_rates = TaxRate.active.ordered

    if @product.save
      set_flash_message(:notice, 'Product was successfully created.')
      redirect_to @product
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @tax_rates = TaxRate.active.ordered
  end

  def update
    @tax_rates = TaxRate.active.ordered

    if @product.update(product_params)
      set_flash_message(:notice, 'Product was successfully updated.')
      redirect_to @product
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @product.invoice_items.any?
      set_flash_message(:alert, 'Cannot delete product that has been invoiced.')
    else
      @product.update(active: false)
      set_flash_message(:notice, 'Product was successfully deleted.')
    end
    redirect_to products_url
  end

  def stock_movement
    movement_type = params[:movement_type]
    quantity = params[:quantity].to_i
    notes = params[:notes]

    begin
      @product.update_stock!(quantity, movement_type, notes)
      set_flash_message(:notice, 'Stock updated successfully.')
    rescue StandardError => e
      set_flash_message(:alert, e.message)
    end

    redirect_to @product
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :sku, :description, :price,
                                   :stock_quantity, :minimum_stock, :tax_rate_id)
  end
end
