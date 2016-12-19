require 'spec_helper'

describe 'config:cf' do
  include_context 'rake'

  it 'creates the merge manifest file for cf' do
    Rake::Task['config:cf'].invoke
  end
end
