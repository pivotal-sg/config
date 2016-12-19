module Config
  class CFManifestMerger
    def initialize(path)
      @path = path
    end

    def add_to_env
      raise StandardError.new("Cloud Foundry manifest file `cf_manifest.yml` not found") unless File.exist?(@path)

      cf_manifest_hash = YAML.load(IO.read(@path))

      settings_hash = Kernel.const_get(Config.const_name).to_hash.stringify_keys

      prefix_keys_with_const_name_hash = to_dotted_hash(settings_hash, {}, Config.const_name)

      env_hash = cf_manifest_hash['applications'].first['env']

      check_conflicting_keys(env_hash, settings_hash)

      env_hash.merge!(prefix_keys_with_const_name_hash)

      cf_manifest_hash
    end

    def to_dotted_hash(source, target = {}, namespace = nil)
      prefix = "#{namespace}." if namespace
      case source
        when Hash
          source.each do |key, value|
            to_dotted_hash(value, target, "#{prefix}#{key}")
          end
        when Array
          source.each_with_index do |value, index|
            to_dotted_hash(value, target, "#{prefix}#{index}")
          end
        else
          target[namespace] = source
      end
      target
    end

    private

    def check_conflicting_keys(env_hash, settings_hash)
      conflicting_keys = env_hash.keys & settings_hash.keys
      raise ArgumentError.new("Conflicting keys: #{conflicting_keys.join(', ')}") if conflicting_keys.any?
    end
  end
end