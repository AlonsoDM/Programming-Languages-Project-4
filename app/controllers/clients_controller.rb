class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  def index
    @clients = Client.active.ordered.page(params[:page]).per(20)
  end

  def show
    @invoices = @client.invoices.recent.limit(10)
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      set_flash_message(:notice, 'Client was successfully created.')
      redirect_to @client
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @client.update(client_params)
      set_flash_message(:notice, 'Client was successfully updated.')
      redirect_to @client
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @client.invoices.any?
      set_flash_message(:alert, 'Cannot delete client with existing invoices.')
    else
      @client.update(active: false)
      set_flash_message(:notice, 'Client was successfully deleted.')
    end
    redirect_to clients_url
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :email, :phone, :address, :tax_id)
  end
end
