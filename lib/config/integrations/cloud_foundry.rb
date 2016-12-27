require 'bundler'
require 'yaml'
require_relative '../../../lib/config/integrations/helpers/cf_manifest_merger'

module Config
  module Integrations
    class CloudFoundry < Struct.new(:app_name, :file_path)

      def invoke
        manifest_path = file_path || 'manifest.yml'
        file_name, _ext = manifest_path.split('.yml')

        manifest_hash = YAML.load(IO.read(File.join(::Rails.root, manifest_path)))

        puts "Generating manifest... (base cf manifest: #{manifest_path})"

        merged_hash = Config::CFManifestMerger.new(app_name, manifest_hash).add_to_env

        target_manifest_path = File.join(::Rails.root, "#{file_name}-#{::Rails.env}.yml")
        IO.write(target_manifest_path, merged_hash.to_yaml)

        puts "File #{target_manifest_path} generated."
      end

    end
  end
end
