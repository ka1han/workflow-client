class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :verify_authentication_console
  before_filter :require_authentication

  def verify_authentication_console
    if ((controller_name + "/" + action_name) != 'authentication_console/new' )
      auth_consoles = AuthenticationConsole.all

      @requires_authentication = true
      @requires_authentication = false if auth_consoles.empty?

      redirect_to '/authentication_console/new' if auth_consoles.empty?
    end
  end

  def require_authentication
    if @requires_authentication and !cookies[:authenticated] and (controller_name != 'login')
      redirect_to '/login'
    end
  end
end
