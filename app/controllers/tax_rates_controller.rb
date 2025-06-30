class TaxRatesController < ApplicationController
  before_action :set_tax_rate, only: [:show, :edit, :update, :destroy]

  def index
    @tax_rates = TaxRate.ordered
  end

  def show
    @products = @tax_rate.products.active.limit(10)
  end

  def new
    @tax_rate = TaxRate.new
  end

  def create
    @tax_rate = TaxRate.new(tax_rate_params)

    if @tax_rate.save
      set_flash_message(:notice, 'Tax rate was successfully created.')
      redirect_to @tax_rate
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @tax_rate.update(tax_rate_params)
      set_flash_message(:notice, 'Tax rate was successfully updated.')
      redirect_to @tax_rate
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @tax_rate.products.any?
      set_flash_message(:alert, 'Cannot delete tax rate that is being used by products.')
    else
      @tax_rate.update(active: false)
      set_flash_message(:notice, 'Tax rate was successfully deleted.')
    end
    redirect_to tax_rates_url
  end

  private

  def set_tax_rate
    @tax_rate = TaxRate.find(params[:id])
  end

  def tax_rate_params
    params.require(:tax_rate).permit(:name, :rate, :description)
  end
end
