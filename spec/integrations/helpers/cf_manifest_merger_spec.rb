require 'spec_helper'
require_relative '../../../lib/config/integrations/helpers/cf_manifest_merger'

describe Config::CFManifestMerger do

  it 'returns the cf manifest template if no settings available' do
    merger = Config::CFManifestMerger.new("#{fixture_path}/cf_manifest.yml")
    Config.load_and_set_settings ''

    resulting_hash = merger.add_to_env
    expect(resulting_hash).to eq(YAML.load(IO.read("#{fixture_path}/cf_manifest.yml")))
  end

  it 'returns a cf manifest file with only the env variable if it does not exist' do
    merger = Config::CFManifestMerger.new("null.yml")
    Config.load_and_set_settings "#{fixture_path}/cf_multilevel.yml"

    expect {
      merger.add_to_env
    }.to raise_error(StandardError, "Cloud Foundry manifest file `cf_manifest.yml` not found")

  end

  it 'merges the given YAML file with the cf manifest YAML file' do
    merger = Config::CFManifestMerger.new("#{fixture_path}/cf_manifest.yml")
    Config.load_and_set_settings "#{fixture_path}/cf_multilevel.yml"

    resulting_hash = merger.add_to_env
    expect(resulting_hash).to eq({
                                     "applications" => [
                                         {
                                             "name" => "some-cf-app",
                                             "instances" => 1,
                                             "env" => {
                                                 "DEFAULT_HOST" => "host",
                                                 "DEFAULT_PORT" => "port",
                                                 "FOO" => "BAR",
                                                 "Settings.world.capitals.europe.germany" => "Berlin",
                                                 "Settings.world.capitals.europe.poland" => "Warsaw",
                                                 "Settings.world.array.0.name" => "Alan",
                                                 "Settings.world.array.1.name" => "Gam",
                                                 "Settings.world.array_with_index.0.name" => "Bob",
                                                 "Settings.world.array_with_index.1.name" => "William"
                                             }
                                         }
                                     ]
                                 })
  end

  it 'raises an exception if there is conflicting keys' do

    merger = Config::CFManifestMerger.new("#{fixture_path}/cf_manifest.yml")
    Config.load_and_set_settings "#{fixture_path}/cf_conflict.yml"

    expect {
      merger.add_to_env
    }.to raise_error(ArgumentError, 'Conflicting keys: DEFAULT_HOST, DEFAULT_PORT')
  end
end