require 'spec_helper'
require_relative '../../../lib/config/integrations/helpers/cf_manifest_merger'

describe Config::CFManifestMerger do

  it 'raises an argument error if you do not specify an app name' do
    expect {
      Config::CFManifestMerger.new(nil, load_manifest('cf_manifest.yml'))
    }.to raise_error(ArgumentError, 'Manifest path & app name must be specified')
  end

  it 'raises an argument error if the application name is not found in the manifest' do
    expect {
      Config::CFManifestMerger.new('undefined', load_manifest('cf_manifest.yml')).add_to_env
    }.to raise_error(ArgumentError, "Application 'undefined' is not specified in your manifest")
  end

  it 'returns the cf manifest template if no settings available' do
    merger = Config::CFManifestMerger.new('app_name', load_manifest('cf_manifest.yml'))
    Config.load_and_set_settings ''

    resulting_hash = merger.add_to_env
    expect(resulting_hash).to eq(load_manifest('cf_manifest.yml'))
  end

  it 'merges the given YAML file with the cf manifest YAML file' do
    merger = Config::CFManifestMerger.new('some-cf-app', load_manifest('cf_manifest.yml'))
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
                                         },
                                         {"name"=>"app_name", "env"=>{"DEFAULT_HOST"=>"host"}}
                                     ]
                                 })
  end

  it 'raises an exception if there is conflicting keys' do
    merger = Config::CFManifestMerger.new('some-cf-app', load_manifest('cf_manifest.yml'))
    Config.load_and_set_settings "#{fixture_path}/cf_conflict.yml"

    expect {
      merger.add_to_env
    }.to raise_error(ArgumentError, 'Conflicting keys: DEFAULT_HOST, DEFAULT_PORT')
  end

  def load_manifest path
    YAML.load(IO.read("#{fixture_path}/#{path}"))
  end
end