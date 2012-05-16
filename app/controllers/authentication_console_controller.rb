class AuthenticationConsoleController < ApplicationController
  def index
    @auth_consoles = AuthenticationConsole.all

    respond_to do |format|
      format.html
      format.xml { render :xml => @auth_consoles }
    end
  end

  def new
    if !params[:authentication_console]
      auth_consoles = AuthenticationConsole.all

      #if auth consoles are empty, nexflow has been started for the first time
      if auth_consoles.empty?
        flash[:error] = "You need to configure an authentication console before using Nexflow."
      end

      @auth_console = AuthenticationConsole.new

      respond_to do |format|
        format.html
        format.xml { render :xml => @auth_console }
      end
    else

      #try to create the new Auth Console, if not, flash the error
      if console = AuthenticationConsole.create(params[:authentication_console])
        redirect_to '/authentication_console'
      else
        flash[:error] = 'Could not create console'
      end
    end
  end

  def edit
  end

  def delete
  end

end
