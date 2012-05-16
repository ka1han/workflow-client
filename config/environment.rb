# Load the rails application
require File.expand_path('../application', __FILE__)

#create the development log file if need be
if !::File.exists?("#{::Rails.root.to_s}/log/development.log")
  ::File.open("#{::Rails.root.to_s}/log/development.log", "w") do |f|
    f.write("")
  end
end
# Initialize the rails application
WorkFlowEngineOnRails::Application.initialize!


