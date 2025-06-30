class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def set_flash_message(type, message)
    flash[type] = message
  end
end
