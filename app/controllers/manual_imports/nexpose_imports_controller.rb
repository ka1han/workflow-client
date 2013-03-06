class ManualImports::NexposeImportsController < ApplicationController
  respond_to :html

  def index

  end

  def upload
    uploaded_io = params[:nexpose_report]
    file_name = uploaded_io.original_filename
    File.open(Rails.root.join('public', 'uploads', file_name), 'w') do |file|
      file.write(uploaded_io.read)
    end
  end
end