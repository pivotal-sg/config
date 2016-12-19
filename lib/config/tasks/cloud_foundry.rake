require 'config/integrations/cloud_foundry'

namespace 'config' do
  task :'cf', [:app] => :environment do |_, args|
    Config::Integrations::CloudFoundry.new(args[:app]).invoke
  end
end
