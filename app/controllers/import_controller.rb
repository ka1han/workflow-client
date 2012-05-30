class ImportController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.xml { render :xml => '' }
    end
  end
end
