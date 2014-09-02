module Xcodeproj
  class Command
    class ConfigDump < Command
      def self.banner
%{Dumps the build settings of all project targets for all configurations in
directories named by the target in givene output directory.

    $ config-dump PROJECT OUTPUT

      It extracts common build settings in a per target base.xcconfig file.
      If no `PROJECT` is specified then the current work directory is searched
      for one.
      If no `OUTPUT` is specified then the project directory will be used.%}
      end

      def initialize(argv)
        xcodeproj_path = argv.shift_argument
        @xcodeproj_path = File.expand_path(xcodeproj_path) if xcodeproj_path

        @output_path  = Pathname(argv.shift_argument || '.')
        unless @output_path.directory?
          raise Informative, 'The output path must be a directory.'
        end

        super unless argv.empty?
      end

      def run
        dump_all_configs(xcodeproj, 'Project')

        xcodeproj.targets.each do |target|
          dump_all_configs(target, target.name)
        end
      end

      def dump_all_configs(configurable, name)
        path = Pathname(name)

        # Dump base configuration to file
        base_settings = extract_common_settings!(configurable.build_configurations)
        base_file_name = "#{name}_base.xcconfig"
        base_file_path = path + base_file_name
        dump_config_to_file(base_settings, base_file_path)

        # Dump each configuration to file
        configurable.build_configurations.each do |config|
          settings = config.build_settings
          dump_config_to_file(settings, path + "#{name}_#{config.name.downcase}.xcconfig", [base_file_name])
        end
      end

      def extract_common_settings!(build_configurations)
        # Grasp all common build settings
        all_build_settings = build_configurations.map(&:build_settings)
        common_build_settings = all_build_settings.reduce do |common_build_settings, config_build_settings|
          common_build_settings.select { |key,value| value == config_build_settings[key] }
        end

        # Remove all common build settings from each configuration specific build settings
        build_configurations.each do |config|
          config.build_settings.reject! { |key| !common_build_settings[key].nil? }
        end

        common_build_settings
      end

      def dump_config_to_file(settings, file_path, includes=[])
        dir = @output_path + file_path + '..'
        dir.mkdir unless dir.exist?

        config = Config.new(settings)
        config.includes = includes
        config.save_as(@output_path + file_path)
      end

    end
  end
end
