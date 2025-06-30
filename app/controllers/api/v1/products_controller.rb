class Api::V1::ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])
    render json: {
      id: @product.id,
      name: @product.name,
      price: @product.price,
      tax_rate: @product.tax_rate.rate,
      stock_quantity: @product.stock_quantity
    }
  end
end
