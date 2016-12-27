require 'spec_helper'

describe 'config:cf' do
  include_context 'rake'

  before :all do
    load File.expand_path("../../../lib/config/tasks/cloud_foundry.rake", __FILE__)
    Rake::Task.define_task(:environment)
  end

  before { allow($stdout).to receive(:puts) } # suppressing console output during testing

  after :all do
    Settings.reload_from_files("#{fixture_path}/settings.yml")
  end

  it 'creates the merge manifest file for cf' do
    Config.load_and_set_settings "#{fixture_path}/cf/cf_multilevel.yml"

    orig_rails_root = Rails.root

    begin
      Rails.application.config.root = Dir.mktmpdir

      FileUtils.cp("#{fixture_path}/cf/cf_manifest.yml", File.join(Rails.root, 'manifest.yml'))

      Rake::Task['config:cf'].execute({:app_name => 'app_name'})

      target_file_path = File.join(Rails.root, 'manifest-test.yml')
      target_file_contents = YAML.load(IO.read(target_file_path))

      expect(target_file_contents["applications"][1]["name"]).to eq "app_name"
      expect(target_file_contents["applications"][1]["env"]["DEFAULT_HOST"]).to eq "host"
      expect(target_file_contents["applications"][1]["env"]["Settings.world.array.0.name"]).to eq "Alan"
    ensure
      Rails.application.config.root = orig_rails_root
    end
  end

  it 'handles a custom manifest name' do

    orig_rails_root = Rails.root

    begin
      Rails.application.config.root = Dir.mktmpdir

      FileUtils.cp("#{fixture_path}/cf/cf_manifest.yml", File.join(Rails.root, 'cf_manifest.yml'))

      Rake::Task['config:cf'].execute({app_name: 'app_name', file_path: 'cf_manifest.yml'})

      target_file_path = File.join(Rails.root, 'cf_manifest-test.yml')

      expect(File.size? target_file_path).to be

    ensure
      Rails.application.config.root = orig_rails_root
    end
  end

  it 'raises an error if the specified file is missing' do
    expect {
      Rake::Task['config:cf'].execute({app_name: 'app_name', file_path: 'null.yml'})
    }.to raise_error(SystemCallError)
  end
end