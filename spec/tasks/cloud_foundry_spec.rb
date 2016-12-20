require 'spec_helper'
require 'rake'

describe 'config:cf' do
  include_context 'rake'



  it 'creates the merge manifest file for cf' do


    orig_rails_root = Rails.root

    begin
      Rails.application.config.root = Dir.mktmpdir

      Rake::Task['config:cf'].invoke('app_name')

      expect(File.exist?('icescream.yml'))

    ensure
      Rails.application.config.root = orig_rails_root
    end
  end
end
