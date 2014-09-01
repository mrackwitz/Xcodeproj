require 'active_support/inflector'
require 'xcodeproj/helper'

module Xcodeproj

  # Represents a parameter set to describe a certain target
  # configuration, which has preset build settings
  #
  class TargetConfiguration

    extend Xcodeproj::Helper::EnumAccessor

    # @return [Symbol]
    #         the platform, can be `:ios` or `:osx`.
    enum_accessor :platform, [:ios, :osx]

    # @return [String]
    #         the deployment target for the platform.
    attr_accessor :deployment_target

    # @return [Symbol]
    #         the product type
    enum_accessor :product_type, Constants::PRODUCT_TYPE_UTI.keys

    # @return [Symbol]
    #         the language
    enum_accessor :language, [:objc, :swift]

    # @return [Symbol]
    #         the type of the build configuration, can be `:release` or
    #         `:debug`.
    enum_accessor :type, [:debug, :release]

    # Init a new instance
    #
    # @params [Hash{Symbol => Symbol|String}] params
    #         key-value pairs for the attributes
    #
    def initialize(params)
      params.each do |key,value|
        raise "[Xcodeproj] Invalid option `#{key}` passed to #{self.class} initializer" unless respond_to?(key)
        send "#{key}=", value
      end
    end

    # Return the name of the platform
    #
    # @return [String]
    #
    def platform_name
      case platform
        when :ios then 'iOS'
        when :osx then 'OSX'
      end
    end

    # Return the name of the config directory, where serialized build settings
    # for all type of build configurations can be found.
    #
    # @return [String]
    #
    def config_dir_name
      [
        product_type != :bundle ? language.to_s.camelize : nil,
        product_type != :bundle ? platform_name : 'OSX',
        product_type == :application ? 'Native' : product_type.to_s.camelize
      ].map(&:to_s).reject(&:empty?).join('_')
    end

    # Return the path of the config file
    #
    # @return [Pathname]
    #
    def config_file_path
      Pathname("#{config_dir_name}/#{config_dir_name}_#{type}.xcconfig")
    end

    # Return the path of the corresponding base config file
    #
    # @return [Pathname]
    #
    def base_config_file_path
      Pathname("#{config_dir_name}/#{config_dir_name}_base.xcconfig")
    end

    # Deserialize the config file
    #
    # @param  [String|Xcodeproj::Application] version
    #         see #config_dir_for_version
    #
    # @return [Hash]
    #
    def settings(version=nil)
      # Deserialize dumped config
      dir = config_dir_for_version(version)
      config = Config.new(dir + config_file_path)
      config.merge_with_includes!
      settings = config.to_hash

      # Get rid of settings, which should been excluded
      settings.reject! { |k,_| Constants::EXCLUDE_BUILD_SETTINGS_KEYS.include?(k) }

      # Overwrite the deployment target if present
      if deployment_target
        settings[deployment_target_setting_key] = deployment_target
      end

      settings
    end

    # Return the build setting to configure the deployment target
    #
    # @return [String]
    #
    def deployment_target_setting_key
      case platform
        when :ios then 'IPHONEOS_DEPLOYMENT_TARGET'
        when :osx then 'MACOSX_DEPLOYMENT_TARGET'
      end
    end

    # Get config directory for Xcode version
    #
    # @raise  [StandardError]
    #         if the given version is ambiguous
    #
    # @raise  [StandardError]
    #         if the given version is unknown
    #
    # @param  [String|Xcodeproj::Application] version
    #         either the Xcode short version or the product build version,
    #         by default the current selected Xcode version will be used.
    #         See {Xcodeproj::Application.current}
    #
    # @return [Pathname]
    #
    def config_dir_for_version(version)
      version ||= Xcodeproj::Application.current
      if version.is_a? Xcodeproj::Application
        app = version
        version = app.product_build_version
        dir = "data/#{app.config_identifier}"
      else
        dirs = Dir["data/*#{version}*"]
        raise "Ambiguous version specified. Please use product build version to select one of:\n#{dirs.join(', ')}" if dirs.count > 1
        dir = dirs.first
      end
      raise "No config found for version '#{version}'." unless File.directory?(dir)
      Pathname("#{dir}/configs")
    end

  end

end
