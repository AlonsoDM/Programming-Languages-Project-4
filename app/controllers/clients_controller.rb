class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy, :toggle_active]

  def index
    @clients = Client.ordered

    # Filter by status if specified
    case params[:status]
    when 'active'
      @clients = @clients.active
    when 'inactive'
      @clients = @clients.where(active: false)
    else
      # Show all by default, but we could change this to active only if preferred
      @clients = @clients
    end

    @clients = @clients.page(params[:page]).per(20)
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
      set_flash_message(:alert, 'Cannot delete client with existing invoices. Use "Set Inactive" instead.')
      redirect_to @client
    else
      @client.destroy
      set_flash_message(:notice, 'Client was successfully deleted.')
      redirect_to clients_url
    end
  end

  def toggle_active
    new_status = !@client.active?

    if @client.update(active: new_status)
      status_text = new_status ? 'activated' : 'deactivated'
      set_flash_message(:notice, "Client was successfully #{status_text}.")
    else
      set_flash_message(:alert, 'Unable to update client status.')
    end

    redirect_to @client
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :email, :phone, :address, :tax_id)
  end
end
