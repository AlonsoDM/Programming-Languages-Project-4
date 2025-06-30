class DashboardController < ApplicationController
  def index
    @low_stock_products = Product.active.low_stock.limit(10)
    @recent_invoices = Invoice.recent.limit(10)
    @total_clients = Client.active.count
    @total_products = Product.active.count
    @pending_invoices = Invoice.by_status('sent').count
  end
end
