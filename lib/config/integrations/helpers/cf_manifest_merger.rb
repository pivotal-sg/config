require_relative 'helpers'

module Config
  class CFManifestMerger
    include Integrations::Helpers

    def initialize(app_name, manifest_hash)
      @app_name = app_name
      @manifest_hash = manifest_hash
      raise ArgumentError.new("Manifest path & app name must be specified") unless @app_name && @manifest_hash
    end

    def add_to_env

      settings_hash = Kernel.const_get(Config.const_name).to_hash.stringify_keys

      prefix_keys_with_const_name_hash = to_dotted_hash(settings_hash, namespace: Config.const_name)

      app_hash = @manifest_hash['applications'].detect { |hash| hash['name'] == @app_name }

      raise ArgumentError, "Application '#{@app_name}' is not specified in your manifest" if app_hash.nil?

      check_conflicting_keys(app_hash['env'], settings_hash)

      app_hash['env'].merge!(prefix_keys_with_const_name_hash)

      @manifest_hash
    end

    private def check_conflicting_keys(env_hash, settings_hash)
      conflicting_keys = env_hash.keys & settings_hash.keys
      raise ArgumentError.new("Conflicting keys: #{conflicting_keys.join(', ')}") if conflicting_keys.any?
    end

  end
end