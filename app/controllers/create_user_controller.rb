class CreateUserController < ApplicationController
  def index
    @user = User.new
  end

end
