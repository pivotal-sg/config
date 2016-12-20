require 'config/integrations/cloud_foundry'

namespace 'config' do
  task :'cf', [:app_name, :file_path] => :environment do |_, args|
    Config::Integrations::CloudFoundry.new(args[:app_name], args[:file_path]).invoke
  end
end
