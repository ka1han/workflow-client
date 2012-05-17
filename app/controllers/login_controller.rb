require 'nexpose'

class LoginController < ApplicationController
  def index
    if !params[:user]
      #first page visit
      @auth_consoles = AuthenticationConsole.all
    else
      #user is trying to auth
      auth_console = AuthenticationConsole.find(params[:auth_console][:id])
      user = params[:user][:username]
      pass = params[:user][:password]

      nsc = Nexpose::Connection.new(auth_console.host, user, pass, auth_console.port)

      begin
        #nsc.login will throw an exception if authentication fails
        #we will catch this below and flash an error
        cookies[:authenticated] = nsc.login
        redirect_to '/'
      rescue
        flash[:error] = "Authentication failed"
      end

    end

  end

end
